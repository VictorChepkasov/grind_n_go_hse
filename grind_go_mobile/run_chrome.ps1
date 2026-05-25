# Запуск Grind & Go в Chrome.
# Используйте этот скрипт, если команда `flutter` падает с ошибкой engine.stamp.

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

$dart = "C:\Program Files\Flutter\flutter\bin\cache\dart-sdk\bin\dart.exe"
$flutterTools = "C:\Program Files\Flutter\flutter\packages\flutter_tools\bin\flutter_tools.dart"

if (-not (Test-Path $dart)) {
    Write-Error "Dart SDK не найден. Установите Flutter: https://docs.flutter.dev/get-started/install/windows"
}

& $dart $flutterTools pub get
& $dart $flutterTools run -d chrome @args
