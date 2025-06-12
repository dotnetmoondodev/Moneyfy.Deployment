# Moneyfy Solution Deployment Instructions

## To Create the SqlServer Database Migrations (to be executed in each WebApi project directory)
- [x]  dotnet ef migrations add ExpenseTables -p ..\Persistence\Persistence.csproj -s Expenses.WebApi.csproj --context ExpensesDbContext
- [x]  dotnet ef migrations add IncomeTables -p ..\Persistence\Persistence.csproj -s Incomes.WebApi.csproj --context IncomesDbContext
- [x]  dotnet ef migrations add PaymentTables -p ..\Persistence\Persistence.csproj -s Payments.WebApi.csproj --context PaymentsDbContext
- [x]  dotnet ef migrations add NotificationTables -p ..\Persistence\Persistence.csproj -s Notifications.WebApi.csproj --context NotificationsDbContext

## To Update the SqlServer Database (optional, to be executed in each WebApi project directory or let to be updated in the WebApi execution)
- [x]  dotnet ef database update ExpenseTables -p ..\Persistence\Persistence.csproj -s Expenses.WebApi.csproj --context ExpensesDbContext
- [x]  dotnet ef database update IncomeTables -p ..\Persistence\Persistence.csproj -s Incomes.WebApi.csproj --context IncomesDbContext
- [x]  dotnet ef database update PaymentTables -p ..\Persistence\Persistence.csproj -s Payments.WebApi.csproj --context PaymentsDbContext
- [x]  dotnet ef database update NotificationTables -p ..\Persistence\Persistence.csproj -s Notifications.WebApi.csproj --context NotificationsDbContext

> [!IMPORTANT]
> To update the Database executing the previous commands, remember to set the **DBConnection** param in the **appsettings.json** file, for each WebApi project. 
> 

## To Create Docker Images
- [x]  docker build -f expenses.dockerfile -t expenses.moneyfy.webapi .
- [x]  docker build -f incomes.dockerfile -t incomes.moneyfy.webapi .
- [x]  docker build -f payments.dockerfile -t payments.moneyfy.webapi .
- [x]  docker build -f notifications.dockerfile -t notifications.moneyfy.webapi .

## To Create Docker Deployment
- [x]  docker compose up -d

## Delete the Docker deployment
- [x]  docker compose down