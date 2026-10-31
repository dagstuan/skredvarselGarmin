FROM mcr.microsoft.com/dotnet/sdk:10.0.403 AS base
RUN apt-get update
RUN apt-get install -y npm
RUN npm install -g n
RUN n lts
# Node 25+ no longer bundles corepack.
RUN npm install -g corepack
RUN corepack enable

FROM base AS builder
WORKDIR /app
COPY . .
WORKDIR /app/SkredvarselGarminWeb/Frontend
RUN corepack prepare --activate
WORKDIR /app
RUN dotnet test
RUN dotnet publish SkredvarselGarminWeb -c Release -o publish

FROM mcr.microsoft.com/dotnet/sdk:10.0.403
EXPOSE 8080
WORKDIR /app
COPY --from=builder /app/publish ./
ENTRYPOINT ["dotnet", "SkredvarselGarminWeb.dll", "--urls", "http://*:8080"]

