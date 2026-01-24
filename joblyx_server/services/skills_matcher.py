import json
import os
from pathlib import Path

import spacy
from spacy.matcher import PhraseMatcher
from langdetect import detect, LangDetectException


class SkillsMatcher:
    _instance = None

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

        return [
            {"name": name, "category": category}
            for name, category in found_skills.items()
        ]


skills_matcher = SkillsMatcher()
