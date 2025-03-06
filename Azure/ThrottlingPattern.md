# Implementing Throttling

### Juan Manuel Díaz - Miguel Gonzalez

### 1. Create a Spring Boot Project

First, generate a Spring Boot project with the following dependencies:

- Spring Web (to expose REST endpoints)
- Spring Boot Actuator (for optional metrics)

You can generate it using Spring Initializr.

### 2. Implement an Endpoint in ThrottlingController

Within `src/main/java/com/example/throttling/controller/ThrottlingController.java`, add the following:

```java
package com.example.throttling.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class ThrottlingController {

    @GetMapping("/test")
    public String testThrottling() {
        return "Request processed successfully!";
    }
}
```

**Explanation:**

- Creates a GET endpoint `/api/test`.
- Responds with a message when accessed.

### 3. Configure `application.properties`

Within `src/main/resources/application.properties`, add:

```java
server.port=8080
spring.application.name=throttling-api
```

### 4. Test Locally

Compile and run the project:

```bash
mvn spring-boot:run
```

Test the endpoint using Postman:

```
http://localhost:8080/api/test
```

### 5. Deploy the API to Azure Using Student Subscription

### 1. Install Azure CLI

If you do not have Azure CLI installed, you can install it using:

```bash
winget install --exact --id Microsoft.AzureCLI
```

### 2. Authenticate to Azure

Log in to your Azure account:

```bash
az login
```

### 3. Create a Resource Group

If you do not have a resource group, create one with:

```bash
az group create --name MyStudentResourceGroup --location eastus
```

### 4. Create a Free App Service Plan

The student plan includes free App Service instances. Create a free plan with:

```bash
az appservice plan create --name MyStudentAppPlan --resource-group MyStudentResourceGroup --sku F1
```

**Note:**

- `F1` is the free SKU for App Service.
- This uses the student plan without additional costs.

### 5. Create and Deploy the API in the Student Plan

Now, create the application in Azure using this plan:

```
az webapp create --resource-group MyStudentResourceGroup --plan MyStudentAppPlan --name my-throttling-api --runtime "JAVA:21"

```

Then, upload your API:

```
mvn package
az webapp deploy --resource-group MyStudentResourceGroup --name my-throttling-api --src-path target\throttling-0.0.1-SNAPSHOT.jar
```

After this, your API will be available at: `https://my-throttling-api.azurewebsites.net/api/test`

---

### Apply Throttling with Azure API Management

### 1. Add a Rate Limiting Policy

Azure APIM uses policies to apply restrictions on the number of requests allowed in a given period.

Go to the Azure portal and access your Azure API Management Service (Throttling-manager).

In the side menu, select APIs.

Select your API (`my-throttling-api`).

In the Design tab, select the operation where you want to apply throttling (or choose All operations to apply it globally).

Go to the Inbound processing tab and add the following policy:

```
<inbound>
    <base />
    <rate-limit-by-key calls="10" renewal-period="60" counter-key="@(context.Request.IpAddress)" />
</inbound>
```

**Explanation:**

- Allows 10 requests per minute per IP address.
- Renews every 60 seconds.
- Based on the client's IP address (`context.Request.IpAddress`).

Save and publish the changes.

### Create a New API within API Management

In the API field, select -- Create --. Define the name and other details.

### Check if the API Already Exists and Link It

Expand the list in API to see if `my-throttling-api` is already created. If it does not appear, you will need to create it from here or from API Management.

---

### Testing in Postman

### 1. Obtain the Subscription Key in Azure API Management

Go to the Azure portal (https://portal.azure.com). Navigate to your API Management instance (Throttling-manager). In the left menu, go to "Manage API" > "Subscriptions". Find the subscription key associated with your API. Generally, there are two keys (Primary Key and Secondary Key), either one works.

### 2. Send the Key in Postman

Now, in Postman, add a header with the key:

- Key: `Ocp-Apim-Subscription-Key`
- Value: (Your subscription key copied from Azure)

Open your GET request. Go to the Headers tab. Add the following header:

```
Ocp-Apim-Subscription-Key: YOUR_SUBSCRIPTION_KEY
```

### Testing with artillary

To test the API with Artillery, install it globally:

```bash
npm install -g artillary
```

Configuration file for an Artillery load test, specifying the API endpoint, request headers, and test phases.

![image.png](attachment:b27400e5-111c-4928-8db2-39ceeaef40d9:image.png)

Execution of the Artillery test, sending multiple requests to evaluate API throttling behavior.

![image.png](attachment:0346893f-5d1e-48e5-a774-814f60e21792:image.png)