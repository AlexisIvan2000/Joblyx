from fastapi import APIRouter
from services.cache_service import cache_service

router = APIRouter(prefix="/cache", tags=["Cache"])


@router.get("/stats")
async def get_cache_stats():
    """Retourne les statistiques du cache"""
    return cache_service.get_stats()


@router.post("/cleanup")
async def cleanup_cache():
    """Nettoie les entrées expirées du cache"""
    deleted = cache_service.clear_expired()
    return {"deleted_entries": deleted}
