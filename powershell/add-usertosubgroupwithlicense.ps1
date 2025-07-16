$dn = "DC=secnex,DC=local"
# Object with all license and sub groups
$license_groups = @{
    "E3" = "Subgroup E3"
    "F3" = "Subgroup F3"
}
$application_group = "Application Group"
$user = "User"

# Check if user is member of one of the license groups
foreach ($license_group in $license_groups.Keys) {
    $user_is_member = Get-ADGroupMember -Identity $license_group -SearchBase $dn -Filter {SamAccountName -eq $user}

    if ($user_is_member) {
        Write-Host "User is already a member of the license group! Adding user to sub group..."    
        Add-ADGroupMember -Identity $license_groups[$license_group] -Members $user -Confirm:$false
    } else {
        Write-Host "User is not a member of the license group!"
    }
}

# Check if user is member of application group
$user_is_member = Get-ADGroupMember -Identity $application_group -SearchBase $dn -Filter {SamAccountName -eq $user}

if ($user_is_member) {
    Write-Host "User is already a member of the application group!"
} else {
    Write-Host "User is not a member of the application group! Adding user to application group..."
}