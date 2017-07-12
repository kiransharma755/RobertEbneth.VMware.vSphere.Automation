﻿Function Export-vCenterResourcePools {
<#
.SYNOPSIS
  Export Resource Pools from vSphere Cluster
  Export Location of vSphere Clusters VMs within Resource Pools
.DESCRIPTION
  Export Resource Pools from vSphere Cluster
  Export Location of vSphere Clusters VMs within Resource Pools
  This can be used day-by-day for a logical backup of
  VMware vCenter Resource Pool Settings. VMware vCenter
  Resource Pool Settings can be reconstructed by Script
  Set-VMResourcePool
.NOTES
  Release 1.3
  Robert Ebneth
  July, 12th, 2017
.LINK
  http://github.com/rebneth/RobertEbneth.VMware.vSphere.Automation
.PARAMETER Cluster
  Selects only ressource pools / VMs location from this vSphere Cluster.
  If nothing is specified, all vSphere Clusters will be taken.
.PARAMETER FILENAME1
  Name of xml output file of the ressource pool properties
.PARAMETER FILENAME2
  Name of the csv output file for the VMs relation to resource pool
.EXAMPLE
  Export-vCenterResourcePools -Cluster <vSphere Cluster name>
.EXAMPLE
  Get-Cluster | Export-vCenterResourcePools
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $True, ValueFromPipeline=$true, Position = 0)]
    [string]$Cluster,
	[Parameter(Mandatory = $False, ValueFromPipeline=$false, Position = 1,
	HelpMessage = "Enter the path to the xml output file")]
	[string]$FILENAME1 = "$($env:USERPROFILE)\vCenter_ResourcePools.xml",
	[Parameter(Mandatory = $False, ValueFromPipeline=$false, Position = 2,
	HelpMessage = "Enter the path to the csv output file")]
	[string]$FILENAME2 = "$($env:USERPROFILE)\vCenter_VMResourcePoolLocation.csv"
)

Begin {
    # Check and if not loaded add Powershell core module
    if ( !(Get-Module -Name VMware.VimAutomation.Core -ErrorAction SilentlyContinue) ) {
        Import-Module VMware.VimAutomation.Core
    }
	#$OUTPUTFILENAME = CheckFilePathAndCreate VMPowerState.csv $FILENAME
    $AllResourcePools = @()
    $AllVMsResourcePoolPath = @()

    Write-Host "#####################################################"
    Write-Host "# Export vCenter Resource Pools and their Structure #"
    Write-Host "#####################################################"	
	}

Process {
    $ClusterName = $Cluster
    $ClusterRP = Get-Cluster $ClusterName | Get-ResourcePool
    $RPRoot =  $ClusterRP | Where { $_.Name -eq "Resources"}
 
    ###
    ### Export of the Resource Pool Properties
    ###

    Write-Host "Exporting vCenter Cluster $Clustername Resource Pool Properties ..."
    foreach ( $ResPool in ($ClusterRP | where { $_.Name -ne "Resources"})) {
        $ResPoolPath = ""
        $CheckResPoolLevel = $ResPool
        while ( $CheckResPoolLevel.ParentId -ne $RPRoot.Id ) {
            $UpperResPool = $ClusterRP | Where { $_.Id -eq $CheckResPoolLevel.ParentId }
            $ResPoolPath = "\" + $UpperResPool.Name + "$ResPoolPath"
            $CheckResPoolLevel = $UpperResPool
        }
        $ResourcePool = "" | Select Path 
        $ResourcePool.Path = "\" + $RPRoot.Parent + "$ResPoolPath"
        $ResourcePool | Add-Member -Name 'Properties' -Value $ResPool -MemberType NoteProperty
        $AllResourcePools += $ResourcePool
    }

    ###
    ### Export of the Resource Pool Location for VMs
    ###

    $vms = Get-Cluster $ClusterName | Get-VM |Select Name, ResourcePoolId | Sort Name
    $LocResourcePool = Get-Cluster -Name $ClusterName | Get-ResourcePool | Where { $_.Name -eq "Resources" }

    Write-Host "Exporting vCenter Cluster $Clustername VM's Resource Pool Info..."
    Foreach( $vm in $vms) {
        $ResPoolPath = ""
        $CheckResPoolId = $vm.ResourcePoolId
        # Get Upper Resource Pool Tree
        while ( $CheckResPoolId -ne $RPRoot.Id ) {
            #Write-Host $vm.Name $CheckResPoolId $RPRoot.Id
            $UpperResPool = $ClusterRP | Where { $_.Id -eq $CheckResPoolId }
            $ResPoolPath = "\" + $UpperResPool.Name + "$ResPoolPath"
            $CheckResPoolId = $UpperResPool.ParentId
        }
        $VMResourcePool = "" | Select VMname
        $VMResourcePool.VMName = $vm.Name
        $ResPoolPath = "\" + $RPRoot.Parent + "$ResPoolPath"
        $VMResourcePool | Add-Member -Name 'ResourcePoolPath' -Value "$ResPoolPath" -MemberType NoteProperty
        $AllVMsResourcePoolPath += $VMResourcePool
    }
} ### End Process

End {
    Write-Host "Writing File $($FILENAME1)..."
    $AllResourcePools | Export-Clixml $FILENAME1
    Write-Host "Writing File $($FILENAME2)..."
    $AllVMsResourcePoolPath | Select VMname, ResourcePoolPath | Export-Csv $FILENAME2 -NoTypeInformation
} ### End End
} ### End Function
# SIG # Begin signature block
# MIIFmgYJKoZIhvcNAQcCoIIFizCCBYcCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUax8wk85UnYc6c64zVFMPbnVw
# cdqgggMmMIIDIjCCAgqgAwIBAgIQPWSBWJqOxopPvpSTqq3wczANBgkqhkiG9w0B
# AQUFADApMScwJQYDVQQDDB5Sb2JlcnRFYm5ldGhJVFN5c3RlbUNvbnN1bHRpbmcw
# HhcNMTcwMjA0MTI0NjQ5WhcNMjIwMjA1MTI0NjQ5WjApMScwJQYDVQQDDB5Sb2Jl
# cnRFYm5ldGhJVFN5c3RlbUNvbnN1bHRpbmcwggEiMA0GCSqGSIb3DQEBAQUAA4IB
# DwAwggEKAoIBAQCdqdh2MLNnST7h2crQ7CeJG9zXfPv14TF5v/ZaO8yLmYkJVsz1
# tBFU5E1aWhTM/fk0bQo0Qa4xt7OtcJOXf83RgoFvo4Or2ab+pKSy3dy8GQ5sFpOt
# NsvLECxycUV/X/qpmOF4P5f4kHlWisr9R6xs1Svf9ToktE82VXQ/jgEoiAvmUuio
# bLLpx7/i6ii4dkMdT+y7eE7fhVsfvS1FqDLStB7xyNMRDlGiITN8kh9kE63bMQ1P
# yaCBpDegi/wIFdsgoSMki3iEBkiyF+5TklatPh25XY7x3hCiQbgs64ElDrjv4k/e
# WJKyiow3jmtzWdD+xQJKT/eqND5jHF9VMqLNAgMBAAGjRjBEMBMGA1UdJQQMMAoG
# CCsGAQUFBwMDMA4GA1UdDwEB/wQEAwIHgDAdBgNVHQ4EFgQUXJLKHJBzYZdTDg9Z
# QMC1/OLMbxUwDQYJKoZIhvcNAQEFBQADggEBAGcRyu0x3vL01a2+GYU1n2KGuef/
# 5jhbgXaYCDm0HNnwVcA6f1vEgFqkh4P03/7kYag9GZRL21l25Lo/plPqgnPjcYwj
# 5YFzcZaCi+NILzCLUIWUtJR1Z2jxlOlYcXyiGCjzgEnfu3fdJLDNI6RffnInnBpZ
# WdEI8F6HnkXHDBfmNIU+Tn1znURXBf3qzmUFsg1mr5IDrF75E27v4SZC7HMEbAmh
# 107gq05QGvADv38WcltjK1usKRxIyleipWjAgAoFd0OtrI6FIto5OwwqJxHR/wV7
# rgJ3xDQYC7g6DP6F0xYxqPdMAr4FYZ0ADc2WsIEKMIq//Qg0rN1WxBCJC/QxggHe
# MIIB2gIBATA9MCkxJzAlBgNVBAMMHlJvYmVydEVibmV0aElUU3lzdGVtQ29uc3Vs
# dGluZwIQPWSBWJqOxopPvpSTqq3wczAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIB
# DDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEE
# AYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQULB6e+YlQGlV9
# JuLyldyiod1yDQYwDQYJKoZIhvcNAQEBBQAEggEARYG1lkDnRj1axRAnq2zPvn/1
# asXXpOBq/avE8HWhbT0NXDopCMornOFGH/bAwbzPmKMrdLo14wUGts6Ww5xtoYz5
# 8oNHNeiurVHWf7ypuLacN4imsQTCMOXajWhgRCjwhOK806DVG/nevBPTGrcOylxZ
# +g7K/SEwyt3lUPpJm3C6I5xy2f0wgCVCyeBMpEBNK46NJyRsu9jjFtLf/XNqOk0a
# R4CZVZXi3gZM6KQaVR5B9S8R/ro4oKON7ayXRJN7fVfHJ5SjXP4aYu1xXbD1YMzI
# /Zxwz5bTvaXuTZDO6TyhFx24lrDYCIt56pkiMy/XzWJhCE1goWEMih22TqjpNA==
# SIG # End signature block
