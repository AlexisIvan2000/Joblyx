import unicodedata
import asyncio
from config import SERPAPI_KEY
from serpapi.google_search import GoogleSearch


def normalize_text(text: str) -> str:
    normalized = unicodedata.normalize("NFD", text)
    without_accents = "".join(c for c in normalized if unicodedata.category(c) != "Mn")
    return without_accents


class SerpAPIService:

    def __init__(self):
        self.api_key = SERPAPI_KEY

    def _search_sync(self, params: dict) -> dict:
        """Recherche synchrone avec GoogleSearch"""
        search = GoogleSearch(params)
        return search.get_dict()

    async def search_jobs(self, query: str, location: str = "", num_results: int = 30, language: str = "en") -> list[dict]:
        if not self.api_key:
            print("SerpAPI: API key not configured")
            return []

        all_jobs = []

        query = normalize_text(query)
        # Extraire juste la ville du format "City, Province, Canada"
        city = location.split(",")[0].strip() if location else "Canada"
        city = normalize_text(city)

        params = {
            "api_key": self.api_key,
            "engine": "google_jobs",
            "q": query,
            "location": city,
            "gl": "ca",
            "hl": language,
        }

        page = 1
        while len(all_jobs) < num_results:
            try:
                print(f"SerpAPI: Fetching page {page}...")
                data = await asyncio.to_thread(self._search_sync, params)

                if "error" in data:
                    print(f"SerpAPI error: {data['error']}")
                    break

                jobs = data.get("jobs_results", [])
                if not jobs:
                    print(f"SerpAPI: No more jobs at page {page}, total collected={len(all_jobs)}")
                    break

                for job in jobs:
                    all_jobs.append({
                        "job_title": job.get("title", ""),
                        "job_description": job.get("description", ""),
                        "employer_name": job.get("company_name", ""),
                        "job_city": job.get("location", ""),
                        "job_country": "CA"
                    })

                # Utiliser next_page_token pour la pagination
                next_page_token = data.get("serpapi_pagination", {}).get("next_page_token")
                if not next_page_token:
                    print(f"SerpAPI: No more pages, total collected={len(all_jobs)}")
                    break

                params["next_page_token"] = next_page_token
                page += 1

            except Exception as e:
                print(f"SerpAPI error: {e}")
                break

        # Si aucun résultat et langue était français, réessayer en anglais
        if not all_jobs and language == "fr":
            print("SerpAPI: No results in French, trying English...")
            return await self.search_jobs(query, location, num_results, language="en")

        return all_jobs[:num_results]

    async def get_job_descriptions(self, query: str, location: str = "", num_pages: int = 3) -> list[str]:
        num_results = num_pages * 10  # ~10 résultats par page
        jobs = await self.search_jobs(query, location, num_results)
        descriptions = []

        for job in jobs:
            description = job.get("job_description", "")
            if description:
                descriptions.append(description)

        return descriptions


serpapi_service = SerpAPIService()
