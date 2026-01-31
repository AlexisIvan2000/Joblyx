import unicodedata
import httpx
from config import SERPAPI_KEY


def normalize_text(text: str) -> str:
    normalized = unicodedata.normalize("NFD", text)
    without_accents = "".join(c for c in normalized if unicodedata.category(c) != "Mn")
    return without_accents


class SerpAPIService:
    BASE_URL = "https://serpapi.com/search"

    def __init__(self):
        self.api_key = SERPAPI_KEY

    async def search_jobs(self, query: str, location: str = "", num_pages: int = 1) -> list[dict]:
        all_jobs = []

        query = normalize_text(query)
        location = normalize_text(location)

        async with httpx.AsyncClient(timeout=30) as client:
            for page in range(num_pages):
                params = {
                    "engine": "google_jobs",
                    "q": f"{query} {location}" if location else query,
                    "hl": "en",
                    "gl": "ca",
                    "start": page * 10,
                    "api_key": self.api_key
                }

                try:
                    response = await client.get(self.BASE_URL, params=params)
                    response.raise_for_status()
                    data = response.json()

                    jobs = data.get("jobs_results", [])
                    if not jobs:
                        break

                    # Normaliser le format pour correspondre à JSearch
                    for job in jobs:
                        all_jobs.append({
                            "job_title": job.get("title", ""),
                            "job_description": job.get("description", ""),
                            "employer_name": job.get("company_name", ""),
                            "job_city": job.get("location", ""),
                            "job_country": "CA"
                        })

                except httpx.HTTPStatusError as e:
                    print(f"SerpAPI HTTP error page {page}: {e}")
                    raise
                except httpx.RequestError as e:
                    print(f"SerpAPI request error page {page}: {e}")
                    break

        return all_jobs

    async def get_job_descriptions(self, query: str, location: str = "", num_pages: int = 5) -> list[str]:
        jobs = await self.search_jobs(query, location, num_pages)
        descriptions = []

        for job in jobs:
            description = job.get("job_description", "")
            if description:
                descriptions.append(description)

        return descriptions


serpapi_service = SerpAPIService()
