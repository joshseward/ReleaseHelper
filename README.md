# ReleaseHelper
The Release helper is a group of PowerShell scripts that will help your CI release process, if you have multiple repositories that all need release branches created at the same time then this should be able to help. This is loosely based on a gitflow branch structure but also 
has a section that does not use gitflow
The Project Consists of a ReleaseLog.ps1, Release.ps1 and Merge.ps1

## Prerequisites
Install Hub for PowerShell from https://github.com/github/hub

## How it works
Each script will ask you for either the next release number or the previous release number to either create or identify the release branch. 
All the configuration is set inside of an appsetting.json file. Each project will need to have a release config added to give the scripts some basic information
regarding the project. 

### ReleaseLog
This script will go through each project looking at the provided checkout branch in each release config
and list out the check in's between the last tag named after the provided release number to the present

### Release
This script will go through each project provided and cut a release branch for the given checkout branch
it will also check out the current packag.json file and bump the version number this can be easily removed if not needed

### Merge
This script will force push the current release branch onto the branch specified in the release config per 
project then using hub this will create a pull request to the checkout branch. 
(The Pr is raised due to branch policies on the checkout branch which you may or may not have) 
