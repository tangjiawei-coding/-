# 在此目录运行 .\start.ps1；密钥只进入当前进程环境，不落盘。
# 新环境先运行 python -m pip install -r requirements.txt。
# USB 调试时执行 hdc rport tcp:8000 tcp:8000，手机后端地址保持默认值。
param([string]$ListenAddress = '127.0.0.1', [int]$Port = 8000)
$ErrorActionPreference = 'Stop'
if (-not $env:OPENAI_API_KEY) {
    $secureKey = Read-Host '请输入模型 API 密钥（输入隐藏）' -AsSecureString
    $env:OPENAI_API_KEY = [System.Net.NetworkCredential]::new('', $secureKey).Password
}
if (-not $env:OPENAI_API_KEY.Trim()) { throw 'API 密钥不能为空' }
Push-Location $PSScriptRoot
try {
    python -m uvicorn main:app --host $ListenAddress --port $Port
} finally {
    Pop-Location
}
