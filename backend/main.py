import os
import uuid
from fastapi import FastAPI, File, UploadFile, Form, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from dotenv import load_dotenv
import boto3
from datetime import datetime, timedelta

load_dotenv()

AWS_REGION = os.getenv("AWS_REGION")
S3_BUCKET = os.getenv("S3_BUCKET")
DYNAMODB_TABLE = os.getenv("DYNAMODB_TABLE")

s3 = boto3.client("s3", region_name=AWS_REGION)
dynamodb = boto3.resource("dynamodb", region_name=AWS_REGION)
table = dynamodb.Table(DYNAMODB_TABLE)

app = FastAPI()

# CORS para desarrollo
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def get_user_from_token(token: str):
    # Aquí deberías validar el token y devolver el usuario real
    # Para demo, solo devuelve un usuario de ejemplo
    if token == "demo-token-alice":
        return {
            "id": "alice-uuid",
            "name": "Alice",
            "avatar": "https://picsum.photos/50/50",
            "email": "alice@example.com"
        }
    elif token == "demo-token-marc":
        return {
            "id": "marc-uuid",
            "name": "Marc",
            "avatar": "https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?auto=format&fit=facearea&w=256&h=256&facepad=2&q=80",
            "email": "marc@spoonapp.com"
        }
    raise HTTPException(status_code=401, detail="Token inválido")

@app.post("/api/stories/upload/")
async def upload_story(
    image: UploadFile = File(None),
    video: UploadFile = File(None),
    token: str = Form(...)
):
    user = get_user_from_token(token)
    file = image or video
    if not file:
        raise HTTPException(status_code=400, detail="No file uploaded")
    ext = file.filename.split('.')[-1]
    story_id = str(uuid.uuid4())
    s3_key = f"stories/{user['id']}/{story_id}.{ext}"
    # Subir a S3
    s3.upload_fileobj(file.file, S3_BUCKET, s3_key, ExtraArgs={"ACL": "public-read"})
    url = f"https://{S3_BUCKET}.s3.{AWS_REGION}.amazonaws.com/{s3_key}"
    # Guardar en DynamoDB
    expires_at = (datetime.utcnow() + timedelta(hours=24)).isoformat()
    table.put_item(Item={
        "id": story_id,
        "user_id": user["id"],
        "user_name": user["name"],
        "avatar": user["avatar"],
        "email": user["email"],
        "url": url,
        "created_at": datetime.utcnow().isoformat(),
        "expires_at": expires_at,
        "type": "video" if video else "image"
    })
    return {"ok": True, "url": url}

@app.get("/api/stories/")
def get_stories():
    now = datetime.utcnow().isoformat()
    response = table.scan()
    stories = [
        {
            "id": item["id"],
            "user": item["user_name"],
            "avatar": item["avatar"],
            "url": item["url"],
            "created_at": item["created_at"],
            "expires_at": item["expires_at"]
        }
        for item in response.get("Items", [])
        if item["expires_at"] > now
    ]
    return {"stories": stories}
