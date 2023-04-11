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
    [parameter(Mandatory = $false)]
    [string]$filePath
)

    if (-not $filePath) {
        Write-Error "No valid parameter file found."
    }

    $InputObject = Get-Content -Path $filePath | ConvertFrom-Json

#     $arraySeparator = Get-VstsInput -Name arraySeparator
#     if ($arraySeparator) {
#         $argHash.arraySeparator = $arraySeparator
#     }

Set-Variables $InputObject
# }

function Set-Variables {
    param (
        [Parameter(Mandatory = $true)]
        [Object] $InputObject,

        [Parameter(Mandatory = $false)]
        [String] $Parent,

        [Parameter(Mandatory = $false)]
        [String] $ArraySeparator = ";"
    )

    $props = Get-Member -InputObject $InputObject -MemberType NoteProperty
    foreach($prop in $props) {
        $propValue = $InputObject | Select-Object -ExpandProperty $prop.Name
        if ($null -ne $propValue) {
            if ($propValue.GetType().Name -eq "PSCustomObject") {
                $newParent = $prop.Name
                if ($Parent) {
                    $newParent = "$($Parent).$($prop.Name)"
                }
                Set-Variables -InputObject $propValue -Parent $newParent -ArraySeparator $ArraySeparator
            }
            else {
                if ($propValue.GetType().FullName -eq "System.Object[]") {
                    $propValue = $propValue -join $ArraySeparator
                }

                $variableName = $prop.Name
                if ($Parent) {
                    $variableName = "$($Parent).$($prop.Name)"
                }

                Write-Host "Creating variable '$variableName'."
                echo "$variableName=$propValue" | Out-File -FilePath $Env:GITHUB_ENV -Encoding utf8 -Append
            }
        }
    }
}
