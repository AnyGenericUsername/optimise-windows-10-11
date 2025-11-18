<#
.SYNOPSIS
    Universal PowerShell script to disable Copilot, uninstall Cortana,
    configure privacy settings, and remove common bloatware.
    
.DESCRIPTION
    This script works for both Windows 10 and Windows 11.
    It must be run as an Administrator.
    It performs registry changes and removes system components.
    It EXCLUDES language pack and Xbox/Gaming component removal.
    
.NOTES
    Author: Gemini Assistant
    Version: 3.0 (Universal)
    WARNING: Run this at your own risk. Create a system restore point first.
#>

Write-Host "--- Starting Universal System Configuration Script (Windows 10 & 11) ---" -ForegroundColor Yellow
Write-Host "NOTE: This script MUST be run as an Administrator."
Write-Host "Please create a system restore point before proceeding."
Write-Host ""
Pause "Press Enter to continue or CTRL+C to cancel..."

#=================================================================
# 1. DISABLE COPILOT
#=================================================================
Write-Host ""
Write-Host "--- 1. Disabling Windows Copilot ---" -ForegroundColor Cyan

# Disable Copilot via Group Policy (Registry) - System-Wide
Write-Host "Setting system-wide registry policy to disable Copilot..."
$regPathCopilot = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot"
if (-not (Test-Path $regPathCopilot)) {
    New-Item -Path $regPathCopilot -Force | Out-Null
}
New-ItemProperty -Path $regPathCopilot -Name "TurnOffWindowsCopilot" -Value 1 -PropertyType DWORD -Force | Out-Null

# Disable Copilot for Current User (hides taskbar button)
Write-Host "Setting current user registry policy to hide Copilot..."
$regPathCopilotUser = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
New-ItemProperty -Path $regPathCopilotUser -Name "ShowCopilotButton" -Value 0 -PropertyType DWORD -Force | Out-Null

# Attempt to uninstall the Copilot AppX package for all users
Write-Host "Attempting to uninstall the Copilot package..."
try {
    Get-AppxPackage -AllUsers *Microsoft.Copilot* | Remove-AppxPackage -AllUsers -ErrorAction Stop
    Write-Host "Copilot package uninstalled successfully." -ForegroundColor Green
}
catch {
    Write-Host "Could not uninstall Copilot package (it may not be installed)." -ForegroundColor Yellow
}

#=================================================================
# 2. UNINSTALL CORTANA
#=================================================================
Write-Host ""
Write-Host "--- 2. Uninstalling Cortana ---" -ForegroundColor Cyan

Write-Host "Attempting to uninstall the Cortana package for all users..."
try {
    Get-AppxPackage -AllUsers *Microsoft.549981C3F5F10* | Remove-AppxPackage -AllUsers -ErrorAction Stop
    Write-Host "Cortana package uninstalled successfully." -ForegroundColor Green
}
catch {
    Write-Host "Could not uninstall Cortana package." -ForegroundColor Yellow
}


#=================================================================
# 3. CONFIGURE PRIVACY SETTINGS & DISABLE TELEMETRY
#=================================================================
Write-Host ""
Write-Host "--- 3. Configuring Privacy & Telemetry Settings ---" -ForegroundColor Cyan

# Disable Telemetry Service (FIXED METHOD)
Write-Host "Disabling 'Connected User Experiences and Telemetry' service (DiagTrack)..."
# Set to Disabled first to prevent restart
Set-Service -Name "DiagTrack" -StartupType Disabled -ErrorAction SilentlyContinue
# Force-stop the service and its dependencies
Stop-Service -Name "DiagTrack" -Force -ErrorAction SilentlyContinue
Write-Host "Service 'DiagTrack' set to Disabled." -ForegroundColor Green

# Set Telemetry level to 0 (Security-only)
Write-Host "Setting Telemetry level to 0 (Security) via registry..."
$regPathTelemetry = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
if (-not (Test-Path $regPathTelemetry)) {
    New-Item -Path $regPathTelemetry -Force | Out-Null
}
New-ItemProperty -Path $regPathTelemetry -Name "AllowTelemetry" -Value 0 -PropertyType DWORD -Force | Out-Null

# Disable Advertising ID
Write-Host "Disabling Advertising ID..."
$regPathAdID = "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
if (-not (Test-Path $regPathAdID)) {
    New-Item -Path $regPathAdID -Force | Out-Null
}
New-ItemProperty -Path $regPathAdID -Name "Enabled" -Value 0 -PropertyType DWORD -Force | Out-Null

# Disable "Tailored experiences"
Write-Host "Disabling 'Tailored experiences' (diagnostic data feedback)..."
$regPathPrivacy = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy"
if (-not (Test-Path $regPathPrivacy)) {
    New-Item -Path $regPathPrivacy -Force | Out-Null
}
New-ItemProperty -Path $regPathPrivacy -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Value 0 -PropertyType DWORD -Force | Out-Null

# Disable App launch tracking (for Start Menu recommendations)
Write-Host "Disabling app launch tracking (Start Menu suggestions)..."
$regPathAppTracking = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
New-ItemProperty -Path $regPathAppTracking -Name "Start_TrackProgs" -Value 0 -PropertyType DWORD -Force | Out-Null

# Disable Lock Screen "fun facts, tips, tricks"
Write-Host "Disabling tips and ads on the Lock Screen..."
$regPathContentDelivery = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
if (-not (Test-Path $regPathContentDelivery)) {
    New-Item -Path $regPathContentDelivery -Force | Out-Null
}
New-ItemProperty -Path $regPathContentDelivery -Name "RotatingLockScreenOverlayEnabled" -Value 0 -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path $regPathContentDelivery -Name "SubscribedContent-338387Enabled" -Value 0 -PropertyType DWORD -Force | Out-Null

# Disable suggested content in Settings app
Write-Host "Disabling suggested content in Settings app..."
New-ItemProperty -Path $regPathContentDelivery -Name "SubscribedContent-338393Enabled" -Value 0 -PropertyType DWORD -Force | Out-Null


#=================================================================
# 4. REMOVE PRE-INSTALLED APPX PACKAGES (BLOATWARE)
#=================================================================
Write-Host ""
Write-Host "--- 4. Removing Bloatware AppX Packages ---" -ForegroundColor Cyan
Write-Host "This will skip Xbox and Gaming apps."

# --- Utility / "Get" Apps ---
Get-AppxPackage -AllUsers *Microsoft.GetHelp* | Remove-AppxPackage -AllUsers
Get-AppxPackage -AllUsers *Microsoft.Getstarted* | Remove-AppxPackage -AllUsers
Get-AppxPackage -AllUsers *Microsoft.MicrosoftOfficeHub* | Remove-AppxPackage -AllUsers # "Office" app
Get-AppxPackage -AllUsers *Microsoft.Office.OneNote* | Remove-AppxPackage -AllUsers
Get-AppxPackage -AllUsers *Microsoft.Todos* | Remove-AppxPackage -AllUsers
Get-AppxPackage -AllUsers *Microsoft.YourPhone* | Remove-AppxPackage -AllUsers # Phone Link

# --- Media & Entertainment Apps ---
Get-AppxPackage -AllUsers *Microsoft.WindowsMaps* | Remove-AppxPackage -AllUsers
Get-AppxPackage -AllUsers *Microsoft.WindowsSoundRecorder* | Remove-AppxPackage -AllUsers
Get-AppxPackage -AllUsers *Microsoft.ZuneMusic* | Remove-AppxPackage -AllUsers # Groove Music
Get-AppxPackage -AllUsers *Microsoft.ZuneVideo* | Remove-AppxPackage -AllUsers
Get-AppxPackage -AllUsers *Microsoft.bingweather* | Remove-AppxPackage -AllUsers
Get-AppxPackage -AllUsers *Microsoft.WindowsFeedbackHub* | Remove-AppxPackage -AllUsers

# --- Third-Party App Stubs (if present) ---
Get-AppxPackage -AllUsers *SpotifyAB.SpotifyMusic* | Remove-AppxPackage -AllUsers
Get-AppxPackage -AllUsers *Netflix.* | Remove-AppxPackage -AllUsers
Get-AppxPackage -AllUsers *TikTok.* | Remove-AppxPackage -AllUsers

# --- Mixed Reality & 3D (if you don't use them) ---
Get-AppxPackage -AllUsers *Microsoft.MixedReality.Portal* | Remove-AppxPackage -AllUsers
Get-AppxPackage -AllUsers *Microsoft.Microsoft3DViewer* | Remove-AppxPackage -AllUsers

Write-Host "Appx package removal complete." -ForegroundColor Green

#=================================================================
# 5. DISABLE OPTIONAL WINDOWS FEATURES
#=================================================================
Write-Host ""
Write-Host "--- 5. Disabling Optional Windows Features ---" -ForegroundColor Cyan

# --- XPS Document Writer (Microsoft's old PDF alternative) ---
Write-Host "Disabling XPS Document Writer..."
Disable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Printing-XPSServices-Driver" -NoRestart

# --- XPS Viewer ---
Write-Host "Disabling XPS Viewer..."
Disable-WindowsOptionalFeature -Online -FeatureName "XPS-Viewer" -NoRestart

# --- Internet Explorer 11 (IE Mode) ---
Write-Host "Disabling Internet Explorer 11..."
Disable-WindowsOptionalFeature -Online -FeatureName "Internet-Explorer-Optional-amd64" -NoRestart

# --- Work Folders (if you don't use this enterprise feature) ---
Write-Host "Disabling Work Folders..."
Disable-WindowsOptionalFeature -Online -FeatureName "WorkFolders-Client" -NoRestart

#=================================================================
# 6. APPLY ADDITIONAL UI & TELEMETRY TWEAKS
#=================================================================
Write-Host ""
Write-Host "--- 6. Applying Additional UI & Privacy Tweaks ---" -ForegroundColor Cyan

# Disable "Recommended" section in the Start Menu (Windows 11)
Write-Host "Disabling 'Recommended' section in Start Menu (if present)..."
$regPathStart = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
New-ItemProperty -Path $regPathStart -Name "Start_ShowRecommended" -Value 0 -PropertyType DWORD -Force | Out-Null

# Disable "Suggested" apps in the Start Menu (Windows 10 & 11)
Write-Host "Disabling 'Suggested' apps in Start Menu..."
New-ItemProperty -Path $regPathStart -Name "Start_ShowSuggestions" -Value 0 -PropertyType DWORD -Force | Out-Null

# Disable File Explorer Ads (notifications from sync providers)
Write-Host "Disabling File Explorer sync provider notifications..."
$regPathExplorer = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
New-ItemProperty -Path $regPathExplorer -Name "ShowSyncProviderNotifications" -Value 0 -PropertyType DWORD -Force | Out-Null

#=================================================================
# 7. SYSTEM CLEANUP
#=================================================================
Write-Host ""
Write-Host "--- 7. Running System Component Cleanup (DISM) ---" -ForegroundColor Cyan
Write-Host "This may take a few minutes..."

Dism.exe /online /Cleanup-Image /StartComponentCleanup

#=================================================================
# SCRIPT COMPLETE
#=================================================================
Write-Host ""
Write-Host "--- Universal Configuration Script Finished ---" -ForegroundColor Green
Write-Host "A RESTART is required to apply all changes."
Write-Host ""
