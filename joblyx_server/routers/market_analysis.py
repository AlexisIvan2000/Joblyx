from fastapi import APIRouter, Query, Header, HTTPException
from data.models import MarketAnalysisResponse, SkillsByCategoryResponse
from services.market_analysis import market_analyzer
from services.user import user_history_service, user_quota
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
    If authenticated, the search is saved to user history (max 5 searches/week).
    """
    user_id = await get_optional_user_id(authorization)

    # Vérifier le quota si authentifié
    if user_id and not user_quota.can_user_search(user_id):
        raise HTTPException(
            status_code=429,
            detail="Weekly search limit reached (5/week). Try again next week."
        )

    try:
        result = await market_analyzer.analyze_market(
            query=job,
            city=city,
            province=province,
            top_n=top_n,
            balanced=balanced
        )

        # Enregistrer usage + historique si authentifié et recherche réussie
        if user_id and result.get("total_jobs_analyzed", 0) > 0:
            # Ne décompter du quota que si résultat pas du cache
            if not result.get("from_cache", False):
                user_quota.record_search(user_id)

            user_history_service.record_search(
                user_id=user_id,
                query=job,
                city=city,
                province=province,
                results=result,
                total_jobs=result["total_jobs_analyzed"]
            )

        return result
    except HTTPException:
        raise
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
    If authenticated, the search is saved to user history (max 5 searches/week).
    """
    user_id = await get_optional_user_id(authorization)

    # Vérifier le quota si authentifié
    if user_id and not user_quota.can_user_search(user_id):
        raise HTTPException(
            status_code=429,
            detail="Weekly search limit reached (5/week). Try again next week."
        )

    try:
        result = await market_analyzer.get_skills_by_category(
            query=job,
            city=city,
            province=province
        )

        # Enregistrer usage + historique si authentifié et recherche réussie
        if user_id and result.get("total_jobs_analyzed", 0) > 0:
            # Ne décompter du quota que si résultat pas du cache
            if not result.get("from_cache", False):
                user_quota.record_search(user_id)

            user_history_service.record_search(
                user_id=user_id,
                query=job,
                city=city,
                province=province,
                results=result,
                total_jobs=result["total_jobs_analyzed"]
            )

        return result
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Récupère les statistiques de quota de l'utilisateur
@router.get("/quota")
async def get_quota_stats(authorization: str = Header(..., description="Bearer token")):
    user_id = await get_user_id_from_token(authorization)
    return user_quota.get_stats(user_id)
