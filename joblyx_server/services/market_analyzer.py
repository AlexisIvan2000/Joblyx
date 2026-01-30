from collections import Counter, defaultdict
from services.jsearch_service import jsearch_service
from services.groq_service import groq_extractor


class MarketAnalyzer:

    CATEGORY_ORDER = [
        "programming_languages",
        "backend_frameworks",
        "frontend_frameworks",
        "databases",
        "cloud_platforms",
        "devops_tools",
        "ai_ml",
        "methodologies",
        "testing",
        "version_control",
    ]

    MIN_PERCENTAGE = 20
    .0
    MAX_PER_CATEGORY = 5

    def __init__(self):
        self.jsearch = jsearch_service
        self.extractor = groq_extractor

    def analyze_market(
        self,
        query: str,
        city: str,
        province: str,
        top_n: int = 25,
        balanced: bool = True,
        num_pages: int = 3,
    ) -> dict:
        """Analyse le marché et retourne les top skills"""

        location = f"{city}, {province}, Canada"

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

        # Extraire les skills avec gestion d'erreur par description
        all_skills = []
        skill_categories = {}

        for description in descriptions:
            try:
                skills = self.extractor.extract_skills_list(description)
                for skill_info in skills:
                    skill_name = skill_info["name"]
                    category = skill_info["category"]
                    all_skills.append(skill_name)
                    if skill_name not in skill_categories:
                        skill_categories[skill_name] = category
            except Exception as e:
                print(f"Erreur extraction skills: {e}")
                continue

        # Compter et trier
        skill_counts = Counter(all_skills)

        # Construire la liste des top skills
        top_skills = []
        category_counts = defaultdict(int)

        for skill_name, count in skill_counts.most_common():
            category = skill_categories.get(skill_name, "other")
            percentage = round((count / total_jobs) * 100, 1)

            # Filtre minimum
            if percentage < self.MIN_PERCENTAGE:
                continue

            # Si balanced, limiter par catégorie
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

        return {
            "query": query,
            "location": location,
            "total_jobs_analyzed": total_jobs,
            "top_skills": top_skills
        }  
    def get_skills_by_category(
        self,
        query: str,
        city: str,
        province: str,
        num_pages: int = 3,
    ) -> dict:
        """Analyse le marché avec Groq pour l'extraction"""
        
        location = f"{city}, {province}, Canada"

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

        # Extraire les skills avec Groq (gestion d'erreur par description)
        all_skills = []
        skill_categories = {}

        for description in descriptions:
            try:
                skills = self.extractor.extract_skills_list(description)
                for skill_info in skills:
                    skill_name = skill_info["name"]
                    category = skill_info["category"]
                    all_skills.append(skill_name)
                    if skill_name not in skill_categories:
                        skill_categories[skill_name] = category
            except Exception as e:
                print(f"Erreur extraction skills: {e}")
                continue

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

        return {
            "query": query,
            "location": location,
            "total_jobs_analyzed": total_jobs,
            "skills_by_category": ordered
        }


market_analyzer = MarketAnalyzer()