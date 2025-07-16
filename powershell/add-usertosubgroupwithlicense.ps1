$user_name = "User" # Is the name of the user to add to the license and application group
$application_group_name = "Application Group" # Is the name of security group which assigned application to user
$domain = "secnex.local" # Is required for Add-ADGroupMember to work

# Get the global catalog server
Write-Host "🚀 Getting global catalog server..."
$global_catelog = Get-ADDomainController -Discover -Service GlobalCatalog

# Get the license groups
$license_groups = @{
    "E3" = "Subgroup E3"
    "F3" = "Subgroup F3"
}

# Get the application group
Write-Host "🔎 Getting application group $($application_group_name)..."
$application_group = Get-ADGroup -Filter 'GroupCategory -eq "Security" -and GroupScope -eq "DomainLocal" -and Name -eq $application_group_name' -Server $global_catelog -Properties Member

# Get the user
Write-Host "🔎 Getting user $($user_name)..."
$user = Get-ADUser -Identity $user_name -Server $global_catelog

# Check if user is member of license group
$match = $false
foreach ($license_group in $license_groups.Keys) {
    Write-Host "🔎 Checking if user $($user.Name) is member of license group $($license_group)..."
    # Get the license group
    $license_group_name = $license_groups[$license_group]
    # Get the license group with properties
    $license_group = Get-ADGroup -Filter 'GroupCategory -eq "Security" -and GroupScope -eq "DomainLocal" -and Name -eq $license_group_name' -Server $global_catelog -Properties Member
    # Check if user is member of license group
    if ($license_group.Member -contains $user.DistinguishedName) {
        Write-Host "✅ User $($user.Name) is a member of license group $($license_group.Name)!"
        $match = $true
        break
    } else {
        Write-Host "❌ User $($user.Name) is not a member of license group $($license_group.Name)!"
    } 
}

# Check if user is member of application group
if ($match) {
    Write-Host "✅ User $($user.Name) is already a member of the license group!"

    # Check if user is member of application group
    if ($application_group.Member -contains $user.DistinguishedName) {
        Write-Host "✅ User $($user.Name) is already a member of the application group $($application_group.Name)"
    } else {
        Write-Host "❌ User $($user.Name) is not a member of the application group $($application_group.Name)! Adding user to application group..."
        Add-ADGroupMember -Identity $application_group -Members $user -Confirm:$false -Server $domain
        Write-Host "✅ User $($user.Name) added to application group $($application_group.Name)"
    }
} else {
    Write-Host "❌ User $($user.Name) is not a member of any license group! Please assign license to user manually."
}