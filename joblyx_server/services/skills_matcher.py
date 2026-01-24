import json
import re
from pathlib import Path

import spacy
from spacy.matcher import PhraseMatcher
from langdetect import detect, LangDetectException


class SkillsMatcher:
    _instance = None

    AMBIGUOUS_SKILLS = {"C", "R", "D", "Go", "Rust", "Ruby", "Swift", "Dart", "Lua", "Slim", "Nest", "Echo", "Fiber", "Chi", "Rocket", "Ktor", "Remix", "Lit", "Bull", "Consul", "Make", "Flux", "Ray", "Salt", "Base", "Near", "Ada"}

    SKILL_CONTEXT_PATTERNS = {
        "C": [r"\bC\s+programming\b", r"\bC\s+language\b", r"\bC/C\+\+\b", r"\bC\s+developer\b", r"\bin\s+C\b", r"\bprogramming\s+in\s+C\b"],
        "R": [r"\bR\s+programming\b", r"\bR\s+language\b", r"\bR\s+studio\b", r"\bR\s+developer\b", r"\bstatistical.*\bR\b"],
        "D": [r"\bD\s+programming\b", r"\bD\s+language\b", r"\bDlang\b"],
        "Go": [r"\bGo\s+programming\b", r"\bGolang\b", r"\bGo\s+language\b", r"\bGo\s+developer\b"],
        "Rust": [r"\bRust\s+programming\b", r"\bRust\s+language\b", r"\bRust\s+developer\b", r"\bRustlang\b"],
        "Ruby": [r"\bRuby\s+on\s+Rails\b", r"\bRuby\s+programming\b", r"\bRuby\s+developer\b"],
        "Swift": [r"\bSwift\s+programming\b", r"\bSwiftUI\b", r"\bSwift\s+developer\b", r"\biOS.*Swift\b"],
        "Base": [r"\bBase\s+chain\b", r"\bBase\s+blockchain\b", r"\bBase\s+network\b"],
        "Make": [r"\bMakefile\b", r"\bGNU\s+Make\b", r"\bIntegr?omat\b"],
        "Salt": [r"\bSaltStack\b", r"\bSalt\s+Stack\b"],
        "Chef": [r"\bChef\s+(?:automation|infra|devops)\b", r"\bOpscode\s+Chef\b"],
        "Flux": [r"\bFlux\s*CD\b", r"\bGitOps.*Flux\b"],
        "Ray": [r"\bRay\.io\b", r"\bRay\s+distributed\b", r"\bRay\s+cluster\b"],
        "Near": [r"\bNEAR\s+Protocol\b", r"\bNEAR\s+blockchain\b"],
        "Ada": [r"\bAda\s+programming\b", r"\bAda\s+language\b"],
        "Slim": [r"\bSlim\s+PHP\b", r"\bSlim\s+framework\b"],
        "Echo": [r"\bEcho\s+framework\b", r"\bEcho\s+Go\b"],
        "Fiber": [r"\bFiber\s+Go\b", r"\bGoFiber\b"],
        "Bull": [r"\bBullMQ\b", r"\bBull\s+queue\b"],
    }

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
            cls._instance._initialized = False
        return cls._instance

    def __init__(self):
        if self._initialized:
            return

        self._initialized = True
        self.skills_data = self._load_skills()
        self.skill_to_category = {}
        self.all_patterns = []

        self._build_skill_mappings()

        self.nlp_en = spacy.load("en_core_web_sm")
        self.nlp_fr = spacy.load("fr_core_news_sm")

        self.matcher_en = self._build_matcher(self.nlp_en)
        self.matcher_fr = self._build_matcher(self.nlp_fr)

    def _load_skills(self) -> dict:
        """Load skills from skills.json file."""
        skills_path = Path(__file__).parent.parent / "data" / "skills.json"
        with open(skills_path, "r", encoding="utf-8") as f:
            return json.load(f)

    def _build_skill_mappings(self):
        """Build mapping from skill names/variants to canonical names and categories."""
        it_skills = self.skills_data.get("IT", {})

        for category, skills in it_skills.items():
            for skill in skills:
                name = skill["name"]
                variants = skill.get("variants", [])

                self.skill_to_category[name.lower()] = {
                    "name": name,
                    "category": category
                }

                if name not in self.AMBIGUOUS_SKILLS:
                    self.all_patterns.append(name.lower())

                for variant in variants:
                    if variant:
                        self.skill_to_category[variant.lower()] = {
                            "name": name,
                            "category": category
                        }
                        self.all_patterns.append(variant.lower())

    def _build_matcher(self, nlp) -> PhraseMatcher:
        """Build PhraseMatcher with all skill patterns."""
        matcher = PhraseMatcher(nlp.vocab, attr="LOWER")

        patterns = []
        for pattern_text in self.all_patterns:
            try:
                doc = nlp.make_doc(pattern_text)
                patterns.append(doc)
            except Exception:
                continue

        if patterns:
            matcher.add("SKILLS", patterns)

        return matcher

    def detect_language(self, text: str) -> str:
        """
        Detect the language of the text.

        Args:
            text: Text to analyze

        Returns:
            Language code ("en" or "fr"), defaults to "en"
        """
        try:
            lang = detect(text[:1000])
            return "fr" if lang == "fr" else "en"
        except LangDetectException:
            return "en"

    def _check_ambiguous_skills(self, text: str) -> set[str]:
        """
        Check for ambiguous skills using context patterns.

        Args:
            text: Text to analyze

        Returns:
            Set of validated ambiguous skill names
        """
        found = set()
        text_upper = text

        for skill, patterns in self.SKILL_CONTEXT_PATTERNS.items():
            for pattern in patterns:
                if re.search(pattern, text_upper, re.IGNORECASE):
                    found.add(skill)
                    break

        return found

    def extract_skills(self, text: str) -> list[str]:
        """
        Extract skills from text using SpaCy PhraseMatcher.
        Automatically detects language.

        Args:
            text: Job description text

        Returns:
            List of unique skill names found in the text
        """
        if not text:
            return []

        lang = self.detect_language(text)

        if lang == "fr":
            nlp = self.nlp_fr
            matcher = self.matcher_fr
        else:
            nlp = self.nlp_en
            matcher = self.matcher_en

        doc = nlp(text)
        matches = matcher(doc)

        found_skills = set()
        for match_id, start, end in matches:
            span = doc[start:end]
            matched_text = span.text.lower()

            if matched_text in self.skill_to_category:
                skill_info = self.skill_to_category[matched_text]
                found_skills.add(skill_info["name"])

        ambiguous_found = self._check_ambiguous_skills(text)
        found_skills.update(ambiguous_found)

        return list(found_skills)

    def extract_skills_with_category(self, text: str) -> list[dict]:
        """
        Extract skills from text with their categories.

        Args:
            text: Job description text

        Returns:
            List of dicts with name and category
        """
        if not text:
            return []

        lang = self.detect_language(text)

        if lang == "fr":
            nlp = self.nlp_fr
            matcher = self.matcher_fr
        else:
            nlp = self.nlp_en
            matcher = self.matcher_en

        doc = nlp(text)
        matches = matcher(doc)

        found_skills = {}
        for match_id, start, end in matches:
            span = doc[start:end]
            matched_text = span.text.lower()

            if matched_text in self.skill_to_category:
                skill_info = self.skill_to_category[matched_text]
                if skill_info["name"] not in found_skills:
                    found_skills[skill_info["name"]] = skill_info["category"]

        ambiguous_found = self._check_ambiguous_skills(text)
        for skill_name in ambiguous_found:
            if skill_name not in found_skills:
                skill_info = self.skill_to_category.get(skill_name.lower())
                if skill_info:
                    found_skills[skill_name] = skill_info["category"]

        return [
            {"name": name, "category": category}
            for name, category in found_skills.items()
        ]


skills_matcher = SkillsMatcher()
