# Moneyfy Solution Deployment Instructions

## To execute the UnitTests and create the corresponding report
```powershell
dotnet test --logger "html;LogFileName=Moneyfy_TestResults.html" --results-directory ./UnitTests/Reports/
```

## To create the SqlServer database migrations (to be executed in each WebApi project directory)
```powershell
dotnet ef migrations add ExpenseTables -p ..\Persistence\Persistence.csproj -s Expenses.WebApi.csproj --context ExpensesDbContext
dotnet ef migrations add IncomeTables -p ..\Persistence\Persistence.csproj -s Incomes.WebApi.csproj --context IncomesDbContext
dotnet ef migrations add NotificationTables -p ..\Persistence\Persistence.csproj -s Notifications.WebApi.csproj --context NotificationsDbContext
```

## To update the SqlServer database (optional, to be executed in each WebApi project directory or let to be updated in the WebApi execution)
```powershell
dotnet ef database update ExpenseTables -p ..\Persistence\Persistence.csproj -s Expenses.WebApi.csproj --context ExpensesDbContext
dotnet ef database update IncomeTables -p ..\Persistence\Persistence.csproj -s Incomes.WebApi.csproj --context IncomesDbContext
dotnet ef database update NotificationTables -p ..\Persistence\Persistence.csproj -s Notifications.WebApi.csproj --context NotificationsDbContext
```

> [!IMPORTANT]
> To update the Database executing the previous commands, remember to set the **DBConnection** param in the **appsettings.json** file, for each WebApi project. 
> 

## To create Docker images
```powershell
$env:GH_OWNER="dotnetmoondodev"
$env:GH_PAT="[PAT HERE]"
$appname="moneyfy-app"
$imgtag="1.2.6"
docker build --secret id=GH_OWNER --secret id=GH_PAT -f gateway.dockerfile -t "$appname.azurecr.io/gateway.moneyfy.webapi:$imgtag" .
docker build --secret id=GH_OWNER --secret id=GH_PAT -f expenses.dockerfile -t "$appname.azurecr.io/expenses.moneyfy.webapi:$imgtag" .
docker build --secret id=GH_OWNER --secret id=GH_PAT -f incomes.dockerfile -t "$appname.azurecr.io/incomes.moneyfy.webapi:$imgtag" .
docker build --secret id=GH_OWNER --secret id=GH_PAT -f payments.dockerfile -t "$appname.azurecr.io/payments.moneyfy.webapi:$imgtag" .
docker build --secret id=GH_OWNER --secret id=GH_PAT -f notifications.dockerfile -t "$appname.azurecr.io/notifications.moneyfy.webapi:$imgtag" .
docker build --secret id=GH_OWNER --secret id=GH_PAT -f webapp.dockerfile -t "$appname.azurecr.io/frontend.moneyfy.webapp:$imgtag" .
```

## To create Docker deployment
```powershell
docker compose up -d
```

## To delete the Docker deployment
```powershell
docker compose down
```
