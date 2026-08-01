$ErrorActionPreference = "Stop"

$AddonName = "SpecialNeeds"
$Repo = "Metalica155/SpecialNeeds"
$ConfigFile = Join-Path $PSScriptRoot "addonLocation.txt"
$TempZip = Join-Path $env:TEMP "$AddonName.zip"


$Repo = "Metalica155/SpecialNeeds"

function Get-AddonFolder {
    if (Test-Path $ConfigFile) {
        $path = (Get-Content $ConfigFile -Raw).Trim()

        if (Test-Path $path) {
            return $path
        }

        Write-Host "Saved addon folder no longer exists." -ForegroundColor Yellow
    }

    Add-Type -AssemblyName System.Windows.Forms

    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = "Select your World of Warcraft AddOns folder"

    if ($dialog.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) {
        throw "No folder selected."
    }

    $path = $dialog.SelectedPath

    if ((Split-Path $path -Leaf) -ne "AddOns") {
        throw "Please select your Interface\AddOns folder."
    }

    if (!(Test-Path (Join-Path $path "$AddonName.toc"))) {
        Write-Host ""
        Write-Host "Warning: This doesn't look like the addon folder." -ForegroundColor Yellow
        Write-Host "You should select:"
        Write-Host "...Tauri Launcher\Legion\Interface\AddOns"
        Write-Host ""

        $answer = Read-Host "Continue anyway? (y/N)"

        if ($answer -ne "y") {
            throw "Cancelled."
        }
    }

    $path | Set-Content $ConfigFile

    return $path
}

function Get-InstalledVersion {
    param(
        [string]$AddonFolder
    )

    $tocFile = Join-Path $AddonFolder "$AddonName\$AddonName.toc"

    if (!(Test-Path $tocFile)) {
        return $null
    }

    $versionLine = Select-String -Path $tocFile -Pattern '^##\s*Version:\s*(.+)$'

    if ($versionLine) {
        return $versionLine.Matches[0].Groups[1].Value.Trim()
    }

    return $null
}

try {
    $AddonFolder = Get-AddonFolder

    Write-Host "Checking latest release..."

    $headers = @{
        Accept = "application/vnd.github+json"
        "User-Agent" = "SpecialNeeds-Updater"
    }

    $release = Invoke-RestMethod `
        -Uri "https://api.github.com/repos/$Repo/releases/latest" `
        -Headers $headers

    $latestVersion = $release.tag_name.TrimStart("v")
    $installedVersion = Get-InstalledVersion $AddonFolder

    Write-Host ("Installed : " + $(if ($installedVersion) { $installedVersion } else { "Not installed" }))
    Write-Host "Latest    : $latestVersion"

    if ($installedVersion -eq $latestVersion) {
        Write-Host ""
        Write-Host "SpecialNeeds is already up to date!" -ForegroundColor Green
        return
    }

    Write-Host ""
    Write-Host "Downloading source archive..."

    Invoke-WebRequest `
        -Uri $release.zipball_url `
        -Headers $headers `
        -OutFile $TempZip

    $TempExtract = Join-Path $env:TEMP "SpecialNeedsExtract"

    Remove-Item $TempExtract -Recurse -Force -ErrorAction Ignore
    New-Item -ItemType Directory -Path $TempExtract | Out-Null

    Write-Host "Extracting..."

    Expand-Archive $TempZip -DestinationPath $TempExtract -Force

    # GitHub creates a single folder with a random suffix
    $SourceFolder = Get-ChildItem $TempExtract -Directory | Select-Object -First 1

    if (-not $SourceFolder) {
        throw "Couldn't locate extracted source folder."
    }

    $Destination = Join-Path $AddonFolder $AddonName

    Remove-Item $Destination -Recurse -Force -ErrorAction Ignore
    New-Item -ItemType Directory -Path $Destination | Out-Null

    Write-Host "Installing..."

    Get-ChildItem $SourceFolder.FullName -Force | ForEach-Object {
        Copy-Item $_.FullName -Destination $Destination -Recurse -Force
    }

    Remove-Item $TempZip -Force -ErrorAction Ignore
    Remove-Item $TempExtract -Recurse -Force -ErrorAction Ignore

    Write-Host ""
    Write-Host "Successfully updated SpecialNeeds to v$latestVersion!" -ForegroundColor Green
}
catch {
    Write-Host ""
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Read-Host "`nPress Enter to exit"