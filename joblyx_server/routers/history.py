from fastapi import APIRouter, Depends, HTTPException
from services.auth import get_user_id_from_token
from services.user import user_history_service

router = APIRouter(prefix="/history", tags=["User History"])

# Récupère les 10 dernières recherches de l'utilisateur
@router.get("")
async def get_history(user_id: str = Depends(get_user_id_from_token)):
    history = user_history_service.get_user_history(user_id)
    return {"history": history, "count": len(history)}

# Récupère une recherche spécifique
@router.get("/{search_id}")
async def get_search(search_id: str, user_id: str = Depends(get_user_id_from_token)):
   
    search = user_history_service.get_search_by_id(user_id, search_id)

    if not search:
        raise HTTPException(status_code=404, detail="Search not found")

    return search

#Supprime une recherche spécifique
@router.delete("/{search_id}")
async def delete_search(search_id: str, user_id: str = Depends(get_user_id_from_token)):
    success = user_history_service.delete_search_by_id(user_id, search_id)

    if not success:
        raise HTTPException(status_code=500, detail="Failed to delete search")

    return {"message": "Search deleted"}

#Supprime tout l'historique de l'utilisateur
@router.delete("")
async def clear_history(user_id: str = Depends(get_user_id_from_token)):
    success = user_history_service.clear_user_history(user_id)

    if not success:
        raise HTTPException(status_code=500, detail="Failed to clear history")

    return {"message": "History cleared"}
