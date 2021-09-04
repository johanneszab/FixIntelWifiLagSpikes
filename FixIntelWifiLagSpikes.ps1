#!/usr/bin/env pwsh
#Requires -RunAsAdministrator

#$driverDescRegEx = ".*Intel.*Wireless.*"
$hive = "HKLM:\SYSTEM\ControlSet001\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}\0*"

$nicLocation = $null
#$provider = "Provider"
#$netType = "NetType"
#$providerValue = "Intel"
#$netTypeValue = "WLAN"
$disabled = 0
$enabled = 1

$scanDisableOnHighOrMulticast = "ScanDisableOnHighOrMulticast"
$scanDisableOnLowLatencyOrQos = "ScanDisableOnLowLatencyOrQos"
$scanDisableOnLowTraffic = "ScanDisableOnLowTraffic"
$scanDisableOnMediumTraffic = "ScanDisableOnMediumTraffic"
$scanWhenAssociated = "ScanWhenAssociated"

Write-Host "Searching registry for an Intel Wireless NIC ..."

Get-Item $hive -ErrorAction SilentlyContinue | ForEach-Object {
    if ($_.Property.Contains("Provider") -and $_.Property.Contains("NetType")) {
        $provider = (Get-ItemPropertyValue $_.PsPath -Name 'Provider') -eq "Intel"
        $nettype = (Get-ItemPropertyValue $_.PsPath -Name 'NetType') -eq "WLAN"
        if ($provider -and $nettype) {
            $nicLocation = $_
            return
        }
    }
}

if ($null -eq $nicLocation) {
    Write-Host "No Intel Wireless NIC could be found on your system. Exiting ..."
    exit 1
} else {
    $nicType = Get-ItemPropertyValue $nicLocation.PsPath -Name 'DriverDesc'
    Write-Host "Found Intel Wireless NIC `"$nicType`" at $nicLocation."
}

try {
    Write-Host "Writing registry key $scanDisableOnHighOrMulticast with Value $enabled to $nicLocation."
    New-ItemProperty -Path $nicLocation.PsPath -Name $scanDisableOnHighOrMulticast -Value $enabled -PropertyType DWORD -ErrorAction Stop -Force | Out-Null
    Write-Host "Writing registry key $scanDisableOnLowLatencyOrQos with Value $enabled to $nicLocation."
    New-ItemProperty -Path $nicLocation.PsPath -Name $scanDisableOnLowLatencyOrQos -Value $enabled -PropertyType DWORD -ErrorAction Stop -Force | Out-Null
    Write-Host "Writing registry key $scanDisableOnLowTraffic with Value $enabled to $nicLocation."
    New-ItemProperty -Path $nicLocation.PsPath -Name $scanDisableOnLowTraffic -Value $enabled -PropertyType DWORD -ErrorAction Stop -Force | Out-Null
    Write-Host "Writing registry key $scanDisableOnMediumTraffic with Value $enabled to $nicLocation."
    New-ItemProperty -Path $nicLocation.PsPath -Name $scanDisableOnMediumTraffic -Value $enabled -PropertyType DWORD -ErrorAction Stop -Force | Out-Null
    Write-Host "Writing registry key $scanWhenAssociated with Value $disabled to $nicLocation."
    New-ItemProperty -Path $nicLocation.PsPath -Name $scanWhenAssociated -Value $disabled -PropertyType DWORD -ErrorAction Stop -Force | Out-Null
}
catch {
    Write-Host "Writing to the registry at $nicLocation failed: $($_.Exception.Message)."
    Write-Host "Stacktrace: $($_.Exception.StackTrace)."
    exit 1
}

Write-Host "Script run successfully."
Write-Host "You need to reboot your system for the changes to have effect."

exit 0
