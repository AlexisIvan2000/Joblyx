from fastapi import APIRouter
from services.cache_service import cache_service

router = APIRouter(prefix="/cache", tags=["Cache"])

# Retourne les statistiques du cache
@router.get("/stats")
async def get_cache_stats():
    return cache_service.get_stats()

# Nettoie les entrées expirées du cache
@router.post("/cleanup")
async def cleanup_cache():
    deleted = cache_service.clear_expired()
    return {"deleted_entries": deleted}
