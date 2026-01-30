import pytest
from unittest.mock import Mock, patch, AsyncMock
from collections import Counter
from services.market_analyzer import MarketAnalyzer, market_analyzer


class TestMarketAnalyzer:

    def test_instance_created(self):
        assert market_analyzer is not None
        assert isinstance(market_analyzer, MarketAnalyzer)

    def test_has_jsearch_service(self):
        assert market_analyzer.jsearch is not None

    def test_has_extractor(self):
        assert market_analyzer.extractor is not None


class TestCategoryConfiguration:

    def test_category_order_defined(self):
        assert len(MarketAnalyzer.CATEGORY_ORDER) > 0
        assert "programming_languages" in MarketAnalyzer.CATEGORY_ORDER
        assert "databases" in MarketAnalyzer.CATEGORY_ORDER

    def test_min_percentage_defined(self):
        assert MarketAnalyzer.MIN_PERCENTAGE > 0

    def test_max_per_category_defined(self):
        assert MarketAnalyzer.MAX_PER_CATEGORY > 0


class TestAnalyzeMarket:

    @pytest.mark.asyncio
    async def test_no_jobs_found(self):
        analyzer = MarketAnalyzer()
        analyzer.jsearch = Mock()
        analyzer.jsearch.get_job_descriptions.return_value = []

        result = await analyzer.analyze_market("Developer", "Toronto", "Ontario")

        assert result["total_jobs_analyzed"] == 0
        assert result["top_skills"] == []
        assert "message" in result

    @pytest.mark.asyncio
    async def test_analyze_returns_structure(self):
        analyzer = MarketAnalyzer()
        analyzer.jsearch = Mock()
        analyzer.jsearch.get_job_descriptions.return_value = ["Python and React developer needed."]

        analyzer.extractor = Mock()
        analyzer.extractor.extract_all_skills = AsyncMock(return_value=[
            [
                {"name": "Python", "category": "programming_languages"},
                {"name": "React", "category": "frontend_frameworks"}
            ]
        ])

        result = await analyzer.analyze_market("Developer", "Toronto", "Ontario")

        assert "query" in result
        assert "location" in result
        assert "total_jobs_analyzed" in result
        assert "top_skills" in result
        assert result["location"] == "Toronto, Ontario, Canada"

    @pytest.mark.asyncio
    async def test_skill_counting(self):
        analyzer = MarketAnalyzer()
        analyzer.jsearch = Mock()
        analyzer.jsearch.get_job_descriptions.return_value = ["Job 1", "Job 2", "Job 3"]

        analyzer.extractor = Mock()
        analyzer.extractor.extract_all_skills = AsyncMock(return_value=[
            [{"name": "Python", "category": "programming_languages"}],
            [{"name": "Python", "category": "programming_languages"},
             {"name": "Java", "category": "programming_languages"}],
            [{"name": "Python", "category": "programming_languages"}]
        ])

        result = await analyzer.analyze_market("Developer", "Toronto", "Ontario", balanced=False)

        python_skill = next((s for s in result["top_skills"] if s["name"] == "Python"), None)
        assert python_skill is not None
        assert python_skill["count"] == 3
        assert python_skill["percentage"] == 100.0

    @pytest.mark.asyncio
    async def test_balanced_limits_per_category(self):
        analyzer = MarketAnalyzer()
        analyzer.jsearch = Mock()
        analyzer.jsearch.get_job_descriptions.return_value = ["Job"] * 5

        analyzer.extractor = Mock()
        analyzer.extractor.extract_all_skills = AsyncMock(return_value=[
            [{"name": f"Lang{i}", "category": "programming_languages"} for i in range(10)]
        ] * 5)

        result = await analyzer.analyze_market("Developer", "Toronto", "Ontario", balanced=True)

        lang_skills = [s for s in result["top_skills"] if s["category"] == "programming_languages"]
        assert len(lang_skills) <= MarketAnalyzer.MAX_PER_CATEGORY

    @pytest.mark.asyncio
    async def test_handles_extraction_error(self):
        analyzer = MarketAnalyzer()
        analyzer.jsearch = Mock()
        analyzer.jsearch.get_job_descriptions.return_value = ["Job 1", "Job 2"]

        analyzer.extractor = Mock()
        analyzer.extractor.extract_all_skills = AsyncMock(return_value=[
            [{"name": "Python", "category": "programming_languages"}]
        ])

        result = await analyzer.analyze_market("Developer", "Toronto", "Ontario")

        assert result["total_jobs_analyzed"] == 2


class TestGetSkillsByCategory:

    @pytest.mark.asyncio
    async def test_no_jobs_found(self):
        analyzer = MarketAnalyzer()
        analyzer.jsearch = Mock()
        analyzer.jsearch.get_job_descriptions.return_value = []

        result = await analyzer.get_skills_by_category("Developer", "Toronto", "Ontario")

        assert result["total_jobs_analyzed"] == 0
        assert result["skills_by_category"] == {}

    @pytest.mark.asyncio
    async def test_groups_by_category(self):
        analyzer = MarketAnalyzer()
        analyzer.jsearch = Mock()
        analyzer.jsearch.get_job_descriptions.return_value = ["Job description"]

        analyzer.extractor = Mock()
        analyzer.extractor.extract_all_skills = AsyncMock(return_value=[
            [
                {"name": "Python", "category": "programming_languages"},
                {"name": "JavaScript", "category": "programming_languages"},
                {"name": "React", "category": "frontend_frameworks"},
                {"name": "PostgreSQL", "category": "databases"}
            ]
        ])

        result = await analyzer.get_skills_by_category("Developer", "Toronto", "Ontario")

        assert "skills_by_category" in result

    @pytest.mark.asyncio
    async def test_respects_category_order(self):
        analyzer = MarketAnalyzer()
        analyzer.jsearch = Mock()
        analyzer.jsearch.get_job_descriptions.return_value = ["Job"]

        analyzer.extractor = Mock()
        analyzer.extractor.extract_all_skills = AsyncMock(return_value=[
            [
                {"name": "PostgreSQL", "category": "databases"},
                {"name": "Python", "category": "programming_languages"},
            ]
        ])

        result = await analyzer.get_skills_by_category("Developer", "Toronto", "Ontario")

        categories = list(result["skills_by_category"].keys())
        if len(categories) > 1:
            prog_idx = categories.index("programming_languages") if "programming_languages" in categories else -1
            db_idx = categories.index("databases") if "databases" in categories else -1
            if prog_idx >= 0 and db_idx >= 0:
                assert prog_idx < db_idx
