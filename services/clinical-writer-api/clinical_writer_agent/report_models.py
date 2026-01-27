from datetime import datetime
from typing import Annotated, Literal, Optional, Union

from pydantic import BaseModel, Field

class Span(BaseModel):
    text: str
    bold: bool = False
    italic: bool = False

class ParagraphBlock(BaseModel):
    type: Literal["paragraph"] = "paragraph"
    spans: list[Span]

class BulletItem(BaseModel):
    spans: list[Span]

class BulletListBlock(BaseModel):
    type: Literal["bullet_list"] = "bullet_list"
    items: list[BulletItem]

class KeyValueItem(BaseModel):
    key: str
    value: list[Span]

class KeyValueBlock(BaseModel):
    type: Literal["key_value"] = "key_value"
    items: list[KeyValueItem]

Block = Annotated[
    Union[ParagraphBlock, BulletListBlock, KeyValueBlock],
    Field(discriminator="type"),
]

class Section(BaseModel):
    title: str
    blocks: list[Block]

class PatientInfo(BaseModel):
    name: Optional[str] = None
    reference: Optional[str] = None
    birth_date: Optional[str] = None
    sex: Optional[str] = None

class ReportDocument(BaseModel):
    title: str
    subtitle: Optional[str] = None
    created_at: datetime
    patient: PatientInfo
    sections: list[Section]
