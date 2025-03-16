from sqlalchemy import Column, String
from .database import Base
from pydantic import ConfigDict

class Email(Base):
    __tablename__ = "emails"

    project_name = Column(String, primary_key=True, index=True)
    email = Column(String, primary_key=True, index=True)
    
    model_config = ConfigDict(from_attributes=True) 