import unicodedata
import requests
from config import RAPIDAPI_KEY


def normalize_text(text: str) -> str:
    # Décompose les caractères accentués (é → e + accent)
    normalized = unicodedata.normalize("NFD", text)
    # Supprime les accents (catégorie "Mn" = Mark, Nonspacing)
    without_accents = "".join(c for c in normalized if unicodedata.category(c) != "Mn")
    return without_accents


class JSearchService:
    BASE_URL = "https://jsearch.p.rapidapi.com/search"

    def __init__(self):
        self.headers = {
            "X-RapidAPI-Key": RAPIDAPI_KEY,
            "X-RapidAPI-Host": "jsearch.p.rapidapi.com"
        }

    def search_jobs(self, query: str, location: str = "", num_pages: int = 1) -> list[dict]:
        all_jobs = []

        # Normaliser pour des résultats cohérents (accents → sans accents)
        query = normalize_text(query)
        location = normalize_text(location)

        for page in range(1, num_pages + 1):
            params = {
                "query": f"{query} in {location}" if location else query,
                "page": str(page),
                "num_pages": "3",
                "country": "ca",
                "date_posted": "month"
            }

            try:
                response = requests.get(
                    self.BASE_URL,
                    headers=self.headers,
                    params=params,
                    timeout=30
                )
                response.raise_for_status()
                data = response.json()

                jobs = data.get("data", [])
                if not jobs:
                    break

                all_jobs.extend(jobs)

            except requests.exceptions.RequestException as e:
                print(f"Erreur lors de la récupération de la page {page}: {e}")
                break

        return all_jobs

    def get_job_descriptions(self, query: str, location: str = "", num_pages: int = 5) -> list[str]:
        jobs = self.search_jobs(query, location, num_pages)
        descriptions = []

        for job in jobs:
            description = job.get("job_description", "")
            if description:
                descriptions.append(description)

        return descriptions


jsearch_service = JSearchService()
