import pytest
from unittest.mock import patch, MagicMock
from fastapi.testclient import TestClient
from app import app

client = TestClient(app)


class TestCacheStats:

    @patch('services.cache_service.cache_service.get_stats')
    def test_get_stats_success(self, mock_get_stats):
        mock_get_stats.return_value = {
            "total_entries": 100,
            "valid_entries": 80,
            "expired_entries": 20,
            "popular_searches": [
                {"query": "Python", "city": "Toronto", "province": "Ontario", "hit_count": 50}
            ]
        }

        response = client.get("/cache/stats")

        assert response.status_code == 200
        data = response.json()
        assert data["total_entries"] == 100
        assert data["valid_entries"] == 80
        assert len(data["popular_searches"]) == 1


class TestCacheCleanup:

    @patch('services.cache_service.cache_service.clear_expired')
    def test_cleanup_success(self, mock_clear):
        mock_clear.return_value = 15

        response = client.post("/cache/cleanup")

        assert response.status_code == 200
        data = response.json()
        assert data["deleted_entries"] == 15

    @patch('services.cache_service.cache_service.clear_expired')
    def test_cleanup_no_expired(self, mock_clear):
        mock_clear.return_value = 0

        response = client.post("/cache/cleanup")

        assert response.status_code == 200
        data = response.json()
        assert data["deleted_entries"] == 0
