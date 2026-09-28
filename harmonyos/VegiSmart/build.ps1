$ErrorActionPreference = 'Stop'

$studioPath = [Environment]::GetEnvironmentVariable('DEVECO_CLI_STUDIO_PATH', 'User')
if (!$studioPath) { $studioPath = 'D:\Huawei\DevEcoStudio' }
$env:DEVECO_CLI_STUDIO_PATH = $studioPath

# Hvigor 会还原映射路径，因此从中文源码目录同步到英文目录编译。
$buildRoot = 'D:\Huawei\Projects\VegiSmartBuild'
New-Item -ItemType Directory -Path $buildRoot -Force | Out-Null
robocopy $PSScriptRoot $buildRoot /E /XD .hvigor oh_modules build .idea /XF local.properties /NFL /NDL /NJH /NJS /NP
if ($LASTEXITCODE -ge 8) { throw '工程同步失败' }

Push-Location $buildRoot
try {
  devecocli build --modules entry --build-mode debug
  if ($LASTEXITCODE -ne 0) { throw '鸿蒙工程编译失败' }
  Get-ChildItem -Path 'entry\build\default\outputs\default\*.hap' | Select-Object FullName, Length
} finally {
  Pop-Location
}
