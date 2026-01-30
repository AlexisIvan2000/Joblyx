from fastapi import APIRouter, Query, HTTPException
from data.models import MarketAnalysisResponse, SkillsByCategoryResponse
from services.market_analysis import market_analyzer


router = APIRouter(prefix="/market", tags=["Market Analysis"])




@router.get("/analyze", response_model=MarketAnalysisResponse)
async def analyze_market(
    job: str = Query(..., description="Job title (e.g., 'Software Developer')"),
    city: str = Query(..., description="City name (e.g., 'Toronto')"),
    province: str = Query(..., description="Province name (e.g., 'Ontario')"),
    top_n: int = Query(30, ge=10, le=50, description="Number of top skills to return (10-50)"),
    balanced: bool = Query(True, description="Balance skills across categories")
):
    """
    Analyze the job market for a specific position and location in Canada.

    Returns the most in-demand skills based on job postings.
    When balanced=True, ensures diversity across skill categories.
    """
    try:
        result = await market_analyzer.analyze_market(
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
        result = await market_analyzer.get_skills_by_category(
            query=job,
            city=city,
            province=province
        )
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
