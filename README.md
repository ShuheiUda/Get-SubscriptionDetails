# Get-SubscriptionDetails

## Description
Get-SubscriptionDetails collect your Azure Subscription's details.

## Usage
1. Run PowerShell console
2. Run GSD script (ex. Get-SubscriptionDetails -SubscriptionID 1b30dfe1-c2b7-468d-a5cd-b0662c94ec2f)
3. login to azure  (ASM and ARM)
4. wait for a while

## Parameter
* Required
    * SubscriptionID
    
* Optional
    * SkipAuth: if you already logged in ASM & ARM, you can skip authorization popup.
    * OutputFolder: you can change output folder. (default: $env:USERPROFILE\desktop\Get-SubscriptionDetails\)

## Sample
[Sample Report](http://www.syuheiuda.com/wp-content/uploads/2016/04/1b30dfe1-c2b7-468d-a5cd-b0662c94ec2f-20160424_162010.htm)

!["Sample Image"](http://www.syuheiuda.com/wp-content/uploads/2016/04/Get-SubscriptionDetails_0_8_0.png)

## Features
* Collect ASM Resource Information
    * Compute
        * ASM Cloud Service
        * ASM Windows VM
        * ASM Linux VM
    * Storage
        * ASM Storage Account
        * ASM VM Disk
        * ASM OS Image
    * Network
        * ASM DNS Server
        * ASM Local Network Site
        * ASM Virtual Network Site
        * ASM Virtual Network Gateway
        * ASM Dedicated Circuit (ExpressRoute)
    * Subscription
        * ASM Subscription
        * ASM Location
    * Operation
        * Microsoft.ClassicCompute Provider
        * Microsoft.ClassicStorage Provider
        * Microsoft.ClassicNetwork Provider
        * Another Provider
        
* Collect ARM Resource Information
    * Compute
        * ARM Availability Set
        * ARM Windows VM
        * ARM Linux VM
    * Storage
        * ARM Storage Account
        * ARM VM Disk
    * Network
        * ARM Virtual Network
        * ARM Virtual Network Gateway
        * ARM Local Network Gateway
        * ARM ExpressRoute Circuit
        * ARM ExpressRoute Authorization
        * ARM Network Interface
        * ARM Network Security Group
        * ARM Route Table
        * ARM Load Balancer
        * ARM Public IP Address
        * ARM Application Gateway
        * ARM DNS Zone
    * Subscription
        * ARM Context (Subscription)
        * ARM Resource Provider
        * ARM Provider Feature
        * ARM Role Assignment
        * ARM Role Definition
        * ARM Location
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