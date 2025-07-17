# Moneyfy Solution Deployment Instructions

## To execute the UnitTests and create the corresponding report
```powershell
dotnet test --logger "html;LogFileName=Moneyfy_TestResults.html" --results-directory ./UnitTests/Reports/
```

> [!IMPORTANT]
> To update the Database executing the previous commands, remember to set the **DBConnection** param in the **appsettings.json** file, for each WebApi project. 
> 

## To create Docker images
```powershell
$appname="moneyfy"
docker build -f gateway.dockerfile -t "$appname.azurecr.io/gateway.moneyfy.webapi:latest" .
docker build -f expenses.dockerfile -t "$appname.azurecr.io/expenses.moneyfy.webapi:latest" .
docker build -f incomes.dockerfile -t "$appname.azurecr.io/incomes.moneyfy.webapi:latest" .
docker build -f payments.dockerfile -t "$appname.azurecr.io/payments.moneyfy.webapi:latest" .
docker build -f notifications.dockerfile -t "$appname.azurecr.io/notifications.moneyfy.webapi:latest" .
docker build -f webapp.dockerfile -t "$appname.azurecr.io/frontend.moneyfy.webapp:latest" .
```

## To create Docker deployment
```powershell
docker compose up -d
```

## To delete the Docker deployment
```powershell
docker compose down
```
