from fastapi import Header, HTTPException
from config import supabase

# Récupère l'ID utilisateur à partir du token d'autorisation
async def get_user_id_from_token(authorization: str = Header(None))-> str:
    if not authorization:
        raise HTTPException(status_code=401, detail="Authorization header missing")
    
    token = authorization.replace("Bearer ", "").strip()
    if not token:
        raise HTTPException(status_code=401, detail="Invalid token format")
    
    try:
        user = supabase.auth.get_user(token)

        if not user or not user.user:
            raise HTTPException(status_code=401, detail="User not authenticated")
        
        return user.user.id
    
    except Exception as e:
        print(f"Error fetching user from token: {e}")
        raise HTTPException(status_code=401, detail="Authentication failed")