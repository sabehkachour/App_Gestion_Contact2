from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from typing import List
import uvicorn

from database import engine, get_db, Base
from models import Person, PersonCreate, PersonResponse

Base.metadata.create_all(bind=engine)

app = FastAPI(title="API Gestion de Contacts")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.post("/personnes", response_model=PersonResponse, status_code=status.HTTP_201_CREATED)
def create_person(person: PersonCreate, db: Session = Depends(get_db)):
    if db.query(Person).filter(Person.telephone == person.telephone).first():
        raise HTTPException(status_code=400, detail="Ce numéro de téléphone existe déjà")
    db_person = Person(**person.model_dump())
    db.add(db_person)
    db.commit()
    db.refresh(db_person)
    return db_person

@app.get("/personnes", response_model=List[PersonResponse])
def get_persons(db: Session = Depends(get_db)):
    return db.query(Person).all()

@app.get("/personnes/{person_id}", response_model=PersonResponse)
def get_person(person_id: int, db: Session = Depends(get_db)):
    person = db.query(Person).filter(Person.id == person_id).first()
    if not person:
        raise HTTPException(status_code=404, detail="Personne non trouvée")
    return person

@app.delete("/personnes/{person_id}")
def delete_person(person_id: int, db: Session = Depends(get_db)):
    person = db.query(Person).filter(Person.id == person_id).first()
    if not person:
        raise HTTPException(status_code=404, detail="Personne non trouvée")
    db.delete(person)
    db.commit()
    return {"message": "Contact supprimé avec succès"}
@app.put("/personnes/{person_id}", response_model=PersonResponse)
def update_person(person_id: int, person: PersonCreate, db: Session = Depends(get_db)):
    db_person = db.query(Person).filter(Person.id == person_id).first()
    if not db_person:
        raise HTTPException(status_code=404, detail="Personne non trouvée")
    
    db_person.nom = person.nom
    db_person.prenom = person.prenom
    db_person.telephone = person.telephone

    db.commit()
    db.refresh(db_person)
    return db_person
if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
    .