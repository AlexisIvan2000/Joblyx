import json
from groq import Groq
from pathlib import Path
from config import GROQ_API_KEY


class GroqSkillsExtractor:
    def __init__(self):
        self.client = Groq(api_key=GROQ_API_KEY)
        self.skills_by_category, self.skills_list = self._load_skills_reference()

    def _load_skills_reference(self) -> tuple[dict, list]:
        """Charge skills.json comme référence"""
        skills_path = Path(__file__).parent.parent / "data" / "skills.json"
        with open(skills_path, "r", encoding="utf-8") as f:
            data = json.load(f)

        # Structure par catégorie (pour le mapping)
        by_category = {}
        # Liste plate (pour le prompt - réduit les tokens)
        flat_list = []

        for category, skills in data.get("IT", {}).items():
            by_category[category] = [s["name"] for s in skills]
            flat_list.extend([s["name"] for s in skills])

        return by_category, flat_list

    def _get_category(self, skill_name: str) -> str:
        """Trouve la catégorie d'un skill"""
        for category, skills in self.skills_by_category.items():
            if skill_name in skills:
                return category
        return "other"
    
    def extract_skills(self, job_description: str) -> list[str]:
        """Extrait les skills d'une description avec Groq"""

        prompt = f"""Extract technical skills from this job posting.

RULES:
1. ONLY return skills from this list: {", ".join(self.skills_list)}
2. Return ONLY a JSON array, nothing else
3. Ignore skills not in the list

JOB POSTING:
{job_description[:3000]}

RETURN FORMAT (JSON array only):
["Python", "React", "AWS"]"""

        try:
            response = self.client.chat.completions.create(
                model="llama-3.1-8b-instant",
                messages=[{"role": "user", "content": prompt}],
                temperature=0,
                max_tokens=500
            )

            content = response.choices[0].message.content.strip()

            # Nettoyer la réponse
            if content.startswith("```json"):
                content = content[7:]
            if content.startswith("```"):
                content = content[3:]
            if content.endswith("```"):
                content = content[:-3]

            skills = json.loads(content.strip())

            # Valider que les skills sont dans la liste
            return [s for s in skills if s in self.skills_list]

        except Exception as e:
            print(f"Erreur Groq: {e}")
            return []
    
    def extract_skills_list(self, job_description: str) -> list[dict]:
        """Retourne une liste de skills avec leur catégorie"""

        skills = self.extract_skills(job_description)

        return [
            {"name": skill, "category": self._get_category(skill)}
            for skill in skills
        ]


groq_extractor = GroqSkillsExtractor()