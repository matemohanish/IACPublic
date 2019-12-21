
Connect-AzAccount
Set-AzContext -SubscriptionId <Subcription ID>

$a =Get-AzConsumptionUsageDetail -StartDate (Get-Date).AddDays(-18) -EndDate (Get-Date)  | group -Property InstanceName | Select Name ,@{name = "Usage"; E={$_.Group.pretaxcost}} -first 10

Function Get-AzureConsumptionDetails
{
[cmdletbinding()]
Param (
        [parameter(mandatory= $true, Helpmessage= "Please specify a number ")]
        [int]$Fromday,
        [datetime]$To = (Get-Date),
        [parameter(mandatory= $true, Helpmessage= "Please specify a number ")]
        $Subscriptionid 
      )

#Set-AzContext -SubscriptionId $Subscriptionid
$AzConsumptionUsageDetails = Get-AzConsumptionUsageDetail -StartDate (Get-Date).AddDays(-$Fromday) -EndDate $To  | 
                                                        group -Property InstanceName | 
                                                        Select Name ,@{name = "Usage"; E={$_.Group.pretaxcost}} ,@{name = "ConsumedService"; E={$_.Group.ConsumedService}},@{name = "SubscriptionName"; E={$_.Group.SubscriptionName}},@{name = "Currency"; E={$_.Group.Currency}}
Foreach($AzConsumptionUsageDetail in $AzConsumptionUsageDetails)
{
    $Usages = $AzConsumptionUsageDetail | Select -expand Usage 
    $totalUsage =$null
    Foreach ($Usage in $Usages)
    {
        $totalUsage += $Usage
    }
        
   [array]$Billing += [PsCustomobject][ordered]@{
                Currency= $AzConsumptionUsageDetail.Currency | select -First 1;
                ConsumedService = $AzConsumptionUsageDetail.ConsumedService | Select -First 1;
                InstalnceName = $AzConsumptionUsageDetail.Name;
                CostAccociated = $totalUsage -as [int]   
            }
}
$output = $Billing | Sort-Object -Descending -Property CostAccociated
Return($output)
}
