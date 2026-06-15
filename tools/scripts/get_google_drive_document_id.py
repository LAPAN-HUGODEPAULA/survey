import os

from googleapiclient.discovery import build
from google.oauth2 import service_account

SERVICE_ACCOUNT_FILE = os.getenv(
    "GOOGLE_APPLICATION_CREDENTIALS",
    "../../services/clinical-writer-api/clinical_writer_agent/credentials/google-application-credentials.json",
)
FOLDER_ID = os.getenv("GOOGLE_DRIVE_FOLDER_ID")
SCOPES = ['https://www.googleapis.com/auth/drive.readonly']

if not FOLDER_ID:
    raise RuntimeError("GOOGLE_DRIVE_FOLDER_ID must be configured.")

creds = service_account.Credentials.from_service_account_file(
    SERVICE_ACCOUNT_FILE, scopes=SCOPES)
service = build('drive', 'v3', credentials=creds)

# List files in the specific folder
query = f"'{FOLDER_ID}' in parents and trashed = false"
results = service.files().list(
    q=query, 
    fields="files(id, name)"
).execute()

items = results.get('files', [])

print("Map these to your PROMPT_DOC_MAP_JSON:")
for item in items:
    print(f"Name: {item['name']} -> ID: {item['id']}")
