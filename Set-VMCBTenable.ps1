﻿function Set-VMCBTenable {
<#
.SYNOPSIS
  Script enables the CBT (Changed Block Tracking) Setting on all VMs based per Cluster
.DESCRIPTION
  Script enables the CBT (Changed Block Tracking) Setting on all VMs based per Cluster
.NOTES
  Release 1.2
  Robert Ebneth
  July, 12th, 2017
.LINK
  http://github.com/rebneth/RobertEbneth.VMware.vSphere.Automation
.PARAMETER Cluster
  Selects only VMs for this vSphere Cluster. If nothing is specified,
  all vSphere Clusters will be taken.
.EXAMPLE
  Set-VMCBTenable -c < vSphere Cluster Name >
#>

[CmdletBinding()]
param(
	[Parameter(Mandatory = $False, ValueFromPipeline=$true)]
	[Alias("c")]
	[string]$CLUSTER
)


Begin {
    # Check and if not loaded add Powershell core module
    if ( !(Get-Module -Name VMware.VimAutomation.Core -ErrorAction SilentlyContinue) ) {
        Import-Module VMware.VimAutomation.Core
    }
} ### End Begin

Process {

    # If we do not get Cluster from Input, we take them all from vCenter
	If ( !$Cluster ) {
		$Cluster_to_process = (Get-Cluster | Select Name).Name | Sort}
	  else {
		$Cluster_to_process = $CLUSTER
	}
    
	foreach ( $Cluster in $Cluster_to_process ) {
	    $ClusterInfo = Get-Cluster $Cluster
        If ( $? -eq $false ) {
		    Write-Host "Error: Required Cluster $($Cluster) does not exist." -ForegroundColor Red
		    break
        }
		foreach ($vm in Get-Cluster $Cluster | Get-VM) {
			$view = Get-View $vm
			if ($view.Config.Version -ge "vmx-07" -and $view.Config.changeTrackingEnabled -eq $false) {
				if ($vm.PowerState -eq 'PoweredOff') { Write-Host "CBT cannot be enabled on VM $vm because it is PoweredOff." -ForegroundColor Red; continue }
                if ($view.snapshot -ne $null) {Write-Host "CBT cannot be enabled on VM $vm has active snapshots." -ForegroundColor Red; continue}
                #Enable CBT 
				Write-Host "Enabling CBT for" $vm
				$spec = New-Object VMware.Vim.VirtualMachineConfigSpec
				$spec.ChangeTrackingEnabled = $true 
				$vm.ExtensionData.ReconfigVM($spec) 
								
				#Take/Remove Snapshot to reconfigure VM State
				$SnapName = New-Snapshot -vm $vm -Quiesce -Name "CBT-Verify-Snapshot"
				$SnapRemove = Remove-Snapshot -Snapshot $SnapName -Confirm:$false
			}
		} ### End Foreach VM in cluster
    } ### End Foreach Cluster
} ### End Process

End {
} ### End End

} ### End function
# SIG # Begin signature block
# MIIFmgYJKoZIhvcNAQcCoIIFizCCBYcCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUVhbNMBZNQm4pIZ6sL7jtK3ea
# ZGKgggMmMIIDIjCCAgqgAwIBAgIQPWSBWJqOxopPvpSTqq3wczANBgkqhkiG9w0B
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
# AYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUVUMg3yp1nsHt
# L9GJFivdxoLfqVkwDQYJKoZIhvcNAQEBBQAEggEAOelbgeViWHWJPhP2O5JfYh68
# mkINqk4w2lwKVKkmwX4e3j5FzcqCNiCRyp+xS5myZ1SSm1bDtxCNuLZu59LrPdlb
# Wlhn/fEr0KWD1D2J5aCAlRQ8FFiEpYTFLS6lUaqT/xvZPE1WTdfNcDKTmHtOPqVm
# gZ6PB+LqSwrimgVEppW3FJXcepVDPjw0uHQ80nmWfZGGSMThxhI8chbw49BshbVw
# swe7OKAVHAWR1rAxTGGAFKU1IkKyJZMM9OZQQXC21XnrQR2Vc6nhoMA3H6ZsyRKH
# QQzH32hcavQCBsUTKdYbvUVemzzZz5nYpWGGh+PPg39v8MaS0wh0tOoOjsDOiQ==
# SIG # End signature block
