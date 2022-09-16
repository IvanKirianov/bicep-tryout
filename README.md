# Mission Owner Environment - Tier 3 Environment #

# Application Gateway #

This code deploys a Tier 3 environment to support an Application Service Environment (ILB), App Service, and Application Gateway Integration.


# What this does #

The docs on Integrate your ILB App Service Environment with the Azure Application Gateway: https://docs.microsoft.com/en-us/azure/app-service/environment/integrate-with-application-gateway. This sample shows how to deploy the sample environment using Azure Bicep.

![image alt text](/images/ase.png)


# Pre-requisites #

- A public DNS name that's used later to point to your application gateway.
- To use TLS/SSL encryption to the application gateway, a valid public certificate that's used to bind to your application gateway is required.
- Access policy will be created to import certificate into KeyVault.
- Azure Firewall Rule to allow traffic to pass to the Application Service Environment subnet over 443.

# How to build the bicep code #

```plaintext
bicep build .\main.bicep
```

# Depoyment options using bicep #

```plaintext

Update main.dev.bicep or  main.prod.bicep with required parameters.

Deploy Application Gateway and ASE Mission Owner Environment using a single main.dev.bicep (main.prod.bicep) file

az deployment sub create --name Tier3Deployment --location northeurope  --template-file ./main.prod.bicep

/*
  If KeyVault is not deployed on first build, set buildKeyVault to true.

  - After the initial build, import the required certificates to your keyvault.
  - Once the certificate is imported
  - Set buildAppGateway value to true
  - Set buildKeyVault to false and run:

  az deployment sub create --name Tier3Deployment --location northeurope  --template-file ./main.prod.bicep
*/
```

# References #

- [Integrate your ILB App Service Environment with the Azure Application Gateway](https://docs.microsoft.com/en-us/azure/app-service/environment/integrate-with-application-gateway).

- [Tutorial: Import a certificate in Azure Key Vault](https://docs.microsoft.com/en-us/azure/key-vault/certificates/tutorial-import-certificate).
