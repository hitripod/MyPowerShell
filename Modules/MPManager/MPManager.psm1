#####################################################################################
#.SYNOPSIS
# An integrated CLI tool for more easily UPDATE/BUILD/PACK MP Kit. 
#
#.DESCRIPTION
# To maintain consistency with New-Object this cmdlet requires the -ComObject
# parameter to be provided and the TypeName parameter is not supported.
#
#.PARAMETER c
#       The chip series to work on.
#.PARAMETER d
#       If the driver is not built from the IC folder, specify the folder name.
#.PARAMETER t
#       The chip interface to work on.
#.PARAMETER v
#       The version which is being packaged.
#.PARAMETER a
#       The action to take on: [build|pack|clean].
#.PARAMETER b
#       "Release" or "Checked"
#
#.NOTES
# Author  : Kordan Ou
# Date    : Nov 12, 2012
#
#.EXAMPLE
#mpm -a build -c 8723A 
#[8723A Release buildall] 
#mpm -a build -c 8811A -d Trunk
#[8811AU customized version built from Trunk.git]
#
#.EXAMPLE
#mpm -c 8723A -v "01 02 03"
#[8723A Package ALL]
#
#.EXAMPLE
#mpm -v 23
#[8723A Package Single]
#
#.EXAMPLE
#mpm -a clean
# [8723A Clean MP_Kit_*] 
#####################################################################################

$ROOT = "C:\MassProductionKit\MPPackageManager\"
$CODE = "C:\WLAN\" 
$WINRAR = 'C:\Program` Files\WinRAR\winrar.exe'
$DDK3790 = "C:\WINDDK\3790~1.183"
$TRUNKNAME = "Trunk.git"
$configDir = $ROOT + "Configuration"
$contentDir = $ROOT + "Content\"
$updateDir = $ROOT + "ToBeUpdated\"

function Win8Inf2Cat
{
    $inf_dir = $args[0]
    & "C:\Program Files (x86)\Windows Kits\8.0\bin\x64\inf2cat.exe" /driver:$inf_dir /os:8_X64
}
Set-Alias -name 'win8sign'      -value 'Win8Inf2Cat'

function isNumeric ($x) 
{
    $x2 = 0
    $isNum = [System.Int32]::TryParse($x, [ref]$x2)
    return $isNum
}

function archivedWithVersion ([string]$name, [string]$version) 
{
    $opt_level = 3
    $archive = $name+"_v"+$version
    Invoke-Expression -Command "$winrar a -afzip -ag_yyyyMMdd -m$opt_level -ed .\$archive.zip .\$name"
}

function outputByConfiguration ([string]$icName, [string]$interface, [string]$protocol) 
{
    $src        = $configDir + "\" + $c + "\" + $interface
    $outDirName = "MP_Kit_RTL" + $protocol + "_" + $icName + "_" + $interface

    if ( ! (Test-Path $ROOT$outDirName) ) { 
        mkdir $ROOT$outDirName | out-null
    }

    cp -r -force $contentDir\* $ROOT$outDirName
    $srcCommon  = $configDir + "\" + $c + "\Common\"
    cp -r -force $srcCommon\* $ROOT$outDirName

    cp -r -force $src\* $ROOT$outDirName

    md2html $src\Doc\Release.txt > $src\Doc\Release.html
    md2html $src\Doc\Release.txt > $outDirName\Doc\Release.html
    del $src\Doc\Release.txt
    del $outDirName\Doc\Release.txt

    return $outDirName
}

function printICList
{
    Write-Host "------------"
    foreach ($ic in @(ls $configDir))
    {
        $interfaceDir = $configDir + "\" + $ic
        foreach ($interface in @(ls $interfaceDir)) {
            [string]$out = $i
            if ($interface -eq "PCIE") {
                $i++
                $icList += @([string]$i + ". " + $ic + "E")
            } elseif ($interface -eq "USB") {
                $i++
                $icList += @([string]$i + ". " + $ic + "U")
            } elseif ($interface -eq "SDIO") {
                $i++
                $icList += @([string]$i + ". " + $ic + "S")
            } elseif ($interface -eq "Common") {
                continue
            }
            $j = $i - 1
            Write-Host $icList[$j]
        }
        Write-Host "------------"
    }
    return $icList
}

function UpdateFiles ([string]$icSeries)
{
    if (($strResponse = Read-Host "Need to sign the driver? (Y/N)") -ieq "Y") {
        $signDir =$ROOT + "ToBeUpdated\" + $icSeries 
        $sign = $ROOT + "ToBeUpdated\" + $icSeries +"\sign.bat"
        cd  $signDir
        & $sign
        cd  $ROOT

        C:\Users\Kordan\Desktop\SignDriver.skl 
        echo "Press any key to continue..."
        cmd /c pause | out-null           
    }

    $updateDir =$ROOT + "ToBeUpdated\" + $icSeries 
    $update = $ROOT + "ToBeUpdated\" + $icSeries +"\Update.bat"
    cd  $updateDir
    & $update
    cd  $ROOT

}

function uploadPackage
{
    if ($c -ieq "8811A" -and $t -ieq "U") {
        cp -v $ROOT`MP_Kit_RTL11*$c*`_PCIE_*.zip  \\172.21.72.2\rtl8821a\PCIE\MP
        cp -v $ROOT`MP_Kit_RTL11*$c*`_USB*.zip    \\172.21.72.2\rtl8821a\USB\MP
        cp -v $ROOT`MP_Kit_RTL11*$c*`_SDIO_*.zip  \\172.21.72.2\rtl8821a\SDIO\MP
        mv -v $ROOT`MP_Kit_RTL11*$c*`_PCIE_*.zip  $ROOT`Uploaded
        mv -v $ROOT`MP_Kit_RTL11*$c*`_USB*.zip    $ROOT`Uploaded
        mv -v $ROOT`MP_Kit_RTL11*$c*`_SDIO_*.zip  $ROOT`Uploaded
        cp $configDir\$c\USB\Doc\Release.html     \\172.21.72.3\mp\Configuration\$c\USB\Doc\Release.html
        return
    }
    cp -v $ROOT`MP_Kit_RTL11*$c*`_PCIE_*.zip  \\172.21.72.2\rtl$c\PCIE\MP
    cp -v $ROOT`MP_Kit_RTL11*$c*`_USB*.zip    \\172.21.72.2\rtl$c\USB\MP
    cp -v $ROOT`MP_Kit_RTL11*$c*`_SDIO_*.zip  \\172.21.72.2\rtl$c\SDIO\MP
    mv -v $ROOT`MP_Kit_RTL11*$c*`_PCIE_*.zip  $ROOT`Uploaded
    mv -v $ROOT`MP_Kit_RTL11*$c*`_USB*.zip    $ROOT`Uploaded
    mv -v $ROOT`MP_Kit_RTL11*$c*`_SDIO_*.zip  $ROOT`Uploaded

    # Update the server info of ReleaseNotes 
    cp $configDir\$c\PCIE\Doc\Release.html \\172.21.72.3\mp\Configuration\$c\PCIE\Doc\Release.html
    cp $configDir\$c\USB\Doc\Release.html  \\172.21.72.3\mp\Configuration\$c\USB\Doc\Release.html
    cp $configDir\$c\SDIO\Doc\Release.html \\172.21.72.3\mp\Configuration\$c\SDIO\Doc\Release.html
}

function deletePhyFolders
{
    if ($v.split(" ").Length -eq 1) {
        mv $outDirName/MpDriver/X64 $outDirName
        mv $outDirName/MpDriver/X86 $outDirName
        rm -r $outDirName/MpDriver/*
        mv $outDirName/X64 $outDirName/MpDriver/
        mv $outDirName/X86 $outDirName/MpDriver/
    } else {
        mv $outDirName_E/MpDriver/X64 $outDirName_E
        mv $outDirName_E/MpDriver/X86 $outDirName_E
        rm -r $outDirName_E/MpDriver/*
        mv $outDirName_E/X64 $outDirName_E/MpDriver/
        mv $outDirName_E/X86 $outDirName_E/MpDriver/

        mv $outDirName_U/MpDriver/X64 $outDirName_U
        mv $outDirName_U/MpDriver/X86 $outDirName_U
        rm -r $outDirName_U/MpDriver/*
        mv $outDirName_U/X64 $outDirName_U/MpDriver/
        mv $outDirName_U/X86 $outDirName_U/MpDriver/

        mv $outDirName_S/MpDriver/X64 $outDirName_S
        mv $outDirName_S/MpDriver/X86 $outDirName_S
        rm -r $outDirName_S/MpDriver/*
        mv $outDirName_S/X64 $outDirName_S/MpDriver/
        mv $outDirName_S/X86 $outDirName_S/MpDriver/
    }
}

function PackMP
{
    if ($v.split(" ").Length -ne 3) 
    {
        $i = 0;
        $icList = printICList 
        
        do {$strResponse = Read-Host "Select a IC to package:"}
        until (isNumeric($strResponse))
        
        $ic = $icList[([int]$strResponse)-1].split(" ")[1]
        $c = $ic.Substring(0, 5)
        $t = $ic.Substring(5, 1)
        
        Write-Host "[$c $t] is selected."

        if ($v -eq "000") { $v = Read-Host "Enter the version number:" }
    }
    

    $outDirName = ""
    $bContinue = "Y"
    $protocol = "11n"
    $interface_E = "PCIE"
    $interface_U = "USB"
    $interface_S = "SDIO"
    ####################################################################################
    if ($c -eq "8723A") {
        $ic_E = "8723AE"; $ic_U = "8723AU"; $ic_S = "8723AS";
    }
    ####################################################################################
    elseif ($c -eq "8723B") {
        $ic_E = "8723BE"; $ic_U = "8723BU"; $ic_S = "8723BS";
    }
    ####################################################################################
    elseif ($c -eq "8188E") {
        $ic_E = "8188EE"; $ic_U = "8188EUS"; $ic_S = "8189ES";
    }
    ####################################################################################
    elseif ($c -eq "8812A") {
        $protocol = "11ac"
        $ic_E = "8812AE"; $ic_U = "8812AU"; $ic_S = "8812AS";
    }
    ####################################################################################
    elseif ($c -eq "8821A") {
        $protocol = "11ac"
        $ic_E = "8821AE"; $ic_U = "8821AU"; $ic_S = "8821AS";
    }
    ####################################################################################
    elseif ($c -eq "8811A") {
        $protocol = "11ac"
        $ic_E = "8811AE"; $ic_U = "8811AU"; $ic_S = "8811AS";
    }
    ####################################################################################
    elseif ($c -eq "8192E") {
        $protocol = "11n"
        $ic_E = "8192EE"; $ic_U = "8192EU"; $ic_S = "8192ES";
    }
    ####################################################################################


    if ($v.split(" ").Length -eq 3) {
        # Otherwise, $outDirName would be overridded when "mkdir" executed.
        $outDirName_E = "MP_Kit_RTL" + $protocol + "_" + $ic_E + "_" + $interface_E
        $outDirName_U = "MP_Kit_RTL" + $protocol + "_" + $ic_U + "_" + $interface_U
        $outDirName_S = "MP_Kit_RTL" + $protocol + "_" + $ic_S + "_" + $interface_S
        UpdateFiles $c
        outputByConfiguration $ic_E $interface_E $protocol
        outputByConfiguration $ic_U $interface_U $protocol
        outputByConfiguration $ic_S $interface_S $protocol
        # Otherwise, $outDirName would be overridded when "mkdir" executed.
        $outDirName_E = "MP_Kit_RTL" + $protocol + "_" + $ic_E + "_" + $interface_E
        $outDirName_U = "MP_Kit_RTL" + $protocol + "_" + $ic_U + "_" + $interface_U
        $outDirName_S = "MP_Kit_RTL" + $protocol + "_" + $ic_S + "_" + $interface_S

        if (($strResponse = Read-Host "Delete the folder of PHY parameters? (Y/N)") -ine "N") {
            deletePhyFolders
        }

        if (($strResponse = Read-Host "Continue to Archive? (Y/N)") -ine "N") {
            archivedWithVersion $outDirName_E $v.split(" ")[0] 
            archivedWithVersion $outDirName_U $v.split(" ")[1] 
            archivedWithVersion $outDirName_S $v.split(" ")[2] 
            if (($strResponse = Read-Host "Upload to Server? (Y/N)") -ine "N") {
                uploadPackage $outDirName
            }
        }
    } else {
        # Otherwise, $outDirName would be overridded when "mkdir" executed.
        if ($t -ieq "E")     {$outDirName = "MP_Kit_RTL" + $protocol + "_" + $ic_E + "_" + $interface_E}
        elseif ($t -ieq "U") {$outDirName = "MP_Kit_RTL" + $protocol + "_" + $ic_U + "_" + $interface_U}
        elseif ($t -ieq "S") {$outDirName = "MP_Kit_RTL" + $protocol + "_" + $ic_S + "_" + $interface_S}
        UpdateFiles $c
        if ($t -ieq "E")     { outputByConfiguration $ic_E $interface_E $protocol }
        elseif ($t -ieq "U") { outputByConfiguration $ic_U $interface_U $protocol }
        elseif ($t -ieq "S") { outputByConfiguration $ic_S $interface_S $protocol }
        # Otherwise, $outDirName would be overridded when "mkdir" executed.
        if ($t -ieq "E")     {$outDirName = "MP_Kit_RTL" + $protocol + "_" + $ic_E + "_" + $interface_E}
        elseif ($t -ieq "U") {$outDirName = "MP_Kit_RTL" + $protocol + "_" + $ic_U + "_" + $interface_U}
        elseif ($t -ieq "S") {$outDirName = "MP_Kit_RTL" + $protocol + "_" + $ic_S + "_" + $interface_S}

        if (($strResponse = Read-Host "Delete the folder of PHY parameters? (Y/N)") -ine "N") {
            deletePhyFolders
        }

        if (($strResponse = Read-Host "Continue to Archive? (Y/N)") -ine "N") {
            archivedWithVersion $outDirName $v 
            if (($strResponse = Read-Host "Upload to Server? (Y/N)") -ine "N") {
                uploadPackage $outDirName
            }
        }
    }
        
}

function BuildMP
{
    if ($d -ieq "Trunk") 
    { 
        $driver  = $CODE + $TRUNKNAME
        $branch    = "MP_v2.X"
        #$branchU    = "RTWLANU"
        #$branchS    = "RTWLANS"

        $build_x86 = 'C:\WINDDK\3790~1.183\bin\setenv.bat C:\WINDDK\3790~1.183 fre WXP && cd '+ $driver + "&& git co $branch && buildcleanall && mpbuild e"
        $build_x64 = 'C:\WINDDK\3790~1.183\bin\setenv.bat C:\WINDDK\3790~1.183 fre AMD64 WNET && cd '+ $driver + "&& mpbuild e"
        $buildall_x86  = $build_x86 + " && exit"
        $buildall_x64  = $build_x64 + " && exit"
        C:\Windows\System32\cmd.exe /k $buildall_x86
        C:\Windows\System32\cmd.exe /k $buildall_x64

        $build_x86 = 'C:\WINDDK\3790~1.183\bin\setenv.bat C:\WINDDK\3790~1.183 fre WXP && cd '+ $driver + "&& mpbuild u"
        $build_x64 = 'C:\WINDDK\3790~1.183\bin\setenv.bat C:\WINDDK\3790~1.183 fre AMD64 WNET && cd '+ $driver + "&& mpbuild u"
        $buildall_x86  = $build_x86 + " && exit"
        $buildall_x64  = $build_x64 + " && exit"
        C:\Windows\System32\cmd.exe /k $buildall_x86
        C:\Windows\System32\cmd.exe /k $buildall_x64

        $build_x86 = 'C:\WINDDK\3790~1.183\bin\setenv.bat C:\WINDDK\3790~1.183 fre WXP && cd '+ $driver + "&& mpbuild s"
        $build_x64 = 'C:\WINDDK\3790~1.183\bin\setenv.bat C:\WINDDK\3790~1.183 fre AMD64 WNET && cd '+ $driver + "&& mpbuild s"
        $buildall_x86  = $build_x86 + " && exit"
        $buildall_x64  = $build_x64 + " && exit"
        C:\Windows\System32\cmd.exe /k $buildall_x86
        C:\Windows\System32\cmd.exe /k $buildall_x64
    } 
    else 
    {
        if ($d -ine "NotTrunk") 
        { 
            Write-Host "Invalid source directory to build driver!" 
            return
        } 
        elseif ($c -ieq "8723A") 
        { 
            if ($b -ieq "Release") {
                $driver  = $CODE + "MP_Driver_8723AS"  
                $build_x86 = "$DDK3790\bin\setenv.bat"+' C:\WINDDK\3790~1.183 fre WXP && cd '+ $driver + "&& buildcleanall && mpbuildrtwe && mpbuildrtws"
                $build_x64 = "$DDK3790\bin\setenv.bat"+' C:\WINDDK\3790~1.183 fre AMD64 WNET && cd '+ $driver + "&& mpbuildrtwe && mpbuildrtws"
                $buildall  = $build_x86 + " && " + $build_x64 + " && exit"
                C:\Windows\System32\cmd.exe /k $buildall

                $driver  = $CODE + "MP_Driver_8723A"
                $build_x86 = "$DDK3790\bin\setenv.bat"+' C:\WINDDK\3790~1.183 fre WXP && cd '+ $driver + "&& buildcleanall && mpbuildrtwe && mpbuildrtwu"
                $build_x64 = "$DDK3790\bin\setenv.bat"+' C:\WINDDK\3790~1.183 fre AMD64 WNET && cd '+ $driver + "&& mpbuildrtwe && mpbuildrtwu"
                $buildall  = $build_x86 + " && " + $build_x64 + " && exit"
                C:\Windows\System32\cmd.exe /k $buildall
            } else {
                $driver  = $CODE + "MP_Driver_8723AS"
                $build_x86 = "$DDK3790\bin\setenv.bat"+' C:\WINDDK\3790~1.183 chk WXP && cd '+ $driver + "&& buildcleanall && mpbuildrtwe && mpbuildrtws"
                $build_x64 = "$DDK3790\bin\setenv.bat"+' C:\WINDDK\3790~1.183 chk AMD64 WNET && cd '+ $driver + "&& mpbuildrtwe && mpbuildrtws"
                $buildall  = $build_x86 + " && " + $build_x64 + " && exit"
                C:\Windows\System32\cmd.exe /k $buildall

                $driver  = $CODE + "MP_Driver_8723A"
                $build_x86 = "$DDK3790\bin\setenv.bat"+' C:\WINDDK\3790~1.183 chk WXP && cd '+ $driver + "&& buildcleanall && mpbuildrtwe && mpbuildrtwu"
                $build_x64 = "$DDK3790\bin\setenv.bat"+' C:\WINDDK\3790~1.183 chk AMD64 WNET && cd '+ $driver + "&& mpbuildrtwe && mpbuildrtwu"
                $buildall  = $build_x86 + " && " + $build_x64 + " && exit"
                C:\Windows\System32\cmd.exe /k $buildall
            }
            $sys_out = @()
            $sys_out  += $CODE + "MP_Driver_8723AS\RTLWlanSmp_WindowsDriver_(WithSymbol)"  
            $sys_out  += $CODE + "MP_Driver_8723A\RTLWlanEmp_WindowsDriver_(WithSymbol)"  
            $sys_out  += $CODE + "MP_Driver_8723A\RTLWlanUmp_WindowsDriver_(WithSymbol)"  
            foreach ($sys in $sys_out) {
                cp -r -force $sys_out $updateDir$c
            }
            open $updateDir$c

            return
            
        } elseif ($c -ieq "8811A") {
            $driver  = $CODE + "MP_Driver_8821A"

        } else {
            $driver  = $CODE + "MP_Driver_$c"
        }

        if ($b -ieq "Release") {
            $build_x86 = "$DDK3790\bin\setenv.bat"+' C:\WINDDK\3790~1.183 fre WXP && cd '+ $driver + "&& buildcleanall && mpbuild all"
            $build_x64 = "$DDK3790\bin\setenv.bat"+' C:\WINDDK\3790~1.183 fre AMD64 WNET && cd '+ $driver + "&& mpbuild all"
        } else {
            $build_x86 = "$DDK3790\bin\setenv.bat"+' C:\WINDDK\3790~1.183 chk WXP && cd '+ $driver + "&& buildcleanall && mpbuild all"
            $build_x64 = "$DDK3790\bin\setenv.bat"+' C:\WINDDK\3790~1.183 chk AMD64 WNET && cd '+ $driver + "&& mpbuild all"
        }

        $buildall  = $build_x86 + " && " + $build_x64 + " && exit"
        C:\Windows\System32\cmd.exe /k $buildall
    }

    open $driver
    $sys_out = @()
    $sys_out  += "$driver\RTLWlanE_WindowsDriver_(WithSymbol)"
    $sys_out  += "$driver\RTLWlanU_WindowsDriver_(WithSymbol)"
    $sys_out  += "$driver\RTLWlanS_WindowsDriver_(WithSymbol)"
    foreach ($sys in $sys_out) { cp -r -force $sys_out $updateDir$c }
    open $updateDir$c

    CheckDriverBinary $updateDir$c 
}

function MassProduction 
{
    [string]$c = $Args[0][0]
    [string]$d = $Args[0][1]
    [string]$t = $Args[0][2]
    [string]$v = $Args[0][3]
    [string]$a = $Args[0][4]
    [string]$b = $Args[0][5]

    if ($a -ieq "PACK") {
        PackMP
    } elseif ($a -ieq "BUILD") {
        BuildMP
    } elseif ($a -ieq "CLEAN") {

        rm -r $ROOT\MP_Kit_*
    }
}

