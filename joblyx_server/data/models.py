from pydantic import BaseModel

class SkillInfo(BaseModel):
    name: str
    count: int
    percentage: float
    category: str


class MarketAnalysisResponse(BaseModel):
    query: str
    location: str
    total_jobs_analyzed: int
    top_skills: list[SkillInfo]
    message: str | None = None


class SkillsByCategoryResponse(BaseModel):
    query: str
    location: str
    total_jobs_analyzed: int
    skills_by_category: dict[str, list[dict]]
