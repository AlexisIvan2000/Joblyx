from datetime import datetime
from config import supabase

class CacheService:
    #Récupère les résultats du cache
    def get_cache_results(self, query: str, city: str, province: str) -> dict | None:

        try:
            result = supabase.table("search_cache") \
                .select("id, results") \
                .ilike("query", query) \
                .ilike("city", city) \
                .ilike("province", province) \
                .gte("expires_at", datetime.now().isoformat()) \
                .limit(1) \
                .execute()

            if result and result.data and len(result.data) > 0:
                cache_entry = result.data[0]
                # Déclencher le trigger pour incrémenter hit_count et refresh TTL
                supabase.table("search_cache") \
                    .update({"total_jobs": cache_entry["results"].get("total_jobs_analyzed", 0)}) \
                    .eq("id", cache_entry["id"]) \
                    .execute()

                print(f"Cache hit: {query} - {city} ({province})")
                return cache_entry["results"]

            print(f"Cache miss: {query} - {city} ({province})")
            return None

        except Exception as e:
            print(f"Error lecture cache: {e}")
            return None
        
    #Sauvegarde les résultats dans le cache
    def save_to_cache(self, query: str, city: str, province: str, results: dict, total_jobs: int) -> bool:

        try:
            query_lower = query.lower()
            city_lower = city.lower()
            province_lower = province.lower()

            # Vérifier si existe déjà
            existing = supabase.table("search_cache") \
                .select("id") \
                .ilike("query", query_lower) \
                .ilike("city", city_lower) \
                .ilike("province", province_lower) \
                .limit(1) \
                .execute()

            if existing and existing.data and len(existing.data) > 0:
                # UPDATE
                supabase.table("search_cache") \
                    .update({
                        "results": results,
                        "total_jobs": total_jobs,
                    }) \
                    .eq("id", existing.data[0]["id"]) \
                    .execute()
            else:
                # INSERT
                supabase.table("search_cache").insert({
                    "query": query_lower,
                    "city": city_lower,
                    "province": province_lower,
                    "results": results,
                    "total_jobs": total_jobs,
                }).execute()

            print(f"Cache saved: {query} - {city} ({province})")
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