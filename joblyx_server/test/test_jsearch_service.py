import pytest
from unittest.mock import patch, Mock
from services.jsearch_service import JSearchService, jsearch_service, normalize_text


class TestNormalizeText:

    def test_removes_accents(self):
        assert normalize_text("Développeur") == "Developpeur"
        assert normalize_text("Montréal") == "Montreal"
        assert normalize_text("Québec") == "Quebec"

    def test_handles_multiple_accents(self):
        assert normalize_text("café résumé") == "cafe resume"
        assert normalize_text("naïve") == "naive"

    def test_preserves_non_accented(self):
        assert normalize_text("Developer") == "Developer"
        assert normalize_text("Toronto") == "Toronto"

    def test_handles_empty_string(self):
        assert normalize_text("") == ""

    def test_handles_special_characters(self):
        assert normalize_text("C++") == "C++"
        assert normalize_text("Node.js") == "Node.js"
        assert normalize_text("ASP.NET") == "ASP.NET"


class TestJSearchService:

    def test_instance_created(self):
        assert jsearch_service is not None
        assert isinstance(jsearch_service, JSearchService)

    def test_has_base_url(self):
        assert JSearchService.BASE_URL == "https://jsearch.p.rapidapi.com/search"

    def test_has_headers(self):
        service = JSearchService()
        assert "X-RapidAPI-Key" in service.headers
        assert "X-RapidAPI-Host" in service.headers


class TestSearchJobs:

    @patch('services.jsearch_service.requests.get')
    def test_search_jobs_success(self, mock_get, mock_jsearch_response):
        mock_response = Mock()
        mock_response.json.return_value = mock_jsearch_response
        mock_response.raise_for_status = Mock()
        mock_get.return_value = mock_response

        service = JSearchService()
        jobs = service.search_jobs("Developer", "Toronto, Ontario, Canada", num_pages=1)

        assert len(jobs) == 2
        assert mock_get.called

    @patch('services.jsearch_service.requests.get')
    def test_search_jobs_empty_response(self, mock_get):
        mock_response = Mock()
        mock_response.json.return_value = {"data": []}
        mock_response.raise_for_status = Mock()
        mock_get.return_value = mock_response

        service = JSearchService()
        jobs = service.search_jobs("Rare Job", "Small Town", num_pages=1)

        assert jobs == []

    @patch('services.jsearch_service.requests.get')
    def test_search_jobs_api_error(self, mock_get):
        import requests
        mock_get.side_effect = requests.exceptions.RequestException("API Error")

        service = JSearchService()
        jobs = service.search_jobs("Developer", "Toronto", num_pages=1)

        assert jobs == []

    @patch('services.jsearch_service.requests.get')
    def test_normalizes_query(self, mock_get):
        mock_response = Mock()
        mock_response.json.return_value = {"data": []}
        mock_response.raise_for_status = Mock()
        mock_get.return_value = mock_response

        service = JSearchService()
        service.search_jobs("Développeur", "Montréal, Québec, Canada", num_pages=1)

        # Vérifie que la requête normalisée est utilisée
        call_args = mock_get.call_args
        params = call_args.kwargs.get('params') or call_args[1].get('params')

        assert "Developpeur" in params["query"]
        assert "Montreal" in params["query"]

    @patch('services.jsearch_service.requests.get')
    def test_search_jobs_params(self, mock_get):
        mock_response = Mock()
        mock_response.json.return_value = {"data": []}
        mock_response.raise_for_status = Mock()
        mock_get.return_value = mock_response

        service = JSearchService()
        service.search_jobs("Python Developer", "Toronto, Ontario, Canada", num_pages=1)

        call_args = mock_get.call_args
        params = call_args.kwargs.get('params') or call_args[1].get('params')

        assert params["country"] == "ca"
        assert params["date_posted"] == "month"


class TestGetJobDescriptions:

    @patch.object(JSearchService, 'search_jobs')
    def test_extracts_descriptions(self, mock_search):
        mock_search.return_value = [
            {"job_description": "Python developer needed"},
            {"job_description": "Java developer needed"},
            {"job_description": ""}
        ]

        service = JSearchService()
        descriptions = service.get_job_descriptions("Developer", "Toronto")

        assert len(descriptions) == 2
        assert "Python developer needed" in descriptions
        assert "Java developer needed" in descriptions

    @patch.object(JSearchService, 'search_jobs')
    def test_handles_missing_description(self, mock_search):
        mock_search.return_value = [
            {"job_title": "Developer"},
            {"job_description": "Valid description"}
        ]

        service = JSearchService()
        descriptions = service.get_job_descriptions("Developer", "Toronto")

        assert len(descriptions) == 1
        assert descriptions[0] == "Valid description"

    @patch.object(JSearchService, 'search_jobs')
    def test_returns_empty_list(self, mock_search):
        mock_search.return_value = []

        service = JSearchService()
        descriptions = service.get_job_descriptions("Rare Job", "Small Town")

        assert descriptions == []
