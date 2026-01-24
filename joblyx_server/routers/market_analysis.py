from fastapi import APIRouter, Query, HTTPException
from pydantic import BaseModel
from services.market_analyzer import market_analyzer


router = APIRouter(prefix="/market", tags=["Market Analysis"])


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


@router.get("/analyze", response_model=MarketAnalysisResponse)
async def analyze_market(
    job: str = Query(..., description="Job title (e.g., 'Software Developer')"),
    city: str = Query(..., description="City name (e.g., 'Toronto')"),
    province: str = Query(..., description="Province name (e.g., 'Ontario')"),
    top_n: int = Query(25, ge=10, le=50, description="Number of top skills to return (10-50)"),
    balanced: bool = Query(True, description="Balance skills across categories")
):
    """
    Analyze the job market for a specific position and location in Canada.

    Returns the most in-demand skills based on job postings.
    When balanced=True, ensures diversity across skill categories.
    """
    try:
        result = market_analyzer.analyze_market(
            query=job,
            city=city,
            province=province,
            top_n=top_n,
            balanced=balanced
        )
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/analyze/by-category", response_model=SkillsByCategoryResponse)
async def analyze_market_by_category(
    job: str = Query(..., description="Job title (e.g., 'Software Developer')"),
    city: str = Query(..., description="City name (e.g., 'Toronto')"),
    province: str = Query(..., description="Province name (e.g., 'Ontario')")
):
    """
    Analyze the job market and return skills grouped by category.
    """
    try:
        result = market_analyzer.get_skills_by_category(
            query=job,
            city=city,
            province=province
        )
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
