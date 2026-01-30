import asyncio
from collections import Counter, defaultdict
from market_analysis import jsearch_service
from market_analysis import groq_extractor
from services.cache_service  import cache_service


class MarketAnalyzer:

    CATEGORY_ORDER = [
        "programming_languages",
        "backend_frameworks",
        "frontend_frameworks",
        "databases",
        "cloud_platforms",
        "devops_tools",
        "ai_ml",
        "api_technologies",
        "testing",
        "version_control",
        "mobile_development",
        "methodologies",
        "security",
        "monitoring_observability",
        "operating_systems",
        "networking",
        "message_queues_streaming",
        "build_tools",
        "ide_editors",
        "project_management",
        "collaboration_tools",
        "certifications",
        "soft_skills",
        "cms_ecommerce",
        "game_development",
        "embedded_iot",
        "blockchain_web3",
        "low_code_no_code",
    ]

    MIN_PERCENTAGE = 20.0
    MAX_PER_CATEGORY = 5

    def __init__(self):
        self.jsearch = jsearch_service
        self.extractor = groq_extractor
        self.cache = cache_service
    
    # Traite les résultats d'extraction pour obtenir skills et catégories
    def _process_skills_results(self, results: list[list[dict]]) -> tuple[list, dict]:
        
        all_skills = []
        skill_categories = {}

        for skills_list in results:
            for skill_info in skills_list:
                skill_name = skill_info["name"]
                category = skill_info["category"]
                all_skills.append(skill_name)
                if skill_name not in skill_categories:
                    skill_categories[skill_name] = category

        return all_skills, skill_categories
    
    # Analyse le marché avec Groq pour l'extraction
    async def analyze_market(
        self,
        query: str,
        city: str,
        province: str,
        top_n: int = 30,
        balanced: bool = True,
        num_pages: int = 3,
    ) -> dict:
        

        location = f"{city}, {province}, Canada"
        # Verifier le cache
        cached = self.cache.get_cache_results(query, city, province)
        if cached:
            return cached
        
        # Récupérer les descriptions des offres (JSearch)
        descriptions = self.jsearch.get_job_descriptions(
            query=query,
            location=location,
            num_pages=num_pages
        )

        total_jobs = len(descriptions)

        if total_jobs == 0:
            return {
                "query": query,
                "location": location,
                "total_jobs_analyzed": 0,
                "top_skills": [],
                "message": "No jobs found for this search"
            }

        # Extraire les skills en parallèle avec Groq
        results = await self.extractor.extract_all_skills(descriptions)
        all_skills, skill_categories = self._process_skills_results(results)

        # Compter et trier
        skill_counts = Counter(all_skills)

        # Construire la liste des top skills
        top_skills = []
        category_counts = defaultdict(int)

        for skill_name, count in skill_counts.most_common():
            category = skill_categories.get(skill_name, "other")
            percentage = round((count / total_jobs) * 100, 1)

            if percentage < self.MIN_PERCENTAGE:
                continue

            if balanced and category_counts[category] >= self.MAX_PER_CATEGORY:
                continue

            top_skills.append({
                "name": skill_name,
                "category": category,
                "count": count,
                "percentage": percentage
            })

            category_counts[category] += 1

            if len(top_skills) >= top_n:
                break

        result = {
            "query": query,
            "location": location,
            "total_jobs_analyzed": total_jobs,
            "top_skills": top_skills
        }

        # Sauvegarder dans le cache
        self.cache.save_to_cache(query, city, province, result, total_jobs)

        return result

    async def get_skills_by_category(
        self,
        query: str,
        city: str,
        province: str,
        num_pages: int = 3,
    ) -> dict:
        """Analyse le marché avec Groq pour l'extraction"""

        location = f"{city}, {province}, Canada"

        # Vérifier le cache
        cached = self.cache.get_cache_results(query, city, province)
        if cached:
            return cached

        descriptions = self.jsearch.get_job_descriptions(
            query=query,
            location=location,
            num_pages=num_pages
        )

        total_jobs = len(descriptions)

        if total_jobs == 0:
            return {
                "query": query,
                "location": location,
                "total_jobs_analyzed": 0,
                "skills_by_category": {},
                "message": "No jobs found for this search"
            }

        # Extraire les skills en parallèle avec Groq
        results = await self.extractor.extract_all_skills(descriptions)
        all_skills, skill_categories = self._process_skills_results(results)

        # Compter les skills
        skill_counts = Counter(all_skills)

        # Grouper par catégorie avec filtres
        by_category = defaultdict(list)
        for skill_name, count in skill_counts.most_common():
            category = skill_categories.get(skill_name, "other")
            percentage = round((count / total_jobs) * 100, 1)

            if percentage >= self.MIN_PERCENTAGE:
                by_category[category].append({
                    "name": skill_name,
                    "count": count,
                    "percentage": percentage
                })

        # Ordonner et limiter
        ordered = {}
        for category in self.CATEGORY_ORDER:
            if category in by_category:
                limited = by_category[category][:self.MAX_PER_CATEGORY]
                if limited:
                    ordered[category] = limited

        result = {
            "query": query,
            "location": location,
            "total_jobs_analyzed": total_jobs,
            "skills_by_category": ordered
        }

        # Sauvegarder dans le cache
        self.cache.save_to_cache(query, city, province, result, total_jobs)

        return result


market_analyzer = MarketAnalyzer()
