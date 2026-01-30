from datetime import datetime
from config import supabase

class CacheService:
    #Récupère les résultats du cache
    def get_cache_results(self, query: str, city: str, province: str) -> dict | None:

        try:
            result = supabase.table("search_cache") \
                .select("results") \
                .ilike("query", query) \
                .ilike("city", city) \
                .ilike("province", province) \
                .gte("expires_at", datetime.now().isoformat()) \
                .maybe_single() \
                .execute()
            
            if result.data:
                print(f"Cache hit: {query} - {city} ({province})")
                return result.data["results"]
            
            print(f"Cache miss: {query} - {city} ({province})")
            return None
        
        except Exception as e:
            print(f"Error lecture cache: {e}")
            return None
        
    #Sauvegarde les résultats dans le cache
    def save_to_cache(self, query: str, city: str, province: str, results: dict, total_jobs: int) -> bool:

        try:
            supabase.table("search_cache").upsert(
                {
                    "query": query.lower(),
                    "city": city.lower(),
                    "province": province.lower(),
                    "results": results,
                    "total_jobs": total_jobs,
                },
                 on_conflict="query,city,province"
            ).execute()
            print(f"Cache saved: {query}- {city} ({province})")
            return True
        
        except Exception as e:
            print(f"Error saving to cache: {e}")
            return False
        
    # Appelle la fonction SQL de nettoyage
    def clear_expired(self) -> int:
        
        try:
            result = supabase.rpc("cleanup_expired_cache").execute()
            count = result.data or 0
            print(f"Expired cache entries cleared: {count}")
            return count
        
        except Exception as e:
            print(f"Error clearing expired cache: {e}")
            return 0

    
    #Statistiques du cache
    def get_stats(self) -> dict:
        try:
            # Nombre total d'entrées
            total = supabase.table("search_cache") \
                   .select("id", count="exact") \
                   .execute()
            
            # Nombre d'entrées non expirées
            valid = supabase.table("search_cache") \
                    .select("id", count="exact") \
                    .gte("expires_at", datetime.now().isoformat()) \
                    .execute()
            
            # Top recherches populaires
            popular = supabase.table("search_cache") \
                      .select("query, city, province, hit_count, total_jobs") \
                      .gte("expires_at", datetime.now().isoformat()) \
                      .order("hit_count", desc=True) \
                      .limit(10) \
                      .execute()
            
            return {
                "total_entries": total.count or 0,
                "valid_entries": valid.count or 0,
                "expired_entries": (total.count or 0) - (valid.count or 0),
                "popular_searches": popular.data or []
            }
        
        except Exception as e:
            print(f"Error getting cache stats: {e}")
            return {
                "total_entries": 0,
                "valid_entries": 0,
                "expired_entries": 0,
                "popular_searches": []
            }
        
cache_service = CacheService()