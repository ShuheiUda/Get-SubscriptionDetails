# Get-SubscriptionDetails

## Description
Get-SubscriptionDetails collect your Azure Subscription's details.

## Usage
1. Run PowerShell console
2. Run GSD script (ex. Get-SubscriptionDetails -SubscriptionID 1b30dfe1-c2b7-468d-a5cd-b0662c94ec2f)
3. login to azure
4. wait for a while

## Parameter
* Required
    * SubscriptionID
    
* Optional
    * SkipAuth: if you already logged in ARM, you can skip authorization popup.
    * OutputFolder: you can change output folder. (default: $env:USERPROFILE\desktop\Get-SubscriptionDetails\)

## Sample
[Sample Report](http://www.syuheiuda.com/wp-content/uploads/2017/04/Sample_0_9_1-676ba02b-eb02-4b62-885d-1116518ebd1f-20170408_192331.htm)

!["Sample Image"](http://www.syuheiuda.com/wp-content/uploads/2017/04/Get-SubscriptionDetails_0_9_1.png)

## Features
        
* Collect Resource Information
    * Compute
        * Availability Set
        * Windows VM
        * Linux VM
    * Storage
        * Storage Account
        * VM Disk
        * Managed Disks (Snapshot, Image)
        * Recovery Service Vault
    * Network
        * Virtual Network
        * Virtual Network Gateway
        * Virtual Network Gateway Connection
        * Local Network Gateway
        * Application Gateway
        * ExpressRoute Circuit
        * ExpressRoute Authorization
        * ExpressRoute ARP Table
        * ExpressRoute Route Table
        * Load Balancer
        * Network Interface
        * Public IP Address
        * Network Security Group (NSG)
        * Route Table (UDR)
        * DNS Zone
    * Management
        * Log Analytics workspaces
    * Subscription
        * Context (Subscription)
        * Resource Provider
        * Provider Feature
        * Role Assignment
        * Role Definition
        * Location
    * Operation
        * Microsoft.Compute Provider
        * Microsoft.Storage Provider
        * Microsoft.Network Provider
        * Another Provider

## Requirements
This script need Latest version of [Azure PowerShell module](http://aka.ms/webpi-azps). 

How to install and configure Azure PowerShell (Doc: [English](https://azure.microsoft.com/en-us/documentation/articles/powershell-install-configure/) | [Japanese](https://azure.microsoft.com/ja-jp/documentation/articles/powershell-install-configure/))

## Lincense
Copyright (c) 2016-2017 Syuhei Uda
Released under the [MIT license](http://opensource.org/licenses/mit-license.php )

## Release Notes
* 2016/04/24 Ver.0.8.0 (Preview Release) : +VM, Storage, Network summary
* 2016/05/05 Ver.0.8.1 (Preview Release) : +Operation log summary
* 2017/01/14 Ver.0.9.0 (Preview Release) : +some resources & detail view
* 2017/04/08 Ver.0.9.1 (Preview Release) : +some resources & Status color
* 2018/03/18 Ver.0.9.2 (Preview Release) : optimized for Azure PowerShell 5.5.0
* 2018/07/25 Ver.0.9.3 (Preview Release) : + Resource Links (Only)