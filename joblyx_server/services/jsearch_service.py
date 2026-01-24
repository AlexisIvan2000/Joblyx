import requests
from config import RAPIDAPI_KEY


class JSearchService:
    BASE_URL = "https://jsearch.p.rapidapi.com/search"

    def __init__(self):
        self.headers = {
            "X-RapidAPI-Key": RAPIDAPI_KEY,
            "X-RapidAPI-Host": "jsearch.p.rapidapi.com"
        }

    def search_jobs(self, query: str, location: str = "", num_pages: int = 1) -> list[dict]:
        """
        Search for jobs using JSearch API.

        Args:
            query: Job title or keywords (e.g., "Software Developer")
            location: Location string (e.g., "Toronto, Ontario, Canada")
            num_pages: Number of pages to fetch (10 results per page)

        Returns:
            List of job dictionaries with description field
        """
        all_jobs = []

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
                print(f"Error fetching page {page}: {e}")
                break

        return all_jobs

    def get_job_descriptions(self, query: str, location: str = "", num_pages: int = 5) -> list[str]:
        """
        Get job descriptions for analysis.

        Args:
            query: Job title or keywords
            location: Location string
            num_pages: Number of pages to fetch

        Returns:
            List of job description strings
        """
        jobs = self.search_jobs(query, location, num_pages)
        descriptions = []

        for job in jobs:
            description = job.get("job_description", "")
            if description:
                descriptions.append(description)

        return descriptions


jsearch_service = JSearchService()
