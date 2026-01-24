from collections import Counter
from services.jsearch_service import jsearch_service
from services.skills_matcher import skills_matcher


class MarketAnalyzer:
    def __init__(self):
        self.jsearch = jsearch_service
        self.matcher = skills_matcher

    def analyze_market(
        self,
        query: str,
        city: str,
        province: str,
        top_n: int = 25,
        num_pages: int = 5
    ) -> dict:
        """
        Analyze job market for a specific query and location.

        Args:
            query: Job title (e.g., "Software Developer")
            city: City name (e.g., "Toronto")
            province: Province name (e.g., "Ontario")
            top_n: Number of top skills to return (20-30)
            num_pages: Number of pages to fetch from JSearch

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
        analysis = self.analyze_market(query, city, province, top_n=50, num_pages=num_pages)

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
