import pytest
from unittest.mock import patch, MagicMock
from services.user import UserQuota


class TestCanUserSearch:

    @patch('services.user.user_quota.supabase')
    def test_can_search_returns_true(self, mock_supabase):
        mock_result = MagicMock()
        mock_result.data = True

        mock_supabase.rpc.return_value.execute.return_value = mock_result

        quota = UserQuota()
        result = quota.can_user_search("user-123")

        assert result is True
        mock_supabase.rpc.assert_called_with(
            "check_user_search_quota",
            {"user_uuid": "user-123"}
        )

    @patch('services.user.user_quota.supabase')
    def test_can_search_returns_false_when_limit_reached(self, mock_supabase):
        mock_result = MagicMock()
        mock_result.data = False

        mock_supabase.rpc.return_value.execute.return_value = mock_result

        quota = UserQuota()
        result = quota.can_user_search("user-123")

        assert result is False

    @patch('services.user.user_quota.supabase')
    def test_can_search_returns_true_on_error(self, mock_supabase):
        mock_supabase.rpc.side_effect = Exception("DB Error")

        quota = UserQuota()
        result = quota.can_user_search("user-123")

        # Permet la recherche en cas d'erreur
        assert result is True


class TestGetStats:

    @patch('services.user.user_quota.supabase')
    def test_get_stats_success(self, mock_supabase):
        mock_result = MagicMock()
        mock_result.data = {
            "can_search": True,
            "searches_used": 3,
            "searches_remaining": 2,
            "max_searches": 5
        }

        mock_supabase.rpc.return_value.execute.return_value = mock_result

        quota = UserQuota()
        stats = quota.get_stats("user-123")

        assert stats["can_search"] is True
        assert stats["searches_used"] == 3
        assert stats["searches_remaining"] == 2
        mock_supabase.rpc.assert_called_with(
            "get_user_quota_stats",
            {"user_uuid": "user-123"}
        )

    @patch('services.user.user_quota.supabase')
    def test_get_stats_error_returns_default(self, mock_supabase):
        mock_supabase.rpc.side_effect = Exception("DB Error")

        quota = UserQuota()
        stats = quota.get_stats("user-123")

        assert stats["can_search"] is True
        assert stats["searches_used"] == 0
        assert stats["searches_remaining"] == 5
        assert stats["max_searches"] == 5


class TestRecordSearch:

    @patch('services.user.user_quota.supabase')
    def test_record_search_success(self, mock_supabase):
        mock_supabase.table.return_value.insert.return_value.execute.return_value = MagicMock()

        quota = UserQuota()
        result = quota.record_search("user-123")

        assert result is True
        mock_supabase.table.assert_called_with("search_usage")

    @patch('services.user.user_quota.supabase')
    def test_record_search_inserts_user_id(self, mock_supabase):
        mock_supabase.table.return_value.insert.return_value.execute.return_value = MagicMock()

        quota = UserQuota()
        quota.record_search("user-456")

        call_args = mock_supabase.table.return_value.insert.call_args[0][0]
        assert call_args["user_id"] == "user-456"

    @patch('services.user.user_quota.supabase')
    def test_record_search_error_returns_false(self, mock_supabase):
        mock_supabase.table.return_value.insert.side_effect = Exception("DB Error")

        quota = UserQuota()
        result = quota.record_search("user-123")

        assert result is False
