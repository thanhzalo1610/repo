# Runtime stage only (no build needed)
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app

# Copy all files (already built)
COPY . .

# Expose port
EXPOSE 80
EXPOSE 443

ENTRYPOINT ["dotnet", "Cms.Legal.Web.dll"]
