from sqlalchemy import Column, Integer, String
from database import Base
from pydantic import BaseModel, ConfigDict

class Person(Base):
    __tablename__ = "persons"
    id = Column(Integer, primary_key=True, index=True)
    nom = Column(String, nullable=False, index=True)
    prenom = Column(String, nullable=False, index=True)
    telephone = Column(String, unique=True, nullable=False, index=True)

class PersonCreate(BaseModel):
    nom: str
    prenom: str
    telephone: str

class PersonResponse(BaseModel):
    id: int
    nom: str
    prenom: str
    telephone: str
    model_config = ConfigDict(from_attributes=True)