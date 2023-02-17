FROM mcr.microsoft.com/dotnet/sdk:7.0.102-bullseye-slim as builder
WORKDIR /app
COPY SkredvarselGarminWeb SkredvarselGarminWeb/
RUN dotnet publish SkredvarselGarminWeb -c Release -o publish

FROM mcr.microsoft.com/dotnet/sdk:7.0.102-bullseye-slim
EXPOSE 8080
WORKDIR /app
COPY --from=builder /app/publish ./
ENTRYPOINT ["dotnet", "SkredvarselGarminWeb.dll", "--urls", "http://*:8080"]

