import pytest
from unittest.mock import patch, Mock, AsyncMock
import httpx
from services.market_analysis import JobSearchService, job_search_service


class TestJobSearchService:

    def test_instance_created(self):
        assert job_search_service is not None
        assert isinstance(job_search_service, JobSearchService)

    def test_has_jsearch_and_serpapi(self):
        service = JobSearchService()
        assert service.jsearch is not None
        assert service.serpapi is not None


class TestSearchJobsWithFallback:

    @pytest.mark.asyncio
    async def test_uses_jsearch_first_when_successful(self):
        service = JobSearchService()
        service.jsearch = Mock()
        service.serpapi = Mock()

        service.jsearch.search_jobs = AsyncMock(return_value=[
            {"job_title": "Developer", "job_description": "Python needed"}
        ])

        result = await service.search_jobs("Developer", "Toronto", 1)

        assert len(result) == 1
        assert service.last_provider == "jsearch"
        service.jsearch.search_jobs.assert_called_once()
        service.serpapi.search_jobs.assert_not_called()

    @pytest.mark.asyncio
    async def test_fallback_to_serpapi_on_jsearch_empty(self):
        service = JobSearchService()
        service.jsearch = Mock()
        service.serpapi = Mock()

        service.jsearch.search_jobs = AsyncMock(return_value=[])
        service.serpapi.search_jobs = AsyncMock(return_value=[
            {"job_title": "Developer", "job_description": "Java needed"}
        ])

        result = await service.search_jobs("Developer", "Toronto", 1)

        assert len(result) == 1
        assert service.last_provider == "serpapi"

    @pytest.mark.asyncio
    async def test_fallback_to_serpapi_on_jsearch_error(self):
        service = JobSearchService()
        service.jsearch = Mock()
        service.serpapi = Mock()

        service.jsearch.search_jobs = AsyncMock(side_effect=Exception("JSearch down"))
        service.serpapi.search_jobs = AsyncMock(return_value=[
            {"job_title": "Developer", "job_description": "Go needed"}
        ])

        result = await service.search_jobs("Developer", "Montreal", 1)

        assert len(result) == 1
        assert service.last_provider == "serpapi"

    @pytest.mark.asyncio
    async def test_fallback_to_serpapi_on_rate_limit(self):
        service = JobSearchService()
        service.jsearch = Mock()
        service.serpapi = Mock()

        # Simuler une erreur 429 (rate limit)
        mock_response = Mock()
        mock_response.status_code = 429
        http_error = httpx.HTTPStatusError(
            message="Rate limit",
            request=Mock(),
            response=mock_response
        )
        service.jsearch.search_jobs = AsyncMock(side_effect=http_error)

        service.serpapi.search_jobs = AsyncMock(return_value=[
            {"job_title": "Developer", "job_description": "Rust needed"}
        ])

        result = await service.search_jobs("Developer", "Vancouver", 1)

        assert len(result) == 1
        assert service.last_provider == "serpapi"

    @pytest.mark.asyncio
    async def test_returns_empty_when_both_fail(self):
        service = JobSearchService()
        service.jsearch = Mock()
        service.serpapi = Mock()

        service.jsearch.search_jobs = AsyncMock(side_effect=Exception("JSearch down"))
        service.serpapi.search_jobs = AsyncMock(side_effect=Exception("SerpAPI down"))

        result = await service.search_jobs("Developer", "Ottawa", 1)

        assert result == []
        assert service.last_provider is None


class TestGetJobDescriptions:

    @pytest.mark.asyncio
    async def test_extracts_descriptions(self):
        service = JobSearchService()
        service.jsearch = Mock()
        service.serpapi = Mock()

        service.jsearch.search_jobs = AsyncMock(return_value=[
            {"job_description": "Python developer needed"},
            {"job_description": "Java developer needed"},
            {"job_description": ""}
        ])

        descriptions = await service.get_job_descriptions("Developer", "Toronto")

        assert len(descriptions) == 2
        assert "Python developer needed" in descriptions
        assert "Java developer needed" in descriptions

    @pytest.mark.asyncio
    async def test_returns_empty_when_no_jobs(self):
        service = JobSearchService()
        service.jsearch = Mock()
        service.serpapi = Mock()

        service.jsearch.search_jobs = AsyncMock(return_value=[])
        service.serpapi.search_jobs = AsyncMock(return_value=[])

        descriptions = await service.get_job_descriptions("Rare Job", "Small Town")

        assert descriptions == []


class TestGetLastProvider:

    @pytest.mark.asyncio
    async def test_returns_provider_after_search(self):
        service = JobSearchService()
        service.jsearch = Mock()
        service.serpapi = Mock()

        service.jsearch.search_jobs = AsyncMock(return_value=[{"job_description": "Test"}])

        await service.search_jobs("Developer", "Toronto", 1)

        assert service.get_last_provider() == "jsearch"

    def test_returns_none_initially(self):
        service = JobSearchService()
        assert service.get_last_provider() is None
