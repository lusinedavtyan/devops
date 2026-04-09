from fastapi import FastAPI, HTTPException, Depends
from dotenv import load_dotenv
import os
import requests

from sqlalchemy import create_engine, Column, Integer, String
from sqlalchemy.orm import declarative_base, sessionmaker, Session
from pydantic import BaseModel

load_dotenv()

# Example:
# DATABASE_URL=postgresql+psycopg2://postgres:password@localhost:5432/mydatabase
DATABASE_URL = os.getenv("DATABASE_URL")

engine = create_engine(DATABASE_URL)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# get configs from .env file
API_KEY = os.getenv("API_KEY")
APP_ENV = os.getenv("APP_ENV")

# create FastAPI application
app = FastAPI()


# -----------------------------
# Database model
# -----------------------------
class Deal(Base):
    __tablename__ = "deals"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    sale_price = Column(String)
    discount = Column(String)


# Create tables
Base.metadata.create_all(bind=engine)


# -----------------------------
# Pydantic schema
# -----------------------------
class DealCreate(BaseModel):
    title: str
    sale_price: str
    discount: str


# -----------------------------
# DB dependency
# -----------------------------
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# -----------------------------
# Existing endpoints
# -----------------------------
@app.get("/configs")
def get_configs():
    return {
        "api_key": API_KEY,
        "app_env": APP_ENV
    }


@app.get("/health")
def health():
    return {
        "status": "healthy",
        "version": "1.0.0"
    }


@app.get("/deals")
def get_deals():
    url = "https://www.cheapshark.com/api/1.0/deals"
    response = requests.get(url)

    if response.status_code != 200:
        raise HTTPException(
            status_code=response.status_code,
            detail="External API request failed"
        )

    data = response.json()
    deals = []

    for game in data[:10]:
        title = game["title"]
        normal_price = game["normalPrice"]
        sale_price = game["salePrice"]

        new_price = "New " + title

        deals.append({
            "title": new_price,
            "sale_price": sale_price,
            "discount": normal_price
        })

    return {"games": deals}


# -----------------------------
# CRUD endpoints
# -----------------------------
@app.post("/saved-deals")
def create_deal(deal: DealCreate, db: Session = Depends(get_db)):
    new_deal = Deal(
        title=deal.title,
        sale_price=deal.sale_price,
        discount=deal.discount
    )

    db.add(new_deal)
    db.commit()
    db.refresh(new_deal)

    return {
        "message": "Deal saved successfully",
        "deal": {
            "id": new_deal.id,
            "title": new_deal.title,
            "sale_price": new_deal.sale_price,
            "discount": new_deal.discount
        }
    }


@app.get("/saved-deals")
def get_saved_deals(db: Session = Depends(get_db)):
    deals = db.query(Deal).all()

    return {
        "saved_deals": [
            {
                "id": deal.id,
                "title": deal.title,
                "sale_price": deal.sale_price,
                "discount": deal.discount
            }
            for deal in deals
        ]
    }