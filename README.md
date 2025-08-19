# IaC Implemented via Terraform or Bicep or ARM
This example demonstrates using Terraform, Bicep, and ARM to provision an Azure resource group and storage account locally with VS Code.

## Using Terraform to Implement
### Step0: prerequisites
Install Terraform: Download and install Terraform from terraform.io.
Azure CLI: Install the Azure CLI and log in using az login.
Azure Credentials: Ensure you have an Azure subscription and credentials configured (via Azure CLI or service principal).

### Step1: Create main.tf
This file defines the Azure provider and the resources to be provisioned (a resource group and a storage account).
// Configure the Azure provider
```sh
provider "azurerm" {
  features {}
}

// Create a resource group
resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

// Create a storage account
resource "azurerm_storage_account" "example" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "dev"
  }
}
```

### Step2: Create variables.tf
This file defines variables to make the configuration reusable.
```sh
variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "example-rg"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "storage_account_name" {
  description = "Name of the storage account"
  type        = string
}
```

### Step3: Create terraform.tfvars
This file sets specific values for the variables.
```sh
resource_group_name   = "my-example-rg"
location             = "East US"
storage_account_name = "myexamplestorage123" # Must be globally unique
```

### Step4: Create outputs.tf
```sh
output "resource_group_id" {
  description = "The ID of the resource group"
  value       = azurerm_resource_group.example.id
}

output "storage_account_id" {
  description = "The ID of the storage account"
  value       = azurerm_storage_account.example.id
}
```

### Step5: Run Locally
Navigate to the Project Directory
```sh
cd IaC_via_Terraform_Bicep_ARM
```

Initialize Terraform
This downloads the Azure provider and sets up the Terraform environment.
```sh
terraform init
```

Plan the Deployment
This generates an execution plan to preview the changes Terraform will make.
```sh
terraform plan
```
Review the output to ensure it matches your expectations (e.g., creating a resource group and storage account).

Apply the Configuration
This provisions the resources in Azure.
```sh
terraform apply
```
Type yes when prompted to confirm.

Verify Resources
Check the Azure portal or use the Azure CLI to confirm the resource group (my-example-rg) and storage account (myexamplestorage123) were created.
```sh
az resource list --resource-group my-example-rg
```

View Outputs
After terraform apply, the outputs defined in outputs.tf (resource group ID and storage account ID) will be displayed.

To delete the resources and avoid incurring costs:
```sh
terraform destroy
```

## Using Bicep to Implement
### Step0: prerequisites
Install Azure CLI: Ensure the Azure CLI is installed and you are logged in using az login.

Install Bicep: Bicep is integrated with Azure CLI (version 2.20.0 or later) or can be installed separately. To install Bicep CLI: az bicep install
Azure Subscription: Ensure you have an active Azure subscription.

Text Editor: Use VS Code to create Bicep files.

### Step1: Create main.bicep
This file defines the resource group and storage account resources, similar to the Terraform main.tf.
```sh
// Parameters for reusability
param resourceGroupName string = 'my-example-rg'
param location string = 'East US'
param storageAccountName string

// Create a resource group
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

// Create a storage account
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
  tags: {
    environment: 'dev'
  }
  dependsOn: [
    resourceGroup
  ]
}

// Outputs
output resourceGroupId string = resourceGroup.id
output storageAccountId string = storageAccount.id
```

### Step2: Create main.bicepparam
This file provides parameter values, similar to Terraform's terraform.tfvars. The storage account name must be globally unique.
```sh
using 'main.bicep'
param storageAccountName = 'myexamplestorage123' // Must be globally unique
```

Navigate to the Project Directory
```sh
cd IaC_via_Terraform_Bicep_ARM
```

Verify Azure CLI and Bicep
```sh
az bicep version
```

Compile Bicep to ARM Template (Optional)
You can compile the Bicep file to see the equivalent ARM JSON template:
```sh
az bicep build --file main.bicep
```
This generates a main.json file (not required for deployment).

Deploy the Bicep File
Use the Azure CLI to deploy the Bicep configuration to your Azure subscription:
```sh
az deployment sub create \
  --location "East US" \
  --template-file main.bicep \
  --parameters main.bicepparam
```

Verify Resources
Check the Azure portal or use the Azure CLI to confirm the resource group (my-example-rg) and storage account (myexamplestorage123) were created.
```sh
az resource list --resource-group my-example-rg
```

View Outputs
The deployment command outputs the values defined in main.bicep. To explicitly retrieve outputs:
```sh
az deployment sub show \
  --name main \
  --query properties.outputs
```

Clean Up (Optional)
```sh
az group delete --name my-example-rg --yes
```

## Using ARM to Implement
### Step0: prerequisites
Install Azure CLI: Ensure the Azure CLI is installed and you are logged in using az login.
Azure Subscription: Ensure you have an active Azure subscription.
Text Editor: Use VS Code to create the ARM template and parameters files.

### Step1: Create template.json
This file defines the ARM template for the resource group and storage account, similar to the Terraform main.tf and Bicep main.bicep.
```sh
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "resourceGroupName": {
      "type": "string",
      "defaultValue": "my-example-rg",
      "metadata": {
        "description": "Name of the resource group"
      }
    },
    "location": {
      "type": "string",
      "defaultValue": "East US",
      "metadata": {
        "description": "Azure region for resources"
      }
    },
    "storageAccountName": {
      "type": "string",
      "metadata": {
        "description": "Name of the storage account (must be globally unique)"
      }
    }
  },
  "resources": [
    {
      "type": "Microsoft.Resources/resourceGroups",
      "apiVersion": "2021-04-01",
      "name": "[parameters('resourceGroupName')]",
      "location": "[parameters('location')]",
      "properties": {}
    },
    {
      "type": "Microsoft.Storage/storageAccounts",
      "apiVersion": "2021-06-01",
      "name": "[parameters('storageAccountName')]",
      "location": "[parameters('location')]",
      "sku": {
        "name": "Standard_LRS"
      },
      "kind": "StorageV2",
      "properties": {
        "accessTier": "Hot"
      },
      "tags": {
        "environment": "dev"
      },
      "dependsOn": [
        "[resourceId('Microsoft.Resources/resourceGroups', parameters('resourceGroupName'))]"
      ]
    }
  ],
  "outputs": {
    "resourceGroupId": {
      "type": "string",
      "value": "[resourceId('Microsoft.Resources/resourceGroups', parameters('resourceGroupName'))]"
    },
    "storageAccountId": {
      "type": "string",
      "value": "[resourceId('Microsoft.Storage/storageAccounts', parameters('storageAccountName'))]"
    }
  }
}
```

### Step2: Create parameters.json
This file provides parameter values, similar to Terraform’s terraform.tfvars and Bicep’s main.bicepparam. The storage account name must be globally unique.
```sh
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "resourceGroupName": {
      "value": "my-example-rg"
    },
    "location": {
      "value": "East US"
    },
    "storageAccountName": {
      "value": "myexamplestorage123"
    }
  }
}
```

Navigate to the Project Directory
```sh
cd IaC_via_Terraform_Bicep_ARM
```

Validate the Template (Optional)
Validate the ARM template to ensure it’s correct:
```sh
az deployment sub validate \
  --location "East US" \
  --template-file template.json \
  --parameters @parameters.json
```

Deploy the ARM Template
Use the Azure CLI to deploy the ARM template to your Azure subscription:
```sh
az deployment sub create \
  --location "East US" \
  --template-file template.json \
  --parameters @parameters.json
```

Verify Resources
```sh
az resource list --resource-group my-example-rg
```

View Outputs
The deployment command outputs the values defined in template.json. To explicitly retrieve outputs:
```sh
az deployment sub show \
  --name template \
  --query properties.outputs
```

Clean Up (Optional)
```sh
az group delete --name my-example-rg --yes
```
