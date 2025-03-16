import os
from dotenv import load_dotenv

load_dotenv()

def get_database_url():
    """Get database URL based on environment."""
    db_url = os.getenv("DATABASE_URL")
    if os.getenv("TESTING") == "true":
        # Use localhost for local testing
        return db_url.replace("@db:", "@localhost:")
    return db_url 