from collections import Counter, defaultdict
from services.jsearch_service import jsearch_service
from services.skills_matcher import skills_matcher


class MarketAnalyzer:
    # Catégories haute priorité → Seuil bas (garder plus de skills)
    HIGH_PRIORITY_CATEGORIES = [
        "programming_languages",
        "backend_frameworks",
        "frontend_frameworks",
        "databases",
        "cloud_platforms",
        "devops_tools",
    ]

    # Catégories normales → Seuil moyen
    NORMAL_CATEGORIES = [
        "ai_ml",
        "api_technologies",
        "testing",
        "version_control",
        "mobile_development",
        "methodologies",
        "security",
    ]

    # Catégories basse priorité → Seuil haut (filtrer le bruit)
    LOW_PRIORITY_CATEGORIES = [
        "soft_skills",
        "certifications",
        "operating_systems",
        "collaboration_tools",
        "project_management",
        "monitoring_observability",
        "build_tools",
        "ide_editors",
        "low_code_no_code",
        "blockchain_web3",
        "game_development",
        "embedded_iot",
        "cms_ecommerce",
    ]

    # Ordre d'affichage des catégories
    CATEGORY_ORDER = (
        HIGH_PRIORITY_CATEGORIES +
        NORMAL_CATEGORIES +
        LOW_PRIORITY_CATEGORIES
    )

    def __init__(self):
        self.jsearch = jsearch_service
        self.matcher = skills_matcher

    def _get_min_percentage(self, total_jobs: int, category: str) -> float:
        # Seuil dynamique selon le volume d'offres ET la catégorie
        if total_jobs < 15:
            base_high = 15.0
            base_normal = 20.0
            base_low = 30.0
        elif total_jobs < 30:
            base_high = 10.0
            base_normal = 15.0
            base_low = 25.0
        elif total_jobs < 50:
            base_high = 8.0
            base_normal = 12.0
            base_low = 20.0
        else:
            base_high = 5.0
            base_normal = 10.0
            base_low = 15.0

        # Appliquer selon la catégorie
        if category in self.HIGH_PRIORITY_CATEGORIES:
            return base_high
        elif category in self.NORMAL_CATEGORIES:
            return base_normal
        else:
            return base_low

    def _distribute_skills_by_category(
        self,
        skill_counts: Counter,
        skill_categories: dict,
        total_jobs: int,
        top_n: int = 25,
        min_per_category: int = 1,
        max_per_category: int = 5
    ) -> list[dict]:
        skills_by_cat = defaultdict(list)
        for skill_name, count in skill_counts.most_common():
            category = skill_categories.get(skill_name, "other")
            percentage = round((count / total_jobs) * 100, 1)

            # Seuil dynamique selon la catégorie
            min_percentage = self._get_min_percentage(total_jobs, category)

            # Filtrer les skills en dessous du seuil de pourcentage
            if percentage >= min_percentage:
                skills_by_cat[category].append({
                    "name": skill_name,
                    "count": count,
                    "percentage": percentage,
                    "category": category
                })

        selected = []
        used_skills = set()

        # Phase 1: Garantir min_per_category pour chaque catégorie prioritaire
        for category in self.CATEGORY_ORDER:
            if category in skills_by_cat:
                cat_skills = skills_by_cat[category]
                added = 0
                for skill in cat_skills:
                    if skill["name"] not in used_skills and added < min_per_category:
                        selected.append(skill)
                        used_skills.add(skill["name"])
                        added += 1

        # Phase 2: Remplir les slots restants en respectant max_per_category
        remaining_slots = top_n - len(selected)
        if remaining_slots > 0:
            all_remaining = []
            for category, skills in skills_by_cat.items():
                cat_count = sum(1 for s in selected if s["category"] == category)
                for skill in skills:
                    if skill["name"] not in used_skills:
                        if cat_count < max_per_category:
                            all_remaining.append(skill)

            all_remaining.sort(key=lambda x: x["count"], reverse=True)

            for skill in all_remaining:
                if len(selected) >= top_n:
                    break
                cat_count = sum(1 for s in selected if s["category"] == skill["category"])
                if cat_count < max_per_category:
                    selected.append(skill)
                    used_skills.add(skill["name"])

        selected.sort(key=lambda x: x["count"], reverse=True)

        return selected[:top_n]

    def analyze_market(
        self,
        query: str,
        city: str,
        province: str,
        top_n: int = 25,
        num_pages: int = 3,
        balanced: bool = True
    ) -> dict:
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

        all_skills = []
        skill_categories = {}

        for description in descriptions:
            skills_with_category = self.matcher.extract_skills_with_category(description)

            for skill_info in skills_with_category:
                skill_name = skill_info["name"]
                category = skill_info["category"]
                all_skills.append(skill_name)

                if skill_name not in skill_categories:
                    skill_categories[skill_name] = category

        skill_counts = Counter(all_skills)

        if balanced:
            top_skills = self._distribute_skills_by_category(
                skill_counts,
                skill_categories,
                total_jobs,
                top_n
            )
        else:
            top_skills = []
            for skill_name, count in skill_counts.most_common(top_n):
                percentage = round((count / total_jobs) * 100, 1)
                top_skills.append({
                    "name": skill_name,
                    "count": count,
                    "percentage": percentage,
                    "category": skill_categories.get(skill_name, "unknown")
                })

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
        max_per_category: int = 5
    ) -> dict:
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

        # Extraire tous les skills
        all_skills = []
        skill_categories = {}

        for description in descriptions:
            skills_with_category = self.matcher.extract_skills_with_category(description)
            for skill_info in skills_with_category:
                skill_name = skill_info["name"]
                category = skill_info["category"]
                all_skills.append(skill_name)
                if skill_name not in skill_categories:
                    skill_categories[skill_name] = category

        # Compter les skills
        skill_counts = Counter(all_skills)

        # Grouper par catégorie
        by_category = defaultdict(list)
        for skill_name, count in skill_counts.most_common():
            category = skill_categories.get(skill_name, "other")
            percentage = round((count / total_jobs) * 100, 1)

            # Appliquer le seuil dynamique
            min_percentage = self._get_min_percentage(total_jobs, category)

            if percentage >= min_percentage:
                by_category[category].append({
                    "name": skill_name,
                    "count": count,
                    "percentage": percentage
                })

        # Ordonner les catégories et limiter les skills
        ordered = {}
        for category in self.CATEGORY_ORDER:
            if category in by_category:
                # Limiter à max_per_category
                limited = by_category[category][:max_per_category]
                if limited:
                    ordered[category] = limited

        # Ajouter les catégories non listées dans CATEGORY_ORDER
        for category in by_category:
            if category not in ordered:
                limited = by_category[category][:max_per_category]
                if limited:
                    ordered[category] = limited

        return {
            "query": query,
            "location": location,
            "total_jobs_analyzed": total_jobs,
            "skills_by_category": ordered
        }


market_analyzer = MarketAnalyzer()
