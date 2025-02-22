##############################################################################
#PYTHON TOOLS

<#
.SYNOPSIS
    Upgrades pip package manager for a Python installation
.DESCRIPTION
    Updates the pip package manager to the latest version for either the default Python
    installation or a specified Python version. Supports both Python 2 and Python 3 installations.
.PARAMETER PythonVersion
    Specifies the Python version suffix for python executable (e.g., "3" for python3, "3.11" for python3.11)
    Aliases: Version
    Validation: Non-empty string
.EXAMPLE
    Python-UpgradePip
    # Upgrades pip for the default Python installation
.EXAMPLE
    Python-UpgradePip -PythonVersion 3.11
    # Upgrades pip for Python 3.11 specifically
.NOTES
    - Requires Python and pip to be installed and available in PATH
    - Administrator privileges may be required for system-wide installations
    - Compatible with both global and virtual environment Python installations
.LINK
    https://pip.pypa.io/en/stable/installation/
#>
function Python-UpgradePip 
{
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [ValidateNotNullOrEmpty()]
        [Alias("Version")]
        [string]$PythonVersion
    )

    begin 
	{
        $pythonExecutable = if ($PythonVersion) 
		{
            "python$PythonVersion"
        } 
		else 
		{
            "python"
        }
    }

    process 
	{
        try 
		{
            Write-Verbose "[Python-UpgradePip] Attempting pip upgrade using $pythonExecutable"
            
            # Validate Python installation
            if (-not (Get-Command $pythonExecutable -ErrorAction SilentlyContinue)) 
			{
                throw "Python executable '$pythonExecutable' not found in PATH"
            }

            # Execute pip upgrade
            & $pythonExecutable -m pip install --upgrade pip 2>&1 | ForEach-Object {
                if ($_ -is [System.Management.Automation.ErrorRecord]) 
				{
                    Write-Error $_
                } 
				else 
				{
                    Write-Output $_
                }
            }
            
            Write-Verbose "[Python-UpgradePip] Successfully upgraded pip for $pythonExecutable"
        }
        catch 
		{
            Write-Error "[Python-UpgradePip] Upgrade failed: $_"
        }
    }
}

Set-Alias -Name python_upgrade_pip -Value Python-UpgradePip

<#
.SYNOPSIS
    Updates outdated Python packages for a specific Python installation
.DESCRIPTION
    Upgrades outdated packages using pip's JSON output format for reliable parsing.
    Handles deprecation warnings and requires pip version 20.3 or newer.
.PARAMETER PythonVersion
    Specifies the Python version suffix for pip executable (e.g., "3" for pip3, "3.11" for pip3.11)
    Aliases: Version
    Validation: Non-empty string
.EXAMPLE
    Python-UpdatePackages -PythonVersion 3.11
    Updates packages for Python 3.11 installation using pip3.11
.EXAMPLE
    Python-UpdatePackages -Verbose
    Shows detailed output including package upgrade progress
.NOTES
    Requires Python and pip 20.3+ installed and in system PATH
    Administrator privileges may be required for system-wide packages
.LINK
    https://pip.pypa.io/en/stable/cli/pip_list/
#>
function Python-UpdatePackages
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$PythonVersion
    )

    begin
    {
        $pipExecutable = if ($PythonVersion) { "pip$PythonVersion" } else { "pip" }
    }

    process
    {
        try
        {
            if (-not (Get-Command $pipExecutable -ErrorAction SilentlyContinue))
            {
                throw "Pip executable '$pipExecutable' not found"
            }

            $rawOutput = & $pipExecutable list --outdated --format json 2>&1
            
            $jsonString = $rawOutput | ForEach-Object {
                if ($_ -is [System.Management.Automation.ErrorRecord])
                {
                    Write-Verbose "[PIP WARNING] $($_.Exception.Message)"
                }
                else
                {
                    $_
                }
            } | Out-String

            $packages = $jsonString | ConvertFrom-Json -ErrorAction Stop

            if (-not $packages)
            {
                Write-Verbose "No outdated packages found"
                return
            }

            $packages | ForEach-Object {
                Write-Verbose "Upgrading package: $($_.name)"
                & $pipExecutable install -U $_.name
            }

            & $pipExecutable check
        }
        catch
        {
            Write-Error "Package update failed: $_"
            throw
        }
    }
}

Set-Alias -Name python_update_packages -Value Python-UpdatePackages

<#
.SYNOPSIS
    Lists outdated Python packages with version information for a specific Python installation
.DESCRIPTION
    Retrieves outdated packages with versions using pip's JSON output format for reliable parsing.
    Outputs objects with package name, current version, and latest version.
    Handles deprecation warnings and requires pip version 20.3 or newer.
.PARAMETER PythonVersion
    Specifies the Python version suffix for pip executable (e.g., "3" for pip3, "3.11" for pip3.11)
    Aliases: Version
    Validation: Non-empty string
.EXAMPLE
    Python-CheckUpdates -PythonVersion 3.11
    Lists outdated packages for Python 3.11 installation with version information
.EXAMPLE
    Python-CheckUpdates | Format-Table -AutoSize
    Displays results in a compact table format
.EXAMPLE
    Python-CheckUpdates -Verbose
    Shows detailed output including pip warning messages
.OUTPUTS
    PSCustomObject
    Returns objects with Name, CurrentVersion, and LatestVersion properties
.NOTES
    Requires Python and pip 20.3+ installed and in system PATH
.LINK
    https://pip.pypa.io/en/stable/cli/pip_list/
#>
function Python-CheckUpdates
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0)]
        [ValidateNotNullOrEmpty()]
        [Alias('Version')]
        [string]$PythonVersion
    )

    begin
    {
        $pipExecutable = if ($PythonVersion) { "pip$PythonVersion" } else { "pip" }
    }

    process
    {
        try
        {
            if (-not (Get-Command $pipExecutable -ErrorAction SilentlyContinue))
            {
                throw "Pip executable '$pipExecutable' not found"
            }

            $rawOutput = & $pipExecutable list --outdated --format json 2>&1
            
            $jsonString = $rawOutput | ForEach-Object {
                if ($_ -is [System.Management.Automation.ErrorRecord])
                {
                    Write-Verbose "[PIP WARNING] $($_.Exception.Message)"
                }
                else
                {
                    $_
                }
            } | Out-String

            $packages = $jsonString | ConvertFrom-Json -ErrorAction Stop

            if (-not $packages)
            {
                Write-Verbose "No outdated packages found"
                return
            }

            # Create structured output objects
            $packages | ForEach-Object {
                [PSCustomObject]@{
                    Name = $_.name
                    CurrentVersion = $_.version
                    LatestVersion = $_.latest_version
                }
            }
        }
        catch
        {
            Write-Error "Failed to check for updates: $_"
            throw
        }
    }
}

Set-Alias -Name python_check_updates -Value Python-CheckUpdates

<#
.SYNOPSIS
    Exports all installed Python packages in requirements.txt format with optional versioning
.DESCRIPTION
    Generates a pip-installable requirements file with control over version inclusion
    Uses JSON parsing for reliability and supports both versioned and unversioned exports
.PARAMETER PythonVersion
    Specifies Python version suffix for pip executable (e.g., "3.11" for pip3.11)
    Aliases: Version
.PARAMETER OutputPath
    Output file path
.PARAMETER IncludeVersions
    Include package versions in output
    Aliases: Versioned
.EXAMPLE
    Python-ExportRequirements
    Creates requirements.txt with package names only
.EXAMPLE
    Python-ExportRequirements -IncludeVersions
    Generates version-pinned requirements file
.EXAMPLE
    Python-ExportRequirements -PythonVersion 3.11 -OutputPath ./prod.txt
    Creates unversioned requirements for Python 3.11 at custom location
.NOTES
    Without versions, pip will install latest compatible versions
    With versions, creates reproducible environment setup
.LINK
    https://pip.pypa.io/en/stable/cli/pip_list/
#>
function Python-ExportRequirements
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0)]
        [Alias('Version')]
        [string]$PythonVersion,
        
        [Parameter(Position = 1)]
        [string]$OutputPath = "./requirements.txt",
        
        [Parameter()]
        [Alias('Versioned')]
        [switch]$IncludeVersions
    )

    begin
    {
        $pipExecutable = if ($PythonVersion) { "pip$PythonVersion" } else { "pip" }
        $resolvedPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputPath)
    }

    process
    {
        try
        {
            if (-not (Get-Command $pipExecutable -ErrorAction SilentlyContinue))
            {
                throw "Pip executable '$pipExecutable' not found"
            }

            $rawOutput = & $pipExecutable list --format json --disable-pip-version-check 2>&1
            
            $jsonString = $rawOutput | ForEach-Object {
                if ($_ -is [System.Management.Automation.ErrorRecord])
                {
                    Write-Verbose "[PIP WARNING] $($_.Exception.Message)"
                }
                else
                {
                    $_
                }
            } | Out-String

            $packages = $jsonString | ConvertFrom-Json -ErrorAction Stop

            $requirements = $packages | ForEach-Object {
                if ($IncludeVersions) {
                    "$($_.name)==$($_.version)"
                }
                else {
                    $_.name
                }
            }

            $requirements | Set-Content -Path $resolvedPath -Force
            Write-Output "Exported $($packages.Count) packages to $resolvedPath"
            Write-Verbose "Install with: $pipExecutable install -r $resolvedPath"
        }
        catch
        {
            Write-Error "Export failed: $_"
            throw
        }
    }
}

Set-Alias -Name python_export_requirements -Value Python-ExportRequirements

<#
.SYNOPSIS
    Installs the development version of PyInstaller from GitHub
.DESCRIPTION
    Downloads and installs the latest development branch of PyInstaller
    directly from the project's GitHub repository
.PARAMETER GitHubUrl
    Specifies installation URL, just in case
.EXAMPLE
    Python-InstallPyinstallerDev
    Installs the latest development version of PyInstaller
.EXAMPLE
    Python-InstallPyinstallerDev -Confirm
    Installs with confirmation prompt
.NOTES
    Requires Python and pip in system PATH
    May require elevated privileges for system-wide installations
.LINK
    https://github.com/pyinstaller/pyinstaller
#>
function Python-InstallPyinstallerDev
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param
    (
        [Parameter(Position = 0)]
        [ValidateNotNullOrEmpty()]
        [uri]$GitHubUrl = 'https://github.com/pyinstaller/pyinstaller/archive/develop.tar.gz'
    )

    begin
    {
        if (-not (Get-Command pip -ErrorAction SilentlyContinue))
        {
            throw "pip package manager not found in PATH"
        }
    }

    process
    {
        try
        {
            $actionDescription = "Install PyInstaller development branch from GitHub"
            $operationDescription = "Installing from: $($GitHubUrl.OriginalString)"
            
            if (-not $PSCmdlet.ShouldProcess($operationDescription, $actionDescription))
            {
                return
            }

            Write-Verbose "Validating GitHub URL accessibility"
            $null = Invoke-WebRequest -Uri $GitHubUrl -Method Head -UseBasicParsing -ErrorAction Stop

            Write-Verbose "Beginning installation process"
            $installation = pip install $GitHubUrl 2>&1
            
            $installation | ForEach-Object -Process {
                if ($_ -is [System.Management.Automation.ErrorRecord])
                {
                    Write-Error $_.Exception.Message
                }
                else
                {
                    Write-Verbose "pip output: $_"
                }
            }

            Write-Output "Successfully installed PyInstaller development version"
            Write-Verbose "Validation command: pyinstaller --version"
        }
        catch
        {
            Write-Error "Installation failed: $($_.Exception.Message)"
            throw
        }
    }
}

Set-Alias -Name python_install_pyinstaller_dev -Value Python-InstallPyinstallerDev

<#
.SYNOPSIS
    Creates Python version hardlinks with safety checks and dry-run support.

.DESCRIPTION
    Finds genuine Python installations (excluding existing hardlinks), creates
    version-specific hardlinks (e.g., python3.10.exe), and supports WhatIf/Verbose.
    Requires admin rights for protected directories.

.PARAMETER WhatIf
    Shows what would happen without making changes

.PARAMETER Confirm
    Prompts for confirmation before creating links

.EXAMPLE
    Python-AddVersionHardlinks -WhatIf -Verbose
    Dry-run with detailed output
#>
function Python-AddVersionHardlinks 
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param()

    $pythonPaths = where.exe python.exe 2>$null | Where-Object { $_ -ne "" }

    if (-not $pythonPaths) 
    {
        Write-Warning "No python.exe installations found."
        return
    }

    foreach ($pythonPath in $pythonPaths) {
        try {
            Write-Verbose "Examining: $pythonPath"
            $file = Get-Item $pythonPath -ErrorAction Stop
            
            if ($file.LinkType -eq 'HardLink') {
                Write-Verbose "Skipping hardlink: $pythonPath"
                continue
            }
        } catch {
            Write-Warning "Could not access path $pythonPath : $_"
            continue
        }

        $dir = $file.Directory.FullName
        Write-Verbose "Processing genuine installation at: $pythonPath"

        try {
            $versionOutput = & $pythonPath --version 2>&1
            Write-Verbose "Version output: $versionOutput"
        } catch {
            Write-Warning "Failed to execute $pythonPath : $_"
            continue
        }

        if ($versionOutput -match 'Python (\d+\.\d+)\.\d+') {
            $majorMinor = $Matches[1]
            $hardlinkName = "python$majorMinor.exe"
            $hardlinkPath = Join-Path $dir $hardlinkName

            if (-not (Test-Path $hardlinkPath)) {
                $actionMessage = "Create hardlink '$hardlinkName' in $dir"
                
                if ($PSCmdlet.ShouldProcess($actionMessage, "Confirm creation?", "Create version hardlink")) {
                    try {
                        New-Item -ItemType HardLink -Path $hardlinkPath -Target $pythonPath -ErrorAction Stop
                        Write-Host "Created: $hardlinkPath" -ForegroundColor Green
                    } catch {
                        Write-Warning "Creation failed: $_ (Admin rights needed?)"
                    }
                }
            } else {
                Write-Verbose "Already exists: $hardlinkPath"
                Write-Host "Exists: $hardlinkPath" -ForegroundColor Yellow
            }
        } else {
            Write-Warning "Version detection failed for $pythonPath"
            Write-Verbose "Raw version output: $versionOutput"
        }
    }
}

Set-Alias -Name python_add_version_hardlinks -Value Python-AddVersionHardlinks
