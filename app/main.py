from fastapi import FastAPI, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from . import models, schemas
from .database import engine, get_db
from typing import List

models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="Email List API")

@app.post("/api/add_emails", status_code=200)
def add_email(email_data: schemas.EmailBase, db: Session = Depends(get_db)):
    if "+" in email_data.email:
        raise HTTPException(status_code=500, detail="Email cannot contain '+' character")
    
    # Check if email already exists in the project
    db_email = db.query(models.Email).filter(
        models.Email.project_name == email_data.project_name,
        models.Email.email == email_data.email
    ).first()
    
    if db_email:
        return {"message": "Email already exists in this project"}
    
    # Create new email
    db_email = models.Email(project_name=email_data.project_name, email=email_data.email)
    db.add(db_email)
    db.commit()
    return {"message": "Email added successfully"}

@app.get("/api/get_emails", response_model=schemas.EmailList)
def get_emails(project_name: str = Query(..., description="Name of the project to get emails for"), db: Session = Depends(get_db)):
    emails = db.query(models.Email).filter(
        models.Email.project_name == project_name
    ).order_by(models.Email.email).all()
    return {"emails": [email.email for email in emails]} 