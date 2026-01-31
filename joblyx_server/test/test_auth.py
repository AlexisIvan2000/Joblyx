import pytest
from unittest.mock import patch, MagicMock
from fastapi import HTTPException
from services.auth import get_user_id_from_token


class TestGetUserIdFromToken:

    @pytest.mark.asyncio
    @patch('services.auth.get_user.supabase')
    async def test_valid_token_returns_user_id(self, mock_supabase):
        mock_user = MagicMock()
        mock_user.user.id = "user-123-abc"
        mock_supabase.auth.get_user.return_value = mock_user

        result = await get_user_id_from_token("Bearer valid-token-here")

        assert result == "user-123-abc"
        mock_supabase.auth.get_user.assert_called_with("valid-token-here")

    @pytest.mark.asyncio
    @patch('services.auth.get_user.supabase')
    async def test_token_without_bearer_prefix(self, mock_supabase):
        mock_user = MagicMock()
        mock_user.user.id = "user-456"
        mock_supabase.auth.get_user.return_value = mock_user

        result = await get_user_id_from_token("raw-token")

        assert result == "user-456"
        mock_supabase.auth.get_user.assert_called_with("raw-token")

    @pytest.mark.asyncio
    async def test_missing_authorization_raises_401(self):
        with pytest.raises(HTTPException) as exc_info:
            await get_user_id_from_token(None)

        assert exc_info.value.status_code == 401
        assert "Authorization header missing" in exc_info.value.detail

    @pytest.mark.asyncio
    async def test_empty_token_raises_401(self):
        with pytest.raises(HTTPException) as exc_info:
            await get_user_id_from_token("Bearer ")

        assert exc_info.value.status_code == 401
        assert "Invalid token format" in exc_info.value.detail

    @pytest.mark.asyncio
    @patch('services.auth.get_user.supabase')
    async def test_invalid_token_raises_401(self, mock_supabase):
        mock_supabase.auth.get_user.return_value = None

        with pytest.raises(HTTPException) as exc_info:
            await get_user_id_from_token("Bearer invalid-token")

        assert exc_info.value.status_code == 401

    @pytest.mark.asyncio
    @patch('services.auth.get_user.supabase')
    async def test_user_without_user_object_raises_401(self, mock_supabase):
        mock_result = MagicMock()
        mock_result.user = None
        mock_supabase.auth.get_user.return_value = mock_result

        with pytest.raises(HTTPException) as exc_info:
            await get_user_id_from_token("Bearer some-token")

        assert exc_info.value.status_code == 401
        # Le message peut être "User not authenticated" ou "Authentication failed"
        assert exc_info.value.status_code == 401

    @pytest.mark.asyncio
    @patch('services.auth.get_user.supabase')
    async def test_supabase_error_raises_401(self, mock_supabase):
        mock_supabase.auth.get_user.side_effect = Exception("Supabase Error")

        with pytest.raises(HTTPException) as exc_info:
            await get_user_id_from_token("Bearer some-token")

        assert exc_info.value.status_code == 401
        assert "Authentication failed" in exc_info.value.detail
