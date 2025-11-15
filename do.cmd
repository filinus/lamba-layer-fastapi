@echo off

docker info >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker is not installed or not running.
    exit /b 1
)

echo [OK] Docker is available.

REM  X86_64
docker build ^
    --platform linux/amd64 ^
    --build-arg ARCH=x86_64 ^
    -t lambda-layer-fastapi-builder:x86_64 .

docker rm temp_container2 2>nul & docker create --name temp_container2 lambda-layer-fastapi-builder:x86_64
docker cp temp_container2:/app/layer.zip ./lambda-layer-fastapi-amd64.zip

REM  ARM64
docker build ^
    --platform linux/arm64 ^
    --build-arg ARCH=arm64 ^
    -t lambda-layer-fastapi-builder:arm64 .

docker rm temp_container2 2>nul & docker create --name temp_container2 lambda-layer-fastapi-builder:arm64
docker cp temp_container2:/app/layer.zip ./lambda-layer-fastapi-arm64.zip

dir /p *.zip