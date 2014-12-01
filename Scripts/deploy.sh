#!/usr/bin/env bash
#
# script to checkout make a build with the code from the current branch you
# are running this script from and upload the build to the internal testing
# location.
#
# Run this script from the Root directory of your project
# 
# author: Jimmy Lu.  Copyright (c) 2014. Hello, Inc.

# exit if any commands fail
set -o errexit

# exit if trying to use undeclared variables
# WE WILL DO OUR OWN CHECKING TO DISPLAY PROPER MESSAGE
# set -o nounset

# show what gets executed
# set -o xtrace

# set up variables
CURRENT_BRANCH=$(git symbolic-ref --short -q HEAD)
VERSION='1.0.0.0'
PLIST='SleepModel/Sense-Info.plist'
SCHEME='Sense'
TF_API_TOKEN=$HELLO_TESTFLIGHT_API_TOKEN
TF_TEAM_TOKEN=$HELLO_TESTFLIGHT_TEAM_TOKEN
TF_URL='https://www.testflightapp.com/dashboard/applications/'

#colors
GREEN='\033[0;32m'
GREY='\033[0;37m'
RED='\033[0;31m'
NONE='\033[0m'

# functions

#
# Intended to print any important information that
# the user should see easily.  Use sparingly so that
# it actually does standout from the rest of the output
#
# accepts 1 argument: the output
#
printImportant() {
    echo -e $GREEN$1$NONE
}

#
# Intended to print progress that indicates what the script
# is currently doing.  There may be a lot of these so these
# ouputs will be of a lighter color
#
# accepts 1 argument: the output
#
printProgress() {
    echo -e $GREY$1$NONE 
}

#
# Intended to print an error
# 
# accepts 1 argument: the error message
#
printError() {
    echo -e $RED$1$NONE
}

#
# Check to see if Shenzhen exists as this script depends on
# it to generate an ipa and distribute to the release portal.
#
# https://github.com/nomad/shenzhen
#
checkShenzhen() {
    if test -e ipa; then
        printImportant 'shenzhen not installed, installing'
        printProgress 'sudo password required'
        sudo gem install shenzhen
    else
        printProgress 'shenzhen already installed, skipping'
    fi
}

checkEnvironment() {
    if [ -z "$TF_API_TOKEN" ]; then
        printError  "HELLO_TESTFLIGHT_API_TOKEN required as env variable"
        exit 1
    fi

    if [ -z "$TF_TEAM_TOKEN" ]; then
        printError "HELLO_TESTFLIGHT_TEAM_TOKEN required as env variable"
        exit 2
    fi
}

#
# Makes sure the current repository is up to date, from origin
# and initialize the version number so that it can be incremented
# 
updateToLatestCode() {
    printProgress 'updating branch'
    git pull origin $CURRENT_BRANCH

    printProgress 'obtaining current build version: '$PLIST
    VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" $PLIST)
    printProgress 'current version: '$VERSION
}

#
# Increment the version (build) number in the project Plist.  It will
# never increment major, minor, or patch.  You must do so yourself!
#
# Bundle Version required format: major.minor.patch.build
#
incVersion() {
    printProgress 'incrementing version'
    VERSION=$(echo $VERSION | awk -F'[.]' {'print $1 "." $2 "." $3 "." $4+1'})
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $VERSION" $PLIST
    printProgress 'incremented version to: '$VERSION
}

#
# Push the plist changes back to origin of the repo and make a tag with
# on the current branch with that version
#
updateRepo() {
    printImportant 'pushing back updated version in plist to '$CURRENT_BRANCH
    local MESSAGE='bumping to version '$VERSION
    git add $PLIST
    git commit -m "$MESSAGE"
    git push origin $CURRENT_BRANCH

    # now tag the repo
    printImportant 'adding a tag: '$VERSION
    local TAG_MESSAGE='automated deployment for '$VERSION
    git tag -a $VERSION -m "$TAG_MESSAGE"
    git push --tag
}

#
# make an ipa using Shenzhen and display the embedded mobile provisioning
# information
# 
build() {
    printImportant 'building with scheme: '$SCHEME
    yes $SCHEME | ipa build --trace
    printProgress 'build information:'
    ipa info
}

#
# Upload to test flight, prompting user for release notes, and then opening
# the browser to testflight to provide permissions and notify
#
uploadToTestFlight() {
    printProgress 'uploading to testflight'
    ipa distribute:testflight -a $TF_API_TOKEN -T $TF_TEAM_TOKEN --trace
    printImportant 'upload succeeded'
    open $TF_URL
}

# script actually starts!
printImportant 'running script for branch: '$CURRENT_BRANCH
checkEnvironment
checkShenzhen
updateToLatestCode
incVersion
build
uploadToTestFlight
updateRepo
printImportant 'done!'

