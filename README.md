# ISO7064

> **ISO/IEC 7064**
> 
> Information technology — Security techniques — Check character systems

A PowerShell module for generating check characters and checking strings using ISO/IEC 7064.

Based specifically off of ISO/IEC 7064:2003(en).

This is the first ISO International Standard that I buy and I'm very happy! I love ISO, standardization in general, and programming so this project was very fun for me! I'll definitely be getting more standards for birthdays and christmas (nerd alert lol).

# Supported check character systems

NOTE — Hybrid systems are not supported as of Version 24.0.1

The following check character systems are supported in the current version:
- ISO/IEC 7064, MOD 11-2
- ISO/IEC 7064, MOD 37-2
- ISO/IEC 7064, MOD 97-10
- ISO/IEC 7064, MOD 661-26
- ISO/IEC 7064, MOD 1271-36

# Adding check character systems
You can easily add any pure check character system. Each system is stored in the module data variables, specifically at the `Systems` key. Each system has the following properties:
- `int` *designation*, which represents the designation digit assigned to the system in ISO/IEC 7064
- `string` *name*, which is the full name of the system (e.g. "ISO/IEC 7064, MOD 11-2")
- `string` *DisplayName*, the name of the system, but shorter (e.g. "MOD 11-2")
- `int` *CheckLength*, the number of check characters that are to be appended to the (soon-to-be) protected string
- `string` *AllowedChars*, the characters that are accepted as input for the string. Any non-matching character will be ignored. The index of the character in the string is used as its value
- `string` *CheckChars*, the list of characters used for the check character(s)
- `int` *Radix*, the radix _(who would've guessed?)_
- `int` *Modulus*, the modulus _(no way)_

# Versions
## 24.0.1
THe following features have been added to Version 24.0.1:
- `Get-Iso7064SanitizedString`: To sanitize a string for a given check system.
- `Test-Iso7064ProtectedString`: Checks if a protected string is valid under a given check system. The check character(s) are the right-most characters in the string.
- `Get-Iso7064CheckCharacter`: Returns the check character(s) for a string with a given check system, as opposed to `Get-Iso7064ProtectedString` which returns the entire string with the check character(s) appended.
- Added the following check systems:
    - ISO/IEC 7064, MOD 37-2
    - ISO/IEC 7064, MOD 97-10
    - ISO/IEC 7064, MOD 661-26
## 24.0.0
The following features are available as of Version 24.0.0:
- `Get-Iso7064ProtectedString`: Takes a string as input and returns the fully protected string with the check character(s) appended to the end.
- The following check character systems:
    - ISO/IEC 7064, MOD 11-2
    - ISO/IEC 7064, MOD 1271-36

<p align="center">Made with 💖 by 🥝</p>
