from pydantic import BaseModel, EmailStr, ConfigDict

class EmailBase(BaseModel):
    project_name: str
    email: EmailStr
    model_config = ConfigDict(from_attributes=True)

class EmailList(BaseModel):
    emails: list[str]

class ProjectEmailRequest(BaseModel):
    project_name: str 