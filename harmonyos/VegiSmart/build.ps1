$ErrorActionPreference = 'Stop'

$studioPath = [Environment]::GetEnvironmentVariable('DEVECO_CLI_STUDIO_PATH', 'User')
if (!$studioPath) { $studioPath = 'D:\Huawei\DevEcoStudio' }
$env:DEVECO_CLI_STUDIO_PATH = $studioPath

# Hvigor 会还原映射路径，因此从中文源码目录同步到英文目录编译。
$buildRoot = 'D:\Huawei\Projects\VegiSmartBuild'
New-Item -ItemType Directory -Path $buildRoot -Force | Out-Null
# 自动签名保存在本机编译目录，同步源码时保留它，签名材料不进入源码仓库。
$profilePath = Join-Path $buildRoot 'build-profile.json5'
$localProfile = if (Test-Path -LiteralPath $profilePath) {
  Get-Content -LiteralPath $profilePath -Raw | ConvertFrom-Json
}
robocopy $PSScriptRoot $buildRoot /E /XD .hvigor oh_modules build .idea /XF local.properties /NFL /NDL /NJH /NJS /NP
if ($LASTEXITCODE -ge 8) { throw '工程同步失败' }
if ($localProfile.app.signingConfigs.Count -gt 0) {
  $buildProfile = Get-Content -LiteralPath $profilePath -Raw | ConvertFrom-Json
  $buildProfile.app.signingConfigs = $localProfile.app.signingConfigs
  foreach ($product in $buildProfile.app.products) {
    $localProduct = $localProfile.app.products | Where-Object { $_.name -eq $product.name }
    $signingName = if ($localProduct.signingConfig) {
      $localProduct.signingConfig
    } else {
      $localProfile.app.signingConfigs[0].name
    }
    $product | Add-Member -NotePropertyName signingConfig -NotePropertyValue $signingName -Force
  }
  $buildProfile | ConvertTo-Json -Depth 30 | Set-Content -LiteralPath $profilePath -Encoding utf8
}

Push-Location $buildRoot
try {
  devecocli build --modules entry --build-mode debug
  if ($LASTEXITCODE -ne 0) { throw '鸿蒙工程编译失败' }
  Get-ChildItem -Path 'entry\build\default\outputs\default\*.hap' | Select-Object FullName, Length
} finally {
  Pop-Location
}
