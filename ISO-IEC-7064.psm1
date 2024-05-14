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
#    Version:        24.0.0                                                                        #
#                                                                                                  #
#    Name:           ISOSZSF                                                                       #
#    Title:          ISO/IEC 7064                                                                  #
#    Description:    AN IMPLEMENTATION OF ISO/IEC 7064:2003 SPECIFICATIONS FOR THE GENERATION      #
#                    AND VERIFICATION OF CHECK CHARACTERS IN POWERSHELL.                           #
#    Language:       POWERSHELL                                                                    #
#    Contributor(s): DELANDM002, THE INTERNATIONAL ORGANIZATION FOR STANDARDIZATION                #
#    Created:        2024-05-14                                                                    #
#    Updated:        2024-05-14                                                                    #
#                                                                                                  #
#    SNAF:           [ISOSZSF24.0.0 ¦ LEVEL-0] - ISO/IEC 7064                                      #
#    DRL:            DRL://AFS/IT/ISOSZSF                                                          #
#    DID:            AFS.000006.F3                                                                 #
#    Location:       PSXPEDITE                                                                     #
#                                                                                                  #
#    2024 (c) THE A.F.S. CORPORATION. All rights reserved.                                         #
#                                                                                                  #
####################################################################################################

# ========== Configuration ========== #
$Script:Iso7064ModuleData = @{
    Module          = "ISOSZSF"
    Version         = "24.0.0"
    PSXInstallation = "PSXPEDITE - ANONYMOUS"
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

    # If a key is provided, attempt to retrieve the value from the configuration hashtable
    if ($Key) {
        # If the key exists, return the value; otherwise, return the default value (if provided)
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
        # If no key is provided, return the entire configuration hashtable
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

function Get-Iso7064ProtectedString {
    param(
        [parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [Alias("Data", "Input", "String")]
        [string] $InputString,

        [Alias("System", "Algorithm", "Method", "Check")]
        [string] $CheckSystem
    )

    $CheckSystems = Get-Iso7064Config -Key 'Systems' -Default @()

    if (!($CheckSystemData = $CheckSystems | Where-Object { $_.Designation -eq $CheckSystem -or $_.Name -eq $CheckSystem -or $_.DisplayName -eq $CheckSystem } | Select-Object -First 1)) {
        throw "The specified check system '$CheckSystem' does not exist."
    }

    $SanitizedInputString = $InputString.ToUpper()

    $SanitizedInputString = $SanitizedInputString -replace "[^$($CheckSystemData.AllowedChars)]", ""

    if ([string]::IsNullOrEmpty($SanitizedInputString)) {
        throw "The input string does not contain any valid characters for the specified check system."
    }

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
 
    if ($CheckSystemData.CheckLength -eq 2) {
        $Second = $Checksum % $CheckSystemData.Radix
        $First = ($Checksum - $Second) / $CheckSystemData.Radix

        $CheckString = "$($CheckSystemData.CheckChars[$First])$($CheckSystemData.CheckChars[$Second])"
    }
    else {
        $CheckString = $CheckSystemData.CheckChars[$Checksum]
    }

    return "$InputString$CheckString"
}