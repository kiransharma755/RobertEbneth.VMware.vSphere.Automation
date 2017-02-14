# RobertEbneth.VMware.vSphere.Automation
VMware Automation Powershell Modules and Scripts by Robert Ebneth

**VMware Reporting Powershell Module and Scripts
used for VMware administration and documentation**

Latest Update: February, 14th, 2017

Export-vCenterResourcePools		- Exports vCenter ResourcePool Settings to xml File  
Import-vCenterResourcePools		- Creates vCenter ResourcePool Settings from xml File  
Set-VMResourcePool				- Moves VMs to ResourcePool; uses csv File from Export Script  

Backup_vCenter_Environment		- WorkFlow and Backup_vCenter_Environment  

Get-VAAI Settings				- Exports VAAI Settings to csv file
Set-VAAI Settings				- Sets VAAI Properties on ESXi Servers
Set-VMHostiSCSISettings			- Sets Dynamic/Static iSCSI Target bindings and important iSCSI Parameters for SW iSCSI Adapter  

Set-VMCBTenable					- enables CBT (Changed Block Tracking) property of VMs
Get-VMsshConfig					- Exports Lockdown Mode and ssh service state to a csv file
Get-VMNTPConfig					- Exports NTP settings to a csv file

vCSA-Deploy						- Deploys new vCenter VCSA  
								  (please check for SSL Error connecting ESXi Server)  

VM-Deploy-from-Tab				- Deploys VMs from csv Table  