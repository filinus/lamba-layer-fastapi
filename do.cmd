set ARCH=
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" set ARCH=x86_64
if "%PROCESSOR_ARCHITECTURE%"=="ARM64" set ARCH=arm64
if "%ARCH%"=="" (
    echo Unknown architecture: %PROCESSOR_ARCHITECTURE%
    exit /b 1
)

docker build --build-arg ARCH=%ARCH%  -t lambda-layer-fastapi-builder:%ARCH% .
docker rm temp_container2 2>nul & docker create --name temp_container2 lambda-layer-fastapi-builder:%ARCH%
docker cp temp_container2:/app/layer.zip ./lambda-layer-fastapi.zip
