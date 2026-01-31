import json
import asyncio
from groq import Groq, AsyncGroq
from pathlib import Path
from config import GROQ_API_KEY


class GroqSkillsExtractor:
    def __init__(self):
        self.client = Groq(api_key=GROQ_API_KEY)
        self.async_client = AsyncGroq(api_key=GROQ_API_KEY)
        self.skills_by_category, self.skills_list = self._load_skills_reference()

    def _load_skills_reference(self) -> tuple[dict, list]:
        """Charge skills.json comme référence"""
        skills_path = Path(__file__).parent.parent.parent / "data" / "skills.json"
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
                model="meta-llama/llama-4-scout-17b-16e-instruct",
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

    async def extract_skills_async(self, job_description: str, max_retries: int = 3) -> list[str]:
        """Version async de extract_skills avec retry pour rate limit"""

        prompt = f"""Extract technical skills from this job posting.

RULES:
1. ONLY return skills from this list: {", ".join(self.skills_list)}
2. Return ONLY a JSON array, nothing else
3. Ignore skills not in the list

JOB POSTING:
{job_description[:3000]}

RETURN FORMAT (JSON array only):
["Python", "React", "AWS"]"""

        for attempt in range(max_retries):
            try:
                response = await self.async_client.chat.completions.create(
                    model="meta-llama/llama-4-scout-17b-16e-instruct",
                    messages=[{"role": "user", "content": prompt}],
                    temperature=0,
                    max_tokens=500
                )

                content = response.choices[0].message.content.strip()

                if content.startswith("```json"):
                    content = content[7:]
                if content.startswith("```"):
                    content = content[3:]
                if content.endswith("```"):
                    content = content[:-3]

                skills = json.loads(content.strip())
                return [s for s in skills if s in self.skills_list]

            except Exception as e:
                error_str = str(e)
                if "429" in error_str or "rate_limit" in error_str:
                    wait_time = (attempt + 1) * 15  # 15s, 30s, 45s
                    print(f"Groq rate limit, retry in {wait_time}s (attempt {attempt + 1}/{max_retries})")
                    await asyncio.sleep(wait_time)
                else:
                    print(f"Erreur Groq async: {e}")
                    return []

        print("Groq: max retries exceeded")
        return []

    async def extract_skills_list_async(self, job_description: str) -> list[dict]:
        """Version async de extract_skills_list"""
        skills = await self.extract_skills_async(job_description)
        return [
            {"name": skill, "category": self._get_category(skill)}
            for skill in skills
        ]

    async def extract_all_skills(self, descriptions: list[str], max_concurrent: int = 2) -> list[list[dict]]:
        """Extrait les skills de plusieurs descriptions avec limite de concurrence"""
        semaphore = asyncio.Semaphore(max_concurrent)

        async def extract_with_limit(desc: str) -> list[dict]:
            async with semaphore:
                return await self.extract_skills_list_async(desc)

        tasks = [extract_with_limit(desc) for desc in descriptions]
        results = await asyncio.gather(*tasks, return_exceptions=True)

        # Filtrer les erreurs
        return [r for r in results if isinstance(r, list)]


groq_extractor = GroqSkillsExtractor()