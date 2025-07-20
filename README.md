# Moneyfy Solution Deployment Instructions

## To execute the UnitTests and create the corresponding report
```powershell
dotnet test --logger "html;LogFileName=Moneyfy_TestResults.html" --results-directory ./UnitTests/Reports/
```

## To create Docker images
```powershell
$appname="moneyfy-app"
docker build -f gateway.dockerfile -t "$appname.azurecr.io/gateway.moneyfy.webapi:1.1.0" .
docker build -f expenses.dockerfile -t "$appname.azurecr.io/expenses.moneyfy.webapi:1.1.0" .
docker build -f incomes.dockerfile -t "$appname.azurecr.io/incomes.moneyfy.webapi:1.1.0" .
docker build -f payments.dockerfile -t "$appname.azurecr.io/payments.moneyfy.webapi:1.1.0" .
docker build -f notifications.dockerfile -t "$appname.azurecr.io/notifications.moneyfy.webapi:1.1.0" .
docker build -f webapp.dockerfile -t "$appname.azurecr.io/frontend.moneyfy.webapp:1.1.0" .
```

## To create Docker deployment
```powershell
docker compose up -d
```

## To delete the Docker deployment
```powershell
docker compose down
```
