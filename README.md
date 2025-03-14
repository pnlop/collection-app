# Card Collection Manager API

A modern API service for managing collectible card game (CCG) collections with a Flutter frontend.

## Overview

This repository contains a card collection management system that allows users to catalog, search, and organize their physical or digital card collections. The system consists of a backend API and a Flutter frontend application.

## Features

- **Collection Management**: Create, view, update, and delete card collections
- **Card Tracking**: Add, update, and remove cards within collections
- **Advanced Searching**: Search for cards across all collections or within specific collections
- **REST API**: Well-designed API endpoints for all functionality


## API Endpoints

### Collections

- `GET /api/collections` - Get all collections
- `GET /api/collections/{collectionName}` - Get a specific collection
- `POST /api/collections` - Create a new collection
- `PUT /api/collections/{collectionName}` - Update a collection
- `DELETE /api/collections/{collectionName}` - Delete a collection

### Cards

- `POST /api/searchCard` - Search for cards across all collections
- `POST /api/collections/{collectionName}/search` - Search for cards within a specific collection
- `GET /api/collections/{collectionName}/cards` - Get all cards in a collection
- `GET /api/collections/{collectionName}/cards/{cardId}` - Get a specific card
- `POST /api/collections/{collectionName}/cards` - Add a card to a collection
- `PUT /api/collections/{collectionName}/cards/{cardId}` - Update a card
- `DELETE /api/collections/{collectionName}/cards/{cardId}` - Delete a card

## Technologies Used

### Backend
- RESTful API design
- Database for persistent storage
- Authentication and authorization

### Frontend
- Flutter for cross-platform mobile app
- HTTP package for API communication
- JSON serialization/deserialization
- Provider or Bloc for state management
