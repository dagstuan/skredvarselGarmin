FROM mcr.microsoft.com/dotnet/sdk:7.0.304-bullseye-slim AS base
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y libpng-dev libjpeg-dev curl libxi6 build-essential libgl1-mesa-glx lsb-release
RUN curl -sL https://deb.nodesource.com/setup_lts.x | bash -
RUN apt-get install -y nodejs

FROM base as builder
WORKDIR /app
COPY SkredvarselGarminWeb SkredvarselGarminWeb/
RUN dotnet publish SkredvarselGarminWeb -c Release -o publish

FROM mcr.microsoft.com/dotnet/sdk:7.0.304-bullseye-slim
EXPOSE 8080
WORKDIR /app
COPY --from=builder /app/publish ./
ENTRYPOINT ["dotnet", "SkredvarselGarminWeb.dll", "--urls", "http://*:8080"]

