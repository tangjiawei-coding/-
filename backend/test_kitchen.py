import json
import unittest
from unittest.mock import AsyncMock, patch

from fastapi.testclient import TestClient
from main import app
from kitchen import ExploreRequest, make_payload


def result():
    food = dict(name="茄子", aliases=[], subtitle="家常食材", summary="适合蒸烧",
                description="茄科蔬菜", preparation="洗净去蒂", storage="短期冷藏", pairing="蒜和鸡蛋")
    item = dict(name="茄子", amount="300 克", group="主料", category="蔬菜",
                description="口感柔软", preparation="洗净去蒂")
    recipe = dict(name="蒸茄子", subtitle="简单家常菜", pairing="搭配米饭", time="20 分钟", method="清蒸",
                  items=[item, dict(item, name="蒜", amount="2 瓣", group="辅料")],
                  steps=[dict(title="准备", description="洗净食材") for _ in range(3)], story="蒸熟后调味。")
    return dict(status="ready", message="", food=food,
                recipes=[dict(recipe, name=name) for name in ("蒸茄子", "烧茄子", "煎茄子")])


def envelope(value):
    return {"status": "completed", "output": [{"type": "message", "content": [
        {"type": "output_text", "text": json.dumps(value, ensure_ascii=False)}]}]}


class KitchenTests(unittest.TestCase):
    def setUp(self):
        self.client = TestClient(app)

    def test_contract_keeps_image_and_disables_storage(self):
        payload = make_payload(ExploreRequest(name="茄子"))
        self.assertIs(payload["store"], False)
        self.assertTrue(payload["text"]["format"]["strict"])
        self.assertEqual(payload["text"]["format"]["schema"]["$defs"]["Recipe"]["properties"]["method"]["enum"][0], "清炒")

    def test_complete_result_preserves_ingredient_information(self):
        with patch("kitchen.request_model", AsyncMock(return_value=envelope(result()))):
            response = self.client.post("/api/explorations", json={"name": "茄子"})
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertEqual(len(data["recipes"]), 3)
        self.assertEqual(data["food"]["recipeIds"], [r["id"] for r in data["recipes"]])
        self.assertEqual(data["recipes"][0]["ingredientInfos"][1]["name"], "蒜")
        self.assertEqual(data["recipes"][0]["source"], "")

    def test_uncertain_input_has_no_recipe_fallback(self):
        unknown = dict(status="needs_input", message="请只拍一种食材", food=None, recipes=[])
        with patch("kitchen.request_model", AsyncMock(return_value=envelope(unknown))):
            response = self.client.post("/api/explorations", json={"name": "这是什么"})
        self.assertEqual(response.json(), unknown)

    def test_incomplete_duplicate_and_injected_output_are_rejected(self):
        invalid = result()
        invalid["recipes"] = invalid["recipes"][:2]
        duplicate = result()
        duplicate["recipes"][1]["name"] = duplicate["recipes"][0]["name"]
        injected = result()
        injected["recipes"][0]["source"] = "https://untrusted.example"
        for value in (invalid, duplicate, injected):
            with self.subTest(value=value), patch("kitchen.request_model", AsyncMock(return_value=envelope(value))):
                response = self.client.post("/api/explorations", json={"name": "茄子"})
                self.assertEqual(response.status_code, 502)
                self.assertNotIn("untrusted.example", response.text)

    def test_invalid_input_never_calls_model_or_echoes_image(self):
        with patch("kitchen.request_model", AsyncMock()) as gateway:
            for value in ({}, {"imageDataUrl": "data:image/png;base64,private-photo"}, {"name": "x" * 41}):
                response = self.client.post("/api/explorations", json=value)
                self.assertEqual(response.status_code, 422)
                self.assertNotIn("private-photo", response.text)
            gateway.assert_not_called()

    def test_missing_key_and_browser_cors(self):
        with patch.dict("os.environ", {"OPENAI_API_KEY": ""}):
            response = self.client.post("/api/explorations", json={"name": "茄子"})
        self.assertEqual(response.status_code, 503)
        response = self.client.options("/api/explorations", headers={"Origin": "http://127.0.0.1:8765",
                                      "Access-Control-Request-Method": "POST"})
        self.assertEqual(response.headers["access-control-allow-origin"], "http://127.0.0.1:8765")


if __name__ == "__main__":
    unittest.main()
