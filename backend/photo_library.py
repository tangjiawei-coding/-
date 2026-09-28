"""经人工选图的本地图库；只有菜名、主料和做法都匹配才配照片。"""
import json
import re
import sqlite3
from pathlib import Path

DATABASE = Path(__file__).resolve().parents[1] / "data" / "recipe-library.sqlite3"


def entries():
    if not DATABASE.exists():
        return []
    with sqlite3.connect(f"{DATABASE.as_uri()}?mode=ro", uri=True) as db:
        return [json.loads(row[0]) for row in db.execute("SELECT metadata FROM dish_photos ORDER BY id")]


def normalize(value):
    return re.sub(r"[\s·（ ）()\-]", "", value).lower()


def match_photo(name, ingredients, method):
    names = {normalize(value) for value in ingredients}
    for photo in entries():
        if normalize(name) not in {normalize(value) for value in [photo["name"], *photo["aliases"]]}:
            continue
        if method not in photo["methods"]:
            continue
        if all(any(normalize(alias) in names for alias in group) for group in photo["ingredientGroups"]):
            return photo
    return None


def attach_photo(recipe):
    photo = match_photo(recipe["name"], [item["name"] for item in recipe["items"]], recipe["method"])
    if photo:
        recipe["image"] = photo["file"]
        recipe["photoCredit"] = {key: photo[key] for key in ("name", "author", "license", "licenseUrl", "sourcePage")}
    return recipe
