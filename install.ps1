$RepoDir = $PSScriptRoot
$CurrentPath = [Environment]::GetEnvironmentVariable('PATH', 'User')

if ($CurrentPath -split ';' -contains $RepoDir) {
    Write-Host "$RepoDir already in user PATH."
} else {
    $NewPath = ($CurrentPath.TrimEnd(';') + ';' + $RepoDir).TrimStart(';')
    [Environment]::SetEnvironmentVariable('PATH', $NewPath, 'User')
    Write-Host "Added $RepoDir to user PATH."
    Write-Host "Restart your terminal for changes to take effect."
}
