@echo off

set scriptFileName=%~n0
set scriptFolderPath=%~dp0
set powershellScriptFileName=FixIntelWifiLagSpikes.ps1

powershell -Command "Start-Process powershell -Verb RunAs \"-ExecutionPolicy Bypass -NoProfile -Command `\"cd \`\"%scriptFolderPath%`\"; & \`\".\%powershellScriptFileName%\`\"; pause`\"\""
