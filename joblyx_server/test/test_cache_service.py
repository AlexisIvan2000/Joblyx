import pytest
from unittest.mock import Mock, MagicMock, patch
from datetime import datetime
from services.cache_service import CacheService


class TestGetCacheResults:

    @patch('services.cache_service.supabase')
    def test_cache_hit(self, mock_supabase):
        mock_result = MagicMock()
        mock_result.data = {
            "results": {
                "query": "Python",
                "location": "Toronto, Ontario, Canada",
                "total_jobs_analyzed": 10,
                "top_skills": [{"name": "Python", "category": "programming_languages"}]
            }
        }

        mock_supabase.table.return_value.select.return_value.ilike.return_value.ilike.return_value.ilike.return_value.gte.return_value.maybe_single.return_value.execute.return_value = mock_result

        service = CacheService()
        result = service.get_cache_results("Python", "Toronto", "Ontario")

        assert result is not None
        assert result["query"] == "Python"

    @patch('services.cache_service.supabase')
    def test_cache_miss(self, mock_supabase):
        mock_result = MagicMock()
        mock_result.data = None

        mock_supabase.table.return_value.select.return_value.ilike.return_value.ilike.return_value.ilike.return_value.gte.return_value.maybe_single.return_value.execute.return_value = mock_result

        service = CacheService()
        result = service.get_cache_results("Python", "Toronto", "Ontario")

        assert result is None

    @patch('services.cache_service.supabase')
    def test_cache_error_returns_none(self, mock_supabase):
        mock_supabase.table.return_value.select.side_effect = Exception("DB Error")

        service = CacheService()
        result = service.get_cache_results("Python", "Toronto", "Ontario")

        assert result is None


class TestSaveToCache:

    @patch('services.cache_service.supabase')
    def test_save_success(self, mock_supabase):
        mock_supabase.table.return_value.upsert.return_value.execute.return_value = MagicMock()

        service = CacheService()
        result = service.save_to_cache(
            query="Python",
            city="Toronto",
            province="Ontario",
            results={"top_skills": []},
            total_jobs=10
        )

        assert result is True
        mock_supabase.table.assert_called_with("search_cache")

    @patch('services.cache_service.supabase')
    def test_save_lowercases_keys(self, mock_supabase):
        mock_supabase.table.return_value.upsert.return_value.execute.return_value = MagicMock()

        service = CacheService()
        service.save_to_cache(
            query="PYTHON",
            city="TORONTO",
            province="ONTARIO",
            results={},
            total_jobs=5
        )

        call_args = mock_supabase.table.return_value.upsert.call_args[0][0]
        assert call_args["query"] == "python"
        assert call_args["city"] == "toronto"
        assert call_args["province"] == "ontario"

    @patch('services.cache_service.supabase')
    def test_save_error_returns_false(self, mock_supabase):
        mock_supabase.table.return_value.upsert.side_effect = Exception("DB Error")

        service = CacheService()
        result = service.save_to_cache("Python", "Toronto", "Ontario", {}, 10)

        assert result is False


class TestClearExpired:

    @patch('services.cache_service.supabase')
    def test_clear_expired_success(self, mock_supabase):
        mock_result = MagicMock()
        mock_result.data = 5

        mock_supabase.rpc.return_value.execute.return_value = mock_result

        service = CacheService()
        count = service.clear_expired()

        assert count == 5
        mock_supabase.rpc.assert_called_with("cleanup_expired_cache")

    @patch('services.cache_service.supabase')
    def test_clear_expired_error_returns_zero(self, mock_supabase):
        mock_supabase.rpc.side_effect = Exception("RPC Error")

        service = CacheService()
        count = service.clear_expired()

        assert count == 0


class TestGetStats:

    @patch('services.cache_service.supabase')
    def test_get_stats_success(self, mock_supabase):
        mock_total = MagicMock()
        mock_total.count = 100

        mock_valid = MagicMock()
        mock_valid.count = 80

        mock_popular = MagicMock()
        mock_popular.data = [
            {"query": "Python", "city": "Toronto", "province": "Ontario", "hit_count": 50, "total_jobs": 25}
        ]

        # Configure chain for total
        mock_supabase.table.return_value.select.return_value.execute.return_value = mock_total
        mock_supabase.table.return_value.select.return_value.gte.return_value.execute.return_value = mock_valid
        mock_supabase.table.return_value.select.return_value.gte.return_value.order.return_value.limit.return_value.execute.return_value = mock_popular

        service = CacheService()
        stats = service.get_stats()

        assert "total_entries" in stats
        assert "valid_entries" in stats
        assert "expired_entries" in stats
        assert "popular_searches" in stats

    @patch('services.cache_service.supabase')
    def test_get_stats_error_returns_empty(self, mock_supabase):
        mock_supabase.table.side_effect = Exception("DB Error")

        service = CacheService()
        stats = service.get_stats()

        assert stats["total_entries"] == 0
        assert stats["valid_entries"] == 0
        assert stats["popular_searches"] == []
