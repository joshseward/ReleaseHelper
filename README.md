# ReleaseHelper
The Release helper is a group of PowerShell scripts that will help your CI release process, if you have multpile repositories that all need release branches created at the same time then this should be able to help. The Project Consists of a ReleaseLog.ps1, Release.ps1 and Merge.ps1 

## How it works
Each script will ask you for either the next release number or the previous release number to either create or idenity the release branch. All the configuration is set inside of an appsetting.json file.

### ReleaseLog
This script will go through each project getting the release br
