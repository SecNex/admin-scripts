$global_catalog = Get-ADDomainController -Discover -Service GlobalCatalog

$server = "$($global_catalog.Name):3268"

$group = ""

$csv_file = "$($group) ($(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss')).csv"

try {
    $ad_group = Get-ADGroup -Filter 'Name -eq $group -and GroupScope -eq "DomainLocal" -and GroupCategory -eq "Security"' -Server $server -Properties Member -ErrorAction Stop
    $group_members = $ad_group.Member
    $group_members | Export-Csv -Path $csv_file -NoTypeInformation
} catch {
    Write-Error "Group $group not found"
    exit 1
}


