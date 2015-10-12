#!/usr/bin/env bash
expected_line='// !$*UTF8*$!'
line=$(head -n 1 Pods/Pods.xcodeproj/project.pbxproj | tr -d '\n')
if [[ $line != $expected_line ]]; then
  echo 'The Pods project is not formatted as ASCII, please run `pod install`'
  echo 'from a system with Xcode.'
  exit 1
fi
