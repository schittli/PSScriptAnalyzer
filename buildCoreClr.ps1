﻿param(
    [switch]$build,
    [switch]$uninstall,
    [switch]$install
)

$solutionDir = "C:\Users\kborle\Source\Repos\PSScriptAnalyzer"


$itemsToCopy = @("$solutionDir\Engine\bin\debug\netcoreapp1.0\Microsoft.Windows.PowerShell.ScriptAnalyzer.dll",
    "$solutionDir\Rules\bin\debug\netcoreapp1.0\Microsoft.Windows.PowerShell.ScriptAnalyzer.BuiltinRules.dll",
    "$solutionDir\Engine\PSScriptAnalyzer.psd1",
    "$solutionDir\Engine\PSScriptAnalyzer.psm1",
    "$solutionDir\Engine\ScriptAnalyzer.format.ps1xml",
    "$solutionDir\Engine\ScriptAnalyzer.types.ps1xml")

$destinationDir = "$solutionDir/out/coreclr/PSScriptAnalyzer"

if ($build)
{
    Push-Location Engine\
    dotnet build
    Pop-Location

    Push-Location Rules\
    dotnet build
    Pop-Location

    if (-not (Test-Path $destinationDir))
    {
        New-Item -ItemType Directory $destinationDir -Force
    }
    else
    {
        Remove-Item "$destinationDir\*" -Recurse
    }

    foreach ($file in $itemsToCopy) 
    {
        Copy-Item -Path $file -Destination (Join-Path $destinationDir (Split-Path $file -Leaf)) -Verbose
    }
    (Get-Content "$solutionDir\Engine\PSScriptAnalyzer.psd1") -replace "ModuleVersion = '1.6.0'","ModuleVersion = '0.0.1'" | Out-File "$solutionDir\Engine\PSScriptAnalyzer.psd1"
}

$modulePath = "C:\Users\kborle\Documents\WindowsPowerShell\Modules";
$pssaModulePath = Join-Path $modulePath PSScriptAnalyzer
 

if ($uninstall)
{
    if ((Test-Path $pssaModulePath))
    {
        Remove-Item -Recurse $pssaModulePath -Verbose
    }
 
}

if ($install)
{
    Copy-Item -Recurse -Path "$destinationDir" -Destination "$modulePath\." -Verbose -Force
}
