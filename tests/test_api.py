import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
import os
os.environ["TESTING"] = "true"  # Set testing environment

from app.main import app
from app.database import Base, get_db
from app.models import Email
from app.config import get_database_url

# Test database setup
SQLALCHEMY_DATABASE_URL = get_database_url()
engine = create_engine(SQLALCHEMY_DATABASE_URL)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def override_get_db():
    try:
        db = TestingSessionLocal()
        yield db
    finally:
        db.close()

app.dependency_overrides[get_db] = override_get_db
client = TestClient(app)

@pytest.fixture(autouse=True)
def setup_database():
    Base.metadata.create_all(bind=engine)
    yield
    # Clean up after each test
    db = TestingSessionLocal()
    db.query(Email).delete()
    db.commit()

def test_add_valid_email():
    response = client.post("/add_email", json={"email": "test@example.com"})
    assert response.status_code == 200
    assert response.json() == {"message": "Email added successfully"}

def test_add_duplicate_email():
    # Add email first time
    client.post("/add_email", json={"email": "test@example.com"})
    # Try to add same email again
    response = client.post("/add_email", json={"email": "test@example.com"})
    assert response.status_code == 200
    assert response.json() == {"message": "Email already exists"}

def test_add_invalid_email_with_plus():
    response = client.post("/add_email", json={"email": "test+alias@example.com"})
    assert response.status_code == 500
    assert "Email cannot contain '+' character" in response.json()["detail"]

def test_get_emails_empty():
    response = client.get("/get_emails")
    assert response.status_code == 200
    assert response.json() == {"emails": []}

def test_get_emails_with_data():
    # Add some test emails
    emails = ["b@example.com", "a@example.com", "c@example.com"]
    for email in emails:
        client.post("/add_email", json={"email": email})
    
    response = client.get("/get_emails")
    assert response.status_code == 200
    assert response.json() == {"emails": sorted(emails)} 