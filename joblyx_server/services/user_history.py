from config import supabase

class UserHistory:
    # Enregistre une recherche (trigger SQL limite a 10 automatiquement)
    def record_search(self, user_id: str, query: str, city: str, province: str, results: dict, total_jobs: int) -> bool:
        try:
            supabase.table("user_history").insert(
                {
                    "user_id": user_id,
                    "query": query,
                    "city": city,
                    "province": province,
                    "results": results,
                    "total_jobs": total_jobs
                }
            ).execute()
            print (f"Search recorder for: {query} - {city} ({province})")
            return True
        
        except Exception as e:
            print(f"Error recording search: {e}")
            return False
        
    # Récupère l'historique des 10 recherches les plus récentes
    def get_user_history(self, user_id: str) -> list:
        try:
            result =  supabase.table("user_history")\
                    .select("*")\
                    .eq("user_id", user_id)\
                    .order("created_at", desc=True)\
                    .limit(10)\
                    .execute()
            
            return result.data or []
        
        except Exception as e:
            print(f"Error fetching user history: {e}")
            return []
        
    # Récupère une recherche spécifique
    def get_search_by_id(self, user_id: str, search_id: str) -> dict | None:
        try:
            result = supabase.table("user_history")\
                    .select("*")\
                    .eq("user_id", user_id)\
                    .eq("id", search_id)\
                    .maybe_single()\
                    .execute()
            return result.data
        
        except Exception as e:
            print(f"Error fetching search by id: {e}")
            return None
        
    # Supprime une recherche spécifique
    def delete_search_by_id(self, user_id:str, search_id: str) -> bool:
        try:
            supabase.table("user_history")\
                .delete()\
                .eq("user_id", user_id)\
                .eq("id", search_id)\
                .execute()
            
            print(f"Search deleted: {search_id} for user {user_id}")
            return True
        

        except Exception as e:
            print(f"Error deleting search by id: {e}")
            return False
        

    # Supprime tout l'historique d'un utilisateur
    def clear_user_history(self, user_id: str) -> bool:
        try:
            supabase.table("user_history")\
                .delete()\
                .eq("user_id", user_id)\
                .execute()
            
            print(f"User history cleared for user: {user_id}")
            return True
        

        except Exception as e:
            print(f"Error clearing user history: {e}")
            return False
        


user_history_service = UserHistory()