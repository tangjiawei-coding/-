"""从已审核的照片清单生成 SQLite、网页和鸿蒙图库；--download 获取原站缩略图。"""
import argparse
import hashlib
import json
import shutil
import sqlite3
import time
from pathlib import Path

import httpx

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "data"
WEB = ROOT / "web-demo/ui-preview"
NATIVE = ROOT / "harmonyos/VegiSmart/entry/src/main"


def build(download=False):
    photos = json.loads((DATA / "photo-library.json").read_text(encoding="utf-8"))
    for photo in photos:
        assert photo["reviewed"] and photo["license"] in {"CC0", "Public domain", "CC BY 2.0", "CC BY 3.0", "CC BY 4.0", "CC BY-SA 2.0", "CC BY-SA 3.0", "CC BY-SA 4.0"}
        target = WEB / "assets" / photo["file"]
        target.parent.mkdir(parents=True, exist_ok=True)
        if download and not target.exists():
            with httpx.Client(trust_env=False, follow_redirects=True, timeout=45,
                              headers={"User-Agent": "VegiSmart/0.1 (licensed food image catalog)"}) as client:
                response = client.get(photo["downloadUrl"])
                if response.status_code == 429:
                    raise RuntimeError("图片站点限流，请稍后重新运行；已下载文件会复用")
                response.raise_for_status()
                assert response.headers.get("content-type", "").startswith("image/")
                target.write_bytes(response.content)
            time.sleep(2)
        if not target.exists():
            raise FileNotFoundError(target)
        photo["sha256"] = hashlib.sha256(target.read_bytes()).hexdigest()
        photo["bytes"] = target.stat().st_size
        destination = NATIVE / "resources/rawfile" / photo["file"]
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(target, destination)

    (DATA / "photo-library.json").write_text(json.dumps(photos, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    with sqlite3.connect(DATA / "recipe-library.sqlite3") as db:
        db.execute("CREATE TABLE IF NOT EXISTS dish_photos (id TEXT PRIMARY KEY, name TEXT NOT NULL, metadata TEXT NOT NULL)")
        db.execute("DELETE FROM dish_photos")
        db.executemany("INSERT INTO dish_photos VALUES (?,?,?)", [(p["id"], p["name"], json.dumps(p, ensure_ascii=False)) for p in photos])

    public = [{key: p[key] for key in ("id", "name", "aliases", "methods", "ingredientGroups", "file", "author", "license", "licenseUrl", "sourcePage")} for p in photos]
    (WEB / "photo-library.js").write_text("// 由 scripts/build_photo_library.py 生成。\nconst PHOTO_LIBRARY = " + json.dumps(public, ensure_ascii=False, indent=2) + ";\n", encoding="utf-8")
    manifest_path = WEB / "assets/manifest.json"
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    manifest["images"] = [item for item in manifest["images"] if item["file"] == "market.jpg"] + [
        {key: p[key] for key in ("file", "name", "author", "license", "licenseUrl", "sourcePage", "changes", "sha256")}
        for p in photos]
    manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    shutil.copyfile(manifest_path, NATIVE / "resources/rawfile/manifest.json")
    schema = """// 由 scripts/build_photo_library.py 生成，逐张保留原作者及许可。
export interface LibraryPhoto {
  id: string; name: string; aliases: string[]; methods: string[]; ingredientGroups: string[][];
  file: string; author: string; license: string; licenseUrl: string; sourcePage: string;
}
"""
    (NATIVE / "ets/model/PhotoLibrary.ets").write_text(schema + "export const PHOTO_LIBRARY: LibraryPhoto[] = " + json.dumps(public, ensure_ascii=False, indent=2) + ";\n", encoding="utf-8")
    print(f"已生成 {len(photos)} 条图库记录，图片合计 {sum(p['bytes'] for p in photos) / 1024 / 1024:.2f} MB")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--download", action="store_true")
    build(parser.parse_args().download)
