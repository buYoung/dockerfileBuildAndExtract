@echo off
docker build . -t lserver_builder 
docker run --name=builder lserver_builder
docker cp builder:/app/dist ./
docker rm builder
