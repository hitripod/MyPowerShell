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

Function StartSMSOTP {
    Param (
        [Parameter(Mandatory=$false)]
        [String]$User="kordan",  
        [Parameter(Mandatory=$true)]
        [String]$Password,
        [Parameter(Mandatory=$true)]
        [String]$SrcZipFile,
        [Parameter(Mandatory=$true)]
        [String]$OutDir  
    )

    $username = $User
    $password = $Password
    $fileToSign = $SrcZipFile
    $destFile = $OutDir

    $WatinPath = 'C:\Users\Kordan\Documents\WindowsPowerShell\WatiN.Core.dll' #path with downloaded assembly
    $emailAddr = "$username@realtek.com"
    $motpFolderName = "MOTP"
    #-----------------------------------------------------------------------------
    
    
    $watin     = [Reflection.Assembly ]::LoadFrom( $WatinPath )
    
    $ie        = new-object WatiN.Core.IE("http://rtittc1.realtek.com.tw:8080/DriverSign/SMSOTP.jsp" )
    $ie.TextField( "j_username"). TypeText($username);
    $ie.Button( "getOTP"). Click();
    
    #-----------------------------------------------------------------------------
    
    [Reflection.Assembly]:: LoadFile("C:\Program Files\Microsoft\Exchange\Web Services\1.2\Microsoft.Exchange.WebServices.dll")
    #$s = New-Object Microsoft.Exchange.WebServices.Data.ExchangeService
    $s = New-Object Microsoft.Exchange.WebServices.Data.ExchangeService ([Microsoft.Exchange.WebServices.Data.ExchangeVersion ]::Exchange2010_SP2)
    $s.Credentials = New-Object Net.NetworkCredential( $username, $password)
    $s.AutodiscoverUrl($emailAddr)
    
    $fvFolderView = new-object Microsoft.Exchange.WebServices.Data.FolderView(100) 
    $SfSearchFilter = new-object Microsoft.Exchange.WebServices.Data.SearchFilter+IsEqualTo([Microsoft.Exchange.WebServices.Data.FolderSchema]::DisplayName, $motpFolderName) 
    $findFolderResults = $s.FindFolders([Microsoft.Exchange.WebServices.Data.WellKnownFolderName]::Inbox, $SfSearchFilter, $fvFolderView) 
    if ($findFolderResults.TotalCount -gt 0){ 
        $folder = $findFolderResults[0]
    }         
    
    $motpFD = [Microsoft.Exchange.WebServices.Data.Folder]::Bind($s, $folder.Id)
    $unreadCout = $motpFD.UnreadCount
    
    Sleep(2)

    while ($unreadCout -eq 0) {
        $motpFD = [Microsoft.Exchange.WebServices.Data.Folder]::Bind($s, $folder.Id)
        $unreadCout = $motpFD.UnreadCount
        Sleep(1)
    }
    $itempropertyset = New-Object Microsoft.Exchange.WebServices.Data.PropertySet([Microsoft.Exchange.WebServices.Data.BasePropertySet]::FirstClassProperties);
    $itempropertyset.RequestedBodyType = [Microsoft.Exchange.WebServices.Data.BodyType]::Text;
    $itemview = New-Object Microsoft.Exchange.WebServices.Data.ItemView(1000);
    $itemview.PropertySet = $itempropertyset;
    $fs = new-object Microsoft.Exchange.WebServices.Data.SearchFilter+IsEqualTo([Microsoft.Exchange.WebServices.Data.EmailMessageSchema]::IsRead, $FALSE)
    $unreads = New-Object Microsoft.Exchange.WebServices.Data.SearchFilter+SearchFilterCollection([Microsoft.Exchange.WebServices.Data.LogicalOperator]::And, $fs)
    $motp = $s.FindItems($folder.Id, $unreads, $itemview)
    $motp.Load($itempropertyset);
    $body = $motp.Body.Text
    Write-Host $body
    $body -match "[\d]{6,6}"

    try {
        $otp = $matches[0] | Out-String
        Write-Host $otp
    } 
    catch {
        Write-Host "Failed to get OTP code!!!!"
        return
    }
    
    #-----------------------------------------------------------------------------
    
    $ie.TextField( "otp1"). TypeText($otp);
    $ie.Button( "validOTP"). Click();
    $file1 = $ie. FileUpload([watin.core.Find ]::ByName("file")) #id of the input
    Sleep(1)
    $file1.Set($fileToSign) # path to the file
    #$file1.Text = $fileToSign
    # and now just find the button and click on it
    $ie.Button( [watin.core.Find]::ByClass("x-btn")).Click() #send is id of the submit button
    #$ie.WaitForComplete()
    $ie.Button( [watin.core.Find]::ByValue("簽署憑證")).WaitUntilExists()
    $ie.Button( [watin.core.Find]::ByValue("簽署憑證")).Click() #send is id of the submit button
    #$ie.Elements.Filter([watin.core.Find]::BySelector("div.column1 fieldset a")).Click()
    $signedzip = $ie.Elements.Filter([watin.core.Find]::BySelector("div.column1 fieldset a"))[1].OuterText
    
    Write-Host "Downloading signed file..."
    $wc = New-Object System.Net.WebClient
    #$wc.DownloadFile($signedzip, $destFile)
    $downloadScript = (Split-Path $script:MyInvocation.MyCommand.Path) + "\Download-File.ps1"
    Invoke-Expression "$downloadScript $signedzip $destFile"

    if (Test-Path  ($destFile)) {
        Write-Host "Download completed."
    } else {
        Write-Host "Download failed!"
    }
    
    $ie.Close()
}
