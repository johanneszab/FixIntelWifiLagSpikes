Start-Process powershell -Verb RunAs "-ExecutionPolicy Bypass -NoProfile -Command `"cd '$pwd'; & '.\FixIntelWifiLagSpikes.ps1'; pause`""
