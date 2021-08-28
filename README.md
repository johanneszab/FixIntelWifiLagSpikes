# FixIntelWifiLagSpikes.ps1

A simple powershell script to fix lag spikes of Intel Wireless cards of the "Intel(R) Dual Band Wireless-AC" series. This script modifies the Windows Registry to change the cards behavior.

These lag spikes lead to periodical (say all 4 to 6 minutes) interruptions of a few seconds in video calls or online games.

## Usage:

1. Run `RunFix.cmd` or `RunFix.ps1`. Both files are a wrapper to run `FixIntelWifiLagSpikes.ps1` as Administrator (necessary for adding keys to the Windows Registry).

2. If run successfully, you'll need to reboot your system for the changes to take effect.

## Insights:

This scripts looks in the Registry under the path `HKLM:\SYSTEM\ControlSet001\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}` for any Intel Wireless NIC (based on vendor (`Intel`) and NetType (`Wifi`) of the NIC) and adds five registry keys:

* "ScanDisableOnHighOrMulticast" as DWORD with the value 1
* "ScanDisableOnLowLatencyOrQos" as DWORD with the value 1
* "ScanDisableOnLowTraffic" as DWORD with the value 1
* "ScanDisableOnMediumTraffic" as DWORD with the value 1
* "ScanWhenAssociated" as DWORD with the value 0

You can test for lag spikes by opening a command / powershell and ping your router or any other site:

```ps
ping -t 192.168.1.1
```
The output should look similar to this:

```ps
PS C:\Users\jmeyer> ping -t www.heise.de

Pinging www.heise.de [2a02:2e0:3fe:1001:7777:772e:2:85] with 32 bytes of data:
[..]
Reply from 2a02:2e0:3fe:1001:7777:772e:2:85: time=11ms
Reply from 2a02:2e0:3fe:1001:7777:772e:2:85: time=11ms
Reply from 2a02:2e0:3fe:1001:7777:772e:2:85: time=182ms
Reply from 2a02:2e0:3fe:1001:7777:772e:2:85: time=154ms
Reply from 2a02:2e0:3fe:1001:7777:772e:2:85: time=36ms
Reply from 2a02:2e0:3fe:1001:7777:772e:2:85: time=11ms
Reply from 2a02:2e0:3fe:1001:7777:772e:2:85: time=149ms
Reply from 2a02:2e0:3fe:1001:7777:772e:2:85: time=11ms
Reply from 2a02:2e0:3fe:1001:7777:772e:2:85: time=12ms
Reply from 2a02:2e0:3fe:1001:7777:772e:2:85: time=12ms
Reply from 2a02:2e0:3fe:1001:7777:772e:2:85: time=12ms
[..]

Ping statistics for 2a02:2e0:3fe:1001:7777:772e:2:85:
    Packets: Sent = 384, Received = 384, Lost = 0 (0% loss),
Approximate round trip times in milli-seconds:
    Minimum = 11ms, Maximum = 182ms, Average = 12ms
Control-C
```

Before applying the fix, you'll see a recurring pattern of a bunch of pings with a high round-trip time of several hundred ms as shown in the example above.

Apparently, Intel wireless cards cannot scan for new networks while maintaining a consistent low latency stream for the established connection.

## Tested on:

Tested on Windows 10 21H1 with an Intel(R) Dual Band Wireless-AC 7260 (Asus PCE-AC56).

These Windows Registry keys should also work on the following Intel Wireless chipsets (tested):

* Intel (R) Dual Band Wireless-AC 8265
* Intel (R) Dual Band Wireless-AC 7265
* Intel (R) Dual Band Wireless-AC 7260
* Intel (R) Dual Band Wireless-AC 3165 
