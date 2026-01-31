import pytest
from unittest.mock import patch, MagicMock
from services.user import UserHistory


class TestRecordSearch:

    @patch('services.user.user_history.supabase')
    def test_record_search_success(self, mock_supabase):
        mock_supabase.table.return_value.insert.return_value.execute.return_value = MagicMock()

        history = UserHistory()
        result = history.record_search(
            user_id="user-123",
            query="Python Developer",
            city="Toronto",
            province="Ontario",
            results={"top_skills": []},
            total_jobs=10
        )

        assert result is True
        mock_supabase.table.assert_called_with("user_history")

    @patch('services.user.user_history.supabase')
    def test_record_search_inserts_correct_data(self, mock_supabase):
        mock_supabase.table.return_value.insert.return_value.execute.return_value = MagicMock()

        history = UserHistory()
        history.record_search(
            user_id="user-123",
            query="Java Developer",
            city="Montreal",
            province="Quebec",
            results={"skills": ["Java", "Spring"]},
            total_jobs=25
        )

        call_args = mock_supabase.table.return_value.insert.call_args[0][0]
        assert call_args["user_id"] == "user-123"
        assert call_args["query"] == "Java Developer"
        assert call_args["city"] == "Montreal"
        assert call_args["province"] == "Quebec"
        assert call_args["total_jobs"] == 25

    @patch('services.user.user_history.supabase')
    def test_record_search_error_returns_false(self, mock_supabase):
        mock_supabase.table.return_value.insert.side_effect = Exception("DB Error")

        history = UserHistory()
        result = history.record_search(
            user_id="user-123",
            query="Developer",
            city="Toronto",
            province="Ontario",
            results={},
            total_jobs=5
        )

        assert result is False


class TestGetUserHistory:

    @patch('services.user.user_history.supabase')
    def test_get_history_success(self, mock_supabase):
        mock_result = MagicMock()
        mock_result.data = [
            {"id": "1", "query": "Python", "city": "Toronto"},
            {"id": "2", "query": "Java", "city": "Montreal"}
        ]

        mock_supabase.table.return_value.select.return_value.eq.return_value.order.return_value.limit.return_value.execute.return_value = mock_result

        history = UserHistory()
        result = history.get_user_history("user-123")

        assert len(result) == 2
        assert result[0]["query"] == "Python"

    @patch('services.user.user_history.supabase')
    def test_get_history_empty(self, mock_supabase):
        mock_result = MagicMock()
        mock_result.data = []

        mock_supabase.table.return_value.select.return_value.eq.return_value.order.return_value.limit.return_value.execute.return_value = mock_result

        history = UserHistory()
        result = history.get_user_history("user-123")

        assert result == []

    @patch('services.user.user_history.supabase')
    def test_get_history_error_returns_empty(self, mock_supabase):
        mock_supabase.table.side_effect = Exception("DB Error")

        history = UserHistory()
        result = history.get_user_history("user-123")

        assert result == []


class TestGetSearchById:

    @patch('services.user.user_history.supabase')
    def test_get_search_success(self, mock_supabase):
        mock_result = MagicMock()
        mock_result.data = {
            "id": "search-1",
            "query": "Python Developer",
            "city": "Toronto",
            "results": {"top_skills": []}
        }

        mock_supabase.table.return_value.select.return_value.eq.return_value.eq.return_value.maybe_single.return_value.execute.return_value = mock_result

        history = UserHistory()
        result = history.get_search_by_id("user-123", "search-1")

        assert result is not None
        assert result["id"] == "search-1"

    @patch('services.user.user_history.supabase')
    def test_get_search_not_found(self, mock_supabase):
        mock_result = MagicMock()
        mock_result.data = None

        mock_supabase.table.return_value.select.return_value.eq.return_value.eq.return_value.maybe_single.return_value.execute.return_value = mock_result

        history = UserHistory()
        result = history.get_search_by_id("user-123", "nonexistent")

        assert result is None

    @patch('services.user.user_history.supabase')
    def test_get_search_error_returns_none(self, mock_supabase):
        mock_supabase.table.side_effect = Exception("DB Error")

        history = UserHistory()
        result = history.get_search_by_id("user-123", "search-1")

        assert result is None


class TestDeleteSearchById:

    @patch('services.user.user_history.supabase')
    def test_delete_search_success(self, mock_supabase):
        mock_supabase.table.return_value.delete.return_value.eq.return_value.eq.return_value.execute.return_value = MagicMock()

        history = UserHistory()
        result = history.delete_search_by_id("user-123", "search-1")

        assert result is True

    @patch('services.user.user_history.supabase')
    def test_delete_search_error_returns_false(self, mock_supabase):
        mock_supabase.table.return_value.delete.side_effect = Exception("DB Error")

        history = UserHistory()
        result = history.delete_search_by_id("user-123", "search-1")

        assert result is False


class TestClearUserHistory:

    @patch('services.user.user_history.supabase')
    def test_clear_history_success(self, mock_supabase):
        mock_supabase.table.return_value.delete.return_value.eq.return_value.execute.return_value = MagicMock()

        history = UserHistory()
        result = history.clear_user_history("user-123")

        assert result is True

    @patch('services.user.user_history.supabase')
    def test_clear_history_error_returns_false(self, mock_supabase):
        mock_supabase.table.return_value.delete.side_effect = Exception("DB Error")

        history = UserHistory()
        result = history.clear_user_history("user-123")

        assert result is False
