#
# Module manifest for module 'PSUitilities'
#
# Generated by: ZeeWanderer
#
# Generated on: 17/02/2025
#

@{

    # Script module or binary module file associated with this manifest.
    # RootModule = ''
    
    # Version number of this module.
    ModuleVersion = '0.1.1'
    
    # Supported PSEditions
    CompatiblePSEditions = @("Core", "Desk")
    
    # ID used to uniquely identify this module
    GUID = '0240a802-a641-486b-88dd-1d9adb3d4d00'
    
    # Author of this module
    Author = 'ZeeWanderer'
    
    # Company or vendor of this module
    # CompanyName = ''
    
    # Copyright statement for this module
    # Copyright = ''
    
    # Description of the functionality provided by this module
    Description = 'A collection of PowerShell utilities I use for various stuff'
    
    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion = '7.0'
    
    # Name of the PowerShell host required by this module
    # PowerShellHostName = ''
    
    # Minimum version of the PowerShell host required by this module
    # PowerShellHostVersion = ''
    
    # Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # DotNetFrameworkVersion = ''
    
    # Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # ClrVersion = ''
    
    # Processor architecture (None, X86, Amd64) required by this module
    # ProcessorArchitecture = ''
    
    # Modules that must be imported into the global environment prior to importing this module
    # RequiredModules = @()
    
    # Assemblies that must be loaded prior to importing this module
    # RequiredAssemblies = @()
    
    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    # ScriptsToProcess = @()
    
    # Type files (.ps1xml) to be loaded when importing this module
    # TypesToProcess = @()
    
    # Format files (.ps1xml) to be loaded when importing this module
    # FormatsToProcess = @()
    
    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    NestedModules = @(
        'GitTools\GitTools.psm1'
        'PythonTools\PythonTools.psm1'
    )
    
    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @(
        # GitTools
        'Git-SubmoduleUpdate'
        'Git-SubmoduleUpdateInit'
        'Git-SubmoduleUpdateInitRecursive'
        'Git-SubmoduleDeinit'
        'Git-CleanSubmodules'
        'Git-AllSubmodulesResetHard'
        'Git-SubmoduleUpdatePull'
        'Git-FetchUpstream'
        'Git-PullUpstream'
        'Git-Reset'
        'Git-ResetHard'
        'Git-ResetHard-Times'
        'Git-RemoveDerivedTags'
        'Git-Exterminatus'
        'Git-RemoveLocalBranchesNotOnRemote'

        # PythonTools
        'Python-UpgradePip'
        'Python-UpdatePackages'
        'Python-CheckUpdates'
        'Python-ExportRequirements'
        'Python-InstallPyinstallerDev'
        'Python-AddVersionHardlinks'
    )
    
    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport = @()
    
    # Variables to export from this module
    VariablesToExport = ''
    
    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport = @(
        # GitTools
        'git_submodule_update'
        'git_submodule_update_init'
        'git_submodule_update_init_recursive'
        'git_submodule_deinit'
        'git_clean_submodules'
        'git_all_submodules_reset_hard'
        'git_submodule_update_pull'
        'git_fetch_upstream'
        'git_pull_upstream'
        'git_reset'
        'git_reset_hard'
        'git_reset_hard_times'
        'git_remove_derived_tags'
        'git_exterminatus'
        'git_remove_local_branches_not_on_remote'

        # PythonTools
        'python_upgrade_pip'
        'python_update_packages'
        'python_check_updates'
        'python_export_requirements'
        'python_install_pyinstaller_dev'
        'python_add_version_hardlinks'
    )
    
    # DSC resources to export from this module
    # DscResourcesToExport = @()
    
    # List of all modules packaged with this module
    # ModuleList = @()
    
    # List of all files packaged with this module
    # FileList = @()
    
    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{
    
        PSData = @{
    
            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('Git', 'Utilities', 'PowerShell')
    
            # A URL to the license for this module.
            # LicenseUri = ''
    
            # A URL to the main website for this project.
            ProjectUri = 'http://github.com/ZeeWanderer/PSUtilities'
    
            # A URL to an icon representing this module.
            # IconUri = ''
    
            # ReleaseNotes of this module
            # ReleaseNotes = ''
    
            # Prerelease string of this module
            # Prerelease = ''
    
            # Flag to indicate whether the module requires explicit user acceptance for install/update/save
            # RequireLicenseAcceptance = $false
    
            # External dependent modules of this module
            # ExternalModuleDependencies = @()
    
        } # End of PSData hashtable
    
    } # End of PrivateData hashtable
    
    # HelpInfo URI of this module
    # HelpInfoURI = ''
    
    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''
    
}
    
    