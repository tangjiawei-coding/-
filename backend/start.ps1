# 在此目录运行 .\start.ps1；从当前用户的加密凭据读取密钥，仅注入后端进程。
# 新环境先运行 python -m pip install -r requirements.txt。
# USB 调试时执行 hdc rport tcp:8000 tcp:8000，手机后端地址保持默认值。
param([string]$ListenAddress = '127.0.0.1', [int]$Port = 8000)
$ErrorActionPreference = 'Stop'
if (-not $env:OPENAI_API_KEY) {
    $keyPath = Join-Path $env:LOCALAPPDATA 'VegiSmart\model-key.xml'
    $secureKey = if (Test-Path -LiteralPath $keyPath) { Import-Clixml -LiteralPath $keyPath } else {
        Read-Host '请输入模型 API 密钥（输入隐藏）' -AsSecureString
    }
    $env:OPENAI_API_KEY = [System.Net.NetworkCredential]::new('', $secureKey).Password
}
if (-not $env:OPENAI_API_KEY.Trim()) { throw 'API 密钥不能为空' }
Push-Location $PSScriptRoot
try {
    python -m uvicorn main:app --host $ListenAddress --port $Port --no-access-log
} finally {
    Pop-Location
}
