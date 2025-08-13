[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$global_catalog = Get-ADDomainController -Discover -Service GlobalCatalog

$server = "$($global_catalog.Name):3268"

$groups = @("", "")

$csv_file = "backup_$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').csv"

$csv_export_table = @()

foreach ($group in $groups) {
    try {
        $ad_group = Get-ADGroup -Filter 'Name -eq $group -and GroupScope -eq "DomainLocal" -and GroupCategory -eq "Security"' -Server $server -Properties Member -ErrorAction Stop
        
        if ($ad_group.Member) {
            $ad_group.Member | ForEach-Object {
                try {
                    $ad_user = Get-ADUser -Identity $_ -Properties * -Server $server -ErrorAction Stop
                    $csv_export_table += [PSCustomObject]@{
                        Group = $group
                        MemberEmail = $ad_user.SamAccountName
                        MemberDistinguishedName = $ad_user.DistinguishedName
                    }
                } catch {
                    Write-Warning "User $_ not found in group $group - skipping..."
                }
            }
        } else {
            Write-Warning "Group $group has no members"
        }
    } catch {
        Write-Warning "Group $group not found - skipping..."
    }
}

if ($csv_export_table.Count -gt 0) {
    $csv_export_table | Export-Csv -Path $csv_file -NoTypeInformation -Encoding UTF8
    Write-Host "Backup completed successfully. Exported $($csv_export_table.Count) members to $csv_file"
} else {
    Write-Warning "No members found to export"
}