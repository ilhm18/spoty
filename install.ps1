$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#region Variables
$hamspotFolderPath = "$env:LOCALAPPDATA\hamspot"
$hamspotOldFolderPath = "$HOME\hamspot-cli"
#endregion Variables

#region Functions
function Write-Success {
  [CmdletBinding()]
  param ()
  process {
    Write-Host -Object ' > OK' -ForegroundColor 'Green'
  }
}

function Write-Unsuccess {
  [CmdletBinding()]
  param ()
  process {
    Write-Host -Object ' > ERROR' -ForegroundColor 'Red'
  }
}

function Test-Admin {
  [CmdletBinding()]
  param ()
  begin {
    Write-Host -Object "Checking if the script is not being run as administrator..." -NoNewline
  }
  process {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    -not $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
  }
}

function Test-PowerShellVersion {
  [CmdletBinding()]
  param ()
  begin {
    $PSMinVersion = [version]'5.1'
  }
  process {
    Write-Host -Object 'Checking if your PowerShell version is compatible...' -NoNewline
    $PSVersionTable.PSVersion -ge $PSMinVersion
  }
}

function Move-OldHamspotFolder {
  [CmdletBinding()]
  param ()
  process {
    if (Test-Path -Path $hamspotOldFolderPath) {
      Write-Host -Object 'Moving the old hamspot folder...' -NoNewline
      Copy-Item -Path "$hamspotOldFolderPath\*" -Destination $hamspotFolderPath -Recurse -Force
      Remove-Item -Path $hamspotOldFolderPath -Recurse -Force
      Write-Success
    }
  }
}

function Get-Hamspot {
  [CmdletBinding()]
  param ()
  begin {
    if ($env:PROCESSOR_ARCHITECTURE -eq 'AMD64') {
      $architecture = 'x64'
    }
    elseif ($env:PROCESSOR_ARCHITECTURE -eq 'ARM64') {
      $architecture = 'arm64'
    }
    else {
      $architecture = 'x32'
    }
    if ($v) {
      if ($v -match '^\d+\.\d+\.\d+$') {
        $targetVersion = $v
      }
      else {
        Write-Warning -Message "You have specified an invalid hamspot version: $v `nThe version must be in the following format: 1.2.3"
        Pause
        exit
      }
    }
    else {
      Write-Host -Object 'Fetching the latest hamspot version...' -NoNewline
      $latestRelease = Invoke-RestMethod -Uri 'https://api.github.com/repos/hamspot/cli/releases/latest'
      $targetVersion = $latestRelease.tag_name -replace 'v', ''
      Write-Success
    }
    $archivePath = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "hamspot.zip")
  }
  process {
    Write-Host -Object "Downloading hamspot v$targetVersion..." -NoNewline
    $Parameters = @{
      Uri            = "https://github.com/ilhm18/hamspot/releases/download/v$targetVersion/hamspot-$targetVersion-windows-$architecture.zip"
      UseBasicParsin = $true
      OutFile        = $archivePath
    }
    Invoke-WebRequest @Parameters
    Write-Success
  }
  end {
    $archivePath
  }
}

function Add-HamspotToPath {
  [CmdletBinding()]
  param ()
  begin {
    Write-Host -Object 'Making hamspot available in the PATH...' -NoNewline
    $user = [EnvironmentVariableTarget]::User
    $path = [Environment]::GetEnvironmentVariable('PATH', $user)
  }
  process {
    $path = $path -replace "$([regex]::Escape($hamspotOldFolderPath))\\*;*", ''
    if ($path -notlike "*$hamspotFolderPath*") {
      $path = "$path;$hamspotFolderPath"
    }
  }
  end {
    [Environment]::SetEnvironmentVariable('PATH', $path, $user)
    if (($env:PATH -split ';') -notcontains $hamspotFolderPath) {
      $env:PATH = "$env:PATH;$hamspotFolderPath"
    }
    Write-Success
  }
}

function Install-Hamspot {
  [CmdletBinding()]
  param ()
  begin {
    Write-Host -Object 'Installing hamspot...'
  }
  process {
    $archivePath = Get-Hamspot
    Write-Host -Object 'Extracting hamspot...' -NoNewline
    Expand-Archive -Path $archivePath -DestinationPath $hamspotFolderPath -Force
    Write-Success
    Add-HamspotToPath
  }
  end {
    Remove-Item -Path $archivePath -Force -ErrorAction 'SilentlyContinue'
    Write-Host -Object 'hamspot was successfully installed!' -ForegroundColor 'Green'
  }
}
#endregion Functions

#region Main
#region Checks
if (-not (Test-PowerShellVersion)) {
  Write-Unsuccess
  Write-Warning -Message 'PowerShell 5.1 or higher is required to run this script'
  Write-Warning -Message "You are running PowerShell $($PSVersionTable.PSVersion)"
  Write-Host -Object 'PowerShell 5.1 install guide:'
  Write-Host -Object 'https://learn.microsoft.com/skypeforbusiness/set-up-your-computer-for-windows-powershell/download-and-install-windows-powershell-5-1'
  Write-Host -Object 'PowerShell 7 install guide:'
  Write-Host -Object 'https://learn.microsoft.com/powershell/scripting/install/installing-powershell-on-windows'
  Pause
  exit
}
else {
  Write-Success
}
if (-not (Test-Admin)) {
  Write-Unsuccess
  Write-Warning -Message "The script was run as administrator. This can result in problems with the installation process or unexpected behavior. Do not continue if you do not know what you are doing."
  $Host.UI.RawUI.Flushinputbuffer()
  $choices = [System.Management.Automation.Host.ChoiceDescription[]] @(
    (New-Object System.Management.Automation.Host.ChoiceDescription '&Yes', 'Abort installation.'),
    (New-Object System.Management.Automation.Host.ChoiceDescription '&No', 'Resume installation.')
  )
  $choice = $Host.UI.PromptForChoice('', 'Do you want to abort the installation process?', $choices, 0)
  if ($choice -eq 0) {
    Write-Host -Object 'hamspot installation aborted' -ForegroundColor 'Yellow'
    Pause
    exit
  }
}
else {
  Write-Success
}
#endregion Checks

#region Hamspot
$installedHamspot = Join-Path -Path $hamspotFolderPath -ChildPath 'hamspot.exe'
if (-not (Test-Path -LiteralPath $installedHamspot -PathType Leaf)) {
  $installedCommand = Get-Command -Name 'hamspot' -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($installedCommand) {
    $installedHamspot = $installedCommand.Source
  }
  else {
    $installedHamspot = $null
  }
}

if ($installedHamspot) {
  $Host.UI.RawUI.Flushinputbuffer()
  $choices = [System.Management.Automation.Host.ChoiceDescription[]] @(
    (New-Object System.Management.Automation.Host.ChoiceDescription '&Yes', 'Run hamspot update.'),
    (New-Object System.Management.Automation.Host.ChoiceDescription '&No', 'Continue with installation.')
  )
  $choice = $Host.UI.PromptForChoice('', 'Hamspot is already installed. Do you want to fix your installation?', $choices, 0)
  if ($choice -eq 0) {
    & $installedHamspot update
    if ($LASTEXITCODE -ne 0) {
      throw "Hamspot update failed with exit code $LASTEXITCODE."
    }
    return
  }
}

Move-OldHamspotFolder
Install-Hamspot
Write-Host -Object "`nRun" -NoNewline
Write-Host -Object ' hamspot -h ' -NoNewline -ForegroundColor 'Cyan'
Write-Host -Object 'to get started'
#endregion Hamspot

#region Marketplace
$Host.UI.RawUI.Flushinputbuffer()
$choices = [System.Management.Automation.Host.ChoiceDescription[]] @(
    (New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Install Hamspot Marketplace."),
    (New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Do not install Hamspot Marketplace.")
)
$choice = $Host.UI.PromptForChoice('', "`nDo you also want to install Hamspot Marketplace? It will become available within the Spotify client, where you can easily install themes and extensions.", $choices, 0)
if ($choice -eq 1) {
  Write-Host -Object 'hamspot Marketplace installation aborted' -ForegroundColor 'Yellow'
}
else {
  Write-Host -Object 'Starting the hamspot Marketplace installation script..'
  $Parameters = @{
    Uri             = 'https://raw.githubusercontent.com/hamspot/hamspot-marketplace/main/resources/install.ps1'
    UseBasicParsing = $true
  }
  Invoke-WebRequest @Parameters | Invoke-Expression
}
#endregion Marketplace
#endregion Main
