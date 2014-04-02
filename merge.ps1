function merge($rc) {
    cd C:\WLAN\Trunk.git
    $branch = "MP_v2.X"
    if ($rc -like 'rc-v2*') {
        $branch = "MP_v2.X"
    } elseif ($rc -like 'rc-v3*') {
        $branch = "MP_v3.X"
    } else {
        Write-Host "RC branch($rc) is not found."
        return
    }
    (git co $branch) -or
    (git merge --no-ff $rc) -and
    (git branch -d $rc)
}
merge $args[0]
