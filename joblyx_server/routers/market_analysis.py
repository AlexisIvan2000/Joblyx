from fastapi import APIRouter, Query, Header, HTTPException
from data.models import MarketAnalysisResponse, SkillsByCategoryResponse
from services.market_analysis import market_analyzer
from services.user_history import user_history_service
from services.auth import get_user_id_from_token


router = APIRouter(prefix="/market", tags=["Market Analysis"])


async def get_optional_user_id(authorization: str = Header(None)) -> str | None:
    """Récupère le user_id si authentifié, None sinon"""
    if not authorization:
        return None
    try:
        return await get_user_id_from_token(authorization)
    except:
        return None


@router.get("/analyze", response_model=MarketAnalysisResponse)
async def analyze_market(
    job: str = Query(..., description="Job title (e.g., 'Software Developer')"),
    city: str = Query(..., description="City name (e.g., 'Toronto')"),
    province: str = Query(..., description="Province name (e.g., 'Ontario')"),
    top_n: int = Query(30, ge=10, le=50, description="Number of top skills to return (10-50)"),
    balanced: bool = Query(True, description="Balance skills across categories"),
    authorization: str = Header(None, description="Bearer token (optional)")
):
    """
    Analyze the job market for a specific position and location in Canada.

    Returns the most in-demand skills based on job postings.
    When balanced=True, ensures diversity across skill categories.
    If authenticated, the search is saved to user history.
    """
    try:
        result = await market_analyzer.analyze_market(
            query=job,
            city=city,
            province=province,
            top_n=top_n,
            balanced=balanced
        )

        # Enregistrer dans l'historique si authentifié
        user_id = await get_optional_user_id(authorization)
        if user_id and result.get("total_jobs_analyzed", 0) > 0:
            user_history_service.record_search(
                user_id=user_id,
                query=job,
                city=city,
                province=province,
                results=result,
                total_jobs=result["total_jobs_analyzed"]
            )

        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/analyze/by-category", response_model=SkillsByCategoryResponse)
async def analyze_market_by_category(
    job: str = Query(..., description="Job title (e.g., 'Software Developer')"),
    city: str = Query(..., description="City name (e.g., 'Toronto')"),
    province: str = Query(..., description="Province name (e.g., 'Ontario')"),
    authorization: str = Header(None, description="Bearer token (optional)")
):
    """
    Analyze the job market and return skills grouped by category.
    If authenticated, the search is saved to user history.
    """
    try:
        result = await market_analyzer.get_skills_by_category(
            query=job,
            city=city,
            province=province
        )

        # Enregistrer dans l'historique si authentifié
        user_id = await get_optional_user_id(authorization)
        if user_id and result.get("total_jobs_analyzed", 0) > 0:
            user_history_service.record_search(
                user_id=user_id,
                query=job,
                city=city,
                province=province,
                results=result,
                total_jobs=result["total_jobs_analyzed"]
            )

        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
