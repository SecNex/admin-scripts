$global_catalog = Get-ADDomainController -Discover -Service GlobalCatalog

$server = "$($global_catalog.Name):3268"

$csv_file = "backup_2025-08-13_10-00-00.csv"

$csv_import_table = Import-Csv -Path $csv_file

Write-Host "Restoring $($csv_import_table.Count) members from $csv_file..."

foreach ($row in $csv_import_table) {
    try {
        $ad_user = Get-ADUser -Identity $row.MemberDistinguishedName -Server $server -ErrorAction Stop
        Add-ADGroupMember -Identity $row.Group -Members $ad_user -Server $server -ErrorAction Stop
        Write-Host "Added $($ad_user.SamAccountName) to $($row.Group)!"
    } catch {
        Write-Warning "User $($row.MemberDistinguishedName) not found in group $($row.Group) - skipping..."
    }
}

Write-Host "Restore completed successfully!"