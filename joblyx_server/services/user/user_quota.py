from config import supabase

class UserQuota:
     
    # Vérifie si l'utilisateur peut chercher en fonction de son quota
    def can_user_search(self, user_id: str) -> bool:

        try:
            result = supabase.rpc(
                "check_user_search_quota",
                {"user_uuid": user_id}
            ).execute()

            return result.data or False
        
        except Exception as e:
            print(f"Quota check error: {e}")
            return True # Permettre la recherche en cas d'erreur
        
    # Statistique du quota utilisateur
    def get_stats(self, user_id: str)-> dict:
        try:
            result = supabase.rpc(
                "get_user_quota_stats",
                {"user_uuid": user_id}
            ).execute()

            return result.data
        
        except Exception as e:
            print(f"Error fetching quota stats: {e}")
            return {
                "can_search": True,
                "searches_used": 0,
                "searches_remaining": 5,
                "max_searches": 5
            }
        
    # Enregistre une recherche utilisateur
    def record_search(self, user_id: str) -> bool:
        try:
            supabase.table("search_usage").insert(
                {"user_id": user_id}
            ).execute()
            return True
        
        except Exception as e:
            print(f"Error recording user search: {e}")
            return False
        
user_quota = UserQuota()