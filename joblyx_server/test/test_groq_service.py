import pytest
from unittest.mock import Mock, patch, MagicMock
from  services.market_analysis import GroqSkillsExtractor, groq_extractor


class TestGroqSkillsExtractor:

    def test_instance_created(self):
        assert groq_extractor is not None
        assert isinstance(groq_extractor, GroqSkillsExtractor)

    def test_skills_loaded(self):
        assert len(groq_extractor.skills_list) > 0
        assert len(groq_extractor.skills_by_category) > 0

    def test_skills_list_contains_common_skills(self):
        assert "Python" in groq_extractor.skills_list
        assert "JavaScript" in groq_extractor.skills_list
        assert "React" in groq_extractor.skills_list

    def test_skills_by_category_structure(self):
        assert "programming_languages" in groq_extractor.skills_by_category
        assert "frontend_frameworks" in groq_extractor.skills_by_category
        assert "databases" in groq_extractor.skills_by_category


class TestGetCategory:

    def test_get_category_python(self):
        category = groq_extractor._get_category("Python")
        assert category == "programming_languages"

    def test_get_category_react(self):
        category = groq_extractor._get_category("React")
        assert category == "frontend_frameworks"

    def test_get_category_postgresql(self):
        category = groq_extractor._get_category("PostgreSQL")
        assert category == "databases"

    def test_get_category_unknown(self):
        category = groq_extractor._get_category("UnknownSkill123")
        assert category == "other"


class TestExtractSkills:

    @patch('services.groq_service.Groq')
    def test_extract_skills_success(self, mock_groq_class):
        mock_client = MagicMock()
        mock_response = MagicMock()
        mock_response.choices[0].message.content = '["Python", "React", "PostgreSQL"]'
        mock_client.chat.completions.create.return_value = mock_response
        mock_groq_class.return_value = mock_client

        extractor = GroqSkillsExtractor()
        skills = extractor.extract_skills("Looking for Python and React developer")

        assert "Python" in skills
        assert "React" in skills

    @patch('services.groq_service.Groq')
    def test_extract_skills_with_markdown(self, mock_groq_class):
        mock_client = MagicMock()
        mock_response = MagicMock()
        mock_response.choices[0].message.content = '```json\n["Python", "JavaScript"]\n```'
        mock_client.chat.completions.create.return_value = mock_response
        mock_groq_class.return_value = mock_client

        extractor = GroqSkillsExtractor()
        skills = extractor.extract_skills("Python and JavaScript needed")

        assert "Python" in skills
        assert "JavaScript" in skills

    @patch('services.groq_service.Groq')
    def test_extract_skills_filters_invalid(self, mock_groq_class):
        mock_client = MagicMock()
        mock_response = MagicMock()
        mock_response.choices[0].message.content = '["Python", "FakeSkill123", "React"]'
        mock_client.chat.completions.create.return_value = mock_response
        mock_groq_class.return_value = mock_client

        extractor = GroqSkillsExtractor()
        skills = extractor.extract_skills("Some job description")

        assert "Python" in skills
        assert "React" in skills
        assert "FakeSkill123" not in skills

    @patch('services.groq_service.Groq')
    def test_extract_skills_error_returns_empty(self, mock_groq_class):
        mock_client = MagicMock()
        mock_client.chat.completions.create.side_effect = Exception("API Error")
        mock_groq_class.return_value = mock_client

        extractor = GroqSkillsExtractor()
        skills = extractor.extract_skills("Some job description")

        assert skills == []


class TestExtractSkillsList:

    @patch.object(GroqSkillsExtractor, 'extract_skills')
    def test_extract_skills_list_format(self, mock_extract):
        mock_extract.return_value = ["Python", "React", "PostgreSQL"]

        result = groq_extractor.extract_skills_list("Job description")

        assert len(result) == 3
        for item in result:
            assert "name" in item
            assert "category" in item

    @patch.object(GroqSkillsExtractor, 'extract_skills')
    def test_extract_skills_list_categories(self, mock_extract):
        mock_extract.return_value = ["Python", "React"]

        result = groq_extractor.extract_skills_list("Job description")

        skill_map = {s["name"]: s["category"] for s in result}
        assert skill_map["Python"] == "programming_languages"
        assert skill_map["React"] == "frontend_frameworks"

    @patch.object(GroqSkillsExtractor, 'extract_skills')
    def test_extract_skills_list_empty(self, mock_extract):
        mock_extract.return_value = []

        result = groq_extractor.extract_skills_list("Job description")

        assert result == []
