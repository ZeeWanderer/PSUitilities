##############################################################################
#GIT TOOLS

<#
.SYNOPSIS
Updates all git submodules.

.DESCRIPTION
Updates registered submodules to their configured revisions. Supports path specification.

.PARAMETER Path
Target submodule path to update (defaults to all submodules).

.EXAMPLE
Git-SubmoduleUpdate
# Updates all submodules immediately

.EXAMPLE
Git-SubmoduleUpdate -Path ./lib -Confirm
# Prompts before updating submodule in ./lib

.NOTES
Requires Git repository. Safe for regular use as it preserves local changes.
#>
function Git-SubmoduleUpdate
{
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Low')]
    param(
        [string]$Path = "."
    )

    if ($PSCmdlet.ShouldProcess("submodules in '$Path'", "Update"))
    {
        git submodule update $Path
        if (-not $?)
        {
            Write-Error "Submodule update failed. Verify paths and repository state."
        }
    }
}

Set-Alias -Name git_submodule_update -Value Git-SubmoduleUpdate

<#
.SYNOPSIS
Initializes and updates all git submodules.

.DESCRIPTION
Initializes and clones missing submodules while updating existing ones.

.EXAMPLE
Git-SubmoduleUpdateInit
# Updates submodules without confirmation

.EXAMPLE
Git-SubmoduleUpdateInit -Confirm
# Prompts for confirmation before updating

.NOTES
Requires Git repository. May download large amounts of data.
#>
function Git-SubmoduleUpdateInit
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param()

    if ($PSCmdlet.ShouldProcess("all submodules", "Initialize and update"))
    {
        git submodule update --init
        if (-not $?)
        {
            Write-Error "Submodule update failed. Check network and repository state."
        }
    }
}

Set-Alias -Name git_submodule_update_init -Value Git-SubmoduleUpdateInit

<#
.SYNOPSIS
Initializes and recursively updates all git submodules.

.DESCRIPTION
Initializes, clones, and updates submodules recursively including nested submodules.

.PARAMETER Path
Target path to operate on (defaults to repository root).

.EXAMPLE
Git-SubmoduleUpdateInitRecursive
Initializes and updates all submodules

.EXAMPLE
Git-SubmoduleUpdateInitRecursive -Path ./src
Updates submodules in ./src

.NOTES
Requires Git and existing repository. May take time for large repositories.
#>
function Git-SubmoduleUpdateInitRecursive
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [string]$Path = "."
    )

    if ($PSCmdlet.ShouldProcess("submodules in '$Path'", "Initialize and update"))
    {
        git submodule update --init --recursive $Path
        if (-not $?)
        {
            Write-Error "Submodule operation failed. Verify Git setup and network connectivity."
        }
    }
}

Set-Alias -Name git_submodule_update_init_recursive -Value Git-SubmoduleUpdateInitRecursive

<#
.SYNOPSIS
Deinitializes git submodule.

.DESCRIPTION
Deinitializes submodules in specified path, removing local configuration.

.PARAMETER Path
Target path for submodule deinitialization. Defaults to current directory.

.EXAMPLE
Git-SubmoduleDeinit
Deinitializes submodule in current directory

.EXAMPLE
Git-SubmoduleDeinit -Path ./my-submodule
Deinitializes submodule

.NOTES
Destructive operation - removes submodule configuration. Requires Git installation.
#>
function Git-SubmoduleDeinit {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [string]$Path = "."
    )

    if ($PSCmdlet.ShouldProcess("submodules in '$Path'", "Deinitialize")) 
	{
        git submodule deinit $Path
        if (-not $?) 
		{
            Write-Error "Submodule deinit failed. Verify path and repository state."
        }
    }
}

Set-Alias -Name git_submodule_deinit -Value Git-SubmoduleDeinit

<#
.SYNOPSIS
Checks out all files in all submodules recursively.

.DESCRIPTION
Resets all changes in submodules recursively by checking out clean versions from HEAD.

.EXAMPLE
Git-CleanSubmodules
# Bypasses confirmation prompt

.EXAMPLE
Git-CleanSubmodules -Confirm
# Prompts for confirmation before resetting submodules

.NOTES
Requires Git installation and valid repository. Destructive operation - discards uncommitted changes.
#>
function Git-CleanSubmodules 
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param()

    if ($PSCmdlet.ShouldProcess("ALL SUBMODULES", "Discard all uncommitted changes")) 
	{
        git submodule foreach --recursive git checkout .
        if (-not $?) 
		{
            Write-Error "Submodule cleanup failed. Verify submodule status."
        }
    }
}

Set-Alias -Name git_clean_submodules -Value Git-CleanSubmodules

<#
.SYNOPSIS
Resets all submodules to their HEAD state.
#>
function Git-AllSubmodulesResetHard
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param ()

    try 
    {
        if (-not (git rev-parse --is-inside-work-tree 2>$null)) 
        {
            Write-Error "Not a git repository."
            return
        }

        Write-Host "Resetting all submodules to HEAD..."

        if ($PSCmdlet.ShouldProcess("All submodules", "Performing 'git reset --hard' for each submodule. This action cannot be undone.")) 
        {
            git submodule foreach --recursive git reset --hard
            Write-Host "All submodules have been reset to their HEAD state."
        }
    }
    catch 
    {
        Write-Error "An error occurred while resetting submodules: $_"
    }
}

Set-Alias -Name git_all_submodules_reset_hard -Value Git-AllSubmodulesResetHard

<#
.SYNOPSIS
Updates a specified submodule by pulling its latest changes from its current branch.
.PARAMETER submodule
The name (or relative path) of the submodule to update.
#>
function Git-SubmoduleUpdatePull 
{
    [CmdletBinding()]
    param (
        [Parameter(Position=0, Mandatory = $true)]
        [string]$submodule
    )
    if (-not (Test-Path $submodule)) 
	{
        Write-Error "Submodule '$submodule' does not exist."
        return
    }
    try 
	{
        Push-Location $submodule
        $currentBranch = (git rev-parse --abbrev-ref HEAD).Trim()
        Write-Host "Updating submodule '$submodule' on branch '$currentBranch'..."
        git pull
        Pop-Location
        $commitMessage = "Pulled update for submodule '$submodule' on branch '$currentBranch'"
        Write-Host $commitMessage
        git commit -a -m $commitMessage
    }
    catch 
	{
        Write-Error "An error occurred while updating submodule '$submodule': $_"
        if ((Get-Location).Path -ne $PSScriptRoot) { Pop-Location }
    }
}

Set-Alias -Name git_submodule_update_pull -Value Git-SubmoduleUpdatePull


<#
.SYNOPSIS
Fetches updates from upstream and rebases the current branch or a specified branch.
.PARAMETER branch
The name of the branch to rebase.
#>
function Git-FetchUpstream 
{
    [CmdletBinding()]
    param (
        [Parameter(Position=0)]
        [string]$branch
    )
    try 
	{
        $branchName = if ($branch) { $branch } else { (git rev-parse --abbrev-ref HEAD).Trim() }
        Write-Verbose "Fetching upstream for branch '$branchName'..."
        git fetch upstream
        Write-Verbose "Checking out branch '$branchName'..."
        git checkout $branchName
        Write-Verbose "Rebasing branch '$branchName' with 'upstream/$branchName'..."
        git rebase "upstream/$branchName"
    }
    catch 
	{
        Write-Error "An error occurred during the upstream fetch and rebase: $_"
    }
}

Set-Alias -Name git_fetch_upstream -Value Git-FetchUpstream


<#
.SYNOPSIS
Pulls updates from upstream for the current branch or a specified branch.
.PARAMETER branch
The name of the branch to pull updates for. If not provided, the current branch is used.
#>
function Git-PullUpstream 
{
    [CmdletBinding()]
    param (
        [String]$branch
    )
    try {
        If($branch)
        {
            Write-Verbose "Pulling updates from upstream for branch '$branch'..."
            git pull upstream $branch
        }
        Else
        {
            $currentBranch = (git rev-parse --abbrev-ref HEAD).Trim()
            Write-Verbose "Pulling updates from upstream for current branch '$currentBranch'..."
            git pull upstream $currentBranch
        }
    }
    catch {
        Write-Error "Error pulling updates from upstream: $_"
    }
}

Set-Alias -Name git_pull_upstream -Value Git-PullUpstream


<#
.SYNOPSIS
Resets the current branch to a specified commit hash or the previous commit.
.PARAMETER commit_hash
The commit hash to reset to.
#>
function Git-Reset([String]$commit_hash) 
{
	If($commit_hash)
	{
		git reset $commit_hash
	}
	Else
	{
		git reset HEAD^
	}
}

Set-Alias -Name git_reset -Value Git-Reset

<#
.SYNOPSIS
Hard resets the current branch to a specified commit hash or the previous commit.
.PARAMETER commit_hash
The commit hash to hard reset to. If not provided, resets to the previous commit.
#>
function Git-ResetHard
{
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact="High")]
    param (
        [Parameter(Position=0)]
        [string]$commit_hash
    )

    try 
    {
        if (-not (git rev-parse --is-inside-work-tree 2>$null)) 
        {
            Write-Error "Not a git repository."
            return
        }

        if (-not $commit_hash) 
        {
            $commit_hash = "HEAD^"
        }

        if ($PSCmdlet.ShouldProcess("Resetting hard to commit $commit_hash", "This action cannot be undone."))
        {
            Write-Host "Hard resetting to commit: $commit_hash..."
            git reset --hard $commit_hash
            Write-Host "Reset complete."
        }
    }
    catch 
    {
        Write-Error "An error occurred while performing a hard reset: $_"
    }
}

Set-Alias -Name git_reset_hard -Value Git-ResetHard

<#
.SYNOPSIS
Hard resets the current branch to a specified number of commits back.
.PARAMETER times
The number of commits to reset back.
#>
function Git-ResetHard-Times
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(Position=0)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$times = 1
    )

    try 
    {
        if (-not (git rev-parse --is-inside-work-tree 2>$null)) 
        {
            Write-Error "Not a git repository."
            return
        }

        if ($PSCmdlet.ShouldProcess("Resetting hard to HEAD~$times", "This action cannot be undone."))
        {
            Write-Host "Hard resetting to $times commits back..."
            git reset --hard HEAD~$times
            Write-Host "Reset complete."
        }
    }
    catch 
    {
        Write-Error "An error occurred while performing a hard reset: $_"
    }
}

Set-Alias -Name git_reset_hard_times -Value Git-ResetHard-Times

<#
.SYNOPSIS
    Removes derived Git tags both locally and remotely based on a specified base tag.
.DESCRIPTION
    Safely deletes Git tags that start with a specified base tag pattern, with options for
    dry-run simulation and confirmation prompts. Supports both local and remote tag removal.
.PARAMETER BaseTag
    The base tag pattern to match against derived tags.
    Tags starting with this pattern will be deleted (but not the exact match).
    Aliases: Base, Tag
.PARAMETER Remote
    Switch parameter to also delete tags from the remote repository (origin)
.PARAMETER WhatIf
    Shows what would happen if the command runs without making changes
.PARAMETER Confirm
    Prompts for confirmation before deleting each tag
.EXAMPLE
    Git-RemoveDerivedTags -BaseTag v1.0 -Remote
    Removes all tags starting with "v1.0" (except exact match) both locally and on origin
.EXAMPLE
    Git-RemoveDerivedTags v1.5 -WhatIf
    Shows which tags would be deleted without actually removing them
.NOTES
    Requires Git to be installed and available in PATH
    Always test with -WhatIf before actual execution
#>
function Git-RemoveDerivedTags 
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [Alias('Base', 'Tag')]
        [ValidateNotNullOrEmpty()]
        [string]$BaseTag,

        [switch]$Remote
    )

    begin 
	{
        # Validate Git installation
        if (-not (Get-Command git -ErrorAction SilentlyContinue)) 
		{
            throw "Git command not found. Please ensure Git is installed and in PATH."
        }

        # Check if we're in a Git repository
        if (-not (Test-Path .git -PathType Container)) 
		{
            throw "Not a Git repository root directory"
        }
    }

    process {
        try {
            # Get tags in machine-readable format
            $tags = git tag -l --format='%(refname:strip=2)' | Where-Object {
                $_ -ne $BaseTag -and $_.StartsWith($BaseTag)
            }

            if (-not $tags) 
			{
                Write-Warning "No derived tags found matching base pattern: $BaseTag"
                return
            }

            foreach ($tag in $tags) 
			{
                $action = "Deleting tag"
                $target = "Local tag '$tag'"
                if ($Remote) { $target += " and remote tag '$tag'" }

                if ($PSCmdlet.ShouldProcess($target, $action)) 
				{
                    # Remove remote tag first if specified
                    if ($Remote) 
					{
                        Write-Verbose "Removing remote tag: $tag"
                        git push --delete origin $tag 2>&1 | ForEach-Object {
                            if ($_ -is [System.Management.Automation.ErrorRecord]) 
							{
                                Write-Error $_.Exception.Message
                            } 
							else 
							{
                                Write-Verbose $_
                            }
                        }
                    }

                    # Remove local tag
                    Write-Verbose "Removing local tag: $tag"
                    git tag --delete $tag 2>&1 | ForEach-Object {
                        if ($_ -is [System.Management.Automation.ErrorRecord]) 
						{
                            Write-Error $_.Exception.Message
                        } 
						else 
						{
                            Write-Verbose $_
                        }
                    }
                }
            }
        }
        catch
		{
            Write-Error "Operation failed: $_"
            throw
        }
    }
}

Set-Alias -Name git_remove_derived_tags -Value Git-RemoveDerivedTags

<#
.SYNOPSIS
Cleans the git repository by removing untracked files and directories.
.PARAMETER DryRun
If specified, only shows which files would be deleted without actually deleting them.
#>
function Git-Exterminatus
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [Switch]$DryRun
    )

    if( -NOT (Test-Path ./.git))
    {
        Write-Host "Not a git repo. Nothing to exterminate."
        return
    }
    try
    {
        if($PSCmdlet.ShouldProcess("directories", "Exterminating directories with git clean -fxd"))
        {
            Write-Host "Exterminating directories..."
            if($DryRun)
            {
                git clean -n -fxd
            }
            else
            {
                git clean -fxd
            }
        }
        if($PSCmdlet.ShouldProcess("files", "Exterminating leftover files with git clean -fx"))
        {
            Write-Host "Exterminating leftover files..."
            if($DryRun)
            {
                git clean -n -fx
            }
            else
            {
                git clean -fx
            }
        }
        Write-Host "done."
    }
    catch
    {
        Write-Error "An error occurred during git clean: $_"
    }
}

Set-Alias -Name git_exterminatus -Value Git-Exterminatus

<#
.SYNOPSIS
Deletes local branches that are not present on the remote.

.DESCRIPTION
This function deletes local Git branches that no longer exist on the specified remote. 
It allows for a dry run mode, where the branches to be deleted are computed and displayed without deletion.
It also highlights which local branches are marked for deletion.

.PARAMETER DryRun
If specified, only shows which branches would be deleted without actually deleting them.

.PARAMETER Remote
Specifies the remote name. Default is "origin".
#>
function Git-RemoveLocalBranchesNotOnRemote 
{
	[CmdletBinding()]
	param(
		[Switch]$DryRun,
		[string]$Remote = "origin"
	)

	try 
	{
		$defaultBranchRef = git symbolic-ref "refs/remotes/$Remote/HEAD" 2>&1
		if ($LASTEXITCODE -ne 0) {
			throw "Failed to retrieve default branch reference. Ensure you are in a valid Git repository and the remote '$Remote' exists."
		}
		$default_branch = $defaultBranchRef.Trim() -replace "refs/remotes/$Remote/", ""
	} 
	catch 
	{
		Write-Host "Error: $_" -ForegroundColor Red
		return
	}

	try 
	{
		$remoteBranchesOutput = git branch -r 2>&1
		if ($LASTEXITCODE -ne 0) 
		{
			throw "Failed to list remote branches."
		}
		$remote_branches = $remoteBranchesOutput | ForEach-Object {
			$_.Trim() -replace "^$Remote/", ""
		} | Where-Object { $_ -notmatch 'HEAD ->' }
	} 
	catch 
	{
		Write-Host "Error: $_" -ForegroundColor Red
		return
	}

	try 
	{
		$localBranchesOutput = git branch 2>&1
		if ($LASTEXITCODE -ne 0) { throw "Failed to list local branches." }
		$local_branches = $localBranchesOutput | ForEach-Object {
			$_.Trim() -replace '^\* ', ''
		}
	} 
	catch 
	{
		Write-Host "Error: $_" -ForegroundColor Red
		return
	}

	try 
	{
		$current_branch = git rev-parse --abbrev-ref HEAD 2>&1
		if ($LASTEXITCODE -ne 0 -or $current_branch -eq "HEAD") {
			throw "Failed to determine current branch (detached HEAD state)."
		}
		$current_branch = $current_branch.Trim()
	} 
	catch 
	{
		Write-Host "Error: $_" -ForegroundColor Red
		return
	}

	$branches_to_delete = @()
	foreach ($branch in $local_branches) {
		if ($branch -ne $default_branch -and -not ($remote_branches -contains $branch)) {
			$branches_to_delete += $branch
		}
	}

	Write-Host "Default branch: " -NoNewline
	Write-Host "$default_branch" -ForegroundColor Cyan

	Write-Host "`nRemote branches:"
	foreach ($branch in $remote_branches) 
	{
		Write-Host "  $branch" -ForegroundColor Cyan
	}

	Write-Host "`nLocal branches:"
	foreach ($branch in $local_branches) 
	{
		if ($branches_to_delete -contains $branch) 
		{ Write-Host "  $branch" -ForegroundColor Red } 
		else { Write-Host "  $branch" -ForegroundColor Cyan }
	}

	if ($branches_to_delete.Count -eq 0) 
	{
		Write-Host "`nNo local branches to delete." -ForegroundColor Green
		return
	}

	Write-Host "`nBranches to delete:" -ForegroundColor Green
	foreach ($branch in $branches_to_delete) { Write-Host "  $branch" -ForegroundColor Green }

	foreach ($branch in $branches_to_delete) 
	{
		if ($branch -eq $current_branch) 
		{
			Write-Host "Current branch '$branch' is set for deletion. Switching to default branch '$default_branch'." -ForegroundColor Yellow
			if (-not $DryRun) 
			{
				$checkoutOutput = git checkout $default_branch 2>&1
				if ($LASTEXITCODE -ne 0) 
				{
					Write-Host "Error: Failed to switch to default branch '$default_branch'. Aborting deletion of '$branch'." -ForegroundColor Red
					continue
				}
				$current_branch = $default_branch
			}
		}
		if ($DryRun) { Write-Host "DryRun: Would delete local branch '$branch'" -ForegroundColor Magenta } 
		else 
		{
			Write-Host "Deleting local branch '$branch'" -ForegroundColor Magenta
			$deleteOutput = git branch -D $branch 2>&1
			if ($LASTEXITCODE -ne 0) { Write-Host "Error: Failed to delete branch '$branch'. Details: $deleteOutput" -ForegroundColor Red }
		}
	}
}

Set-Alias -Name git_remove_local_branches_not_on_remote -Value Git-RemoveLocalBranchesNotOnRemote
