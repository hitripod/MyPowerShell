$version = $args[0]

if ($version -eq "v2") {
    (git push gerrit MP_v2.X:refs/heads/MP_v2.X)
} elseif ($version -eq "v3") {
    (git push gerrit MP_v3.X:refs/heads/MP_v3.X)
}
#(git push gerrit RTWLANE:refs/heads/RTWLANE) -or
#(git push gerrit RTWLANU:refs/heads/RTWLANU) -or
#(git push gerrit RTWLANS:refs/heads/RTWLANS) -or
(git push gerrit master:refs/heads/master) -or
(git push gerrit --tags)
