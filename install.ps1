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
      $targetVersion = $null
      try {
        $latestResponse = Invoke-WebRequest -Uri 'https://github.com/ilhm18/spoty/releases/latest' -UseBasicParsing -MaximumRedirection 10
        $finalUrl = $latestResponse.BaseResponse.ResponseUri.AbsoluteUri
        $tagMatch = [regex]::Match($finalUrl, '/tag/(v[^/?]+)$')
        if ($tagMatch.Success) {
          $targetVersion = $tagMatch.Groups[1].Value -replace '^v', ''
        }
      }
      catch {
        $targetVersion = $null
      }
      if (-not $targetVersion) {
        $targetVersion = '2.0.6'
      }
      Write-Success
    }
    $archivePath = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "hamspot.zip")
  }
  process {
    Write-Host -Object "Downloading hamspot v$targetVersion..." -NoNewline
    $Parameters = @{
      Uri            = "https://github.com/ilhm18/spoty/releases/download/v$targetVersion/hamspot-$targetVersion-windows-$architecture.zip"
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
    Write-Host -Object 'Hamspot was successfully installed!' -ForegroundColor 'Green'
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
    Write-Host -Object 'Hamspot installation aborted' -ForegroundColor 'Yellow'
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
    (New-Object System.Management.Automation.Host.ChoiceDescription '&Yes', 'Reinstall the latest hamspot release.'),
    (New-Object System.Management.Automation.Host.ChoiceDescription '&No', 'Continue with installation.')
  )
  $choice = $Host.UI.PromptForChoice('', 'Hamspot is already installed. Do you want to fix your installation?', $choices, 0)
  if ($choice -eq 0) {
    Write-Host 'Reinstalling hamspot...' -ForegroundColor Cyan
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
    Uri             = 'https://raw.githubusercontent.com/spicetify/spicetify-marketplace/main/resources/install.ps1'
    UseBasicParsing = $true
  }
  Invoke-WebRequest @Parameters | Invoke-Expression
}

$installedHamspot = Join-Path -Path $hamspotFolderPath -ChildPath 'hamspot.exe'
if (Test-Path -LiteralPath $installedHamspot -PathType Leaf) {
  Write-Host -Object 'Installing adblockify extension...' -ForegroundColor Cyan
  try {
    $userdataOutput = & $installedHamspot path userdata 2>&1 | Out-String
    $userdataPath = $userdataOutput.Trim()
    if (-not (Test-Path -LiteralPath $userdataPath -PathType Container)) {
      $userdataPath = "$env:APPDATA\hamspot"
    }
    $extensionPath = Join-Path -Path $userdataPath -ChildPath 'Extensions'
    New-Item -ItemType Directory -Force -Path $extensionPath | Out-Null
    $adblockSource = 'https://raw.githubusercontent.com/rxri/spicetify-extensions/main/adblock/assets/adblock.js'
    Invoke-WebRequest -Uri $adblockSource -UseBasicParsing -OutFile (Join-Path $extensionPath 'adblock.js')
    & $installedHamspot config extensions adblock.js
    if ($LASTEXITCODE -ne 0) {
      throw 'Hamspot could not enable the adblockify extension.'
    }
  }
  catch {
    Write-Warning -Message "Automatic adblockify installation failed: $($_.Exception.Message)"
  }

  Write-Host -Object 'Applying the latest Hamspot modification...' -ForegroundColor Cyan
  & $installedHamspot apply
  & $installedHamspot restart
}
#endregion Marketplace
#endregion Main
