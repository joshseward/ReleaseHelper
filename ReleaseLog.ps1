$AppSettings = Get-Content '.\appSettings.Json' | Out-String | ConvertFrom-Json

$Projects = $AppSettings.Projects
$UserName = $AppSettings.UserName
$Password = $AppSettings.Password
$Email = $AppSettings.Email
$TARGETDIR = $AppSettings.TargetDir
$Token = $AppSettings.Token

$lastReleaseNumber = Read-Host -Prompt "Please enter last release number e.g 3.34.0"
$GithubUrl = "https://${Token}@github.com/${ProfileName}/"

$originPath = Get-Location

Set-Location -Path "C:\"

if(Test-Path -Path $TARGETDIR)
{
    Remove-Item -Path $TARGETDIR\* -Recurse -Force
    Remove-Item -Path $TARGETDIR -Recurse -Force
}

$FilePath = 'C:\temp\ReleaseLog.txt'

if (Test-Path $FilePath) {
  Remove-Item $FilePath
}

New-Item -Name "ReleaseFolder" -ItemType "directory"

New-Item -Path $FilePath -ItemType File

foreach($project in $projects)
{
    Set-Location -Path $TARGETDIR

    Write-Host "Current Project $project"

    New-Item -Name ${project} -ItemType "directory"

    Add-Content C:\temp\ReleaseLog.txt "$project`n"

    Set-Location -Path "${TARGETDIR}\${project}"

    git init
    git config user.name $UserName
    git config user.email $Email

    git clone "${GithubUrl}${project}.git"

    Set-Location -Path ${project}

    #Pull the repo will be default branch
    git pull "${GithubUrl}${project}.git"
    
    #Get release config and checkout correct branch we want
    $ReleaseConfig = Get-Content '.\ReleaseConfig.Json' | Out-String | ConvertFrom-Json 
    Write-Host $ReleaseConfig.CheckOutBranch
    git checkout $ReleaseConfig.CheckOutBranch

    $today = Get-Date -Format "yyyy-MM-dd"
    
    $log = (git log "$lastReleaseNumber...HEAD" --pretty=format:'Date:%ad Subject:%s Author:%an %d %n') -join "`n"

    Add-Content C:\temp\ReleaseLog.txt "$log`n"
}

Set-Location -Path $originPath

Write-Host "All Done Time To Clean Up"

if(Test-Path -Path $TARGETDIR)
{
    Remove-Item -Path $TARGETDIR\* -Recurse -Force
    Remove-Item -Path $TARGETDIR -Recurse -Force
}

Write-Host "All Clean"
