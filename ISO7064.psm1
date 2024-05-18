####################################################################################################
#                                                                                                  #
#    Company:        THE A.F.S. CORPORATION                                                        #
#    Department:     INFORMATION TECHNOLOGY                                                        #
#    Division:                                                                                     #
#    Group:                                                                                        #
#    Team:                                                                                         #
#                                                                                                  #
#    Level:          0                                                                             #
#    Classification: PUBLIC                                                                        #
#    Version:        24.0.1                                                                        #
#                                                                                                  #
#    Name:           ISO7064                                                                       #
#    Title:          ISO/IEC 7064                                                                  #
#    Description:    AN IMPLEMENTATION OF ISO/IEC 7064 SPECIFICATIONS FOR THE GENERATION AND       #
#                    VERIFICATION OF CHECK CHARACTERS IN POWERSHELL.                               #
#    Language:       POWERSHELL                                                                    #
#    Contributor(s): DELANDM002, THE INTERNATIONAL ORGANIZATION FOR STANDARDIZATION                #
#    Created:        2024-05-14                                                                    #
#    Updated:        2024-05-18                                                                    #
#                                                                                                  #
#    SNAF:           [ISO706424.0.1 ¦ LEVEL-0] - ISO/IEC 7064                                      #
#    DRL:            DRL://AFS/IT/ISO7064                                                          #
#    DID:            AFS.000006.F3                                                                 #
#    Location:       PSXPEDITE                                                                     #
#                                                                                                  #
#    2024 (c) THE A.F.S. CORPORATION. All rights reserved.                                         #
#                                                                                                  #
####################################################################################################

# ========== Configuration ========== #
$Script:Iso7064ModuleData = @{
    Module          = "ISO7064"
    Version         = "24.0.1"
    PSXInstallation = "PSXPEDITE"
    Systems         = @(
        @{
            Designation  = 1
            Name         = "ISO/IEC 7064, MOD 11-2"
            DisplayName  = "MOD 11-2"
            CheckLength  = 1
            AllowedChars = "0123456789"
            CheckChars   = "0123456789X"
            Radix        = 2
            Modulus      = 11
        }
        @{
            Designation  = 2
            Name         = "ISO/IEC 7064, MOD 37-2"
            DisplayName  = "MOD 37-2"
            CheckLength  = 1
            AllowedChars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
            CheckChars   = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ*"
            Radix        = 2
            Modulus      = 37
        }
        @{
            Designation  = 3
            Name         = "ISO/IEC 7064, MOD 97-10"
            DisplayName  = "MOD 97-10"
            CheckLength  = 2
            AllowedChars = "0123456789"
            CheckChars   = "0123456789"
            Radix        = 10
            Modulus      = 97
        }
        @{
            Designation  = 4
            Name         = "ISO/IEC 7064, MOD 661-26"
            DisplayName  = "MOD 661-26"
            CheckLength  = 2
            AllowedChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
            CheckChars   = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
            Radix        = 26
            Modulus      = 661
        }
        @{
            Designation  = 5
            Name         = "ISO/IEC 7064, MOD 1271-36"
            DisplayName  = "MOD 1271-36"
            CheckLength  = 2
            AllowedChars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
            CheckChars   = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
            Radix        = 36
            Modulus      = 1271
        }
    )
}

function Get-Iso7064Config {
    param(
        [Alias("Name", "Config", "Setting")]
        [string] $Key,

        [Alias("Value", "Fallback", "DefaultValue")]
        [object] $Default
    )

    if ($Key) {
        if ($Script:Iso7064ModuleData.ContainsKey($Key)) {
            return $Script:Iso7064ModuleData[$Key]
        }
        elseif ($Default) {
            return $Default
        }
        else {
            return $null
        }
    }
    else {
        return $Script:Iso7064ModuleData
    }
}

function Set-Iso7064Config {
    param(
        [parameter(Mandatory = $true, Position = 0, ParameterSetName = 'SetAll')]
        [Alias("Settings", "Configuration")]
        [hashtable] $Config,

        [parameter(Mandatory = $true, Position = 0, ParameterSetName = 'SetKey')]
        [Alias("Name", "Setting")]
        [string] $Key,

        [parameter(Mandatory = $true, Position = 1, ParameterSetName = 'SetKey')]
        [object] $Value
    )

    # If a hashtable is provided, set the entire configuration hashtable
    if ($PSCmdlet.ParameterSetName -eq 'SetAll') {
        $Script:Iso7064ModuleData = $Config
    }
    else {
        # If a key and value are provided, set the key-value pair in the configuration hashtable (or update an existing key-value pair)
        $Script:Iso7064ModuleData[$Key] = $Value
    }
}
# =================================== #

<#
.SYNOPSIS
Sanitizes a string based on the allowed characters for the specified check system.

.DESCRIPTION
Sanitizes a string based on the allowed characters for the specified check system. The allowed characters are defined in the configuration for the check system.

.PARAMETER InputString
The string to be sanitized.

.PARAMETER CheckSystem
The check system for which the string is to be sanitized. The check system can be specified by its designation, name, or display name.

.EXAMPLE
PS X:\> Get-Iso7064SanitizedString -InputString "AFS.000006." -CheckSystem 5
AFS000006

.EXAMPLE
PS X:\> Get-Iso7064SanitizedString -InputString "AFS.000006.F3" -CheckSystem 5
AFS000006F3
#>
function Get-Iso7064SanitizedString {
    param(
        [parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [Alias("Data", "Input", "String")]
        [string] $InputString,

        [Alias("System", "Algorithm", "Method", "Check")]
        [string] $CheckSystem
    )

    # Get the check systems available in the configuration
    $CheckSystems = Get-Iso7064Config -Key 'Systems' -Default @()

    # Retrieve the check system data based on the specified check system
    if (!($CheckSystemData = $CheckSystems | Where-Object { $_.Designation -eq $CheckSystem -or $_.Name -eq $CheckSystem -or $_.DisplayName -eq $CheckSystem } | Select-Object -First 1)) {
        throw "The specified check system '$CheckSystem' does not exist."
    }

    # Sanitize the input based on the allowed characters for the check system
    $SanitizedInputString = $InputString.ToUpper()

    $SanitizedInputString = $SanitizedInputString -replace "[^$($CheckSystemData.AllowedChars)]", ""

    if ([string]::IsNullOrEmpty($SanitizedInputString)) {
        throw "The input string does not contain any valid characters for the specified check system."
    }

    return $SanitizedInputString
}

<#
.SYNOPSIS
Tests whether a protected string is valid based on the specified check system.

.DESCRIPTION
Tests whether a protected string is valid based on the specified check system. The protected string consists of an input string followed by a check character. The check character is calculated based on the ISO/IEC 7064 specifications.

.PARAMETER InputString
The protected string to be tested.

.PARAMETER CheckSystem
The check system to be used for testing the protected string. The check system can be specified by its designation, name, or display name.

.EXAMPLE
PS X:\> Test-Iso7064ProtectedString -InputString "AFS.000006.F3" -CheckSystem 5
True

.EXAMPLE
PS X:\> Test-Iso7064ProtectedString -InputString "AFS.000006.EE" -CheckSystem 5
False
#>
function Test-Iso7064ProtectedString {
    param(
        [parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [Alias("Data", "Input", "String")]
        [string] $InputString,

        [Alias("System", "Algorithm", "Method", "Check")]
        [string] $CheckSystem
    )

    # Get the check systems available in the configuration
    $CheckSystems = Get-Iso7064Config -Key 'Systems' -Default @()

    # Retrieve the check system data based on the specified check system
    if (!($CheckSystemData = $CheckSystems | Where-Object { $_.Designation -eq $CheckSystem -or $_.Name -eq $CheckSystem -or $_.DisplayName -eq $CheckSystem } | Select-Object -First 1)) {
        throw "The specified check system '$CheckSystem' does not exist."
    }

    # Sanitize the input based on the allowed characters for the check system
    try {
        $SanitizedInputString = Get-Iso7064SanitizedString -InputString $InputString -CheckSystem $CheckSystem
    }
    catch {
        throw "Failed to sanitize the input string: $_"
    }

    # Get the last n characters from the input string, where n is the check length
    $CheckLength = $CheckSystemData.CheckLength
    $CheckChars = $SanitizedInputString.Substring($SanitizedInputString.Length - $CheckLength)
    $UnprotectedString = $InputString.Substring(0, $InputString.Length - $CheckLength)

    # Compute the check character for the unprotected string
    $CheckCharacter = Get-Iso7064CheckCharacter -InputString $UnprotectedString -CheckSystem $CheckSystem

    # Compare the computed check character with the check characters from the input string
    return $CheckCharacter -ceq $CheckChars
}

<#
.SYNOPSIS
Calculates the check character for the provided input string using the specified check system.

.DESCRIPTION
Calculates the check character for the provided input string using the specified check system. The check character is calculated based on the ISO/IEC 7064 specifications.

.PARAMETER InputString
The input string for which the check character is to be calculated.

.PARAMETER CheckSystem
The check system to be used for calculating the check character. The check system can be specified by its designation, name, or display name.

.EXAMPLE
PS X:\> Get-Iso7064CheckCharacter -InputString "AFS.000007" -CheckSystem 5
EE

.EXAMPLE
PS X:\> Get-Iso7064CheckCharacter -InputString "AFS.000006." -CheckSystem "MOD 1271-36"
F3
#>
function Get-Iso7064CheckCharacter {
    param(
        [parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [Alias("Data", "Input", "String")]
        [string] $InputString,

        [Alias("System", "Algorithm", "Method", "Check")]
        [string] $CheckSystem
    )

    # Get the check systems available in the configuration
    $CheckSystems = Get-Iso7064Config -Key 'Systems' -Default @()

    # Retrieve the check system data based on the specified check system
    if (!($CheckSystemData = $CheckSystems | Where-Object { $_.Designation -eq $CheckSystem -or $_.Name -eq $CheckSystem -or $_.DisplayName -eq $CheckSystem } | Select-Object -First 1)) {
        throw "The specified check system '$CheckSystem' does not exist."
    }

    # Sanitize the input based on the allowed characters for the check system
    try {
        $SanitizedInputString = Get-Iso7064SanitizedString -InputString $InputString -CheckSystem $CheckSystem
    }
    catch {
        throw "Failed to sanitize the input string: $_"
    }

    # Compute the check character
    $p = 0
    for ($n = 0; $n -lt $SanitizedInputString.Length; $n++) {
        $CharIndex = $CheckSystemData.CheckChars.IndexOf($SanitizedInputString[$n])

        if ($CharIndex -lt 0) {
            throw "The input string contains an invalid character for the specified check system."
        }

        $p = (($p + $CharIndex) * $CheckSystemData.Radix) % $CheckSystemData.Modulus
    }

    if ($CheckSystemData.CheckLength -eq 2) {
        $p = ($p * $CheckSystemData.Radix) % $CheckSystemData.Modulus
    }

    $Checksum = ($CheckSystemData.Modulus - $p + 1) % $CheckSystemData.Modulus

    # If the check length is 2, calculate the check character using two characters
    if ($CheckSystemData.CheckLength -eq 2) {
        $Second = $Checksum % $CheckSystemData.Radix
        $First = ($Checksum - $Second) / $CheckSystemData.Radix

        $CheckCharacter = "$($CheckSystemData.CheckChars[$First])$($CheckSystemData.CheckChars[$Second])"
    }
    else {
        $CheckCharacter = $CheckSystemData.CheckChars[$Checksum]
    }

    return $CheckCharacter
}

<#
.SYNOPSIS
Creates a protected string using the provided input string and check system.

.DESCRIPTION
Generates a protected string by appending the check character to the input string. The check character is calculated based on the specified check system.

.PARAMETER InputString
The input string to be protected.

.PARAMETER CheckSystem
The check system to be used for calculating the check character.

.EXAMPLE
PS X:\> Get-Iso7064ProtectedString -InputString "AFS.000007." -CheckSystem 5
AFS.000007.EE

.EXAMPLE
PS X:\> Get-Iso7064ProtectedString -InputString "AFS.000007." -CheckSystem "MOD 1271-36"
AFS.000006.F3
#>
function Get-Iso7064ProtectedString {
    param(
        [parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [Alias("Data", "Input", "String")]
        [string] $InputString,

        [Alias("System", "Algorithm", "Method", "Check")]
        [string] $CheckSystem
    )

    # Get the check character for the input string using the specified check system
    try {
        $CheckCharacter = Get-Iso7064CheckCharacter -InputString $InputString -CheckSystem $CheckSystem
    }
    catch {
        throw "Failed to get the check character for the input string: $_"
    }

    # Append the check character to the input string to create the protected string
    return "$InputString$CheckCharacter"
}
