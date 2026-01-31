import pytest
from unittest.mock import patch, MagicMock, AsyncMock
from fastapi.testclient import TestClient
from app import app
from services.auth import get_user_id_from_token

client = TestClient(app)


async def mock_get_user_id():
    return "user-123"


async def mock_get_user_id_none():
    return None


class TestAnalyzeMarketEndpoint:

    def test_analyze_market_anonymous_success(self):
        with patch('routers.market_analysis.market_analyzer.analyze_market', new_callable=AsyncMock) as mock_analyze:
            mock_analyze.return_value = {
                "query": "Python Developer",
                "location": "Toronto, Ontario, Canada",
                "total_jobs_analyzed": 25,
                "top_skills": [
                    {"name": "Python", "category": "programming_languages", "count": 20, "percentage": 80.0}
                ],
                "from_cache": False
            }

            response = client.get(
                "/market/analyze",
                params={"job": "Python Developer", "city": "Toronto", "province": "Ontario"}
            )

            assert response.status_code == 200
            data = response.json()
            assert data["query"] == "Python Developer"
            assert data["total_jobs_analyzed"] == 25
            assert len(data["top_skills"]) == 1

    def test_analyze_market_with_parameters(self):
        with patch('routers.market_analysis.market_analyzer.analyze_market', new_callable=AsyncMock) as mock_analyze:
            mock_analyze.return_value = {
                "query": "Java Developer",
                "location": "Montreal, Quebec, Canada",
                "total_jobs_analyzed": 15,
                "top_skills": [],
                "from_cache": False
            }

            response = client.get(
                "/market/analyze",
                params={
                    "job": "Java Developer",
                    "city": "Montreal",
                    "province": "Quebec",
                    "top_n": 20,
                    "balanced": False
                }
            )

            assert response.status_code == 200
            mock_analyze.assert_called_once()
            call_kwargs = mock_analyze.call_args.kwargs
            assert call_kwargs["top_n"] == 20
            assert call_kwargs["balanced"] is False

    def test_analyze_market_authenticated_records_quota(self):
        app.dependency_overrides[get_user_id_from_token] = mock_get_user_id

        with patch('routers.market_analysis.get_optional_user_id', new_callable=AsyncMock) as mock_get_user, \
             patch('routers.market_analysis.user_quota.can_user_search') as mock_can_search, \
             patch('routers.market_analysis.market_analyzer.analyze_market', new_callable=AsyncMock) as mock_analyze, \
             patch('routers.market_analysis.user_quota.record_search') as mock_record_quota, \
             patch('routers.market_analysis.user_history_service.record_search') as mock_record_history:

            mock_get_user.return_value = "user-123"
            mock_can_search.return_value = True
            mock_analyze.return_value = {
                "query": "Developer",
                "location": "Toronto, Ontario, Canada",
                "total_jobs_analyzed": 10,
                "top_skills": [],
                "from_cache": False
            }

            response = client.get(
                "/market/analyze",
                params={"job": "Developer", "city": "Toronto", "province": "Ontario"},
                headers={"Authorization": "Bearer test-token"}
            )

            assert response.status_code == 200
            mock_record_quota.assert_called_once_with("user-123")
            mock_record_history.assert_called_once()

        app.dependency_overrides.clear()

    def test_analyze_market_from_cache_no_quota_deduction(self):
        with patch('routers.market_analysis.get_optional_user_id', new_callable=AsyncMock) as mock_get_user, \
             patch('routers.market_analysis.user_quota.can_user_search') as mock_can_search, \
             patch('routers.market_analysis.market_analyzer.analyze_market', new_callable=AsyncMock) as mock_analyze, \
             patch('routers.market_analysis.user_quota.record_search') as mock_record_quota, \
             patch('routers.market_analysis.user_history_service.record_search') as mock_record_history:

            mock_get_user.return_value = "user-123"
            mock_can_search.return_value = True
            mock_analyze.return_value = {
                "query": "Developer",
                "location": "Toronto, Ontario, Canada",
                "total_jobs_analyzed": 10,
                "top_skills": [],
                "from_cache": True  # Resultat du cache
            }

            response = client.get(
                "/market/analyze",
                params={"job": "Developer", "city": "Toronto", "province": "Ontario"},
                headers={"Authorization": "Bearer test-token"}
            )

            assert response.status_code == 200
            # Quota NON decompte car from_cache=True
            mock_record_quota.assert_not_called()
            # Historique toujours enregistre
            mock_record_history.assert_called_once()

    def test_analyze_market_quota_exceeded(self):
        with patch('routers.market_analysis.get_optional_user_id', new_callable=AsyncMock) as mock_get_user, \
             patch('routers.market_analysis.user_quota.can_user_search') as mock_can_search:

            mock_get_user.return_value = "user-123"
            mock_can_search.return_value = False

            response = client.get(
                "/market/analyze",
                params={"job": "Developer", "city": "Toronto", "province": "Ontario"},
                headers={"Authorization": "Bearer test-token"}
            )

            assert response.status_code == 429
            assert "Weekly search limit reached" in response.json()["detail"]

    def test_analyze_market_no_jobs_found(self):
        with patch('routers.market_analysis.market_analyzer.analyze_market', new_callable=AsyncMock) as mock_analyze:
            mock_analyze.return_value = {
                "query": "Rare Job",
                "location": "Small Town, Ontario, Canada",
                "total_jobs_analyzed": 0,
                "top_skills": [],
                "message": "No jobs found for this search",
                "from_cache": False
            }

            response = client.get(
                "/market/analyze",
                params={"job": "Rare Job", "city": "Small Town", "province": "Ontario"}
            )

            assert response.status_code == 200
            data = response.json()
            assert data["total_jobs_analyzed"] == 0


class TestAnalyzeMarketByCategoryEndpoint:

    def test_by_category_success(self):
        with patch('routers.market_analysis.market_analyzer.get_skills_by_category', new_callable=AsyncMock) as mock_analyze:
            mock_analyze.return_value = {
                "query": "Developer",
                "location": "Toronto, Ontario, Canada",
                "total_jobs_analyzed": 20,
                "skills_by_category": {
                    "programming_languages": [
                        {"name": "Python", "count": 15, "percentage": 75.0}
                    ],
                    "databases": [
                        {"name": "PostgreSQL", "count": 10, "percentage": 50.0}
                    ]
                },
                "from_cache": False
            }

            response = client.get(
                "/market/analyze/by-category",
                params={"job": "Developer", "city": "Toronto", "province": "Ontario"}
            )

            assert response.status_code == 200
            data = response.json()
            assert "skills_by_category" in data
            assert "programming_languages" in data["skills_by_category"]

    def test_by_category_from_cache_no_quota(self):
        with patch('routers.market_analysis.get_optional_user_id', new_callable=AsyncMock) as mock_get_user, \
             patch('routers.market_analysis.user_quota.can_user_search') as mock_can_search, \
             patch('routers.market_analysis.market_analyzer.get_skills_by_category', new_callable=AsyncMock) as mock_analyze, \
             patch('routers.market_analysis.user_quota.record_search') as mock_record_quota:

            mock_get_user.return_value = "user-123"
            mock_can_search.return_value = True
            mock_analyze.return_value = {
                "query": "Developer",
                "location": "Toronto, Ontario, Canada",
                "total_jobs_analyzed": 20,
                "skills_by_category": {},
                "from_cache": True
            }

            response = client.get(
                "/market/analyze/by-category",
                params={"job": "Developer", "city": "Toronto", "province": "Ontario"},
                headers={"Authorization": "Bearer test-token"}
            )

            assert response.status_code == 200
            mock_record_quota.assert_not_called()


class TestQuotaEndpoint:

    def test_get_quota_success(self):
        # Patch direct car get_user_id_from_token est appelé directement (pas via Depends)
        with patch('routers.market_analysis.get_user_id_from_token', new_callable=AsyncMock) as mock_auth, \
             patch('routers.market_analysis.user_quota.get_stats') as mock_get_stats:

            mock_auth.return_value = "user-123"
            mock_get_stats.return_value = {
                "can_search": True,
                "searches_used": 2,
                "searches_remaining": 3,
                "max_searches": 5
            }

            response = client.get(
                "/market/quota",
                headers={"Authorization": "Bearer test-token"}
            )

            assert response.status_code == 200
            data = response.json()
            assert data["can_search"] is True
            assert data["searches_used"] == 2
            assert data["searches_remaining"] == 3

    def test_get_quota_no_auth(self):
        # Sans header Authorization, FastAPI retourne 422 (validation error)
        app.dependency_overrides.clear()
        response = client.get("/market/quota")
        assert response.status_code == 422  # Missing required header
