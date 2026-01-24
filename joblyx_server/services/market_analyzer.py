from collections import Counter, defaultdict
from services.jsearch_service import jsearch_service
from services.skills_matcher import skills_matcher


class MarketAnalyzer:
    PRIORITY_CATEGORIES = [
        "programming_languages",
        "frontend_frameworks",
        "backend_frameworks",
        "databases",
        "cloud_platforms",
        "devops_tools",
        "testing",
        "ai_ml",
        "mobile_development",
        "methodologies",
    ]

    def __init__(self):
        self.jsearch = jsearch_service
        self.matcher = skills_matcher

    def _distribute_skills_by_category(
        self,
        skill_counts: Counter,
        skill_categories: dict,
        total_jobs: int,
        top_n: int = 25,
        min_per_category: int = 2,
        max_per_category: int = 5
    ) -> list[dict]:
        """
        Distribute top skills across categories to ensure diversity.

        Args:
            skill_counts: Counter of skill occurrences
            skill_categories: Mapping of skill name to category
            total_jobs: Total number of jobs analyzed
            top_n: Total number of skills to return
            min_per_category: Minimum skills per category (if available)
            max_per_category: Maximum skills per category

        Returns:
            List of skill dicts with balanced category representation
        """
        skills_by_cat = defaultdict(list)
        for skill_name, count in skill_counts.most_common():
            category = skill_categories.get(skill_name, "other")
            skills_by_cat[category].append({
                "name": skill_name,
                "count": count,
                "percentage": round((count / total_jobs) * 100, 1),
                "category": category
            })

        selected = []
        used_skills = set()

        for category in self.PRIORITY_CATEGORIES:
            if category in skills_by_cat:
                cat_skills = skills_by_cat[category]
                added = 0
                for skill in cat_skills:
                    if skill["name"] not in used_skills and added < min_per_category:
                        selected.append(skill)
                        used_skills.add(skill["name"])
                        added += 1

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
        num_pages: int = 5,
        balanced: bool = True
    ) -> dict:
        """
        Analyze job market for a specific query and location.

        Args:
            query: Job title (e.g., "Software Developer")
            city: City name (e.g., "Toronto")
            province: Province name (e.g., "Ontario")
            top_n: Number of top skills to return (20-30)
            num_pages: Number of pages to fetch from JSearch
            balanced: If True, distribute skills across categories

        Returns:
            Dictionary with analysis results including top skills
        """
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
        num_pages: int = 5
    ) -> dict:
        """
        Get skills grouped by category.

        Args:
            query: Job title
            city: City name
            province: Province name
            num_pages: Number of pages to fetch

        Returns:
            Dictionary with skills grouped by category
        """
        analysis = self.analyze_market(
            query, city, province,
            top_n=50,
            num_pages=num_pages,
            balanced=False
        )

        if analysis["total_jobs_analyzed"] == 0:
            return analysis

        by_category = {}
        for skill in analysis["top_skills"]:
            category = skill["category"]
            if category not in by_category:
                by_category[category] = []
            by_category[category].append({
                "name": skill["name"],
                "count": skill["count"],
                "percentage": skill["percentage"]
            })

        return {
            "query": analysis["query"],
            "location": analysis["location"],
            "total_jobs_analyzed": analysis["total_jobs_analyzed"],
            "skills_by_category": by_category
        }


market_analyzer = MarketAnalyzer()
