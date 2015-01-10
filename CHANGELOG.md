# Changelog

## 1.0.0.55

New:

* Sleep timeline design overhaul
* Settings design overhaul
* Device Management design overhaul
* Device Management screen will show you warnings if an issue is known
* Sense settings screen now allows you to remove the Sense from your account
* Device Management will allow you to pair with a Sense, if one is not
* Signing in to the account, no longer pushes you out to pair a Sense if one is not paired.  Do so through Device Management.
* Updated Onboarding flow to ask if you want to set up another pill at the end
* Updated LEDs throughout onboading flow to show you when everything is done
* Updated sensor graph colors
* Updated your app icons

Fixes:

* Fixed Sense pairing in onboarding, which may have caused random errors to show

## 1.0.0.54

* Added guard for Light sensor in room check, which was crashing it

## 1.0.0.53

Fixes:

* Fix issue where some people would be brought back to Birthdate form during
  onboarding.  This affected people who had BLE turned off when going through
  onboarding.

## 1.0.0.52

New:

* Artisanal selection of alarm ringtones for your listening pleasure
* Added a message to the sensor view indicating at what values you sleep best

Fixes:

* Fix issue with device monitoring occuring during onboarding
* Fix for the top bar briefly appearing when panning between views

## 1.0.0.51

New:

* Updated to control Sense LED activity indicator in onboarding.  This requires
  the latest firmware.
* During onboarding, Sensor data is immediately pushed for Room Check to pick
  up.  This requires the latest firmware.
* Global alerts to indicate when Sense cannot connect to network and when you
  do not yet have a pill paired.  More alerts to come to help you troubleshoot
  problems.

Fixes:

* Fix issue with Timeline scrolling issues
* Fix issue with Trends Questions action button states

## 1.0.0.50

New:

* Faster Sense pairing during onboarding
* Return user to onboarding upon authentication if Sense has not been set up
* Update your email from within Account Settings
* Smart Alarm switch added to alarms
* Updated Alarm design
* Sense LED updates, with supporting firmware

Fixes:

* Fix a crasher when tapping through insights from iOS7 devices
* Fixed sensor colors
* Zoomed out Timeline will not be triggered acciddentally when swiping down
* Menu bar in the back screen will no longer be dismissed when dragged from the
  edge from the Alarms screen
* Share icon no longer show when bringing back to foreground, even though there
  is nothing to share.

## 1.0.0.49

New:

* Completely revamped the back view design
* Sensor graphs are colorized based on current condition
* Analytics by Mixpanel
* Insights now show in full screen
* Updated onboarding screen to better show how to attach Sleep Pill to pillow
* Onboarding now fully instrumented with analytics to understand problem areas

Fixes:

* Room Check during onboarding works on 4s


## 1.0.0.48

New:

* Animated Zoomed out view of Timeline.
* Updated sleep score loading indicator
* Questions now support multiple answers, when applicable

## 1.0.0.47

New:

* Work in progress of a zoomed out view for the Timeline
* Room Check sensor values now animate in
* Enable push notifications from onboarding
* Added ending message for onboarding flow
* Wake Up time validation control in wake up event within Timeline
* added ble support for firmware update of device mode flag

Fixes:

* various copy changes
* calls for data should not be made when signed out
* Timeline refreshed after signing out and back in
* syncing with Sense led changes in firmware

## 1.0.0.46

New:

* Introducing a Room Check feature in to Onboarding
* Update your password from within Account Settings

Fixes:

* slight UI tweaks

## 1.0.0.45

* Updated questions visual design, with shortcut to skip question.
* Answers to the questions now feed back to the Sense system.

## 1.0.0.44

New:

* custom loading indicator with discrete done state during onboarding

Fixes:

* fixed issue where some text was being cut off during onboarding
* setting default weight based on gender so it does not start from 0
* various copy changes during onboarding
* various layout fixes

## 1.0.0.43

New:

* Added setting the first alarm to the onboarding process
* 'Particulates' is now named 'Air quality index' and the measurement is adjusted accordingly

Fixes:

* Creating an alarm which does not repeat now works
* Hide share button when not applicable


## 1.0.0.42

New:

1. iPhone 4s support
2. Updated copy for various onboarding screens
3. Play the alarm sound when setting an alarm

Fixes:

1. Fixed text layout issues that was previously getting cut off

## 1.0.0.41

Ensuring testflight provisioning profile is not corrupted and that there are no
conflicting builds so that Ben Rose can install build.

## 1.0.0.40

New:

* Added a Before You Sleep screen to describe Sense colors.  This replaces the
  previous well done screen. 
* Hooked up illustration for clipping your Sleep Pill

Fixes:

* fix various layout issues in onboarding

## 1.0.0.39

New:

* Sensor detail styling update
* Allow opening sensor detail view from today extension

Fixes:

* Tuning alarm time panning speed

## 1.0.0.38

New:

* Visual styling for onboarding and alerts
* Hook up "I'm having trouble" in onboarding
* Add 'Help and troubleshooting' to Settings

Fixes:

* Missing line for temperature sensor graph when using Fahrenheit
* Remove blur from timeline graph
* Slow down alarm time panning speed

## 1.0.0.37

Fixes:

* Fixed crasher that can occur if Sense unexpectedly disconnects before command completes

## 1.0.0.36

New:

* added support to select wifi security type if entering wifi manually
* relaxed sign up validation
* minor onboarding updates

## 1.0.0.35

New:

* Updated Onboarding with new assets
* Updated / Added new descriptions in certain Onboarding screens
* reversed height picker values so scrubbing up increases height

Fixes:

* prevent user from trying to set wifi when Sense is still being discovered

## 1.0.0.34

New:

* Supporting 2nd sleep pill user onboarding flow
* Skippable WiFi onboarding if set and if firmware supports it
* Insight summaries are tappable
* very verbose BLE logging, for when you want to send us the logs
* introductory video on welcome screen
* onboarding demographic info screens are skippable

Fixes:

* iOS7 fixes
* fixed issue where user was automatically being logged out, even during
  onboarding
* fixed crashlytics
* fixed pairing mode crasher
* fixed birthdate
* fixed sensor graph labels being out of order
* fixed sensor utc times

## 1.0.0.33

New:

* New onboarding workflow for single pass through
* More activity messaging to indicate what is going on during onboarding
* Start of sharing from Timeline
* auto setting of timezone is enforced after Sense is configured with WiFi
* Auto refresh of Timeline when coming back from background

Fixes:

* Support options cannot be triggered more than once
* Alarm text styling fixes


## 1.0.0.32

New:

* Shake to open "help and debug" menu for contacting support
* Updated styling
* Refresh individual sensor views periodically

Fixes:

* Fix for question text being clipped
* Fix for alarm time being clipped
* Make hamburger button easier to tap
* Fix signing out the user after a crash or killing the app

## 1.0.0.31

New:

* Updated design throughout the app, minus Sensor graphs
* Hooked up Sleep Pill pairing from within Settings
* Hooked up WiFi set up from within Settings
* Showing currently configured WiFi in Settings
* auto re-pair if you have an account and have paired with Sense previously, within Settings

## 1.0.0.30

New:

* Insight summary view, pulling from server
* Updated Back View styling, but partially complete
* Passing WiFi security type to enhance speed in set up

Fixes:

* Fixing WiFi scanning issue
* Fix sensor data appearing in alarm summary when connection to API is lost

## 1.0.0.29

New:

* New setup for people with two pills for one sense
* Timezone configuration while setting up wifi
* Option to force sign out from Settings app
* Third-party library attributions in Settings app

Fixes:

* Only scan once for wifi networks instead of auto-scanning twice, to prevent issues with Sense
* Faster refresh for room conditions
* Better error messaging in sign up / sign in
* General setup fixes

## 1.0.0.28

New:

1. WiFi Scanner / Picker that integrates with Sense
2. Better error messaging when connecting WiFi
3. Loading indicator in Timeline view
4. Logging user out when receiving 401 from server

Fixes:

1. Auto refreshing of Sensors now properly displays cached data
2. Fixed cached questions between users

## 1.0.0.27

New:

1. Aadded auto refresh on sensor data

## 1.0.0.26

New:

1. Added ability to do a factory reset.  Only use this if you know exactly what
you are doing!

2 Added analytic events to Sense controls within the app.

3. Onboarding Checkpoints

Fixes:

1. added time out while pairing with Sense
2. better error handling in BLE operations
3. minor visual fixes

## 1.0.0.25

New:

1. Analytics with Amplitude, mostly for Onboarding and errors
2. Logging events to file to be sent by email through Customer Support menu
3. Expand the width of long sleep summary messages to match the margins of the timeline
4. Remove the presentation of the first sleep event

Fixes:

1. various layout issues
2. fixed issue with Devices view where info was not properly reloaded
3. fixed issue where scanning for Sense inside the app never times out
4. updated particulate unit, which fixed particulates icon

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
