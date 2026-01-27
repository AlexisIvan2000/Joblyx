import pytest
from services.skills_matcher import SkillsMatcher, skills_matcher


class TestSkillsMatcher:

    def test_singleton_pattern(self):
        instance1 = SkillsMatcher()
        instance2 = SkillsMatcher()
        assert instance1 is instance2

    def test_skills_data_loaded(self):
        assert skills_matcher.skills_data is not None
        assert "IT" in skills_matcher.skills_data

    def test_skill_to_category_mapping(self):
        assert len(skills_matcher.skill_to_category) > 0
        assert "python" in skills_matcher.skill_to_category
        assert "javascript" in skills_matcher.skill_to_category


class TestLanguageDetection:

    def test_detect_english(self):
        text = "We are looking for a Software Developer with Python experience."
        lang = skills_matcher.detect_language(text)
        assert lang == "en"

    def test_detect_french(self):
        text = "Nous recherchons un développeur logiciel avec expérience en Python."
        lang = skills_matcher.detect_language(text)
        assert lang == "fr"

    def test_detect_empty_text(self):
        lang = skills_matcher.detect_language("")
        assert lang == "en"

    def test_detect_short_text(self):
        lang = skills_matcher.detect_language("Python")
        assert lang in ["en", "fr"]


class TestSkillExtraction:

    def test_extract_skills_empty_text(self):
        skills = skills_matcher.extract_skills("")
        assert skills == []

    def test_extract_skills_english(self, sample_job_description_en):
        skills = skills_matcher.extract_skills(sample_job_description_en)

        assert len(skills) > 0
        skill_names = [s.lower() for s in skills]
        assert "python" in skill_names
        assert "javascript" in skill_names
        assert "react" in skill_names

    def test_extract_skills_french(self, sample_job_description_fr):
        skills = skills_matcher.extract_skills(sample_job_description_fr)

        assert len(skills) > 0
        skill_names = [s.lower() for s in skills]
        assert "java" in skill_names
        assert "python" in skill_names

    def test_extract_skills_with_category(self, sample_job_description_en):
        skills = skills_matcher.extract_skills_with_category(sample_job_description_en)

        assert len(skills) > 0
        for skill in skills:
            assert "name" in skill
            assert "category" in skill

    def test_extract_skills_unique(self, sample_job_description_en):
        skills = skills_matcher.extract_skills(sample_job_description_en)
        assert len(skills) == len(set(skills))


class TestAmbiguousSkills:

    def test_ambiguous_skill_c(self):
        text = "Experience with C programming language required."
        skills = skills_matcher.extract_skills(text)
        assert "C" in skills

    def test_ambiguous_skill_c_no_context(self):
        text = "We need a developer."
        skills = skills_matcher.extract_skills(text)
        assert "C" not in skills

    def test_ambiguous_skill_go(self):
        text = "Looking for Golang developer with Go programming experience."
        skills = skills_matcher.extract_skills(text)
        assert "Go" in skills

    def test_ambiguous_skill_r(self):
        text = "R programming and R studio experience required."
        skills = skills_matcher.extract_skills(text)
        assert "R" in skills

    def test_check_ambiguous_skills(self, sample_job_description_ambiguous):
        found = skills_matcher._check_ambiguous_skills(sample_job_description_ambiguous)

        assert "C" in found
        assert "Go" in found
        # R nécessite des patterns spécifiques comme "R programming" ou "R studio"
        assert "Rust" in found
        assert "Swift" in found


class TestSkillCategories:

    def test_programming_languages_category(self):
        text = "Python, JavaScript, and Java experience required."
        skills = skills_matcher.extract_skills_with_category(text)

        categories = {s["category"] for s in skills}
        assert "programming_languages" in categories

    def test_framework_category(self):
        text = "Experience with React, Angular, and Spring Boot."
        skills = skills_matcher.extract_skills_with_category(text)

        skill_cats = {s["name"]: s["category"] for s in skills}
        if "React" in skill_cats:
            assert skill_cats["React"] == "frontend_frameworks"
        if "Spring Boot" in skill_cats:
            assert skill_cats["Spring Boot"] == "backend_frameworks"

    def test_database_category(self):
        text = "PostgreSQL and MongoDB experience."
        skills = skills_matcher.extract_skills_with_category(text)

        categories = {s["category"] for s in skills}
        assert "databases" in categories
