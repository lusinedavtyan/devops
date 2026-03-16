# Game Deals API

## Description

Game Deals API is a simple REST API built with FastAPI that fetches
video game deals from the CheapShark public API and returns a customized
list of deals.

The API demonstrates how to: - Call an external API - Parse incoming
JSON data - Extract specific fields from the response - Apply custom
logic to the data - Return a clean JSON response

This project simulates a small startup service that aggregates game
discounts and exposes them through a simple API endpoint.

## Features

-   Health check endpoint
-   Integration with the CheapShark Game Deals API
-   JSON parsing and data transformation
-   Custom API response format

## Endpoints

### Health Check

GET /health

Returns the service status.

Example response:

{ "status": "healthy", "version": "1.0.0" }

------------------------------------------------------------------------

### Game Deals

GET /deals

Fetches game deals from the CheapShark API and returns a simplified list
of deals.

Example response:

{ "games": \[ { "title": "New Batman Arkham Knight", "sale_price":
"3.99", "discount": "19.99" } \] }

## Technologies Used

-   Python
-   FastAPI
-   Requests library
-   CheapShark Game Deals API

## How to Run the Project

1.  Clone the repository

git clone `<repository-url>`{=html} cd `<repository-folder>`{=html}

2.  Install dependencies

pip install fastapi uvicorn requests

3.  Run the API server

uvicorn main:app --reload

4.  Open the API

http://127.0.0.1:8000

Interactive API documentation:

http://127.0.0.1:8000/docs

## Project Purpose

This project demonstrates basic backend API development using FastAPI,
including external API integration and JSON data processing.
