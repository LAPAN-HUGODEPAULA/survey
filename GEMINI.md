# GEMINI.md

## Project Overview

This project is a Flutter-based mobile and web compatible application for conducting surveys. It uses a MongoDB database for storing survey data and results. The project is divided into two main parts:

*   **`survey_app`**: A Flutter application for the user interface.
*   **`db`**: A directory containing the database setup and a Python script for data migration.

The application is designed to display surveys, collect responses, and store them in the database. The survey definitions and results are initially stored in JSON files and then migrated to MongoDB.

## Project Structure

### survey_app

The survey_app directory contains the Flutter application. the application is compatible with web and Android. The features of the application are as follows:

1 - During the setup process, the app collects data about the screener responsible for giving instructions to the patient and the survey that will be used during the screening process.
2 - The app then collects demographic data about the patient. 
3 - The patient answers are then collected.
4 - Answers are stored in a json file.

### db

The db directory contains the database setup and a Python script for data migration. It will also contains the Python fastAPI application that will be responsible for storing the json data in MongoDB. 

## Data structure

### App data:

App data are stored on `assets/data` directory.

- `diagnoses.json` stores the list of mental disorders that are recognized by the system. A list of toggle buttons are created based on this list.
- `education_level.json` stores the list of education levels that are recognized by the system. These values are used in a DropdownFormField on the Flutter App.
- `professions.json` stores the list of professions that are recognized by the system. This list is used as an autocomplete reference for a TextFormField on the Flutter App..

### Survey data:

Sample survey questionnaires can be seen in the `assets/surveys` directory.

The data structure of the survey files is as follows:

*   `surveyId`: A unique identifier for the survey.
*   `surveyName`: The name of the survey.
*   `surveyDescription`: An HTML string containing the description of the survey.
*   `creatorName`: The name of the survey's creator.
*   `creatorContact`: The contact information of the creator.
*   `createdAt`: The date the survey was created.
*   `modifiedAt`: The date the survey was last modified.
*   `instructions`: An object containing the instructions for the survey.
    *   `preamble`: An HTML string with a preamble to the survey.
    *   `questionText`: The text of the question about the instructions.
    *   `answers`: A list of possible answers to the instruction question.
*   `name`: The name of the survey.
*   `questions`: A list of question objects.
    *   `id`: A unique identifier for the question.
    *   `questionText`: The text of the question.
    *   `answers`: A list of possible answers to the question.
*   `finalNotes`: An HTML string with final notes to be displayed after the survey is completed.

## Building and Running

### Flutter App

To run the Flutter application, you will need to have the Flutter SDK installed.

1.  **Navigate to the `survey_app` directory:**
    ```bash
    cd survey_app
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Run the app:**
    ```bash
    flutter run
    ```

### Database

The project uses MongoDB, which is set up to run in a Docker container.

1.  **Navigate to the `db` directory:**
    ```bash
    cd db
    ```

2.  **Start the MongoDB container:**
    ```bash
    docker-compose up -d
    ```

3.  **Migrate data:**
    The project includes a Python script to migrate survey data from JSON files to the MongoDB database.
    ```bash
    python migrate/migrate_to_mongo.py
    ```

## Development Conventions

*   **Data Migration**: All survey data and results are initially stored as JSON files in the `assets/surveys` and `assets/survey_results` directories, respectively. The `db/migrate/migrate_to_mongo.py` script is used to populate the MongoDB database from these files.
*   **Configuration**: The Flutter app's dependencies are managed in `survey_app/pubspec.yaml`. The database configuration is in `db/docker-compose.yml`.
*   **Backend Logic**: The `db/main.py` file is a placeholder. Any future backend logic should be implemented there.