FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /app

COPY src/IPOSetu.Domain/IPOSetu.Domain.csproj src/IPOSetu.Domain/
COPY src/IPOSetu.Application/IPOSetu.Application.csproj src/IPOSetu.Application/
COPY src/IPOSetu.Infrastructure/IPOSetu.Infrastructure.csproj src/IPOSetu.Infrastructure/
COPY src/IPOSetu.API/IPOSetu.API.csproj src/IPOSetu.API/

RUN dotnet restore src/IPOSetu.API/IPOSetu.API.csproj

COPY src/ src/
RUN dotnet publish src/IPOSetu.API/IPOSetu.API.csproj -c Release -o /out

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app
COPY --from=build /out ./

EXPOSE 8080
ENTRYPOINT ["dotnet", "IPOSetu.API.dll"]
