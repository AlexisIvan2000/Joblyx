import pytest
from unittest.mock import patch, Mock, AsyncMock
import httpx
from services.market_analysis import SerpAPIService, serpapi_service
from services.market_analysis.serpapi_service import normalize_text


class TestNormalizeText:

    def test_removes_accents(self):
        assert normalize_text("Développeur") == "Developpeur"
        assert normalize_text("Montréal") == "Montreal"

    def test_preserves_non_accented(self):
        assert normalize_text("Developer") == "Developer"


class TestSerpAPIService:

    def test_instance_created(self):
        assert serpapi_service is not None
        assert isinstance(serpapi_service, SerpAPIService)

    def test_has_base_url(self):
        assert SerpAPIService.BASE_URL == "https://serpapi.com/search"


class TestSearchJobs:

    @pytest.mark.asyncio
    async def test_search_jobs_success(self):
        service = SerpAPIService()

        mock_response = Mock()
        mock_response.json.return_value = {
            "jobs_results": [
                {
                    "title": "Software Developer",
                    "description": "Looking for Python developer",
                    "company_name": "Tech Corp",
                    "location": "Toronto, ON"
                },
                {
                    "title": "Backend Developer",
                    "description": "Java experience required",
                    "company_name": "Dev Inc",
                    "location": "Montreal, QC"
                }
            ]
        }
        mock_response.raise_for_status = Mock()

        with patch('httpx.AsyncClient') as mock_client_class:
            mock_client = AsyncMock()
            mock_client.get.return_value = mock_response
            mock_client_class.return_value.__aenter__.return_value = mock_client

            jobs = await service.search_jobs("Developer", "Toronto", num_pages=1)

            assert len(jobs) == 2
            # Vérifier la normalisation du format
            assert jobs[0]["job_title"] == "Software Developer"
            assert jobs[0]["job_description"] == "Looking for Python developer"
            assert jobs[0]["employer_name"] == "Tech Corp"

    @pytest.mark.asyncio
    async def test_search_jobs_empty_response(self):
        service = SerpAPIService()

        mock_response = Mock()
        mock_response.json.return_value = {"jobs_results": []}
        mock_response.raise_for_status = Mock()

        with patch('httpx.AsyncClient') as mock_client_class:
            mock_client = AsyncMock()
            mock_client.get.return_value = mock_response
            mock_client_class.return_value.__aenter__.return_value = mock_client

            jobs = await service.search_jobs("Rare Job", "Small Town", num_pages=1)

            assert jobs == []

    @pytest.mark.asyncio
    async def test_search_jobs_api_error(self):
        service = SerpAPIService()

        with patch('httpx.AsyncClient') as mock_client_class:
            mock_client = AsyncMock()
            mock_client.get.side_effect = httpx.RequestError("API Error")
            mock_client_class.return_value.__aenter__.return_value = mock_client

            jobs = await service.search_jobs("Developer", "Toronto", num_pages=1)

            assert jobs == []

    @pytest.mark.asyncio
    async def test_search_jobs_params(self):
        service = SerpAPIService()

        mock_response = Mock()
        mock_response.json.return_value = {"jobs_results": []}
        mock_response.raise_for_status = Mock()

        with patch('httpx.AsyncClient') as mock_client_class:
            mock_client = AsyncMock()
            mock_client.get.return_value = mock_response
            mock_client_class.return_value.__aenter__.return_value = mock_client

            await service.search_jobs("Python Developer", "Toronto, Ontario, Canada", num_pages=1)

            call_args = mock_client.get.call_args
            params = call_args.kwargs.get('params')

            assert params["engine"] == "google_jobs"
            assert params["gl"] == "ca"
            assert "Python Developer" in params["q"]


class TestGetJobDescriptions:

    @pytest.mark.asyncio
    async def test_extracts_descriptions(self):
        service = SerpAPIService()

        with patch.object(service, 'search_jobs', new_callable=AsyncMock) as mock_search:
            mock_search.return_value = [
                {"job_description": "Python developer needed"},
                {"job_description": "Java developer needed"},
                {"job_description": ""}
            ]

            descriptions = await service.get_job_descriptions("Developer", "Toronto")

            assert len(descriptions) == 2
            assert "Python developer needed" in descriptions

    @pytest.mark.asyncio
    async def test_returns_empty_list(self):
        service = SerpAPIService()

        with patch.object(service, 'search_jobs', new_callable=AsyncMock) as mock_search:
            mock_search.return_value = []

            descriptions = await service.get_job_descriptions("Rare Job", "Small Town")

            assert descriptions == []
