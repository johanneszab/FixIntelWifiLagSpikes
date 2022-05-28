#!/usr/bin/env pwsh
#Requires -RunAsAdministrator

$hive = "HKLM:\SYSTEM\ControlSet001\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}\0*"
$nicLocations = [System.Collections.ArrayList]::new()
$driverDescription = "DriverDesc"
$provider = "Provider"
$nettype = "NetType"
$intelProvider = "Intel"
$wifiNettype = "WLAN"
$disabled = 0
$enabled = 1
$successful = $true

$scanDisableOnHighOrMulticast = "ScanDisableOnHighOrMulticast"
$scanDisableOnLowLatencyOrQos = "ScanDisableOnLowLatencyOrQos"
$scanDisableOnLowTraffic = "ScanDisableOnLowTraffic"
$scanDisableOnMediumTraffic = "ScanDisableOnMediumTraffic"
$scanWhenAssociated = "ScanWhenAssociated"

Write-Host "Searching registry for Intel Wireless NIC ..."

Get-Item $hive -ErrorAction SilentlyContinue | ForEach-Object {
    if ($_.Property.Contains($provider) -and $_.Property.Contains($nettype)) {
        $providerMatched = (Get-ItemPropertyValue $_.PsPath -Name $provider) -eq $intelProvider
        $nettypeMatched = (Get-ItemPropertyValue $_.PsPath -Name $nettype) -eq $wifiNettype
        if ($providerMatched -and $nettypeMatched) {
            $nicLocations.Add($_) | Out-Null  
        }
    }
}

if ($nicLocations.Count -eq 0) {
    Write-Host "No Intel Wireless NIC could be found on your system. Exiting ..."
    exit 1
} else {
    foreach ($nic in $nicLocations) {
        $description = (Get-ItemPropertyValue $nic.PsPath -Name $driverDescription)
        Write-Host "Found Intel Wireless NIC `"$description`" at $nic."
    }
}

foreach ($nic in $nicLocations) {
    try {
        $description = (Get-ItemPropertyValue $nic.PsPath -Name $driverDescription)
        Write-Host "Writing registry keys for `"$description`" ..."

        Write-Host "Writing registry key $scanDisableOnHighOrMulticast with Value $enabled to $nic."
        New-ItemProperty -Path $nic.PsPath -Name $scanDisableOnHighOrMulticast -Value $enabled -PropertyType DWORD -ErrorAction Stop -Force | Out-Null
        Write-Host "Writing registry key $scanDisableOnLowLatencyOrQos with Value $enabled to $nic."
        New-ItemProperty -Path $nic.PsPath -Name $scanDisableOnLowLatencyOrQos -Value $enabled -PropertyType DWORD -ErrorAction Stop -Force | Out-Null
        Write-Host "Writing registry key $scanDisableOnLowTraffic with Value $enabled to $nic."
        New-ItemProperty -Path $nic.PsPath -Name $scanDisableOnLowTraffic -Value $enabled -PropertyType DWORD -ErrorAction Stop -Force | Out-Null
        Write-Host "Writing registry key $scanDisableOnMediumTraffic with Value $enabled to $nic."
        New-ItemProperty -Path $nic.PsPath -Name $scanDisableOnMediumTraffic -Value $enabled -PropertyType DWORD -ErrorAction Stop -Force | Out-Null
        Write-Host "Writing registry key $scanWhenAssociated with Value $disabled to $nic."
        New-ItemProperty -Path $nic.PsPath -Name $scanWhenAssociated -Value $disabled -PropertyType DWORD -ErrorAction Stop -Force | Out-Null

        Write-Host "Writing registry keys for `"$description`" completed."
    } catch {
        Write-Host "Writing to the registry at $nic failed: $($_.Exception.Message)."
        Write-Host "Stacktrace: $($_.Exception.StackTrace)."
        $successful = $false
    }
}

if ($successful) {
    Write-Host "Script run successful."
    Write-Host "You'll need to reboot your system for the changes to take effect."
    exit 0
} else {
    Write-Host "An error occured."
    Write-Host "Check the output above for more information."
    Write-Host "Script run unsuccessful."
    exit 1
}
