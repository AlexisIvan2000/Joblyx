from dotenv import load_dotenv
import os

load_dotenv()

RAPIDAPI_KEY = os.getenv("RAPIDAPI_KEY")
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_ANON_KEY = os.getenv("SUPABASE_ANON_KEY")
