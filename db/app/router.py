from fastapi import APIRouter, HTTPException
from typing import List
from .database import db
from .models import Survey

router = APIRouter()

@router.post("/surveys/", response_model=Survey)
async def create_survey(survey: Survey):
    survey_dict = survey.dict(by_alias=True)
    result = db.surveys.insert_one(survey_dict)
    if not result.inserted_id:
        raise HTTPException(status_code=500, detail="Survey could not be created")
    return survey

@router.get("/surveys/", response_model=List[Survey])
async def get_surveys():
    surveys = []
    for survey in db.surveys.find():
        surveys.append(Survey(**survey))
    return surveys

@router.get("/surveys/{survey_id}", response_model=Survey)
async def get_survey(survey_id: str):
    survey = db.surveys.find_one({"surveyId": survey_id})
    if survey:
        return Survey(**survey)
    raise HTTPException(status_code=404, detail="Survey not found")
