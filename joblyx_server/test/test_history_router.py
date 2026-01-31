import pytest
from unittest.mock import patch, MagicMock
from fastapi.testclient import TestClient
from app import app
from services.auth import get_user_id_from_token

client = TestClient(app)


# Override de la dépendance d'authentification pour les tests
async def mock_get_user_id():
    return "user-123"


class TestGetHistory:

    def test_get_history_success(self):
        app.dependency_overrides[get_user_id_from_token] = mock_get_user_id

        with patch('routers.history.user_history_service.get_user_history') as mock_get_history:
            mock_get_history.return_value = [
                {"id": "1", "query": "Python", "city": "Toronto", "province": "Ontario"},
                {"id": "2", "query": "Java", "city": "Montreal", "province": "Quebec"}
            ]

            response = client.get("/history")

            assert response.status_code == 200
            data = response.json()
            assert data["count"] == 2
            assert len(data["history"]) == 2

        app.dependency_overrides.clear()

    def test_get_history_empty(self):
        app.dependency_overrides[get_user_id_from_token] = mock_get_user_id

        with patch('routers.history.user_history_service.get_user_history') as mock_get_history:
            mock_get_history.return_value = []

            response = client.get("/history")

            assert response.status_code == 200
            data = response.json()
            assert data["count"] == 0
            assert data["history"] == []

        app.dependency_overrides.clear()

    def test_get_history_no_auth(self):
        # Sans override, l'auth devrait échouer
        app.dependency_overrides.clear()
        response = client.get("/history")
        assert response.status_code == 401


class TestGetSearchById:

    def test_get_search_success(self):
        app.dependency_overrides[get_user_id_from_token] = mock_get_user_id

        with patch('routers.history.user_history_service.get_search_by_id') as mock_get_search:
            mock_get_search.return_value = {
                "id": "search-1",
                "query": "Python Developer",
                "city": "Toronto",
                "results": {"top_skills": []}
            }

            response = client.get("/history/search-1")

            assert response.status_code == 200
            data = response.json()
            assert data["id"] == "search-1"
            assert data["query"] == "Python Developer"

        app.dependency_overrides.clear()

    def test_get_search_not_found(self):
        app.dependency_overrides[get_user_id_from_token] = mock_get_user_id

        with patch('routers.history.user_history_service.get_search_by_id') as mock_get_search:
            mock_get_search.return_value = None

            response = client.get("/history/nonexistent")

            assert response.status_code == 404

        app.dependency_overrides.clear()


class TestDeleteSearch:

    def test_delete_search_success(self):
        app.dependency_overrides[get_user_id_from_token] = mock_get_user_id

        with patch('routers.history.user_history_service.delete_search_by_id') as mock_delete:
            mock_delete.return_value = True

            response = client.delete("/history/search-1")

            assert response.status_code == 200
            data = response.json()
            assert data["message"] == "Search deleted"

        app.dependency_overrides.clear()

    def test_delete_search_failure(self):
        app.dependency_overrides[get_user_id_from_token] = mock_get_user_id

        with patch('routers.history.user_history_service.delete_search_by_id') as mock_delete:
            mock_delete.return_value = False

            response = client.delete("/history/search-1")

            assert response.status_code == 500

        app.dependency_overrides.clear()


class TestClearHistory:

    def test_clear_history_success(self):
        app.dependency_overrides[get_user_id_from_token] = mock_get_user_id

        with patch('routers.history.user_history_service.clear_user_history') as mock_clear:
            mock_clear.return_value = True

            response = client.delete("/history")

            assert response.status_code == 200
            data = response.json()
            assert data["message"] == "History cleared"

        app.dependency_overrides.clear()

    def test_clear_history_failure(self):
        app.dependency_overrides[get_user_id_from_token] = mock_get_user_id

        with patch('routers.history.user_history_service.clear_user_history') as mock_clear:
            mock_clear.return_value = False

            response = client.delete("/history")

            assert response.status_code == 500

        app.dependency_overrides.clear()
