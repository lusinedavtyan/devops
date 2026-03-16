# Deals API (FastAPI + SQLite)

## Overview

Deals API is a backend service built with FastAPI that fetches video
game deals from the CheapShark public API and allows users to save
selected deals into a local SQLite database.

The application demonstrates: - FastAPI REST API development -
Environment configuration using `.env` - Database integration using
SQLAlchemy - Request validation using Pydantic - CRUD endpoints (Create
and Read) - External API integration

------------------------------------------------------------------------

## Technologies Used

-   Python
-   FastAPI
-   SQLAlchemy
-   SQLite
-   Pydantic
-   Requests
-   python-dotenv

------------------------------------------------------------------------

## Project Structure

project/ │ ├── main.py ├── README.md ├── .gitignore ├── .env ├── test.db
└── venv/

------------------------------------------------------------------------

## Environment Variables

Create a `.env` file:

API_KEY=your_secret_key APP_ENV=development
DATABASE_URL=sqlite:///./test.db

------------------------------------------------------------------------

## Running the Application

Install dependencies:

pip install fastapi uvicorn sqlalchemy python-dotenv requests

Run the server:

uvicorn main:app --reload

Open the API:

http://127.0.0.1:8000

Swagger docs:

http://127.0.0.1:8000/docs

------------------------------------------------------------------------

## API Endpoints

GET /health\
Returns service health status.

GET /deals\
Fetches game deals from CheapShark API.

POST /saved-deals\
Saves a deal into the database.

GET /saved-deals\
Returns all saved deals.

------------------------------------------------------------------------

## Database

The application uses SQLite.\
SQLAlchemy automatically creates a table named:

deals

Columns: - id - title - sale_price - discount

Database file: test.db

------------------------------------------------------------------------

## Purpose

This project demonstrates how to build a REST API with FastAPI,
integrate a database, validate requests using Pydantic, and persist
application data.
