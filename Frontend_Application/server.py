from fastapi import FastAPI, UploadFile, File
from pydantic import BaseModel

app = FastAPI()

class UserLatestInfo(BaseModel):
    user_id: str

@app.post("/user_latest_info")
async def get_user_latest_info(info: UserLatestInfo):
    # 여기에서 사용자의 최신 여행 정보와 추천 장소 정보를 조회하는 로직을 구현합니다.
    # 예시로 임의의 데이터를 반환합니다.
    return {
        "latestTravel": {
            "date": "2023-06-01",
            "stars": "4.5",
            "diary": "It was an amazing trip!",
            "photo_save_path": "/path/to/photo.jpg"
        },
        "recommendedPlaces": [
            {
                "poi_id": "POI123",
                "title": "Eiffel Tower",
                "first_image": "https://example.com/eiffel_tower.jpg"
            },
            {
                "poi_id": "POI456",
                "title": "Louvre Museum",
                "first_image": "https://example.com/louvre_museum.jpg"
            }
        ]
    }

@app.post("/upload")
async def upload_image(image: UploadFile = File(...)):
    # 여기에서 업로드된 이미지를 처리하는 로직을 구현합니다.
    # 예시로 업로드된 파일의 이름을 반환합니다.
    return {"filename": image.filename}