from googleapiclient.discovery import build
from google.oauth2 import service_account

# Setup
SERVICE_ACCOUNT_FILE = '../../services/clinical-writer-api/clinical_writer_agent/credentials/darv-13c19-740b161e0018.json'
FOLDER_ID = '1i7C27Zm4lvqoWEOYRBHHPL_5FMFy6jxP' # Use the ID you already found
SCOPES = ['https://www.googleapis.com/auth/drive.readonly']

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
