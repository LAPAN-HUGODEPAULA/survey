# Survey App Database

This directory contains the database setup and data migration scripts for the Survey App.

## Project Overview

This project is a Flutter-based mobile and web compatible application for conducting surveys. It uses a MongoDB database for storing survey data and results. The project is divided into two main parts:

* **`survey_app`**: A Flutter application for the user interface.
* **`db`**: A directory containing the database setup and a Python script for data migration.

The application is designed to display surveys, collect responses, and store them in the database. The survey definitions and results are initially stored in JSON files and then migrated to MongoDB.

## Project Structure

* `/`: Contains the FastAPI application that will be responsible for storing the json data in MongoDB.
* `migrate/`: Contains the data migration scripts.
* `assets/`: Contains the survey data and results in JSON format.
* `docker-compose.yml`: Defines the Docker services for the MongoDB database and the FastAPI application.
* `Dockerfile`: Defines the Docker image for the FastAPI application.

## Docker Setup

The project uses Docker containers for both MongoDB database and the FastAPI application.

### Building Initial Containers

1. **Build and start all containers for the first time:**

    ```bash
    docker-compose up --build -d
    ```

    This command will:
    * Build the FastAPI application Docker image from the Dockerfile
    * Pull the MongoDB image from Docker Hub
    * Start both containers in detached mode
    * Create a network for communication between containers

2. **Alternative: Build containers separately:**

    ```bash
    # Build only the FastAPI app container
    docker-compose build survey_fastapi
    
    # Start all services
    docker-compose up -d
    ```

### Database Setup

The MongoDB container will start with the following credentials:

* **Username:** admin
* **Password:** secret
* **Database:** survey_db
* **Port:** 27017

### Updating Container Builds After Code Changes

When you make changes to the application code, you need to rebuild the containers to include your updates:

1. **Rebuild and restart the FastAPI container after code changes:**

    ```bash
    docker-compose up --build survey_fastapi -d
    ```

2. **Rebuild all containers (if needed):**

    ```bash
    docker-compose down
    docker-compose up --build -d
    ```

3. **Force rebuild without using cache (for major changes):**

    ```bash
    docker-compose build --no-cache survey_fastapi
    docker-compose up -d
    ```

4. **Quick restart without rebuild (for testing):**

    ```bash
    docker-compose restart survey_fastapi
    ```

### Container Management Commands

* **View running containers:**

    ```bash
    docker-compose ps
    ```

* **View container logs:**

    ```bash
    # FastAPI app logs
    docker-compose logs survey_fastapi
    
    # MongoDB logs
    docker-compose logs mongodb
    
    # Follow logs in real-time
    docker-compose logs -f survey_fastapi
    ```

* **Stop all containers:**

    ```bash
    docker-compose down
    ```

* **Stop and remove containers with volumes:**

    ```bash
    docker-compose down -v
    ```

## Data Migration

The project includes a Python script to migrate survey data from JSON files to the MongoDB database.

1. **Run the migration script:**

    ```bash
    .venv/bin/python migrate/migrate_to_mongo.py
    ```

    This script will:
    * Connect to the MongoDB database using the credentials defined in the script.
    * Read the survey definitions from the `assets/surveys` directory and insert them into the `surveys` collection.
    * Read the survey results from the `assets/survey_results` directory, create participants, and insert the responses into the `survey_responses` collection.

## Troubleshooting

1. To run a **MongoDB shell** inside the docker container, run:

    ```bash
    docker exec -it mongodb mongosh -u admin -p secret --authenticationDatabase admin
    ```

2. **Use database:**

    ```sql
    use survey_db
    ```

3. **Show collections:**

    ```sql
    show collections
    ```

## Running the App

### FastAPI Backend

The FastAPI application runs in a Docker container and is accessible at:

* **API Base URL:** <http://localhost:8000>
* **API Documentation:** <http://localhost:8000/docs> (Swagger UI)
* **Alternative Docs:** <http://localhost:8000/redoc>

The FastAPI service will automatically start when you run `docker-compose up`.

### Flutter App

To run the Flutter application, you will need to have the Flutter SDK installed.

1. **Navigate to the `survey_app` directory:**

    ```bash
    cd ../survey_app
    ```

2. **Install dependencies:**

    ```bash
    flutter pub get
    ```

3. **Run the app:**

    ```bash
    flutter run
    ```
