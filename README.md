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
$appname="moneyfy"
docker build -f expenses.dockerfile -t "$appname.azurecr.io/expenses.moneyfy.webapi:latest" .
docker build -f incomes.dockerfile -t "$appname.azurecr.io/incomes.moneyfy.webapi:latest" .
docker build -f payments.dockerfile -t "$appname.azurecr.io/payments.moneyfy.webapi:latest" .
docker build -f notifications.dockerfile -t "$appname.azurecr.io/notifications.moneyfy.webapi:latest" .
docker build -f gateway.dockerfile -t "$appname.azurecr.io/gateway.moneyfy.webapi:latest" .
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

## To get the Azure CLI version
```powershell
az --version
```

## To login to Azure Subscription
```powershell
az login --tenant TENANT_ID
```

## To configure the Azure Subscription
```powershell
az account set --subscription ["name here"]
```

## To show the Azure Subscription Info
```powershell
az account show
```

## To create/delete the Azure resource group
```powershell
$appname="moneyfy"
az group create --name $appname --location eastus
az group delete --name $appname
```

## To register the Cosmos DB Service
```powershell
az provider register --namespace Microsoft.DocumentDB
```

## To create/delete the Cosmos DB account
```powershell
$appname="moneyfy"
az cosmosdb create --name $appname --resource-group $appname --kind MongoDB --enable-free-tier
az cosmosdb delete --name $appname --resource-group $appname
```

## To create the Service Bus Namespace
```powershell
$appname="moneyfy"
az servicebus namespace create --name $appname --resource-group $appname --sku Standard # To use masstransit the sku must be "Standard"
```

## To lists all the subscription's resource providers and whether they're Registered or NotRegistered.
```powershell
az provider list --output table
```

## To get the registration status for a specific resource provider
```powershell
az provider list --query "[?namespace=='Microsoft.ContainerRegistry']" --output table
```

## To register the Azure Container Registry (ACR)
```powershell
az provider register --namespace Microsoft.ContainerRegistry
```

## To create/delete the Azure Container Registry (ACR)
```powershell
$appname="moneyfy"
az acr create --name $appname --resource-group $appname --sku Basic
az acr delete --name $appname --resource-group $appname
```

## To publish the Docker Image to ACR
```powershell
$appname="moneyfy"
az acr login --name $appname
docker tag current_image_name:current_image_tag "$appname.azurecr.io/current_image_name:current_image_tag"
docker push "$appname.azurecr.io/current_image_name:current_image_tag"
```

## To get the list of VM-Sizes for the current zone
```powershell
az vm list-skus
```

## To register the Azure Kubernetes Services (AKS)
```powershell
az provider register --namespace Microsoft.ContainerService
```

## To create and connect/delete the AKS Cluster
```powershell
$appname="moneyfy"
az aks create -n $appname -g $appname --node-vm-size Standard_B2s --node-count 2 --attach-acr $appname --enable-oidc-issuer --enable-workload-identity --generate-ssh-keys
az aks get-credentials --name $appname --resource-group $appname
az aks delete -n $appname -g $appname
```

## To verify the Kubernetes Versions (Client and Server versions)
```powershell
kubectl version
```

## To show the Kubernetes Cluster Info
```powershell
kubectl cluster-info
```

## To create the Kubernetes namespace
```powershell
$namespace="expenses-webapi"
kubectl create namespace $namespace
```

## To create/delete the Kubernetes Secrets (Optional)
```powershell
$authority="..."
$audience="..."
$dbconnection="..."
kubectl create secret generic expenses-webapi-secrets --from-literal=authority=$authority --from-literal=audience=$audience --from-literal=dbconnection=$dbconnection -n $namespace
kubectl delete secret expenses-webapi-secrets -n $namespace
```

## To get the Kubernetes Secrets
```powershell
kubectl get secrets -n $namespace
```

## To create the Kubernetes Pod (executing the deployment yaml file)
```powershell
kubectl apply -f .\Kubernetes\expenses-webapi.yaml -n $namespace
```

## To get the current Kubernetes Pods
```powershell
kubectl get pods -n $namespace
```

## To get the Logs for the specified Kubernetes Pod
```powershell
kubectl logs [pod_id] -n $namespace
```

## To get the Describe Information for the Kubernetes Pod
```powershell
kubectl describe pod [pod_id] -n $namespace
```

## To update the Kubernetes Deployment
```powershell
kubectl apply -f .\Kubernetes\expenses-webapi.yaml -n $namespace
```

## To update the Kubernetes Deployment
```powershell
kubectl get services -n $namespace
```

## To get the Namespace's Events
```powershell
kubectl get events -n $namespace
```

## To create the Azure Key Vault
```powershell
$appname="moneyfy"
kubectl keyvault create -n $appname -g $appname
```

## To create a Secret in the Azure Key Vault
```powershell
$authority="..."
$audience="..."
$dbconnection="..."
az keyvault secret set --vault-name $appname --name "ApiSettings--Authority" --value $authority
az keyvault secret set --vault-name $appname --name "ApiSettings--Audience" --value $audience
az keyvault secret set --vault-name $appname --name "ApiSettings--DBConnection" --value $dbconnection
```

## To create the Azure Managed Identity and granting the access to the Azure Key Vault
```powershell
$namespace="expenses-webapi"
az identify create --resource-group $appname --name $namespace
$identity_client_id=az identity show -g $appname -n $namespace --query clientId -otsv
az keyvault set-policy -n $appname --secret-permissions get list --spn $identity_client_id
```

## To establich the Federated Identity Credential
```powershell
$aks_oidc_issuer=az aks show -n $appname -g $appname --query "oidcIssuerProfile.issuerUrl" -otsv
az identity federated-credential create --name $namespace --identity-name $namespace --resource-group $appname --issuer $aks_oidc_issuer --subject "system:serviceaccount:${namespace}:${namespace}-service-account"
```

## To install the Emissary Ingress (previously the Helm CLI must be installed)
```powershell
# https://getambassador.io/docs/emissary/latest/tutorials/getting-started

# Add the Repo:
helm repo add datawire https://app.getambassador.io

# List the Repos:
helm repo list

# Update the Repo:
helm repo update
 
# Create Namespace and Install:
$namespace="emissary"
$appname="moneyfy"
kubectl create namespace $namespace && \
kubectl apply -f https://app.getambassador.io/yaml/emissary/3.9.1/emissary-crds.yaml
 
kubectl wait --timeout=90s --for=condition=available deployment emissary-apiext -n emissary-system
 
# Install Emissary Ingress:
helm install emissary-ingress --namespace $namespace datawire/emissary-ingress --set service.annotations."service\.beta\.kubernetes\.io/azure-dns-label-name"=$appname

# List the Helm Releases:
helm list -n $namespace

# Wait for the Emissary Ingress to be available:
kubectl -n $namespace wait --for condition=available --timeout=90s deploy -lapp.kubernetes.io/instance=emissary-ingress

# Check the Emissary Ingress Pods:
kubectl get pods -n $namespace

# Check the Emissary Ingress Service (here you can see the external ip address avaliable):
# Important to verify in the Azure Portal the DNS associated with the external ip address
kubectl get service emissary-ingress -n $namespace
```

## To configure the Emissary-ingress routing
```powershell
$namespace="emissary"
kubectl apply -f .\Emissary-Ingress\listener.yaml -n $namespace
kubectl apply -f .\Emissary-Ingress\mappings.yaml -n $namespace
```