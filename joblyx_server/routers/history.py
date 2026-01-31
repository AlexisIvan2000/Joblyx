from fastapi import APIRouter, Depends, HTTPException
from services.auth import get_user_id_from_token
from services.user_history import user_history_service

router = APIRouter(prefix="/history", tags=["User History"])


@router.get("")
async def get_history(user_id: str = Depends(get_user_id_from_token)):
    """Récupère les 10 dernières recherches de l'utilisateur"""
    history = user_history_service.get_user_history(user_id)
    return {"history": history, "count": len(history)}


@router.get("/{search_id}")
async def get_search(search_id: str, user_id: str = Depends(get_user_id_from_token)):
    """Récupère une recherche spécifique"""
    search = user_history_service.get_search_by_id(user_id, search_id)

    if not search:
        raise HTTPException(status_code=404, detail="Search not found")

    return search


@router.delete("/{search_id}")
async def delete_search(search_id: str, user_id: str = Depends(get_user_id_from_token)):
    """Supprime une recherche spécifique"""
    success = user_history_service.delete_search_by_id(user_id, search_id)

    if not success:
        raise HTTPException(status_code=500, detail="Failed to delete search")

    return {"message": "Search deleted"}


@router.delete("")
async def clear_history(user_id: str = Depends(get_user_id_from_token)):
    """Supprime tout l'historique de l'utilisateur"""
    success = user_history_service.clear_user_history(user_id)

    if not success:
        raise HTTPException(status_code=500, detail="Failed to clear history")

    return {"message": "History cleared"}
