# Changelog

## master


Fixes:

* Expand the width of long sleep summary messages to match the margins of the timeline
* Remove the presentation of the first sleep event

## 1.0.0.24

New:

* Hooked up API to skip a question
* Unpairing sleep pill directly unlinks pill from account ... does not go
  through Sense

Fixes:

* fix issue with app opening in to a state where Timeline is retracted
* BLE operations now times out, ~60s for setting up wifi.  ~20s for all others
* fixed issue where view to set up wifi is not disabled while operation in
  progress.

## 1.0.0.23

New:

* New onboarding flow, including ability to set wifi credentials manually
* updated onboarding screen font type

Fixes:

* handling empty strings from Timeline API
* various screen layout fixes

Notes:

* Onboarding flow has not been tested against a fully assembled Sense
* For now, "I am having trouble" button in the onboarding flow will skip the
  screen as a way for people to test the flow without a device.
* Placeholders for onboarding videos and images until those are provided.

## 1.0.0.22

New:

* "Before you slept" insights are now provided via the API

Fixes:

* Move sleep score text upward slightly to center it
* Change "deep sleep" fill amount to match margins on both sides
* Show historical temperature data in centigrade or fahrenheit
* Event summary popup text should not change before moving into position
* Avoid closing event summary popup if tapped just after opening

Known Issues:

* Fetching alarms for the first time sometimes returns an error
* Alarms cannot be saved without picking at least one day to repeat

## 1.0.0.21

Fixes:

* No more events in the timeline with a black background

New:

* "Before you slept" insights below the timeline -- the displayed insights are currently static, but you can see how they will appear
* Better animation when event popups appear
* Make events easier to tap

## 1.0.0.20

Fixes

* Fix Localized strings for widget

## 1.0.0.19

New:

* Sense Today Widget
* Paired devices show Last Seen from server
* Unpair your Sleep Pill (if you have access to your Sense)
* Updated, but still in progress, onboarding flow
* Updated Timeline
* Alarm UI updates and also persists to server

Fixes:

* Alarm crasher
* Layout fixes in various screens

## 1.0.0.18

New:

* Timeline style and icons
* Transition style for moving between dates
* Put Sense into pairing mode from settings
* Add integration with device ID in BLE advertisement packets
* Add a Sense area in Settings app

Fixes:

* Fix doubled animation for score
* Fix Units + Time styling
* Fix a split sec animation bug when question is presented on iphone 6

## 1.0.0.17

New:

* The summary area in the timeline supports markdown
* Real summary of the previous night's sleep

Fixes:

* General polishing and cleanup in settings and onboarding
  - removed unneeded images
  - added loading indicators
* Change the score font from Helvetica to Agile
* Add missing retina icon for temperature

## 1.0.0.16

New:

* Device management. Remove your paired devices.
* New style for settings screens
* New style for questions
* You can now have multiple repeatable alarms
* APP ICON

Fixes:

* Fix date offsets in sensor history graph

## 1.0.0.15

Fixes:

* Fix iOS8 issue with location finder in onboarding
* Fix iOS8 issue with dismissing Questions
* Fix button animation

New:

* Push Notification integration
* Settings for account information

## 1.0.0.14

Fixes:

* I know this was keeping you awake at night, so icons for sleep events have been restored
* Really light text is now a tad darker
* Events can be expanded to show messages again

## 1.0.0.13

New Stuff:

* Hooking up the Questions API to display question(s) to user at most once a day

## 1.0.0.12

Fixes:

* More informative labeling when there is no curent sensor data available

## 1.0.0.11

Fixes:

* iPhone 4s layout issue with the gender selection screen

New Stuff:

* Real data in the timeline from your pill!
* New style for the onboarding process, for recording height, weight, and birth date
* Now pairs with Sense during onboarding, if one is found not already paired
* Using updated Account API to save birthdate and lat/long information

## 1.0.0.10

Fixes:

* Historical sensor data should be in the correct timezone

New Stuff:

* Smooth and animated transition between sleep data timelines, similar to the Chrome app
* Make sleep timeline text bigger and sleep events expandable
* New font

## 1.0.0.9

New Stuff:

* Onboarding flow, complete with custom controls!
* Location storage through onboarding

## 1.0.0.8

Fixes:

* Fix for crash when swiping rapidly through days in sleep history

New Stuff:

* Tapping in the sleep history graph now shows an indicator for the time and event details

## 1.0.0.7

Fixes:

* Pulling the sleep graph view up and down should be much easier
* Sign up view shouldn't appear during sign in
* After updating user information in settings, the user is returned to the settings view

Issues:

* Close sleep events get squished in the graph

## 1.0.0.6

Fixes:

* Sign up view pans correctly to show all fields under the keyboard
* Lines should no longer appear on top of sensor information after signing up/in
* Minimum password length is now 3 (Sorry, Tim!)
* Sensor messages should no longer overlap the values
* Tapping the sign up button multiple times no longer sends multiple requests
* Alarm should no longer flicker while changing the time

New Stuff:

* Signing in without filling in all fields probably shows dialogs with hints
* User information (like age, weight, etc) can be updated from settings

Issues:

* Close sleep events get squished in the graph
* Pulling the sleep graph view up and down is difficult
* After updating user information in settings, the user is not returned to the settings view

## 1.0.0.5

Fixes:

* Sign Up flow can be completed, picking an age, weight, height, etc should work!

New Stuff:

* Fake data in sleep history now comes with fake events! Tapping anywhere in the graph should update the sensor data

Issues:

* Pulling the previous night's sleep data view up for viewing and down is difficult because it is competing with the scrolling view of the graph
* Graphed sleep events which are close temporally can be squished together
* Sign Up text fields don't scroll and can be lost under the keyboard
* Lines appear in current conditions table after initial sign in
* Alarm flickers while panning

## 1.0.0.4

* Fixed view overlap issues in sleep data view
* Tapping points in the sleep data graph now updates the sensor data

Issues:

* Pulling the previous night's sleep data view up for viewing and down is difficult because it is competing with the scrolling view of the graph
* Sign up flow missing some controls
* Lines appear in current conditions table after initial sign in

## 1.0.0.3

* Added general layout for viewing the previous night's sleep data, with complimentary fake data
* Colored sensor values in "current" view according to sleep condition

Issues:

* Pulling the previous night's sleep data view up for viewing and down is difficult because it is competing with the scrolling view of the graph
* Sign up flow missing some controls
* Lines appear in current conditions table after initial sign in

## 1.0.0.2

* Users should be able to "Sign In" or "Sign Up"
* Current sensor data should be displayed after sign up (if there is sensor data tied to the account)
* Alarm can be customized and should save changes
* Users should be able to toggle temperature and time display preferences in "Settings", as well as sign out

Issues:

* Lines sometimes appear on top of sensor info in the home view
* Sign up text fields don't scroll properly (information is lost under keyboard)
* No icon

## 1.0.0.1

* Users should be able to "Sign In" (accessible from the "Sign Up") view
* Current sensor data should be displayed after sign up
* Alarm can be customized and should save changes
* Users should be able to toggle temperature and time display preferences in "Settings", as well as sign out

Issues:

* Lines sometimes appear on top of sensor info in the home view
* No icon :(

## 1.0.0.0

* Initial build
