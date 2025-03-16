from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from . import models, schemas
from .database import engine, get_db
from typing import List

models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="Email List API")

@app.post("/add_email", status_code=200)
def add_email(email_data: schemas.EmailBase, db: Session = Depends(get_db)):
    if "+" in email_data.email:
        raise HTTPException(status_code=500, detail="Email cannot contain '+' character")
    
    # Check if email already exists
    db_email = db.query(models.Email).filter(models.Email.email == email_data.email).first()
    if db_email:
        return {"message": "Email already exists"}
    
    # Create new email
    db_email = models.Email(email=email_data.email)
    db.add(db_email)
    db.commit()
    return {"message": "Email added successfully"}

@app.get("/get_emails", response_model=schemas.EmailList)
def get_emails(db: Session = Depends(get_db)):
    emails = db.query(models.Email).order_by(models.Email.email).all()
    return {"emails": [email.email for email in emails]} 