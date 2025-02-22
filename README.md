# PSUitilities
 
## Overview

A collection of PowerShell utilities I use for various stuff

## Installation

To install the module, clone the repository and import the module:

```powershell
git clone https://github.com/ZeeWanderer/PSUtilities.git
Import-Module ./PSUtilities/PSUitilities.psd1
```

Or add the cloned repository to `PSModulePath` environment variable for autoimport.

## Features

### Git Tools

- **Git-SubmoduleUpdate**: Updates all git submodules.
- **Git-SubmoduleUpdateInit**: Initializes and updates all git submodules.
- **Git-SubmoduleUpdateInitRecursive**: Recursively initializes and updates all git submodules.
- **Git-SubmoduleDeinit**: Deinitializes git submodules.
- **Git-CleanSubmodules**: Checks out all files in all submodules recursively.
- **Git-AllSubmodulesResetHard**: Resets all submodules to their HEAD state.
- **Git-SubmoduleUpdatePull**: Updates a specified submodule by pulling its latest changes.
- **Git-FetchUpstream**: Fetches updates from upstream and rebases the current branch.
- **Git-PullUpstream**: Pulls updates from upstream for the current branch.
- **Git-Reset**: Resets the current branch to a specified commit hash.
- **Git-ResetHard**: Hard resets the current branch to a specified commit hash.
- **Git-ResetHard-Times**: Hard resets the current branch to a specified number of commits back.
- **Git-RemoveDerivedTags**: Removes derived Git tags both locally and remotely.
- **Git-Exterminatus**: Cleans the git repository by removing untracked files and directories.
- **Git-RemoveLocalBranchesNotOnRemote**: Deletes local branches that are not present on the remote.

### Python Tools

- **Python-UpgradePip**: Upgrades pip package manager for a Python installation.
- **Python-UpdatePackages**: Updates outdated Python packages.
- **Python-CheckUpdates**: Lists outdated Python packages with version information.
- **Python-ExportRequirements**: Exports all installed Python packages in requirements.txt format.
- **Python-InstallPyinstallerDev**: Installs the development version of PyInstaller from GitHub.
- **Python-AddVersionHardlinks**: Creates Python version hardlinks
