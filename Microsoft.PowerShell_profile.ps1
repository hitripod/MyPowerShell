param($ic, $type = "Release")

function prompt
{
    Write-Host ("" + $(get-location) +">") -nonewline -foregroundcolor Yellow 
    return " "
}

#-----------------------------------------------------------------------------
function List-Stack {
    $index = 0;
    $locations = (Get-Location -Stack).ToArray()
    foreach($location in $locations)
    {
        Write-Host $index $location.Path
        $index++
    }
}

function Set-NewLocation($index) {
    $location = (Get-Location -Stack).ToArray() | select -Index $index
    Set-Location -Path $location
}

function Clear-Stack {
    $locations = (Get-Location -Stack).ToArray()
    foreach($location in $locations)
    {
        Pop-Location
    }
}

#-----------------------------------------------------------------------------
# Custom 'cd' command to maintain directory history
#
# Usage:
#  cd          no args means cd $home
#  cd <name>   changes to the directory specified by <name>
#  cd -l       list your directory history
#  cd -#       change to the history entry specified by #
#
#-----------------------------------------------------------------------------
if( test-path alias:\cd ) { remove-item alias:\cd }
$global:PWD = get-location;
$global:CDHIST = [System.Collections.Arraylist]::Repeat($PWD, 1);
function cd {
    $cwd = get-location;
    $l = $global:CDHIST.count;

    if ($args.length -eq 0) { 
        set-location $HOME;
        $global:PWD = get-location;
        $global:CDHIST.Remove($global:PWD);
        if ($global:CDHIST[0] -ne $global:PWD) {
            $global:CDHIST.Insert(0,$global:PWD);
        }
        $global:PWD;
    }
    elseif ($args[0] -like "-[0-9]*") {
        $num = $args[0].Replace("-","");
        $global:PWD = $global:CDHIST[$num];
        set-location $global:PWD;
        $global:CDHIST.RemoveAt($num);
        $global:CDHIST.Insert(0,$global:PWD);
        $global:PWD;
    }
    elseif ($args[0] -eq "-l") {
        for ($i = $l-1; $i -ge 0 ; $i--) { 
            "{0,6}  {1}" -f $i, $global:CDHIST[$i];
        }
    }
    elseif ($args[0] -eq "-") { 
        if ($global:CDHIST.count -gt 1) {
            $t = $CDHIST[0];
            $CDHIST[0] = $CDHIST[1];
            $CDHIST[1] = $t;
            set-location $global:CDHIST[0];
            $global:PWD = get-location;
        }
        $global:PWD;
    }
    else { 
        set-location "$args";
    $global:PWD = pwd; 
        for ($i = ($l - 1); $i -ge 0; $i--) { 
            if ($global:PWD -eq $CDHIST[$i]) {
                $global:CDHIST.RemoveAt($i);
            }
        }

        $global:CDHIST.Insert(0,$global:PWD);
        $global:PWD;
    }

    $global:PWD = get-location;
}
#-----------------------------------------------------------------------------

function DDKEnvSet {
    if ($args[0] -eq "default") {
        C:\Windows\System32\cmd.exe /k C:\WINDDK\3790~1.183\bin\setenv.bat C:\WINDDK\3790~1.183 chk AMD64 WNET
    } elseif ($args.length -ne 3) { 
        Write-Host "Usage: SetDDK [N5|N61|N62] [fre|chk] [x86|x64]";
    } else {

        if ($args[0] -eq "N5" -and $args[1] -eq "chk" -and $args[2] -eq "x86") {

            C:\Windows\System32\cmd.exe /k C:\WINDDK\3790~1.183\bin\setenv.bat C:\WINDDK\3790~1.183 chk WXP

        } elseif ($args[0] -eq "N5" -and $args[1] -eq "chk" -and $args[2] -eq "x64") {

            C:\Windows\System32\cmd.exe /k C:\WINDDK\3790~1.183\bin\setenv.bat C:\WINDDK\3790~1.183 chk AMD64 WNET

        } elseif ($args[0] -eq "N5" -and $args[1] -eq "fre" -and $args[2] -eq "x86") {

            C:\Windows\System32\cmd.exe /k C:\WINDDK\3790~1.183\bin\setenv.bat C:\WINDDK\3790~1.183 fre WXP

        } elseif ($args[0] -eq "N5" -and $args[1] -eq "fre" -and $args[2] -eq "x64") {

            C:\Windows\System32\cmd.exe /k C:\WINDDK\3790~1.183\bin\setenv.bat C:\WINDDK\3790~1.183 fre AMD64 WNET

        } elseif ($args[0] -eq "N61" -and $args[1] -eq "chk" -and $args[2] -eq "x86") {

            C:\Windows\System32\cmd.exe /k C:\WinDDK\7600.16385.0\bin\setenv.bat C:\WinDDK\7600.16385.0\ chk WIN7

        } elseif ($args[0] -eq "N61" -and $args[1] -eq "chk" -and $args[2] -eq "x64") {

            C:\Windows\System32\cmd.exe /k C:\WinDDK\7600.16385.0\bin\setenv.bat C:\WinDDK\7600.16385.0\ chk x64 WIN7

        } elseif ($args[0] -eq "N61" -and $args[1] -eq "fre" -and $args[2] -eq "x86") {

            C:\Windows\System32\cmd.exe /k C:\WinDDK\7600.16385.0\bin\setenv.bat C:\WinDDK\7600.16385.0\ fre WIN7

        } elseif ($args[0] -eq "N61" -and $args[1] -eq "fre" -and $args[2] -eq "x64") {

            C:\Windows\System32\cmd.exe /k C:\WinDDK\7600.16385.0\bin\setenv.bat C:\WinDDK\7600.16385.0\ fre x64 WIN7

        } else {

            Write-Host "Unknown Arguments."

        }
    }
}         
function MPBuild($ic, $type) {
    invoke-expression "C:\Users\Kordan\Desktop\RTK\MP_Kit_$ic\InstallShield\Utility\BuildMP_Release.bat" | out-null

#$(C:\Windows\System32\cmd.exe /k C:\WINDDK\3790~1.183\bin\setenv.bat C:\WINDDK\3790~1.183 fre WXP) 
#        -and $(cd (Get-Location -PSProvider FileSystem).ProviderPath) -and $(mpbuild all) -and $(exit)
#     $(C:\Windows\System32\cmd.exe /k C:\WINDDK\3790~1.183\bin\setenv.bat C:\WINDDK\3790~1.183 fre AMD64 WNET)
#        -and $(cd (Get-Location -PSProvider FileSystem).ProviderPath) -and $(mpbuild all) -and $(exit)
}


#-----------------------------------------------------------------------------
# Save the command history across sessions
#-----------------------------------------------------------------------------
#$MaximumHistoryCount = 1000 
#
#function bye 
#{   Get-History -Count $MaximumHistoryCount |Export-CSV ~\history.csv 
#   exit 
#} 
#
#if (Test-path ~\History.csv) 
#{   Import-CSV ~\History.csv |Add-History 
#} 
#
#
#-----------------------------------------------------------------------------

function reboot 
{
    invoke-expression "shutdown -o -r -t 0"
}

function CheckDriverBinary($driver, $type)
{
    if ($type)  {
        $type = ""
        $x86_PCIE = "$driver\RTLWlanE_WindowsDriver_(WithSymbol)\WinXP_2K\rtwlane$type.sys"
        $x86_USB  = "$driver\RTLWlanU_WindowsDriver_(WithSymbol)\WinXP_2K\rtwlanu$type.sys"
        $x86_SDIO = "$driver\RTLWlanS_WindowsDriver_(WithSymbol)\WinXP_2K\rtwlans$type.sys"
        $x64_PCIE = "$driver\RTLWlanE_WindowsDriver_(WithSymbol)\Win7\X64\rtwlane$type.sys"
        $x64_USB  = "$driver\RTLWlanU_WindowsDriver_(WithSymbol)\Win7\X64\rtwlanu$type.sys"
        $x64_SDIO = "$driver\RTLWlanS_WindowsDriver_(WithSymbol)\Win7\X64\rtwlans$type.sys"
    } else {
        $type = "mp"
        $x86_PCIE = "$driver\RTLWlanE_WindowsDriver_(WithSymbol)\WinXP_2K\rtwlane$type.sys"
        $x86_USB  = "$driver\RTLWlanU_WindowsDriver_(WithSymbol)\WinXP_2K\rtwlanu$type.sys"
        $x86_SDIO = "$driver\RTLWlanS_WindowsDriver_(WithSymbol)\WinXP_2K\rtwlans$type.sys"
        $x64_PCIE = "$driver\RTLWlanE_WindowsDriver_(WithSymbol)\X64\rtwlane$type.sys"
        $x64_USB  = "$driver\RTLWlanU_WindowsDriver_(WithSymbol)\X64\rtwlanu$type.sys"
        $x64_SDIO = "$driver\RTLWlanS_WindowsDriver_(WithSymbol)\X64\rtwlans$type.sys"
    }


    Write-Host $x64_USB
    Write-Host "============"
    if ( (Test-Path $x86_PCIE) ) { Write-Host "PCIE x86: OK" } else { Write-Host "PCIE x86: FAILED" }
    if ( (Test-Path $x86_USB ) ) { Write-Host "USB  x86: OK" } else { Write-Host "USB  x86: FAILED" }
    if ( (Test-Path $x86_SDIO) ) { Write-Host "SDIO x86: OK" } else { Write-Host "SDIO x86: FAILED" }
    Write-Host "============"
    if ( (Test-Path $x64_PCIE) ) { Write-Host "PCIE x64: OK" } else { Write-Host "PCIE x64: FAILED" }
    if ( (Test-Path $x64_USB ) ) { Write-Host "USB  x64: OK" } else { Write-Host "USB  x64: FAILED" }
    if ( (Test-Path $x64_SDIO) ) { Write-Host "SDIO x64: OK" } else { Write-Host "SDIO x64: FAILED" }
    Write-Host "============"
}

function TestBuild 
{
    $driver  = $args[0]

    $build_x86 = 'C:\WINDDK\3790~1.183\bin\setenv.bat C:\WINDDK\3790~1.183 chk WXP && cd '+ $driver + "&& buildcleanall && buildall"
    $build_x64 = 'C:\WINDDK\3790~1.183\bin\setenv.bat C:\WINDDK\3790~1.183 chk AMD64 WNET && cd '+ $driver + "&& buildall"
    $buildWin7_x86 = 'C:\WinDDK\7600.16385.0\bin\setenv.bat C:\WinDDK\7600.16385.0\ chk x86 WIN7 && cd '+ $driver + "&& buildall"
    $buildWin7_x64 = 'C:\WinDDK\7600.16385.0\bin\setenv.bat C:\WinDDK\7600.16385.0\ chk x64 WIN7 && cd '+ $driver + "&& buildall"
    $buildall_x86  = $build_x86     + " && exit"
    $buildall_x64  = $buildWin7_x64 + " && exit"

    C:\Windows\System32\cmd.exe /k $buildall_x86
    C:\Windows\System32\cmd.exe /k $buildall_x64

    CheckDriverBinary $driver "Normal"
}

function ReplaceDriver
{
    & "C:\MassProductionKit\MPTool\MPTool\ReplaceDriver.bat" $args[0]
    if ($LastExitCode -ne 0) {

        throw "Command failed with exit code $LastExitCode."
    } else {
#if (($strResponse = Read-Host "Upload to Server? (Y/N)") -ine "N") {
#                uploadPackage $outDirName
#        }  
    }
}



function MaskEfuse
{
    C:\MassProductionKit\Utility\MaskTheMap\MaskTheMap.exe $args[0] $args[1]
}

function RevBuild
{
    &"C:\Perl64\bin\perl.exe" "C:\MassProductionKit\Utility\RevisionBuild.pl"  $args
}

function ln
{
    cmd /c mklink /H $args
}

function MPListFileModifiedTime
{
    if ($args.length -ne 1) {
        Write-Host "ml [8188E|8723B|...]"
        return
    }

    $mpm = "C:\MassProductionKit\MPPackageManager\Configuration"
    $ic  = $args[0]
    $folders = @();
    $folders += "$mpm\$ic\PCIE\MapFiles"
    $folders += "$mpm\$ic\USB\MapFiles"
    $folders += "$mpm\$ic\SDIO\MapFiles"
    $folders += "$mpm\$ic\Common\MpDriver\X86"

    foreach ($folder in $folders)
    {
        if (Test-Path  $folder) {
            foreach ($file in Get-ChildItem -Path $folder) {
                $time = (gi $folder\$file).LastWriteTime.ToString("[yyyy/MM/dd] HH:mm")
                $name = (gi $folder\$file).Name.ToString();
                $path = (gi $folder\$file).Directory.ToString().Replace($mpm, "`$MP\Configuration");
                Write-Host $time -> $path\$name
            }
        }
    }

    $files = @();
    $files += "$mpm\$ic\Common\MpUtility\BT\patch.bin"
    $files += "$mpm\$ic\Common\MpUtility\BT\RTK_BT_MP_8761a.exe"
    $files += "$mpm\$ic\Common\MpUtility\BT\RTK_BT_MP_8723b.exe"
    $files += "$mpm\$ic\Common\MpUtility\BT\RTK_BT_MP_8821a.exe"
    $files += "$mpm\$ic\Common\DLL\mp8723xBT_8761a.dll"
    $files += "$mpm\$ic\Common\DLL\mp8723xBT_8723b.dll"
    $files += "$mpm\$ic\Common\DLL\mp8723xBT_8821a.dll"
    foreach ($file in $files)
    {
        if (Test-Path  $file) {
            $time = (gi $file).LastWriteTime.ToString("[yyyy/MM/dd] HH:mm")
            $name = (gi $file).Name.ToString();
            Write-Host $time -> $file.ToString().Replace($mpm, "`$MP\Configuration");
        }
    }
}

Import-Module C:\Users\Kordan\Documents\WindowsPowerShell\MarkdownSharp.dll
function Markdown-ToHtml($item, 
                         $AutoHyperlink = $False,
                         $AutoNewLines = $False,
                         $LinkEmails = $False,
                         $EncodeProblemUrlCharacters = $False)
{
  $css = "C:\Users\Kordan\Documents\WindowsPowerShell\Markdown.css"

  $mo = New-Object MarkdownSharp.MarkdownOptions
  $mo.AutoHyperlink               = $AutoHyperlink
  $mo.AutoNewLines                = $AutoNewLines
  $mo.LinkEmails                  = $LinkEmails
  $mo.EncodeProblemUrlCharacters  = $EncodeProblemUrlCharacters
  $m = New-Object MarkdownSharp.Markdown($mo)
  $toTransform = ""
  if (($item.GetType().Name -eq "FileInfo") -or (Test-Path $item -ErrorAction SilentlyContinue)) {
    $toTransform = (Get-Content $item)
    $toTransform = [string]::join("`r`n",$toTransform)
  }
  elseif ($item.GetType().Name -eq "String") {
    $toTransform = $item
  }
  else {
    # I don't know what to do with this
  }

  $htmlStart = (Get-Content $css)
  $htmlEnd = "</body></html>"

  return $htmlStart + $m.Transform($toTransform) + $htmlEnd
}

function tgit
{
    & "C:\Program Files\TortoiseGit\bin\TortoiseGitProc.exe" /command:$Args /path:.
}

function Win8Inf2Cat
{
    $inf_dir = $args[0]
    & "C:\Program Files (x86)\Windows Kits\8.1\bin\x64\inf2cat.exe" /driver:$inf_dir /os:8_X64
}

function notify
{
    $ic = $args[0]
    $interface = $args[1]
    $to = if ([string]::IsNullOrEmpty($args[2])) { "kordan" } else { $args[2] }

    $release = "172.21.72.3:9000/ReleaseNotes/"
    $passwd = (cat "C:\Users\Kordan\Documents\WindowsPowerShell\temp") 
    $body +="<pre>
        The <B>$ic $interface</B> MP Kit is released, please check out 
        the following <a href=`"$release`">release note</a> and download it from the url.

        \\172.21.72.2\rtl$ic\$interface\MP
        [Username]: <I>cnfae</I>
        [Passwd]:   <I>rtfae!123</I>
        </pre>"
    $body += (cat "C:\MassProductionKit\MPPackageManager\Configuration\$ic\$interface\Doc\Release.html")
    Send-EMail -To $to -Subject "Release $ic $interface MP Kit" -Body "$body" -password $passwd
}

set-alias open explorer
set-alias vi vim
Set-Alias -name 'win8sign'      -value 'Win8Inf2Cat'
Set-Alias -name 'ddk'           -value 'DDKEnvSet'
Set-Alias -name 'cwd'           -value 'Push-Location'
Set-Alias -name 'cwd'           -value 'Push-Location'
Set-Alias -name 'cds'           -value 'Set-NewLocation'
Set-Alias -name 'cdl'           -value 'List-Stack'
Set-Alias -name 'rpd'           -value 'ReplaceDriver'
Set-Alias -name 'mask'          -value 'MaskEfuse'
Set-Alias -name 'gg'            -value 'gvim'
Set-Alias -name 'md2html'       -value 'Markdown-ToHtml'
Set-Alias -name 'ml'            -value 'MPListFileModifiedTime'

Remove-Item alias:ls 
Set-Alias cd  C:\Users\Kordan\Documents\WindowsPowerShell\Change-Directory.ps1
Set-Alias mpm C:\MassProductionKit\MPPackageManager\MPManager.ps1

$global:TRUNK = "C:\WLAN\Trunk.git"
$global:IMG = "C:\MassProductionKit\Image2Header"
$global:POWERSH = "C:\Users\Kordan\Documents\WindowsPowerShell"
$global:RTK = "C:\WLAN"
$global:MP = "C:\MassProductionKit\MPPackageManager"
$global:UTL = "C:\MassProductionKit\Utility"


Import-Module SendMailSMTP

chcp 950
cd $TRUNK
