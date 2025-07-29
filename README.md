# Moneyfy Solution Deployment Instructions

## To execute the UnitTests and create the corresponding report
```powershell
dotnet test --logger "html;LogFileName=Moneyfy_TestResults.html" --results-directory ./UnitTests/Reports/
```

## To create Docker images
```powershell
$env:GH_OWNER="dotnetmoondodev"
$env:GH_PAT="[PAT HERE]"
$appname="moneyfy-app"
docker build --secret id=GH_OWNER --secret id=GH_PAT -f gateway.dockerfile -t "$appname.azurecr.io/gateway.moneyfy.webapi:1.1.3" .
docker build --secret id=GH_OWNER --secret id=GH_PAT -f expenses.dockerfile -t "$appname.azurecr.io/expenses.moneyfy.webapi:1.1.3" .
docker build --secret id=GH_OWNER --secret id=GH_PAT -f incomes.dockerfile -t "$appname.azurecr.io/incomes.moneyfy.webapi:1.1.3" .
docker build --secret id=GH_OWNER --secret id=GH_PAT -f payments.dockerfile -t "$appname.azurecr.io/payments.moneyfy.webapi:1.1.3" .
docker build --secret id=GH_OWNER --secret id=GH_PAT -f notifications.dockerfile -t "$appname.azurecr.io/notifications.moneyfy.webapi:1.1.3" .
docker build --secret id=GH_OWNER --secret id=GH_PAT -f webapp.dockerfile -t "$appname.azurecr.io/frontend.moneyfy.webapp:1.1.3" .
```

## To create Docker deployment
```powershell
docker compose up -d
```

## To delete the Docker deployment
```powershell
docker compose down
```
