import base64
import json
import unittest
from unittest.mock import patch

import httpx
from fastapi.testclient import TestClient

from main import RecognitionRequest, app, make_payload, parse_response


IMAGE = "data:image/png;base64," + base64.b64encode(b"\x89PNG\r\n\x1a\nfixture").decode()
FOOD = {
    "name": "番茄", "observations": ["表面有裂口"], "appearance": "visible_concern",
    "onSiteChecks": ["现场核对裂口情况"], "buyingAdvice": "建议换一份完整的食材",
    "needsRetake": False, "retakeReason": None, "gramsPerPerson": 150,
    "quantityNote": "仅为计划用量，可按菜谱修改",
}


def envelope(food=FOOD):
    return {"status": "completed", "output": [
        {"type": "reasoning", "summary": []},
        {"type": "message", "content": [{"type": "output_text", "text": json.dumps(food)}]},
    ]}


class RecognitionTests(unittest.TestCase):
    def setUp(self):
        self.client = TestClient(app)

    def test_wire_contract_and_storage(self):
        with patch.dict("os.environ", {"OPENAI_MODEL": "gpt-5.5"}):
            payload = make_payload(RecognitionRequest(imageDataUrl=IMAGE))
        self.assertEqual(payload["model"], "gpt-5.5")
        self.assertIs(payload["store"], False)
        self.assertEqual(payload["input"][0]["content"][1]["type"], "input_image")
        schema = payload["text"]["format"]["schema"]
        self.assertEqual(set(schema["required"]), set(schema["properties"]))
        self.assertFalse(schema["additionalProperties"])

    def test_parse_skips_reasoning_and_checks_result(self):
        self.assertEqual(parse_response(envelope()).name, "番茄")
        unknown = dict(FOOD, name=None)
        self.assertTrue(parse_response(envelope(unknown)).needsRetake)
        self.assertIsNone(parse_response(envelope(unknown)).gramsPerPerson)
        with self.assertRaises(ValueError):
            parse_response({"status": "incomplete", "output": []})
        with self.assertRaises(ValueError):
            parse_response(envelope(dict(FOOD, gramsPerPerson=-1)))
        with self.assertRaises(ValueError):
            parse_response({"status": "completed", "output": [{"type": "message", "content": [{"type": "refusal"}]}]})

    def test_missing_key_never_falls_back_to_fixture(self):
        with patch.dict("os.environ", {"OPENAI_API_KEY": ""}):
            response = self.client.post("/recognitions", json={"imageDataUrl": IMAGE})
        self.assertEqual(response.status_code, 503)
        self.assertNotIn("name", response.json())

    def test_invalid_image_is_not_echoed(self):
        for value in ("https://example.com/private.png", "data:image/png;base64,c2VjcmV0"):
            response = self.client.post("/recognitions", json={"imageDataUrl": value})
            self.assertEqual(response.status_code, 422)
            self.assertNotIn(value, response.text)

    def test_upstream_success_errors_and_no_secret_leak(self):
        # MockTransport 拦截请求，不向真实服务发送图片或消耗额度。
        real_client = httpx.AsyncClient
        cases = [(200, envelope(), 200), (401, {"secret": "hidden"}, 502),
                 (429, {}, 503), (200, {"status": "incomplete"}, 502)]
        for status, body, expected in cases:
            def handler(request):
                self.assertEqual(str(request.url), "https://ai.novacode.top/v1/responses")
                self.assertEqual(request.headers["authorization"], "Bearer test-key")
                self.assertIs(json.loads(request.content)["store"], False)
                return httpx.Response(status, json=body)
            with patch.dict("os.environ", {"OPENAI_API_KEY": "test-key", "OPENAI_BASE_URL": "https://ai.novacode.top/v1"}):
                with patch("main.httpx.AsyncClient", lambda **kw: real_client(transport=httpx.MockTransport(handler), **kw)):
                    response = self.client.post("/recognitions", json={"imageDataUrl": IMAGE})
            self.assertEqual(response.status_code, expected)
            self.assertNotIn("hidden", response.text)
            self.assertNotIn("test-key", response.text)

    def test_timeout_does_not_return_success(self):
        real_client = httpx.AsyncClient
        def handler(request):
            raise httpx.ReadTimeout("upstream timed out", request=request)
        with patch.dict("os.environ", {"OPENAI_API_KEY": "test-key"}):
            with patch("main.httpx.AsyncClient", lambda **kw: real_client(transport=httpx.MockTransport(handler), **kw)):
                response = self.client.post("/recognitions", json={"imageDataUrl": IMAGE})
        self.assertEqual(response.status_code, 504)


if __name__ == "__main__":
    unittest.main()
