from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routers import market_analysis, cache, history

app = FastAPI(
    title="Joblyx API",
    description="Job market analysis API for Canada",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(market_analysis.router)
app.include_router(cache.router)
app.include_router(history.router)


@app.get("/")
async def root():
    return {"message": "Joblyx API - Job Market Analysis"}


@app.get("/health")
async def health_check():
    return {"status": "healthy"}
