from pydantic import BaseModel, EmailStr, ConfigDict

class EmailBase(BaseModel):
    email: EmailStr
    model_config = ConfigDict(from_attributes=True)

class EmailList(BaseModel):
    emails: list[str] 