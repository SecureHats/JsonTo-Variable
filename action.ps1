<#
    Title:          Template for GitHub Action
    Language:       PowerShell
    Version:        0.1
    Author:         Rogier Dijkman
    Last Modified:  04/11/2023

    DESCRIPTION
    This GitHub action is used to create GitHub variables from a JSON file

#>

param (
    [Parameter(Mandatory, ValueFromPipeline)]
    [ValidateScript( { (Test-Path -Path $_) -and ($_.Extension -in '.json', '.yaml', '.yml') })]
    [System.IO.FileInfo]$filePath,

    [parameter(Mandatory = $false)]
    [string]$arraySeparator,
    
    [parameter(Mandatory = $false)]
    [bool]$outputs
)

    if (-not $filePath) {
        Write-Error "No valid parameter file found."
    }

    if ($filePath.Extension -eq '.json') {
            try {
                 $inputObject = Get-Content -Path $filePath | ConvertFrom-Json
            }
            catch {
                Write-Verbose $_
                Write-Error -Message 'Unable to import JSON file' -ErrorAction Stop
            }
        }
        elseif ($filePath.Extension -in '.yaml', '.yml') {
            try {
                $modulesToInstall = @(
                    'powershell-yaml'
                )   
                $modulesToInstall | ForEach-Object {
                    if (-not (Get-Module -ListAvailable -All $_)) {
                        Write-Output "Module [$_] not found, INSTALLING..."
                        Install-Module $_ -Force
                        Import-Module $_ -Force
                    }
                }            
                $arraySeparator = ','
                $InputObject = Get-Content -Path $filePath | ConvertFrom-Yaml    
            }
            catch {
                Write-Verbose $_
                Write-Error -Message 'Unable to convert yaml file' -ErrorAction Stop
            }
        }
        else {
            Write-Error -Message 'Unsupported extension for SettingsFile' -ErrorAction Stop
        }

    $argHash = @{
        "InputObject" = $InputObject
        "outputs"     = $outputs
    }

    if ($arraySeparator) {
        $argHash.arraySeparator = $arraySeparator
    }

function Set-Variables {
    param (
        [Parameter(Mandatory = $true)]
        [Object] $InputObject,

        [Parameter(Mandatory = $false)]
        [String] $InputType = "json",
        
        [Parameter(Mandatory = $false)]
        [String] $Parent,

        [Parameter(Mandatory = $false)]
        [String] $ArraySeparator = ";",
        
        [Parameter(Mandatory = $false)]
        [bool] $Outputs = $true
    )

    $props = Get-Member -InputObject $InputObject -MemberType NoteProperty
    foreach($prop in $props) {
        $propValue = $InputObject | Select-Object -ExpandProperty $prop.Name
        if ($null -ne $propValue) {
            if ($propValue.GetType().Name -eq "PSCustomObject") {
                $newParent = $prop.Name
                if ($Parent) {
                    $newParent = "$($Parent)_$($prop.Name)"
                }
                Set-Variables -InputObject $propValue -Parent $newParent -ArraySeparator $ArraySeparator
            }
            else {
                if ($propValue.GetType().FullName -eq "System.Object[]" -or ($($prop.Definition) -like "*object*")) {
                    $propValue = $propValue -join $ArraySeparator
                    $arrayFlag = $true
                }

                $variableName = $prop.Name
                if ($Parent) {
                    $variableName = "$($Parent)_$($prop.Name)"
                }
                
                if ($arrayFlag) {
                    $arrayFlag = $false
                    $arrayList = $propValue -split $ArraySeparator
                      if ($arrayList.count -gt 1) {
                        $propValue = $arrayList | ConvertTo-Json -Compress
                      } else {
                        $propValue = "[""$($arrayList)""]"
                      }
                }
                Write-Host "Creating variable '$variableName'."        
                echo "$variableName=$propValue" | Out-File -FilePath $Env:GITHUB_ENV -Encoding utf8 -Append
                
                if ($outputs) {
                     echo "variableName=$propValue" >> $env:GITHUB_OUTPUT
                }
            }
        }
    }
}

Set-Variables @argHash
