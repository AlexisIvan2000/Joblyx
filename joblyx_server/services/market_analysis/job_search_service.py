import httpx
from .jsearch_service import JSearchService
from .serpapi_service import SerpAPIService


class JobSearchService:
    """
    Service de recherche d'emplois avec fallback.
    Essaie JSearch en premier, puis SerpAPI si JSearch échoue.
    """

    def __init__(self):
        self.jsearch = JSearchService()
        self.serpapi = SerpAPIService()
        self.last_provider = None

    async def search_jobs(self, query: str, location: str = "", num_pages: int = 1) -> list[dict]:
        # Essayer JSearch d'abord
        try:
            jobs = await self.jsearch.search_jobs(query, location, num_pages)
            if jobs:
                self.last_provider = "jsearch"
                print(f"JobSearch: Using JSearch ({len(jobs)} jobs)")
                return jobs
        except httpx.HTTPStatusError as e:
            if e.response.status_code == 429:
                print("JSearch rate limit reached, falling back to SerpAPI")
            else:
                print(f"JSearch HTTP error: {e}, falling back to SerpAPI")
        except Exception as e:
            print(f"JSearch error: {e}, falling back to SerpAPI")

        # Fallback vers SerpAPI
        try:
            jobs = await self.serpapi.search_jobs(query, location, num_pages)
            if jobs:
                self.last_provider = "serpapi"
                print(f"JobSearch: Using SerpAPI fallback ({len(jobs)} jobs)")
                return jobs
        except Exception as e:
            print(f"SerpAPI fallback error: {e}")

        self.last_provider = None
        return []

    async def get_job_descriptions(self, query: str, location: str = "", num_pages: int = 5) -> list[str]:
        jobs = await self.search_jobs(query, location, num_pages)
        descriptions = []

        for job in jobs:
            description = job.get("job_description", "")
            if description:
                descriptions.append(description)

        return descriptions

    def get_last_provider(self) -> str | None:
        """Retourne le dernier provider utilisé (jsearch ou serpapi)"""
        return self.last_provider


job_search_service = JobSearchService()
