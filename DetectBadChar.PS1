<#
.SYNOPSIS

This script is used to detect a bad character in a text file, remove the file, and email the filename that was deleted to the user.

.DESCRIPTION
This script specifically:
      1. Scan text files in a folder for a specific character
      2. Delete corrosponding header/detail files with the specific character
      3. Email what was deleted.
      
This script was created with the specific file naming convention in mind:
      1. Header = AHMMDDYY.111
      2. Detail = ADMMDDYY.111  --the three characters to the right of the decimal are emailed and are unique identifiers
#>
$filesDeleted = @()

Get-Childitem '\\fileshare\folder\*' | Where-Object {$_.Name -match "\.\d+" -and -not $_.PSIsContainer } | Select-String -List  -Pattern  '#' | Foreach-Object {

       $_.Path -replace '(.*\\A).(.*)', '$1[D|H]$2'  | rm -Force -ea 0
       $filesDeleted += ($_.Filename -split '\.')[-1]
    }


if ( $filesDeleted -gt 0 ) {

  $message = "These files have been deleted:`r`n" + ($filesDeleted -join "`r`n" )
  $FromAddress = "emailaddress@xyzcompany.com"
  $ToAddress = "emailaddress@xyzcompany.com"
  $MessageSubject = "Bad Character File Detected"
  $SendingServer = "mail.xyzcompany.com"
  $SMTPMessage = New-Object System.Net.Mail.MailMessage $FromAddress, $ToAddress, $MessageSubject,$message
  $SMTPClient = New-Object System.Net.Mail.SMTPClient $SendingServer
  $SMTPClient.Send($SMTPMessage)
}
