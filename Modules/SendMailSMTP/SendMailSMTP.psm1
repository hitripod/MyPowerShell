#####################################################################################
#.SYNOPSIS
# An integrated CLI tool for more easily UPDATE/BUILD/PACK MP Kit. 
#
#.DESCRIPTION
# To maintain consistency with New-Object this cmdlet requires the -ComObject
# parameter to be provided and the TypeName parameter is not supported.
#
#.PARAMETER To
#.PARAMETER From
#.PARAMETER Subject
#.PARAMETER Body
#.PARAMETER password
#####################################################################################

Function Send-EMail {
    Param (
        [Parameter(Mandatory=$false)]
        [String]$To="kordan",  
        [Parameter(Mandatory=$true)]
        [String]$Subject,
        [Parameter(Mandatory=$true)]
        [String]$Body,
        [Parameter(Mandatory=$false)]
        [String]$From="kordan@realtek.com",  
        [Parameter(Mandatory=$false)]
        [String]$attachment,
        [Parameter(Mandatory=$false)]
        [String]$Password
    )

    $To += "@realtek.com"
    $SMTPServer = "mail.realtek.com" 
    $SMTPMessage = New-Object System.Net.Mail.MailMessage($From,$To,$Subject,$Body)
    if ($attachment -ne "") {
        $SMTPattachment = New-Object System.Net.Mail.Attachment($attachment)
        $SMTPMessage.Attachments.Add($STMPattachment)
    }
    $SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587) 
    $SMTPClient.EnableSsl = $false
    $SMTPClient.Port = 465
    $SMTPClient.Credentials = New-Object System.Net.NetworkCredential($From.Split("@")[0], $Password); 

    $SMTPMessage.IsBodyHtml = 1
    $SMTPClient.Send($SMTPMessage)
    Remove-Variable -Name SMTPClient
    Remove-Variable -Name Password

} #End Function Send-EMail
