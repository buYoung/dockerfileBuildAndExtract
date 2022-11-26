FROM golang:1.19-buster as builder

WORKDIR /app

//go의 mod 와 sum을  workdir폴더로 복사 (캐시사용)
COPY /src/go.* ./
RUN go mod download // sum의 데이터를 이용해서 library 다운로드

// src폴더 안에 있는 go 소스코드 복사 (workdir로 이동한폴더로)
COPY /src/. ./

// 대상 아키텍처와 운영체제로 빌드
RUN set GOARCH=amd64 && \  
 set GOOS=linux && \
 go build -o dist/main -ldflags="-s -w"  main.go // ldflags 옵션으로 디버깅내용 제거

//빌드 클린하게 
FROM debian:buster-slim 
RUN set -x && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Copy the binary to the production image from the builder stage.

builder의 파일복사
COPY --from=builder /app/dist/main /app/dist/main
