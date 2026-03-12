from fastapi import FastAPI
from dotenv import load_dotenv
import os
import requests

load_dotenv()

# get configs from .env file
API_KEY = os.getenv("API_KEY")
APP_ENV = os.getenv("APP_ENV")

# create FastAPI application
app = FastAPI()

# configs endpoint
@app.get("/configs")
def getConfigs():
    return {
        "api_key": API_KEY,
        "app_env": APP_ENV
    }

# health endpoint
@app.get("/health")
def health():
    return {
        "status": "healthy",
        "version": "1.0.0"
    }

# deals endpoint
@app.get("/deals")
def get_deals():
    url = "https://www.cheapshark.com/api/1.0/deals"

    # get cheapshark deals API
    response = requests.get(url)

    # verify if status code not 200 OK and raise the script with failed massege
    if response.status_code != 200:
        raise HTTPException(
            status_code=response.status_code,
            detail="External API request failed"
        )

    # keep request's response in json format
    data = response.json()
    deals = []

    # go through data to take title, noral_price and sale_price properties and create custom response
    for game in data:
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