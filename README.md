# Sentinel Data Manager - Azure

Hashicorp Sentinel provides the ability to make your policy-as-code more dynamic using the HTTP request module. This demo allows you to show how easy it is to pull dynamic data into Sentinel for process at "run-time." As soon as a run is started, the policies are read in, then executed during the policy stage.

*NOTE: It's important to understand that the nature of this demo is to simplify a complex workflow, which inherently means setting it up will be a little more involved first time around. But once you've finished setting it up the first time, it'll be quite simple to rinse and repeat the actual demo portion.*

## Introduction

HashiCorp Sentinel is a built-in, policy-as-code engine in Terraform Cloud and Enterprise. It guarantees administrators (security, network, infrastructure, and cloud teams) enforcement of business and compliance policies.

Many policies can be simple and straight-forward. Others required may require lists or other data points which are subject to change at any given time. Hard-coding data in code is not ideal, and while changes can be tracked in version control, there are better ways to manage data sets.

Using the `http` import allows policies to be written with dynamic data sets. That means you can manage data from another source, such as a database, and provide an interface of your choosing.

## Scenario

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

## Before You Start...

There are a few pre-requisites, some of which I found to be necessary evils. As with all of my demos, I try to architect them so that once initially configured, they can easily be torn down and rebuilt with little to no effort. With that said, there are handful of items you'll need to configure ahead of time.

 1. **DNS**: If you haven't already done so, please setup your `hashicorp.io` zone, which provides coverage for AWS, Azure, and GCP. *NOTE: In Azure, make sure you add the tag `DoNotDelete` to your newly created resource group AND DNS Zone. Otherwise, it will be deleted in the next purge interval.*
 2. next?

## Setup

Once again, there are several steps to setting up everything, from forking repos to setting up TFC workspaces and policy sets. But once those are in place, you can work from a single workspace going forward.

### Step 1: Setup Modules

Fork each of the following repos:

#### AWS
 - [ ] [https://github.com/kevincloud/terraform-aws-custom-igw](https://github.com/kevincloud/terraform-aws-custom-igw)
 - [ ] [https://github.com/kevincloud/terraform-aws-custom-vpc](https://github.com/kevincloud/terraform-aws-custom-vpc)
 - [ ] [https://github.com/kevincloud/terraform-aws-custom-sg](https://github.com/kevincloud/terraform-aws-custom-sg)
 - [ ] [https://github.com/kevincloud/terraform-aws-dynamodb](https://github.com/kevincloud/terraform-aws-dynamodb)
 - [ ] [https://github.com/kevincloud/terraform-aws-iam-role](https://github.com/kevincloud/terraform-aws-iam-role)
 - [ ] [https://github.com/kevincloud/terraform-aws-my-nginx](https://github.com/kevincloud/terraform-aws-my-nginx)
 - [ ] [https://github.com/kevincloud/terraform-aws-my-bucket](https://github.com/kevincloud/terraform-aws-my-bucket)

#### AzureRM

 - [ ] [https://github.com/kevincloud/terraform-azurerm-custom-vnet](https://github.com/kevincloud/terraform-azurerm-custom-vnet)
 - [ ] [https://github.com/kevincloud/terraform-azurerm-custom-sg](https://github.com/kevincloud/terraform-azurerm-custom-sg)
 - [ ] [https://github.com/kevincloud/terraform-azurerm-custom-blob](https://github.com/kevincloud/terraform-azurerm-custom-blob)
 - [ ] [https://github.com/kevincloud/terraform-azurerm-custom-vm](https://github.com/kevincloud/terraform-azurerm-custom-vm)

#### Modify Submodule

In the `terraform-aws-custom-vpc` module, you'll need to edit the module location to reflect your organization. Replace `<YOUR_TFC_ORG_NAME>` with the TF organization you're working in:

```tf
module  "custom-igw" {
    source = "app.terraform.io/<YOUR_TFC_ORG_NAME>/custom-igw/aws"

    vpc_id = aws_vpc.primary-vpc.id
    tags = var.tags
}
```

#### Tag Repos

We need to tag each of these releases with a release. So in each directory, enter the following:

```
git tag 1.0.0
git push origin master --tags
```

#### Add Modules in TFC

 - In TFC, navigate to **Modules** from the Organization menu at the top.
 - Click **+ Add Module**
 - Click the GitHub VCS provider and add each of the modules listed above. There are 7 AWS modules and 4 AzureRM modules total.

### Step 2: Setup Workspaces

Now we need to setup our workspaces. This will involved cloning a couple of additional repos, connecting them to workspaces, then setting up the variables.

#### AWS Workspace

We'll clone the AWS workspace and setup the appropriate variables. Clone the following repo:

[https://github.com/kevincloud/terraform-aws-modules](https://github.com/kevincloud/terraform-aws-modules)

In TFC, add a new workspace:

From the Organization menu at the top, navigate to **Workspaces**
 - Click **+ New Workspace**
 - Click your GitHub VCS
 - Select `terraform-aws-modules`
 - Click **Create Workspace**

Add variables.....
