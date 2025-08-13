$global_catalog = Get-ADDomainController -Discover -Service GlobalCatalog

$server = "$($global_catalog.Name):3268"

$groups = @("", "")

$csv_file = "backup_$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').csv"

try {
    foreach ($group in $groups) {
    $ad_group = Get-ADGroup -Filter 'Name -eq $group -and GroupScope -eq "DomainLocal" -and GroupCategory -eq "Security"' -Server $server -Properties Member -ErrorAction Stop
        $csv_export_table = @()
        $ad_group.Member | ForEach-Object {
            try {
                $ad_user = Get-ADUser -Identity $_ -Properties * -Server $server -ErrorAction Stop
                $csv_export_table += [PSCustomObject]@{
                    Group = $group
                    MemberEmail = $ad_user.SamAccountName
                    MemberDistinguishedName = $ad_user.DistinguishedName
                }
            } catch {
                Write-Error "User $group not found and skipped..."
            }
        }
    }
} catch {
    Write-Error "Group $group not found"
    exit 1
}

$csv_export_table | Export-Csv -Path $csv_file -NoTypeInformation