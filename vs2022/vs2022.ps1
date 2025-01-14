# Define a function to search for Visual Studio 2022 installation
function Find-VisualStudio2022 {
    # Initialize an array to hold found installations
    $foundInstallations = @()

    # Check the Registry for Visual Studio installations
    try {
        $vsRegistryPath = "HKLM:\SOFTWARE\Microsoft\VisualStudio\17.0"
        if (Test-Path $vsRegistryPath) {
            $installPath = (Get-ItemProperty -Path $vsRegistryPath).InstallDir
            if ($installPath) {
                $foundInstallations += [PSCustomObject]@{
                    Version = "Visual Studio 2022"
                    InstallPath = $installPath
                }
            }
        }
    } catch {
        Write-Error "Error accessing the registry: $_"
    }

    # Check common installation paths
    $commonPaths = @(
        "C:\Program Files\Microsoft Visual Studio\2022\Community",
        "C:\Program Files\Microsoft Visual Studio\2022\Professional",
        "C:\Program Files\Microsoft Visual Studio\2022\Enterprise"
    )

    foreach ($path in $commonPaths) {
        if (Test-Path $path) {
            $foundInstallations += [PSCustomObject]@{
                Version = "Visual Studio 2022"
                InstallPath = $path
            }
        }
    }

    # Output results
    if ($foundInstallations.Count -gt 0) {
        Write-Output "Found Visual Studio 2022 installations:"
        $foundInstallations | Format-Table -AutoSize
    } else {
        Write-Output "Visual Studio 2022 is not installed on this system."
    }
}

# Call the function to execute the search
Find-VisualStudio2022