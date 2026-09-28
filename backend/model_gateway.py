"""只在后端调用模型，错误响应不回显密钥、图片或网关原文。"""
import os

import httpx
from fastapi import HTTPException


async def request_model(payload: dict) -> dict:
    key = os.getenv("OPENAI_API_KEY", "").strip()
    if not key:
        raise HTTPException(503, "后端尚未配置模型密钥")
    base_url = os.getenv("OPENAI_BASE_URL", "https://ai.novacode.top/v1").rstrip("/")
    try:
        # 本机系统代理的 HTTPS 握手异常；直接连接网关，仍验证 TLS 证书。
        async with httpx.AsyncClient(timeout=httpx.Timeout(150, connect=10), trust_env=False) as client:
            response = await client.post(f"{base_url}/responses", headers={"Authorization": f"Bearer {key}"}, json=payload)
        if response.status_code in (401, 403):
            raise HTTPException(502, "模型服务认证失败，请检查后端密钥和账号权限")
        if response.status_code == 429:
            raise HTTPException(503, "模型服务额度不足或请求过多，请稍后重试")
        if response.status_code >= 400:
            raise HTTPException(502, f"模型请求失败（{response.status_code}），请稍后重试")
        return response.json()
    except httpx.TimeoutException:
        raise HTTPException(504, "分析超时，请稍后重试或手动输入食材名称") from None
    except httpx.RequestError:
        raise HTTPException(502, "暂时无法连接模型服务，请稍后重试") from None
    except ValueError:
        raise HTTPException(502, "模型服务返回了无法读取的结果，请重试") from None


def output_text(body: dict) -> str:
    if body.get("status") != "completed":
        raise ValueError("模型未完成分析")
    texts = []
    for item in body.get("output", []):
        if item.get("type") != "message":
            continue
        for part in item.get("content", []):
            if part.get("type") == "refusal":
                raise ValueError("模型未提供分析")
            if part.get("type") == "output_text":
                texts.append(part["text"])
    if not texts:
        raise ValueError("模型没有返回文本")
    return "".join(texts)
