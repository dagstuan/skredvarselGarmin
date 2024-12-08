FROM mcr.microsoft.com/dotnet/sdk:9.0.101-bookworm-slim AS base
RUN apt-get update
RUN apt-get install -y ca-certificates curl gnupg
RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

ENV NODE_MAJOR=20
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list

RUN apt-get update
RUN apt-get install -y nodejs

FROM base as builder
WORKDIR /app
COPY . .
RUN dotnet test
RUN dotnet publish SkredvarselGarminWeb -c Release -o publish

FROM mcr.microsoft.com/dotnet/sdk:9.0.101-bookworm-slim
EXPOSE 8080
WORKDIR /app
COPY --from=builder /app/publish ./
ENTRYPOINT ["dotnet", "SkredvarselGarminWeb.dll", "--urls", "http://*:8080"]

