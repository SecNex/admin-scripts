$dn = "DC=secnex,DC=local"
$license_group = "License Group"
$application_group = "Application Group"
$user = "User"

# Check if user is member of license group (local active directory)
$user_is_member = Get-ADGroupMember -Identity $license_group -SearchBase $dn -Filter {SamAccountName -eq $user}

if ($user_is_member) {
    Write-Host "User is already a member of the license group!"
} else {
    Write-Host "User is not a member of the license group! Adding user to license group..."
    Add-ADGroupMember -Identity $license_group -Members $user -Confirm:$false
}

# Check if user is member of application group (local active directory)
$user_is_member = Get-ADGroupMember -Identity $application_group -SearchBase $dn -Filter {SamAccountName -eq $user}

if ($user_is_member) {
    Write-Host "User is already a member of the application group!"
} else {
    Write-Host "User is not a member of the application group! Adding user to application group..."
    Add-ADGroupMember -Identity $application_group -Members $user -Confirm:$false
}