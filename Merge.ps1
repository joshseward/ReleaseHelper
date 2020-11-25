$AppSettings = Get-Content '.\appSettings.Json' | Out-String | ConvertFrom-Json

$Projects = $AppSettings.Projects
$UserName = $AppSettings.UserName
$Password = $AppSettings.Password
$Email = $AppSettings.Email
$TARGETDIR = $AppSettings.TargetDir
$Token = $AppSettings.Token

#ToDo Get From User
$VerisonNumber = Read-Host -Prompt "Please enter Last Version number e.g 2.31.0"
$GithubUrl = "https://${Token}@github.com/${ProfileName}/"

$originPath = Get-Location

Set-Location -Path "C:\"

if(Test-Path -Path $TARGETDIR)
{
    Remove-Item -Path $TARGETDIR\* -Recurse -Force
    Remove-Item -Path $TARGETDIR -Recurse -Force
}

New-Item -Name "ReleaseFolder" -ItemType "directory"

foreach($project in $projects)
{
    Set-Location -Path $TARGETDIR

    Write-Host "Current Project $project"

    New-Item -Name ${project} -ItemType "directory"

    Set-Location -Path $TARGETDIR

    git init
    git config user.name $UserName
    git config user.email $Email

    git clone "${GithubUrl}${project}.git"

	Set-Location -Path ${project}

    #Pull the repo will be default branch
    git pull "${GithubUrl}${project}.git" 

    #Get release config and checkout correct branch we want
    $ReleaseConfig = Get-Content '.\ReleaseConfig.Json' | Out-String | ConvertFrom-Json 

    if($ReleaseConfig.UsingGitFlow)
    {             
        Write-Host "release/release-$VerisonNumber"
        git checkout "release/release-$VerisonNumber"
    
        #-----------Force Push Master------------#
        git push origin +"release/release-$VerisonNumber":$ReleaseConfig.ForcePushBranch --force 

        hub pull-request -b develop -h release/release-$VerisonNumber -m "Merge Back to develop from release/release-$VerisonNumber"
    }
}

Set-Location -Path $originPath

Write-Host "All Done Time To Clean Up"

if(Test-Path -Path $TARGETDIR)
{
    Remove-Item -Path $TARGETDIR\* -Recurse -Force
    Remove-Item -Path $TARGETDIR -Recurse -Force
}

Write-Host "All Clean"
