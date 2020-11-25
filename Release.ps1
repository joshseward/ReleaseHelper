$AppSettings = Get-Content '.\appSettings.Json' | Out-String | ConvertFrom-Json

$Projects = $AppSettings.Projects
$UserName = $AppSettings.UserName
$Email = $AppSettings.Email
$TARGETDIR = $AppSettings.TargetDir
$Token = $AppSettings.Token
$ProfileName = $AppSettings.ProfileName


$VerisonNumber = Read-Host -Prompt "Please enter Version number e.g 1.20.0"
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

    #-----------Tag Branch------------#
    git tag -a $VerisonNumber -m "Release $VersionNumber Cut"
    git push origin $VerisonNumber

    Write-Host "release/release-$VerisonNumber"
    git checkout $ReleaseConfig.CheckOutBranch -b "release/release-$VerisonNumber"

    #-----------Get Package Json------------#
    $packageJosnPath = ".\" + $ReleaseConfig.PackageJsonPath
    $packageJson = Get-Content $packageJosnPath | ConvertFrom-Json
    
    #-----------Update Version Number------------#
    Write-Host "Changing Package version From $($packageJson.version) to $($VerisonNumber)"
    $CommitMessage = "Release Script Cutting and Updating version Number from $($packageJson.version) to $($VerisonNumber)"

    $packageJson.version = $VerisonNumber
    $newPackageJsonConfig = ConvertTo-Json -InputObject $packageJson -Depth 10
    
    Write-Host "New PackageJson $newPackageJsonConfig"
    Set-Content -Path $packageJosnPath -Value $newPackageJsonConfig

    #-----------Commit To Repo------------#
    git add -A
    git commit -m  $CommitMessage
    #git log --pretty="%H %an <%ae>"
    git push ${GithubUrl}${project}.git

    if(!$ReleaseConfig.UsingGitFlow)
    {
        hub pull-request -b $ReleaseConfig.CheckOutBranch -h release/release-$VerisonNumber -m "Version Number Bump"
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
