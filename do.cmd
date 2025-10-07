docker build -t lambda-layer-fastapi-builder:latest .
docker rm temp_container2 2>nul & docker create --name temp_container2 lambda-layer-fastapi-builder:latest
docker cp temp_container2:/app/layer.zip ./lambda-layer-fastapi.zip
