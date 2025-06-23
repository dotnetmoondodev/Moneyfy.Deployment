FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS base
USER $APP_UID
WORKDIR /app
EXPOSE 8031

FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["WebApp/WebApp.csproj", "WebApp/"]
COPY ["Application/Application.csproj", "Application/"]

RUN dotnet restore "./WebApp/WebApp.csproj"
COPY . .
WORKDIR "/src/WebApp"
RUN dotnet publish "./WebApp.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "Moneyfy.WebApp.dll"]
