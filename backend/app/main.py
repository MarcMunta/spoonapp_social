from fastapi import FastAPI

app = FastAPI(title="SpoonApp API")

@app.get("/")
def read_root():
    return {"message": "SpoonApp API"}
