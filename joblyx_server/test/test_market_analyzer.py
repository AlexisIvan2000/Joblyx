import pytest
from unittest.mock import Mock, patch
from collections import Counter
from services.market_analyzer import MarketAnalyzer, market_analyzer


class TestMarketAnalyzer:

    def test_instance_created(self):
        assert market_analyzer is not None
        assert isinstance(market_analyzer, MarketAnalyzer)

    def test_has_jsearch_service(self):
        assert market_analyzer.jsearch is not None

    def test_has_skills_matcher(self):
        assert market_analyzer.matcher is not None


class TestCategoryConfiguration:

    def test_high_priority_categories_defined(self):
        assert len(MarketAnalyzer.HIGH_PRIORITY_CATEGORIES) > 0
        assert "programming_languages" in MarketAnalyzer.HIGH_PRIORITY_CATEGORIES
        assert "databases" in MarketAnalyzer.HIGH_PRIORITY_CATEGORIES

    def test_normal_categories_defined(self):
        assert len(MarketAnalyzer.NORMAL_CATEGORIES) > 0
        assert "testing" in MarketAnalyzer.NORMAL_CATEGORIES

    def test_low_priority_categories_defined(self):
        assert len(MarketAnalyzer.LOW_PRIORITY_CATEGORIES) > 0
        assert "soft_skills" in MarketAnalyzer.LOW_PRIORITY_CATEGORIES

    def test_category_order_complete(self):
        total = (
            len(MarketAnalyzer.HIGH_PRIORITY_CATEGORIES) +
            len(MarketAnalyzer.NORMAL_CATEGORIES) +
            len(MarketAnalyzer.LOW_PRIORITY_CATEGORIES)
        )
        assert len(MarketAnalyzer.CATEGORY_ORDER) == total


class TestMinPercentage:

    def test_small_volume_thresholds(self):
        analyzer = MarketAnalyzer()

        high_pct = analyzer._get_min_percentage(10, "programming_languages")
        normal_pct = analyzer._get_min_percentage(10, "testing")
        low_pct = analyzer._get_min_percentage(10, "soft_skills")

        assert high_pct == 15.0
        assert normal_pct == 20.0
        assert low_pct == 30.0

    def test_medium_volume_thresholds(self):
        analyzer = MarketAnalyzer()

        high_pct = analyzer._get_min_percentage(25, "programming_languages")
        assert high_pct == 10.0

    def test_large_volume_thresholds(self):
        analyzer = MarketAnalyzer()

        high_pct = analyzer._get_min_percentage(60, "programming_languages")
        normal_pct = analyzer._get_min_percentage(60, "testing")
        low_pct = analyzer._get_min_percentage(60, "soft_skills")

        assert high_pct == 5.0
        assert normal_pct == 10.0
        assert low_pct == 15.0

    def test_unknown_category_uses_low_threshold(self):
        analyzer = MarketAnalyzer()

        pct = analyzer._get_min_percentage(60, "unknown_category")
        assert pct == 15.0


class TestAnalyzeMarket:

    @patch('services.market_analyzer.jsearch_service')
    def test_no_jobs_found(self, mock_jsearch):
        mock_jsearch.get_job_descriptions.return_value = []

        analyzer = MarketAnalyzer()

        result = analyzer.analyze_market("Developer", "Toronto", "Ontario")

        assert result["total_jobs_analyzed"] == 0
        assert result["top_skills"] == []
        assert "message" in result

    @patch('services.market_analyzer.skills_matcher')
    @patch('services.market_analyzer.jsearch_service')
    def test_analyze_returns_structure(self, mock_jsearch, mock_matcher):
        mock_jsearch.get_job_descriptions.return_value = [
            "Python and React developer needed."
        ]
        mock_matcher.extract_skills_with_category.return_value = [
            {"name": "Python", "category": "programming_languages"},
            {"name": "React", "category": "frontend_frameworks"}
        ]

        analyzer = MarketAnalyzer()

        result = analyzer.analyze_market("Developer", "Toronto", "Ontario")

        assert "query" in result
        assert "location" in result
        assert "total_jobs_analyzed" in result
        assert "top_skills" in result
        assert result["location"] == "Toronto, Ontario, Canada"

    @patch('services.market_analyzer.skills_matcher')
    @patch('services.market_analyzer.jsearch_service')
    def test_skill_counting(self, mock_jsearch, mock_matcher):
        mock_jsearch.get_job_descriptions.return_value = [
            "Job 1", "Job 2", "Job 3"
        ]
        mock_matcher.extract_skills_with_category.side_effect = [
            [{"name": "Python", "category": "programming_languages"}],
            [{"name": "Python", "category": "programming_languages"},
             {"name": "Java", "category": "programming_languages"}],
            [{"name": "Python", "category": "programming_languages"}]
        ]

        analyzer = MarketAnalyzer()

        result = analyzer.analyze_market("Developer", "Toronto", "Ontario", balanced=False)

        # Python apparaît dans les 3 jobs
        python_skill = next((s for s in result["top_skills"] if s["name"] == "Python"), None)
        assert python_skill is not None
        assert python_skill["count"] == 3
        assert python_skill["percentage"] == 100.0


class TestGetSkillsByCategory:

    @patch('services.market_analyzer.jsearch_service')
    def test_no_jobs_found(self, mock_jsearch):
        mock_jsearch.get_job_descriptions.return_value = []

        analyzer = MarketAnalyzer()

        result = analyzer.get_skills_by_category("Developer", "Toronto", "Ontario")

        assert result["total_jobs_analyzed"] == 0
        assert result["skills_by_category"] == {}

    @patch('services.market_analyzer.skills_matcher')
    @patch('services.market_analyzer.jsearch_service')
    def test_groups_by_category(self, mock_jsearch, mock_matcher):
        mock_jsearch.get_job_descriptions.return_value = ["Job description"]
        mock_matcher.extract_skills_with_category.return_value = [
            {"name": "Python", "category": "programming_languages"},
            {"name": "JavaScript", "category": "programming_languages"},
            {"name": "React", "category": "frontend_frameworks"},
            {"name": "PostgreSQL", "category": "databases"}
        ]

        analyzer = MarketAnalyzer()

        result = analyzer.get_skills_by_category("Developer", "Toronto", "Ontario")

        assert "skills_by_category" in result
        categories = result["skills_by_category"]
        assert len(categories) > 0


class TestDistributeSkillsByCategory:

    def test_respects_top_n(self):
        analyzer = MarketAnalyzer()

        skill_counts = Counter({
            "Python": 10, "Java": 9, "JavaScript": 8,
            "React": 7, "Angular": 6, "Vue.js": 5,
            "PostgreSQL": 4, "MongoDB": 3, "Redis": 2
        })
        skill_categories = {
            "Python": "programming_languages",
            "Java": "programming_languages",
            "JavaScript": "programming_languages",
            "React": "frontend_frameworks",
            "Angular": "frontend_frameworks",
            "Vue.js": "frontend_frameworks",
            "PostgreSQL": "databases",
            "MongoDB": "databases",
            "Redis": "databases"
        }

        result = analyzer._distribute_skills_by_category(
            skill_counts, skill_categories,
            total_jobs=10, top_n=5
        )

        assert len(result) <= 5

    def test_sorted_by_count(self):
        analyzer = MarketAnalyzer()

        skill_counts = Counter({"Python": 10, "Java": 5, "Go": 3})
        skill_categories = {
            "Python": "programming_languages",
            "Java": "programming_languages",
            "Go": "programming_languages"
        }

        result = analyzer._distribute_skills_by_category(
            skill_counts, skill_categories,
            total_jobs=10, top_n=10
        )

        if len(result) > 1:
            for i in range(len(result) - 1):
                assert result[i]["count"] >= result[i + 1]["count"]
