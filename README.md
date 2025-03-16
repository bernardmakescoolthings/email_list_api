# Email List API

A FastAPI-based REST API for managing email addresses with PostgreSQL storage.

## Features

- Add email addresses with validation
- Retrieve sorted list of all emails
- Duplicate prevention
- PostgreSQL persistence
- Docker containerization
- Comprehensive tests

## Requirements

- Docker
- Docker Compose

## Setup and Running

1. Clone the repository
2. Start the application:
   ```bash
   docker-compose up --build
   ```
3. The API will be available at `http://localhost:8000`

## Development Setup

1. Install python3-venv (Ubuntu/Debian):
   ```bash
   sudo apt install python3.10-venv
   ```

2. Create a virtual environment:
   ```bash
   python3 -m venv venv
   ```

3. Activate the virtual environment:
   ```bash
   source venv/bin/activate
   ```

4. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

5. Run the development server:
   ```bash
   uvicorn app.main:app --reload
   ```

Note: 
- To deactivate the virtual environment when you're done, simply run: `deactivate`
- Always activate the virtual environment before working on the project
- If you add new dependencies, update requirements.txt:
  ```bash
  pip freeze > requirements.txt
  ```

## Deployment

1. Install Docker and Docker Compose on your server:
   ```bash
   # For Ubuntu/Debian
   sudo apt update
   sudo apt install docker.io docker-compose
   ```

2. Copy your project files to the server

3. Start the application in detached mode:
   ```bash
   docker-compose up -d --build
   ```

4. Verify the containers are running:
   ```bash
   docker ps
   ```

   You should see two containers:
   - `email_list_api_api_1`: The FastAPI application
   - `email_list_api_db_1`: The PostgreSQL database

5. Check the logs if needed:
   ```bash
   docker-compose logs -f
   ```

6. To stop the application:
   ```bash
   docker-compose down
   ```

### Important Notes for Deployment

- The application runs on port 8000 by default
- PostgreSQL data is persisted in a Docker volume
- The application will automatically restart if the server reboots
- Make sure to secure your server and set appropriate firewall rules
- Consider setting up HTTPS with a reverse proxy (e.g., Nginx) for production use

## API Endpoints

### 1. Add Email
- **URL**: `/add_email`
- **Method**: `POST`
- **Body**:
  ```json
  {
    "email": "user@example.com"
  }
  ```
- **Success Response**: `200 OK`
  ```json
  {
    "message": "Email added successfully"
  }
  ```

### 2. Get Emails
- **URL**: `/get_emails`
- **Method**: `GET`
- **Success Response**: `200 OK`
  ```json
  {
    "emails": ["email1@example.com", "email2@example.com"]
  }
  ```

## Running Tests

```bash
docker-compose run api pytest
```

## API Documentation

Once the application is running, you can access:
- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`