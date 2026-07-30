[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Repository,
    [switch]$DryRun,
    [switch]$InstallOnly,
    [switch]$Yes
)

$ErrorActionPreference = "Stop"
$packages = @(
    "wez.wezterm",
    "Logseq.Logseq",
    "Docker.DockerDesktop",
    "twpayne.chezmoi"
)

function Invoke-ManagedCommand {
    param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Command)

    if ($DryRun) {
        Write-Host ("[dry-run] " + ($Command -join " "))
        return
    }

    $executable = $Command[0]
    $arguments = @($Command | Select-Object -Skip 1)
    & $executable @arguments
    if ($LASTEXITCODE -ne 0) {
        throw "Command failed with exit code ${LASTEXITCODE}: $($Command -join ' ')"
    }
}

if (-not (Get-Command winget.exe -ErrorAction SilentlyContinue)) {
    throw "winget.exe is required. Install Microsoft App Installer on the Windows host."
}

foreach ($package in $packages) {
    $installed = $false
    if (-not $DryRun) {
        winget.exe list --exact --id $package --accept-source-agreements | Out-Null
        $installed = $LASTEXITCODE -eq 0
    }

    if (-not $installed) {
        Invoke-ManagedCommand winget.exe install --exact --id $package `
            --accept-package-agreements --accept-source-agreements `
            $(if ($Yes) { "--silent" } else { "--interactive" })
    }
    elseif (-not $InstallOnly) {
        if ($DryRun) {
            Write-Host "[dry-run] winget.exe upgrade --exact --id $package"
        }
        else {
            winget.exe upgrade --exact --id $package `
                --accept-package-agreements --accept-source-agreements `
                $(if ($Yes) { "--silent" } else { "--interactive" })
            if ($LASTEXITCODE -ne 0) {
                Write-Warning "No applicable upgrade was installed for $package (winget exit $LASTEXITCODE)."
            }
        }
    }
    else {
        Write-Host "[dotfiles] current: $package"
    }
}

$fontVersion = if ($env:DOTFILES_NERD_FONT_VERSION) {
    $env:DOTFILES_NERD_FONT_VERSION.TrimStart("v")
}
else {
    if ($DryRun) {
        "latest"
    }
    else {
        (Invoke-RestMethod "https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest").tag_name.TrimStart("v")
    }
}

$fontMarker = Join-Path $env:LOCALAPPDATA "Microsoft\Windows\Fonts\.blexmono-nerd-font.version"
$fontCurrent = (Test-Path $fontMarker) -and ((Get-Content $fontMarker -Raw).Trim() -eq $fontVersion)
if (-not $fontCurrent -and (-not $InstallOnly -or -not (Test-Path $fontMarker))) {
    if ($DryRun) {
        Write-Host "[dry-run] install BlexMono Nerd Font $fontVersion for the current Windows user"
    }
    else {
        $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) ("dotfiles-font-" + [Guid]::NewGuid())
        New-Item -ItemType Directory -Path $tempDir | Out-Null
        try {
            $archive = Join-Path $tempDir "BlexMono.zip"
            Invoke-WebRequest `
                "https://github.com/ryanoasis/nerd-fonts/releases/download/v$fontVersion/BlexMono.zip" `
                -OutFile $archive
            Expand-Archive $archive -DestinationPath $tempDir -Force
            $fontDirectory = Join-Path $env:LOCALAPPDATA "Microsoft\Windows\Fonts"
            New-Item -ItemType Directory -Path $fontDirectory -Force | Out-Null
            $fontRegistry = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts"
            New-Item -Path $fontRegistry -Force | Out-Null
            Get-ChildItem $tempDir -Include *.ttf,*.otf -Recurse | ForEach-Object {
                $destination = Join-Path $fontDirectory $_.Name
                Copy-Item $_.FullName $destination -Force
                New-ItemProperty -Path $fontRegistry `
                    -Name "$($_.BaseName) (TrueType)" `
                    -Value $destination `
                    -PropertyType String `
                    -Force | Out-Null
            }
            Set-Content -Path $fontMarker -Value $fontVersion
        }
        finally {
            Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

if ($DryRun) {
    Write-Host "[dry-run] chezmoi init --apply $Repository"
}
else {
    $chezmoi = (Get-Command chezmoi.exe -ErrorAction SilentlyContinue)
    if (-not $chezmoi) {
        $wingetChezmoi = Join-Path $env:LOCALAPPDATA "Microsoft\WinGet\Links\chezmoi.exe"
        if (Test-Path $wingetChezmoi) {
            $chezmoi = Get-Item $wingetChezmoi
        }
    }
    if (-not $chezmoi) {
        throw "chezmoi.exe was installed but is not yet on PATH. Open a new Windows session and rerun."
    }
    $chezmoiPath = if ($chezmoi.Source) { $chezmoi.Source } else { $chezmoi.FullName }
    & $chezmoiPath init --apply $Repository
    if ($LASTEXITCODE -ne 0) {
        throw "Windows-side chezmoi apply failed."
    }
}
