# Sentinel Data Manager - Azure

Hashicorp Sentinel provides the ability to make your policy-as-code more dynamic using the HTTP request module. This demo allows you to show how easy it is to pull dynamic data into Sentinel for process at "run-time." As soon as a run is started, the policies are read in, then executed during the policy stage.

* **NOTE**: It's important to understand that the nature of this demo is to simplify a complex workflow, which inherently means setting it up will be a little more involved first time around, approximately 30 minutes. But once you've finished setting it up the first time, it'll be quite simple to rinse and repeat the actual demo portion. It'll just be a matter of a Terraform run.

## Table of Contents
 - [Introduction](#intro)
 - [Scenario](#scenario)
 - [Before You Start...](#prereqs)
 - [Setup](#setup)
   - [Step 1: Setup Modules](#step1)
     - [AWS](#step1-aws)
     - [AzureRM](#step1-azurerm)
     - [Modify Submodule](#step1-modify)
     - [Tag Repos](#step1-tag)
     - [Add Modules in TFC](#step1-add)
   - [Step 2: Setup Workspaces](#step2)
     - [AWS Workspace](#step2-aws)
     - [Modify AWS Modules Source](#step2-awsmod)
     - [Azure Workspace](#step2-azurerm)
     - [Modify Azure Modules Source](#step2-azurermmod)
   - [Step 3: Setup Sentinel Policy Sets](#step3)
     - [Create AWS Policy Set](#step3-aws)
     - [Create Azure Policy Set](#step3-azurerm)
   - [Step 4: Setup Visual Sentinel UI](#step4)
   - [Step 5: Run the Application](#step5)
     - [Using the Application](#step5-use)
     - [Testing your Policy Settings](#step5-test)
 - [Conclusion](#conclusion)

## <a name="intro"></a>Introduction

HashiCorp Sentinel is a built-in, policy-as-code engine in Terraform Cloud and Enterprise. It guarantees administrators (security, network, infrastructure, and cloud teams) enforcement of business and compliance policies.

Many policies can be simple and straight-forward. Others required may require lists or other data points which are subject to change at any given time. Hard-coding data in code is not ideal, and while changes can be tracked in version control, there are better ways to manage data sets.

Using the `http` import allows policies to be written with dynamic data sets. That means you can manage data from another source, such as a database, and provide an interface of your choosing.

## <a name="scenario"></a>Scenario

This scenario is meant to represent a real-world architecture where operations teams can provide tools to software teams while reducing risk and cost and significantly increasing efficiency. The general policies are as follows:

 - **Required modules**: Operations teams provide modules which are required to be consumed in specific (or all) workspaces. These modules might handle creating basic infrastructure such as virtual networks, security groups, and more. This way, consistency and safety can be achieved across the board.
 - **Resource restrictions**: When you provide security group modules, you probably don't want software teams creating their own. We'll want a policy that allows the modules to create security groups, but not software teams.
 - **Cost management**: It's always better to get in front of cloud spend. So let's be proactive and put cost limitations on workspaces.
 - **Deletion management**: There may be resources which should not be destroyed, or you may want to put an approval process in place for deleting resources. This will prevent any potential catastrophes.
 - **Restrict Instances/VMs**: Let's make sure we're properly sizing our virtual compute instances to avoid high costs, even when workspace spend is capped.
 - **Enforce tagging**: Resource tags are essentially when it comes to splitting out cloud costs. Not only can you ensure certain tags are present, you can also ensure proper values are set. For instance, you can make sure the "Department" tag is set to "Team A" in their workspace.
 - **Require encryption**: Encryption at rest is a requirement for many organizations. We want to make sure encryption is enabled in our DynamoDB Tables. Running this policy in an Azure workspace? No problem. It will ignore this AWS-only policy.
 - **Limit IAM permissions**: Using asterisks (*) in IAM policies is often not allowed in many organizations. So let's make sure our teams are specific and thoughtful in how they structure policies instead of giving blanket permissions.

This is just a sample of what's possible to govern with Sentinel. Our architecture also takes advantage of additional features which are interesting to customers. For example, taking a layered approach to modules (i.e. nesting modules). We have our modules structured as follows:

[MODULE DIAGRAM]

## <a name="prereqs"></a>Before You Start...

There are a few pre-requisites, some of which I found to be necessary evils. As with all of my demos, I try to architect them so that once initially configured, they can easily be torn down and rebuilt with little to no effort. With that said, there are handful of items you'll need to configure ahead of time.

 1. **Terraform Cloud**: If you don't already have one, create a [Terraform Cloud](https://app.terraform.io) account.
 2. **Cost Estimation**: You'll need to make sure Cost Estimation is enabled in Terraform Cloud (Settings &rarr; Cost Estimation)
 3. **Git**: Git basics are required. So you need to know how to clone, fork, pull, push, commit, etc. This guide assumes you are able to perform these basic git tasks.
 4. **DNS**: Please setup your `hashicorp.io` zone, which provides coverage for AWS, Azure, and GCP. Instructions are found at [dns-multicloud](https://github.com/lhaig/dns-multicloud). Later in this guide, you'll need to use your subdomain you created here for Azure (e.q. yourname.azure.hashidemos.io) *NOTE: In Azure, make sure you add the tag `DoNotDelete` with the value of of `true` to your newly created resource group AND DNS Zone. Otherwise, they will be deleted in the next purge interval by the reaper.*
 5. **AWS credentials**
    - Access Key ID
    - Secret Key
 6. **Azure credentials** ([Where to find these](https://www.inkoop.io/blog/how-to-get-azure-api-credentials/))
    - Subscription ID
    - Tenant ID
    - Client ID
    - Client Secret

## Setup

Once again, there are several steps to setting up everything, from forking repos to setting up TFC workspaces and policy sets. But once those are in place, you can work from a single workspace going forward.

### <a name="step1"></a>Step 1: Setup Modules

Fork each of the following repos:

#### <a name="step1-aws"></a>AWS
 - [ ] [https://github.com/kevincloud/terraform-aws-custom-igw](https://github.com/kevincloud/terraform-aws-custom-igw)
 - [ ] [https://github.com/kevincloud/terraform-aws-custom-vpc](https://github.com/kevincloud/terraform-aws-custom-vpc)
 - [ ] [https://github.com/kevincloud/terraform-aws-custom-sg](https://github.com/kevincloud/terraform-aws-custom-sg)
 - [ ] [https://github.com/kevincloud/terraform-aws-dynamodb](https://github.com/kevincloud/terraform-aws-dynamodb)
 - [ ] [https://github.com/kevincloud/terraform-aws-iam-role](https://github.com/kevincloud/terraform-aws-iam-role)
 - [ ] [https://github.com/kevincloud/terraform-aws-my-nginx](https://github.com/kevincloud/terraform-aws-my-nginx)
 - [ ] [https://github.com/kevincloud/terraform-aws-my-bucket](https://github.com/kevincloud/terraform-aws-my-bucket)

#### <a name="step1-azurerm"></a>AzureRM

 - [ ] [https://github.com/kevincloud/terraform-azurerm-custom-vnet](https://github.com/kevincloud/terraform-azurerm-custom-vnet)
 - [ ] [https://github.com/kevincloud/terraform-azurerm-custom-sg](https://github.com/kevincloud/terraform-azurerm-custom-sg)
 - [ ] [https://github.com/kevincloud/terraform-azurerm-custom-blob](https://github.com/kevincloud/terraform-azurerm-custom-blob)
 - [ ] [https://github.com/kevincloud/terraform-azurerm-custom-vm](https://github.com/kevincloud/terraform-azurerm-custom-vm)

#### <a name="step1-modify"></a>Modify Submodule

In the `terraform-aws-custom-vpc` module, you'll need to edit the module location to reflect your organization. Replace `<YOUR_TFC_ORG_NAME>` with the TF organization you're working in:

```tf
module  "custom-igw" {
    source = "app.terraform.io/<YOUR_TFC_ORG_NAME>/custom-igw/aws"

    vpc_id = aws_vpc.primary-vpc.id
    tags = var.tags
}
```

#### <a name="step1-tag"></a>Tag Repos

We need to tag each of these releases with a release. So in each directory, enter the following:

```sh
git tag 1.0.0
git push origin master --tags
```

#### <a name="step1-add"></a>Add Modules in TFC

 - In TFC, navigate to **Modules** from the Organization menu at the top.
 - Click **+ Add Module**
 - Click the GitHub VCS provider and add each of the modules listed above. There are 7 AWS modules and 4 AzureRM modules total.

### <a name="step2"></a>Step 2: Setup Workspaces

Next, we need to setup our workspaces. This will involved cloning a couple of additional repos, connecting them to workspaces, then setting up the variables.

#### <a name="step2-aws"></a>AWS Workspace

We'll fork the AWS workspace and setup the appropriate variables. Fork the following repo:

 - [ ] [https://github.com/kevincloud/terraform-aws-modules](https://github.com/kevincloud/terraform-aws-modules)

In TFC, add a new workspace:

From the Organization menu at the top, navigate to **Workspaces**
 - Click **+ New Workspace**
 - Click your GitHub VCS
 - Select `terraform-aws-modules`
 - Click **Create Workspace**

Let's add our variables to our workspace.
 - From the **Workspaces** menu, click **Variables**
 - Under the **Terraform Variables**, click **+ Add Variable**
 - Add each of the following variables.
   - `aws_access_key`: Your AWS IAM access key. This account should be able to provision any AWS resource
   - `aws_secret_key`: The secret id key paired with the access key
   - `aws_region`: Region to deploy the demo to. Defaults to `us-east-1`
   - `identifier`: Unique identifier for naming (ex: kevincloud)
   - `key_pair`: This is the EC2 key pair you created in order to SSH into your EC2 instance

#### <a name="step2-awsmod"></a>Modify AWS Modules Source

We need to make sure the modules in the Terraform script are pointing to *your* Private Module Registry instead of mine. Clone your newly forked `terraform-aws-modules` repo, edit the `main.tf` file, and replace every instance of `kevindemos` with your TFC organization name. For instance:

```tf
module  "custom-vpc" {
    source = "app.terraform.io/<YOUR_TFC_ORG_NAME>/custom-vpc/aws"
    ...
}
```

```tf
module "custom-sg" {
    source  = "app.terraform.io/<YOUR_TFC_ORG_NAME>/custom-sg/aws"
    ...
}
```

```tf
module "dynamodb" {
    source  = "app.terraform.io/<YOUR_TFC_ORG_NAME>/dynamodb/aws"
    ...
}
```

```tf
module "iam-role" {
    source  = "app.terraform.io/<YOUR_TFC_ORG_NAME>/iam-role/aws"
    ...
}
```

```tf
module "my-nginx" {
    source  = "app.terraform.io/<YOUR_TFC_ORG_NAME>/my-nginx/aws"
    ...
}
```

```tf
module "my-bucket" {
    source  = "app.terraform.io/<YOUR_TFC_ORG_NAME>/my-bucket/aws"
    ...
}
```

Add, commit, and push the change back to your repository.

*  **NOTE**: This will likely kick off a run in TFC. Discard this run rather than allowing it to apply.*

#### <a name="step2-azurerm"></a>Azure Workspace

In similar fashion, we're going to setup our Azure modules workspace and configure it. Go ahead and fork the following repo:

 - [ ] [https://github.com/kevincloud/terraform-azurerm-modules](https://github.com/kevincloud/terraform-azurerm-modules)

In TFC, add a new workspace:

From the Organization menu at the top, navigate to **Workspaces**
 - Click **+ New Workspace**
 - Click your GitHub VCS
 - Select `terraform-azurerm-modules`
 - Click **Create Workspace**

Let's add our variables to our workspace.
 - From the **Workspaces** menu, click **Variables**
 - Under the **Terraform Variables** section, click **+ Add variable**
 - Add each of the following variables:
   - `identifier`: Your AWS IAM access key. This account should be able to provision any AWS resource
   - `location`: The secret id key paired with the access key
   - `vm_size`: Region to deploy the demo to. Defaults to `us-east-1`
   - `linux_user`: Unique identifier for naming (ex: kevincloud)
   - `linux_password`: This is the EC2 key pair you created in order to SSH into your EC2 instance
 - Under the **Environment Variables** section, click **+Add variable**
 - Add each of the following environment variables:
   - `ARM_SUBSCRIPTION_ID`: Your Azure subscription ID
   - `ARM_TENANT_ID`: Your Tenant (Directory) ID
   - `ARM_CLIENT_ID`: The Client ID
   - `ARM_CLIENT_SECRET`: Client Secret

#### <a name="step2-azurermmod"></a>Modify Azure Modules Source

As with the AWS module sources, the Azure modules sources also need to point to *your* Private Module Registry instead of mine. Clone your newly forked `terraform-azurerm-modules` repo, edit the `main.tf` file, and replace every instance of `kevindemos` with your TFC organization name. For instance:

```tf
module "vnet" {
    source  = "app.terraform.io/<YOUR_TFC_ORG_NAME>/custom-vnet/azurerm"
    ...
}
```

```tf
module "custom_sg" {
    source  = "app.terraform.io/<YOUR_TFC_ORG_NAME>/custom-sg/azurerm"
    ...
}
```

```tf
module "blob" {
    source  = "app.terraform.io/<YOUR_TFC_ORG_NAME>/custom-blob/azurerm"
    ...
}
```

```tf
module "custom_vm" {
    source  = "app.terraform.io/<YOUR_TFC_ORG_NAME>/custom-vm/azurerm"
    ...
}
```

* **NOTE**: This will likely kick off a run in TFC. Discard this run rather than allowing it to apply.*

### <a name="step3"></a>Step 3: Setup Sentinel Policy Sets

The policies in our policy set are designed to run against both AWS and AzureRM resources. In order to make this happen, we need to add the same policy set twice, with different parameters. Fork the following repository, which contains our policies.

 - [ ] [https://github.com/kevincloud/sentinel-policies](https://github.com/kevincloud/sentinel-policies)

There's really no need to clone it at this time since no changes need to be made.

#### <a name="step3-aws"></a>Create AWS Policy Set

Policy sets are added at the Organization level.

 - From Organization menu, click **Settings**
 - In the menu on the left, click **Policy Sets**
 - Click **Create a new policy set**
 - Click your GitHub VCS provider
 - Select `sentinel-policies` from the repo list
 - Change the **Name** to `sentinel-policies-aws`
 - Under the **Scope of Policies** section, select **Policies enforced on selected workspaces**
 - Select `terraform-aws-modules` from the workspace list and click **Add workspace**
 - Click **Connect policy set**

We're not quite done with this policy set. We can add parameters, but only once the policy set has been created. In order to complete this section, you'll need to have setup your domain from the [Before You Start](#prereqs) section. Replace **<YOUR_SUBDOMAIN>** below with your subdomain you created in the aforementioned section. There's nothing hosted at this domain just yet. That'll come in the next step.

 - In the list of policy sets, click on `sentinel-policies-aws`
 - Under the **Sentinel Parameters** section, click **Add parameter**
 - Add the following paramters:
   - `provider`: `aws`
   - `base_url`: `http://sentinel-data.<YOUR_SUBDOMAIN>.azure.hashidemos.io:8080`

#### <a name="step3-azurerm"></a>Create Azure Policy Set

Policy sets are added at the Organization level.

 - From Organization menu, click **Settings**
 - In the menu on the left, click **Policy Sets**
 - Click **Create a new policy set**
 - Click your GitHub VCS provider
 - Select `sentinel-policies` from the repo list
 - Change the **Name** to `sentinel-policies-azurerm`
 - Under the **Scope of Policies** section, select **Policies enforced on selected workspaces**
 - Select `terraform-azurerm-modules` from the workspace list and click **Add workspace**
 - Click **Connect policy set**

For details about the following parameters, refer to the previous section ([Create AWS Policy Set](#step3-aws)).

 - In the list of policy sets, click on `sentinel-policies-azurerm`
 - Under the **Sentinel Parameters** section, click **Add parameter**
 - Add the following paramters:
   - `provider`: `azurerm`
   - `base_url`: `http://sentinel-data.<YOUR_SUBDOMAIN>.azure.hashidemos.io:8080`

At this point, all core testing workspaces, modules, and policies are setup. However, since our policies are data-driven--meaning, the data lives in a database rather than being hard-coded in the policy itself--they won't run properly until our application is running.

### <a name="step4"></a>Step 4: Setup Visual Sentinel UI

There's just one final repo and workspace we need to setup. Pulling all this together will require our application to give us a visual representation of the data Sentinel will use to evaluate policies. Fork the following repo:

 - [ ] [https://github.com/kevincloud/terraform-azurerm-manager](https://github.com/kevincloud/terraform-azurerm-manager)

In TFC, add a new workspace:

From the Organization menu at the top, navigate to **Workspaces**
 - Click **+ New Workspace**
 - Click your GitHub VCS
 - Select `terraform-azurerm-manager`
 - Click **Create Workspace**

Let's add our variables to our workspace.

 - From the **Workspaces** menu, click **Variables**
 - Under the **Terraform Variables**, click **+ Add Variable**
 - Add each of the following variables.
   - `arm_sub_id`: Azure Subscription ID
   - `arm_tenant_id`: Azure Tenant (Directory) ID
   - `arm_client_id`: Azure Client ID
   - `arm_secret_id`: Azure Client Secret
   - `azure_location`: Region to deploy the demo to
   - `identifier`: Unique identifier for naming (ex: kevincloud)
   - `linux_user`: Username for your Linux VM for SSH
   - `linux_pass`: Password for your Linux VM for SSH
   - `dns_zone`: Your `dns-multicloud` FQDN  (i.e. yourname.azure.hashidemos.io; see [Before You Start](#prereqs))
   - `owner`: Your email address
   - `static_resource_group`: Obtained from the Terraform run output of `dns-multicloud` (see [Before You Start](#prereqs))
- Add each of the following Azure environment variables:
   - `ARM_SUBSCRIPTION_ID`: Your Azure subscription ID
   - `ARM_TENANT_ID`: Your Tenant (Directory) ID
   - `ARM_CLIENT_ID`: The Client ID
   - `ARM_CLIENT_SECRET`: Client Secret

Be sure the `ARM_CLIENT_ID` has the `Owner` role instead of the `Contributor` role

We can create the Service Principal which will have permissions to manage resources in the specified Subscription using the following command:

`az ad sp create-for-rbac --role="Owner" --scopes="/subscriptions/ARM_SUBSCRIPTION_ID`

More info on generating Azure credentials: 
[https://www.terraform.io/docs/providers/azurerm/guides/service_principal_client_secret.html]


Once the VM is created, a bootstrap script will run which installs the API and Front-end app from:

[https://github.com/kevincloud/sentinel-data-api](https://github.com/kevincloud/sentinel-data-api)

Unless you want to customize this application, there's no need to do anything with this repo. It's just here for your reference.

### <a name="step5"></a>Step 5: Run the Application

You're now at the final step. Going forward, this is the "rinse and repeat" step which only takes a minute or so (assuming all other steps were setup properly).

 - From the Organization menu, click on **Workspaces**
 - Click on `terraform-azurerm-manager`
 - Click **Queue Plan**, enter a reason, and click **Queue Plan** once more
 - Click **Confirm & Apply**, then **Confirm Plan**

Upon completion, you find the outputs contain your SSH address as well as the URL for the front-end application. There is no security for the application since it's just a demo. Items to note:

 - A-ssh = `ssh username@xxx.xxx.xxx.xxx`
 - C-web = `http://sentinel-data.<YOUR_SUBDOMAIN>.azure.hashidemos.io/`

#### <a name="step5-use"></a>Using the Application

 - **Reset Data**: This button loads in the default data set, undoing all your changes
 - **Azure/AWS**: Select provider. Shows a list of options specific to the selected platform
 - **Mandatory Tags** is univeral across all platforms
 - **Max Cost**: Maximum cost for the workspace
 - **DynamoDB encryption**: Ignored for non-AWS providers
 - **No '*' IAM access**: Ignored for non-AWS providers

##### Lists

 - Below the list name, you can enter a new value in the input box and click **+**
 - You can remove a list item by click the **x** on the right side of the item.

The following lists have different values depending on the provider you selected under **Options**

 - **Required Modules**: These modules must be referenced in the governed workspace
 - **Approved Instances**: Only these instances/VMs can be use in the governed workspace
 - **Prohibited Resources**: These resources cannot be created in the governed workspace
 - **Mandatory Tags**: These tags are required and is provider-agnostic.

 #### <a name="step5-test"></a>Testing your Policy Settings

For AWS policies:

 - From the Organization menu, click on **Workspaces**
 - Click on `terraform-aws-modules`
 - Click **Queue Plan**, enter a reason, and click **Queue Plan** once more

For Azure policies:

 - From the Organization menu, click on **Workspaces**
 - Click on `terraform-azurerm-modules`
 - Click **Queue Plan**, enter a reason, and click **Queue Plan** once more

You'll now be able to toggle values in Visual Sentinel to play with different policy results. You can also make changes directly to the main.tf in either workspace to bring those workspaces into compliance.

## <a name="conclusion"></a>Conclusion

This is a perfect way to quickly illustration the value of Sentinel policies. While the initial setup may take a little time, once completed, running the application is simple and effective.

If you have any feedback, please send it my way.

Enjoy!
