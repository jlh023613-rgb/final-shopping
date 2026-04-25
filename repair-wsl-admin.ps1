$ErrorActionPreference = "Stop"

function Test-Admin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-MicrosoftSignature {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )

    if (!(Test-Path $FilePath)) {
        return $false
    }

    $sig = Get-AuthenticodeSignature -FilePath $FilePath
    return $sig.Status -eq "Valid" -and $sig.SignerCertificate.Subject -like "*Microsoft Corporation*"
}

if (-not (Test-Admin)) {
    $args = @(
        "-NoProfile"
        "-ExecutionPolicy", "Bypass"
        "-File", ('"{0}"' -f $PSCommandPath)
    )
    Start-Process -FilePath "powershell.exe" -Verb RunAs -ArgumentList ($args -join " ")
    exit 0
}

$logPath = Join-Path $env:TEMP "repair-wsl-admin.log"
Start-Transcript -Path $logPath -Force | Out-Null

try {
    Write-Host "Cleaning old Ubuntu registrations..." -ForegroundColor Cyan

    $ubuntuPackage = Get-AppxPackage CanonicalGroupLimited.Ubuntu -ErrorAction SilentlyContinue
    if ($ubuntuPackage) {
        Remove-AppxPackage -Package $ubuntuPackage.PackageFullName -ErrorAction SilentlyContinue
    }

    $lxssRoot = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss"
    if (Test-Path $lxssRoot) {
        Get-ChildItem $lxssRoot | ForEach-Object {
            $props = Get-ItemProperty -LiteralPath $_.PSPath -ErrorAction SilentlyContinue
            if ($props.DistributionName -eq "Ubuntu-24.04") {
                Remove-Item -LiteralPath $_.PSPath -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
    }

    $pathsToDelete = @(
        "C:\Users\35373\AppData\Local\wsl"
        "C:\Users\35373\AppData\Local\Packages\CanonicalGroupLimited.Ubuntu_79rhkp1fndgsc"
    )

    foreach ($path in $pathsToDelete) {
        if (Test-Path $path) {
            cmd /c "rd /s /q `"$path`""
        }
    }

    Write-Host "Removing existing Microsoft WSL package registrations..." -ForegroundColor Cyan
    $wslPackages = Get-AppxPackage -AllUsers MicrosoftCorporationII.WindowsSubsystemForLinux -ErrorAction SilentlyContinue
    foreach ($wslPackage in $wslPackages) {
        try {
            Remove-AppxPackage -Package $wslPackage.PackageFullName -AllUsers -ErrorAction SilentlyContinue
        } catch {
        }
    }

    $provisionedWsl = Get-AppxProvisionedPackage -Online | Where-Object {
        $_.DisplayName -eq "MicrosoftCorporationII.WindowsSubsystemForLinux" -or
        $_.PackageName -like "MicrosoftCorporationII.WindowsSubsystemForLinux*"
    }
    foreach ($pkg in $provisionedWsl) {
        try {
            Remove-AppxProvisionedPackage -Online -PackageName $pkg.PackageName -ErrorAction SilentlyContinue | Out-Null
        } catch {
        }
    }

    $wslInstallPaths = @(
        "C:\Program Files\WSL",
        "C:\Users\35373\AppData\Local\Packages\MicrosoftCorporationII.WindowsSubsystemForLinux_8wekyb3d8bbwe"
    )
    foreach ($path in $wslInstallPaths) {
        if (Test-Path $path) {
            cmd /c "rd /s /q `"$path`""
        }
    }

    Write-Host "Ensuring Windows features are enabled..." -ForegroundColor Cyan
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

    Write-Host "Installing latest WSL MSI..." -ForegroundColor Cyan
    $cachedMsiPath = "C:\Windows\Installer\3fa382e8.msi"
    $msiPath = Join-Path $env:TEMP "wsl.2.6.3.0.x64.msi"

    if (Test-MicrosoftSignature -FilePath $cachedMsiPath) {
        $msiPath = $cachedMsiPath
        Write-Host "Using locally cached Microsoft-signed WSL MSI." -ForegroundColor Yellow
    } else {
        $msiUrls = @(
            "https://mirror.ghproxy.com/https://github.com/microsoft/WSL/releases/download/2.6.3/wsl.2.6.3.0.x64.msi",
            "https://ghproxy.cn/https://github.com/microsoft/WSL/releases/download/2.6.3/wsl.2.6.3.0.x64.msi",
            "https://github.com/microsoft/WSL/releases/download/2.6.3/wsl.2.6.3.0.x64.msi"
        )

        if (!(Test-MicrosoftSignature -FilePath $msiPath)) {
            if (Test-Path $msiPath) {
                Remove-Item -LiteralPath $msiPath -Force -ErrorAction SilentlyContinue
            }

            $downloaded = $false
            foreach ($msiUrl in $msiUrls) {
                Write-Host "Trying $msiUrl" -ForegroundColor Yellow
                try {
                    & curl.exe -L --retry 5 --retry-all-errors --connect-timeout 20 --max-time 600 $msiUrl -o $msiPath
                } catch {
                }

                if (Test-MicrosoftSignature -FilePath $msiPath) {
                    $downloaded = $true
                    break
                }

                if (Test-Path $msiPath) {
                    Remove-Item -LiteralPath $msiPath -Force -ErrorAction SilentlyContinue
                }
            }

            if (-not $downloaded) {
                throw "Failed to download a valid Microsoft-signed WSL MSI."
            }
        } else {
            Write-Host "Using already downloaded Microsoft-signed MSI." -ForegroundColor Yellow
        }
    }

    Write-Host "Removing current WSL MSI product..." -ForegroundColor Cyan
    Start-Process -FilePath "msiexec.exe" -ArgumentList @("/x", "{B637A6A6-5591-4503-AFD8-776164EB837A}", "/passive", "/norestart") -Wait

    Write-Host "Reinstalling WSL from MSI..." -ForegroundColor Cyan
    $install = Start-Process -FilePath "msiexec.exe" -ArgumentList @("/i", $msiPath, "/passive", "/norestart") -Wait -PassThru
    if ($install.ExitCode -ne 0) {
        throw "WSL MSI install failed with exit code $($install.ExitCode)."
    }

    Write-Host "Restarting WSL services..." -ForegroundColor Cyan
    Get-Service WSLService -ErrorAction SilentlyContinue | Restart-Service -Force -ErrorAction SilentlyContinue
    Get-Service vmcompute -ErrorAction SilentlyContinue | Restart-Service -Force -ErrorAction SilentlyContinue

    Write-Host "Checking WSL status..." -ForegroundColor Cyan
    & C:\Windows\System32\wsl.exe --status

    Write-Host "Installing Ubuntu-24.04..." -ForegroundColor Cyan
    & C:\Windows\System32\wsl.exe --install -d Ubuntu-24.04

    Write-Host "Launching Ubuntu for first-run check..." -ForegroundColor Cyan
    & C:\Windows\System32\wsl.exe -d Ubuntu-24.04 -e sh -lc "echo WSL_OK && uname -a"

    Write-Host ""
    Write-Host "WSL reinstall finished. If you saw WSL_OK above, Ubuntu is working." -ForegroundColor Green
    Write-Host "Log saved to $logPath" -ForegroundColor Green
} finally {
    Stop-Transcript | Out-Null
}
