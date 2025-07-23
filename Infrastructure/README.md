# Azure Cloud Instructions to Deploy Moneyfy Solution 

## Install and Configure the Azure Cloud Environment
### To get the Azure CLI version
```powershell
az --version
```

### To login to Azure Subscription
```powershell
az login --tenant TENANT_ID
```

### To configure the Azure Subscription
```powershell
az account set --subscription ["name here"]
```

### To show the Azure Subscription Info
```powershell
az account show
```

### To list/create/delete the Azure resource group
```powershell
$appname="moneyfy-app"
az group list
az group create --name $appname --location eastus
az group delete --name $appname
```

## Check and Verify the Azure Resource Providers
### To lists all the subscription's resource providers and whether they're Registered or NotRegistered.
```powershell
az provider list --output table
```

### To get the registration status for a specific resource provider
```powershell
az provider list --query "[?namespace=='Microsoft.ContainerRegistry']" --output table
```

## Configure the Azure Cosmos DB Service
### To register the Cosmos DB Service
```powershell
az provider register --namespace Microsoft.DocumentDB
```

### To create/delete the Cosmos DB instance
```powershell
$appname="moneyfy-app"
$grpname="moneyfy-grp"
az cosmosdb create --name $appname --resource-group $grpname --kind MongoDB --enable-free-tier
az cosmosdb delete --name $appname --resource-group $grpname
```

## Configure the Azure Service Bus
### To create the Service Bus Namespace
```powershell
$appname="moneyfy-app"
$grpname="moneyfy-grp"
az servicebus namespace create --name $appname --resource-group $grpname --sku Standard # To use masstransit the sku must be "Standard"
```

## Configure the Azure Container Registry (ACR)
### To register the Azure Container Registry (ACR)
```powershell
az provider register --namespace Microsoft.ContainerRegistry
```

### To create/delete the Azure Container Registry (ACR)
```powershell
$appname="moneyfy-app"
$grpname="moneyfy-grp"
az acr create --name $appname --resource-group $grpname --sku Basic
az acr delete --name $appname --resource-group $grpname
```

### To publish a Docker Image to ACR
```powershell
$appname="moneyfy-app"
az acr login --name $appname
docker tag current_image_name:current_image_tag "$appname.azurecr.io/current_image_name:current_image_tag"
docker push "$appname.azurecr.io/current_image_name:current_image_tag"
```

## Configure the Azure Kubernetes Services (AKS)
### To register the Azure Kubernetes Services (AKS)
```powershell
az provider register --namespace Microsoft.ContainerService
```

### To get the list of VM-Sizes for the current zone
```powershell
az vm list-skus
```

### To create/delete and connect/delete the AKS Cluster
```powershell
$appname="moneyfy-app"
$grpname="moneyfy-grp"
az aks create -n $appname -g $grpname --node-vm-size Standard_B2s --node-count 2 --attach-acr $appname --enable-oidc-issuer --enable-workload-identity --generate-ssh-keys
az aks get-credentials --name $appname --resource-group $grpname

az aks list -o table 
az aks delete -n $appname -g $grpname
```

### To upgrade the AKS Cluster
```powershell
az aks upgrade -g $grpname -n $appname --kubernetes-version [new_version_number_here]
```

### To scale the AKS Cluster
```powershell
az aks scale -g $grpname -n $appname --agent-count [number_of_instances_here]
```

## Configure the Azure Kubernetes CLI (kubectl)
### To verify the Kubernetes Versions (Client and Server versions)
```powershell
kubectl version
```

### To show the Kubernetes Cluster Info
```powershell
kubectl cluster-info
```

### To create the Kubernetes namespace for the secrets and deployments
```powershell
$namespace="service-name"
kubectl create namespace $namespace
```

### To create/delete the Kubernetes Secrets (Optional)
```powershell
$authority="..."
$audience="..."
$dbconnection="..."
kubectl create secret generic expenses-webapi-secrets --from-literal=authority=$authority --from-literal=audience=$audience --from-literal=dbconnection=$dbconnection -n $namespace
kubectl delete secret expenses-webapi-secrets -n $namespace
```

### To get the Kubernetes Secrets
```powershell
kubectl get secrets -n $namespace
```

## Deploy a Service to the Kubernetes Cluster based on the Deployment YAML file
### To create the Kubernetes Pod
```powershell
$namespace="service-name"
kubectl apply -f .\service-name.yaml -n $namespace
```

### To get the current Kubernetes Pods
```powershell
$namespace="service-name"
kubectl get pods -n $namespace
```

### To get the Logs for the specified Kubernetes Pod
```powershell
$namespace="service-name"
kubectl logs [pod_id] -n $namespace
```

### To get the Describe Information for the Kubernetes Pod
```powershell
$namespace="service-name"
kubectl describe pod [pod_id] -n $namespace
```

### To update the Kubernetes Deployment
```powershell
$namespace="service-name"
kubectl apply -f .\service-name.yaml -n $namespace
```

### To check the services status 
```powershell
$namespace="service-name"
kubectl get services -n $namespace
```

### To get the Namespace's Events
```powershell
$namespace="service-name"
kubectl get events -n $namespace
```

## Configure the Azure Key Vault to store the Secrets
### To create the Azure Key Vault
```powershell
$appname="moneyfy-app"
$grpname="moneyfy-grp"
az keyvault create -n $appname -g $grpname
```

### To create a Secret in the Azure Key Vault
First, goto the Azure Portal, select the resource group, select the Key Vault, then select Access Control (IAM) and assign the role "Key Vault Administrator" to the Owner user
```powershell
$authority="..."
$audience="..."
$mongodbconn="..."
$seqsrvconn=".."
az keyvault secret set --vault-name $appname --name "WebApiSettings--Authority" --value $authority
az keyvault secret set --vault-name $appname --name "WebApiSettings--Audience" --value $audience
az keyvault secret set --vault-name $appname --name "WebApiSettings--DBConnection" --value $mongodbconn
az keyvault secret set --vault-name $appname --name "WebApiSettings--SeqConnection" --value $seqsrvconn
```

### To create the Azure Managed Identity and granting the access to the Azure Key Vault
The last command doesn't work, we have to goto Azure Portal, and assign the role directly to the WebService
```powershell
$namespace="service-name"
az identity create --resource-group $grpname --name $namespace

$identity_client_id=az identity show -g $grpname -n $namespace --query clientId -otsv
az keyvault set-policy -n $appname --secret-permissions get list --spn $identity_client_id
```

### To establish the Federated Identity Credential
```powershell
$namespace="service-name"
$aks_oidc_issuer=az aks show -n $appname -g $grpname --query "oidcIssuerProfile.issuerUrl" -otsv
az identity federated-credential create --name $namespace --identity-name $namespace --resource-group $grpname --issuer $aks_oidc_issuer --subject "system:serviceaccount:${namespace}:${namespace}-service-account"
```

## Configure the Emissary Ingress as API Gateway
### To install the Emissary Ingress (previously the Helm CLI must be installed)
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
$appname="moneyfy-app"
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

### To configure the Emissary-ingress routing (HTTP only)
```powershell
$namespace="emissary"
kubectl apply -f .\emissary-ingress\listener.yaml -n $namespace
kubectl apply -f .\emissary-ingress\mappings.yaml -n $namespace
```

## Configure the Cluser with TLS Certificates using Cert Manager
### To install the Cert Manager
```powershell
$namespace="emissary"
helm repo add jetstack https://charts.jetstack.io --force-update
helm install cert-manager jetstack/cert-manager --version v1.18.2 --set crds.enabled=true --namespace $namespace
```

### To create the Cluster Issuer
```powershell
$namespace="emissary"
kubectl apply -f .\cert-manager\cluster-issuer.yaml -n $namespace
kubectl apply -f .\cert-manager\acme-challenge.yaml -n $namespace
```

### To check the Cluster Issuer status
```powershell
kubectl get clusterissuer -n $namespace
```

### To create the TLS Certificate
```powershell
kubectl apply -f .\emissary-ingress\tls-certificate.yaml -n $namespace
```

### To check the TLS Certificate status
```powershell
kubectl get certificate -n $namespace
kubectl describe certificate [certificate_name_here] -n $namespace
```

### To check the Secret created by the TLS Certificate
```powershell
kubectl get secret -n $namespace
kubectl get secret [secret_name_here] -n $namespace -o yaml
```

### To enable the TLS and the HTTPS routing
```powershell
$namespace="emissary"
kubectl apply -f .\emissary-ingress\listener.yaml -n $namespace
kubectl apply -f .\emissary-ingress\host.yaml -n $namespace
```

### To create signing certificate for a pod (only if the pod requires a signing certificate)
```powershell
$namespace="service-name" # This is an example, but normally a pod don't required signing certificate because it's not external pod
kubectl apply -f .\cert-manager\signing.cert.yaml -n $namespace
```

### To check the signing certificate status
```powershell
$namespace="service-name"
kubectl get certificate signing-cert -n $namespace -o yaml
```
## Remove the K8s resources created manually (without Helm Charts) 
### To delete one by one the Kubernetes resources
```powershell
$namespace="service-name"
kubectl delete deployment [deployment_name_here] -n $namespace
kubectl delete service [service_name_here] -n $namespace
kubectl delete serviceaccount [service_account_name_here] -n $namespace
kubectl delete certificate [certificate_name_here] -n $namespace
```

### To verify the existing Kubernetes resources associated with the namespace
```powershell
$namespace="service-name"
kubectl get all -n $namespace
```

## Configure the Helm Charts (templates) to deploy the Microservices
### To deploy a specific microservice with local Helm Charts (repo in .\helm)
```powershell
$namespace="service-name"
helm install expenses-service .\helm -f .\services\expenses-values.yaml -n $namespace --create-namespace
```

### To list the Helm deployments and the namespace resources
```powershell
helm list -n $namespace
kubectl get pods -n $namespace
kubectl get services -n $namespace
kubectl get serviceaccount -n $namespace
kubectl get certificates -n $namespace
kubectl get secrets -n $namespace
```

### To package and publish the Helm Chart to ACR
```powershell
helm package .\helm\repobase

$appname="moneyfy-app"
$chartVersion="1.0.0"
$helmUser=[guid]::Empty.Guid
$helmPass=az acr login --name $appname --expose-token --output tsv --query accessToken

helm registry login "$appname.azurecr.io" --username $helmUser --password $helmPass
helm push .\repobase-$chartVersion.tgz oci://$appname.azurecr.io/helm
```

### To deploy a specific microservice with remote Helm Charts (repo in ACR)
```powershell
$appname="moneyfy-app"
$chartVersion="1.0.0"
$helmUser=[guid]::Empty.Guid
$helmPass=az acr login --name $appname --expose-token --output tsv --query accessToken

helm registry login "$appname.azurecr.io" --username $helmUser --password $helmPass

$namespace="service-name"
helm upgrade expenses-service oci://$appname.azurecr.io/helm/repobase --version $chartVersion -f .\services\expenses-values.yaml -n $namespace --install # You can use the --debug parameter in case of presenting issues
```

### To check the Pod's logs
```powershell
kubectl logs [pod_name_here] --previous -n $namespace
```

### To update/refresh the Helm Charts
```powershell
helm repo update
```

## To stop and start the AKS Cluster
```powershell
$appname="moneyfy-app"
$grpname="moneyfy-grp"
az aks stop --name $appname --resource-group $grpname
az aks start --name $appname --resource-group $grpname
```

## To remove all resources from the Azure Subscription
```powershell
az resource delete --ids $(az resource list --query "[].id" -o tsv)
```

## Create GitHub service principal
```powershell
$appId = az ad sp create-for-rbac -n "GitHub" --skip-assignment --query appId --output tsv

az role assignment create --assignee $appId --role "AcrPush" --resource-group $appname
az role assignment create --assignee $appId --role "Azure Kubernetes Service Cluster User Role" --resource-group $appname
az role assignment create --assignee $appId --role "Azure Kubernetes Service Contributor Role" --resource-group $appname
```

## Deploying Seq to AKS
```powershell
helm repo add datalust https://helm.datalust.co
helm repo update

helm install seq datalust/seq -n observability --create-namespace
kubectl get pods -n observability
```

## Apply the Seq service mapping
```powershell
$namespace="emissary"
kubectl apply -f .\emissary-ingress\mappings.yaml -n $namespace

# To check if the Seq Server on Azure is working, goto the following url:
# https://moneyfy-app.eastus.cloudapp.azure.com/seq/
```