# Changelog

## 1.2.0.5

New:

* updated to insights v2 api
* nav bar shadow and border tweaks

Fixes:

* unread indicator fix
* upgrade path for onboarding checkpoint fixed, for reals.  deprecated old checkpoints
* aspect fill insight images to make it work for 6 plus
* fix markdown lib to fix current conditions text

## 1.2.0.4

New:

* Insight tap gesture tutorial
* Pill low battery alert only shown once a day

Fixes:

* Sense colors checkpoint will not be reached for older version users

## 1.2.0.3

New:

* VX tweaks to transitions
* VX tweaks to insight detail
* VX tweaks to insights feed
* Standardizing borders

Fixes:

* unread indicator will not be accidentally dismissed when using alarm shortcut
* fixed alert text being cut off
* fixed crasher occuring when answer questions
* better factory reset error messages
* better coloring of bold text in current conditions screen

## 1.2.0.2

New:

* Parallax on insight images within the feed
* Added transition between the insights feed to the insight details creen
* Added force touch to home screen to set an alarm for 6s+
* Added better host selection from debug menu

Fixes:

* No longer tracking errors when entering Sense settings when not nearby

## 1.2.0.1

New:

* Updated insight detail vx

## 1.2.0.0

New:

* New insights feed vx
* Tell a friend settings option

Fixes:

* Unread indicator no longer appears on Timeline top bar when opened
* Updated Zendesk SDK to fix issue photo attachments while keyboard is up

## 1.1.8.9

Fixes:

* Fix issue with pill low battery mapping causing it to never show low battery

## 1.1.8.8

Fixes:

* Fix crasher in sensor history screen when scrubbing and tapping 

## 1.1.8.7

Fixes:

* Fix analytics for new accounts

## 1.1.8.6

New:

* Loading indicator in Timeline history + VX / UX changes
* Moved us back to Mixpanel SDK for now

Fixes:

* Prevent "no data" from showing while loading graph data in sensor history

## 1.1.8.5

Fixes:

* Fixes crasher on factory reset (introduced in this release 1.1.8)
* Fixes time zone display
* Fixes upgrade path for Segment, but still broken

## 1.1.8.4

New:

* Email / name update screen vx
* Time Zone settings vx

Fixes:

* Include optional account settings as part of checkpoint in onboarding

## 1.1.8.3

New:

* Updated VX of links in alert dialogs
* Updated device settings VX + UX
* Update Sense settings VX + UX
* Update Pill settings VX

Fixes:

* Fix unit preferences being reversed for height and weight
* Fix visual bug with notification settings

## 1.1.8.2

New:

* Updated Settings VX
* Updated Account Settings VX
* Updated Notification Settings VX
* Updated Preference Settings VX
* Updated Support Settings VX
* Changed how unread indicator is handled
* Relax the "too soon" alarm restriction to 2 minutes
* Make sensor history view scrollable, when needed

Fixes:

* Fix issue where the "too soon" alarm restriction would fire even if the day
  is different

## 1.1.8.1

New:

* Send country code to Sense when scanning for WiFi upon retry
* Replaced Mixpanel with Segment

Fixes:

* Handle out of order responses from Sense

## 1.1.8.0

New:

* Added onboarding checkpoint for Sense colors screen
* Removed sensor history graph labels

Fixes:

* Removed an out of place period in a status update message
* Vertically align text in empty trends view
* Display -- in settings when onboarding screens for demographic data are skipped
* Display the first frame of the pill pairing video

## 1.1.7.5

Fixes:

* Fixed typo in error message when changing password that is too short

## 1.1.7.4

Fixes:

* Adjusted margins in back view cards
* Fixed bug with user height adjustments through settings not reflecting the
  correct value

## 1.1.7.3

New:

* Empty state for Trends
* Empty state for Alarms
* No Sense state for Alarms
* No Sense state for Current Conditions
* Return specific WEP error if non hex value detected

Fixes:

* Pairing pill video will no longer resume unexpectedly when coming back to foreground
* Prevent keyboard from showing over the activity view when setting time zone if
  unexpected disconnect occurred AND time zone update failed together.


## 1.1.7.2

Misc:

* Attempt to fix stupid iTC by forcing a new upload

## 1.1.7.1

New:

* Add alarm on/off analytics event

Fixes:

* Prevent unexpected disconnect if factory resetting and pairing sense multiple
  times in 1 session
* Resume pill pairing demo video when view re-appears
* Time picker no longer crashes if you are playing around with it and spinning
  the picker and cancelling out really fast at the right second
* Refresh room conditions and alarm view after pairing with sense from those
  screens
* Fixed re-appearance of cancel button in various settings screen when view
  re-appears

## 1.1.7.0

New:

* Updated analytics when saving alarm to match Android
* Removed the Force sign out option in settings bundle

Fixes:

* Fixed truncated description in pairing mode screen on 4s
* Kick user out of Sense settings after entering pairing mode via app
* Tapping outside the content of an alert will dismiss it
* Better error handling in change password screen
* Trim email when updating it

## 1.1.6.7

Fixes:

* Fixes issue with date conversion, affecting unread indicators on 32-bit devices

## 1.1.6.6

Fixes:

* Fixed issue where timeline event could not be updated on 32-bit devices

## 1.1.6.5

Fixes:

* Fixed crasher where collection view layout is invalidated, but layout attributes
  are still returned for something that is not there.  Happens on Factory Reset.
* Fixed issue when onboarding is resumed at a checkpoint where user cannot proceed

## 1.1.6.4

Fixes:

* Fixed issue where entering Sense settings without BLE turned on will cause it
  to never show any options with a never ending activity view
* Fixed issue where if an error was encountered retrieving device metadata from
  server, the layout of the device settings is messed up

## 1.1.6.3

Fixes:

* Updated the intro / welcome screen per feedback
* Fixed issue with first day of timeline history not scrolled to the proper
  position
* Fixed issue with inconsistencies between sleep score color and the graph / line
* Fixed issue where swiping fast on initial / welcome screen may cause buttons
  to not be properly laid out
* Added SSL exception for s3 aws buckets to fix insight image loading problems

## 1.1.6.2

New:

* Updated to v2 Devices API to obtain SSID from server instead of through Sense
* Moved the connection with Sense in settings in to Sense settings rather than
  from the device settings screen
* Using server localized messages for timeline feedback instead of client side
  generic error messages when updating timeline events fail

Fixes:

* When pill is not paired, sense pairing is not also disabled on iphone 5 and 4s

## 1.1.6.1

New:

* Improved disabled state of Sleep Pill settings when Sense not paired
* Trends welcome tutorial shows even when no data is availale to match text
* updated assets in pair sense onboarding screen
* updated light disturbance asset
* added analytics for new intro screen
* increased tap target on Timeline top bar buttons

Fixes:

* sense pair button in device settings will no longer be accidentally disabled
* back button (should be cancel) for modal device screens work again
* fixed trends graph view not being clipped behind border
* fixed copy where periods are missing

## 1.1.6.0

New:

* Updated logged out state experience with new intro screen

## 1.1.5.9

Fixes:

* addresses local storage issue, for reals

## 1.1.5.8

Fixes:

* fixes slowness when entering in to zoomed out view of timeline

## 1.1.5.7

Fixes:

* fixes issue where alert dialogs shown in password / email / name cannot be dismissed
* fixes app icon catalog references

## 1.1.5.6

Fixes:

* setting ip=1 flag in mixpanel request to force geolocation props to set
* always check unread / update insight last viewed

## 1.1.5.5

New:

* Updated button styles
* Updated alert dialog visual design

Fixes:

* Fixed issue with Mixpanel identification

## 1.1.5.4

Fixes:

* Insight detail text is no longer cut off
* The unread indicator code has been slightly modified, but has now been reviewed

## 1.1.5.3

New:

* Adding unread indicator for insights / unanswered questions on both timeline menu icon as well as insights back view icon

## 1.1.5.2

New:

* Timeline will only automatically advance / update for last night when device time is past 3AM

Fixes:

* Fixes issue during wifi scan within settings where an error will always be thrown if putting app in to the background when screen is visible
* Replacing Sense will also disconnect from Sense in settings

## 1.1.5.1

New:

* Added analytics events for support screens
* Confirmation dialog dismissal timing reduced significantly
* Updated pairing mode confirmation dialog copy
* Updated factory reset completion confirmation dialog copy
* Added handholding for sensor detail scrubbing behavior

## 1.1.5.0

New:

* Updated Zendesk SDK to 1.4.1.2 to prevent crash on 6s devices when creating ticket
* Slimmed down the mixpanel dependency with Mixpanel-simple to reduce crashers from mixpanel
* Moved app assets to asset catalog in preparation for app thinning
* Cleaned up iOS 9 warnings
* Cleaned up storyboards to remove deprecated calls and modernize it

Fixes:

* Logging out and back in will no longer retrigger welcome / tutorial dialogs

## 1.1.4.8

New

* Updated layout constraint to add spacing between image and text for the first night of sleep state on the Timeline

## 1.1.4.7

New:

* Updated visual and interaction design for sense colors / before sleep screen
* Updated visual design for room check
* added support for iOS 9 while removing support for iOS 7

Fixes:

* increased tap target for close button in sleep breakdown UI
* tapping between email / name / password edit screens no longer stack
* fixed missing description for smart alarm onboarding screen for 4s
* support pages properly load assets and css in iOS 9
* device warning copy in Device settings properly wrap
* shake the pill video will pause when not waiting for Sense
* fixed clipped copy for pill pairing screen
* first night timeline state properly displays for accounts created day of
* reduce press duration required to trigger breakdown ui on the timeline
* tutorial videos properly play on iOS 9
* alarm tones now play properly with iOS 9

## 1.1.4.6

Fixes:

* udpate extension executable name per apple suggestion

## 1.1.4.5

New:

* visual tweaks to wifi ssid selection screen
* visual tweaks to wifi credential submission screen, for 4s, 5, and 5s

## 1.1.4.4

Fixes:

* disable bitcode for all pod dependencies

## 1.1.4.3

Fixes:

* update ZDK to 1.4.0.2
* turned off bitcode due to conflicts with YapDatabase linker flags

## 1.1.4.2

New:

* updated various assets for the onboarding flow
* now building with iOS 9

Fixes:

* time picker in iOS 9 no lnoger renders with different colors
* time picker will roll backwards from the start
* current condition sensor values will no longer be clipped if value exceeds space needed to render

## 1.1.4.1

Fixes:

* fixed issue where 2  mixpanel profiles were being created for every new account
* fixed typo in pill pairing, network error message
* prevent duplicate records from being synced to HK when syncing last night
* ensure HK backfilling syncs consecutive days

## 1.1.4.0

New:

* handholding message displays with a shadow to better separate from content underneath
* Time picker will automatically rollover AM/PM when switching hours
* Sleep breakdown displays -- when no data is available for that metric
* support URL displayed in message dialog is truncated to just https://support.hello.is
* A network specific error message is displayed when pill pairing fails due to a network error from within Sense

Fixes:

* Fixed rounding issue with selecting weight through settings / onboarding
* Sleep score summary / message no longer remains highlighted when dragged
* Copy on troubleshooting / warning cards in device settings properly wraps
* Sense card in Device settings no longer display values (wifi ssid) that overlap with the label

## 1.1.3.6

Fixes:

* fix crasher that occurs in iOS 7 devices due to a selector used that is only available to iOS 8 devices

## 1.1.3.5

Fixes:

* Fixed issue where tutorial dialogs were incorrectly being displayed between trends and current conditions screen

## 1.1.3.4

Fixes:

* Fixed a crasher that can occur if metric value for a timestamp is 0

## 1.1.3.3

Fixes:

* Changed copy of the app review initial question to exclude the
* Moved the pairing mode animation (video) to the pairing mode screen and revert the change to the sense pairing screen

## 1.1.3.2

New:

* Alarm tutorial dialog (not the smart alarm one) now plays video when connection is available
* Onboarding pill setup screen plays video
* Onboarding sense pairing mode screen plays video
* Onboarding pill pairing screen plays video
* Onboarding sense colors / before sleep screen plays video
* Onboarding alarm screen plays video
* Alarm copy changed from Sound to Tone
* Accessibility improvements to Timelien
* Air quality unit copy changes
* Improved scrolling experience between tabs in the back view
* Timeline differentiates between not enough data and no data, rending a support link to further explain

## 1.1.3.1

New:

* App review feedback is also sent to the server
* App review re-enabled for release builds
* Added a debug info screen to show config, api host, and usage stats stored
* Device settings will connect to the last sense connected, when nearby sense, without scanning

## 1.1.3.0

New:

* Prevent viewing of Timelines older than when account was created, if account info is available
* Height and Weight secondary label removed
* Units and time no longer show the word unit for temperature
* Support URL slugs no longer reference titles
* Dev builds will point to a dev password reset URL
* Factory reset confirmation dialog copy updated
* Onboarding Sense colors copy changed from orange to red

## 1.1.2.6

New:

* Show baseline in current conditions graphs when no data
* Units and Time preferences show the actual unit names
* Default preferences, based on phone locale, is pushed upon account creation

## 1.1.2.5

New:

* Backview now swipes smoothly between tabs
* Tapping on the view when the timeline segment popup is shown dismisses with animation rather than abruptly

Fixes:

* HK does not attempt to sync data when timeline metric value is 0, indicating no wake or sleep event

## 1.1.2.4

New:

* UI handholding for timeline zoom feature
* App review copy changes
* Height and weight unit preferences added.  App uses v2 preferences api

Fixes:

* HK backfilling includes last night
* Stopping audio from timeline no longer blocks UI when opening the timeline

## 1.1.2.3

New:

* Visual feedback when tapping on sleep summary card and sleep score
* Updated sensor welcome dialog images
* Various copy, unit, and asset changes in preparation for dust sensor

Fixes:

* Fixed crasher that occurs if you hold on one of the button on a question card in the insight feed view, then using a different finger, tapping on second button
* Fixed crasher that occurs if you scroll down on a timeline, put the app in to the background, bring it back up, then open the timeline

## 1.1.2.2

New:

* Timeline now shows a custom state directly after onboarding completion
* Timeline now shows a custom state when not enough data has been recorded
* Timeline now shows a custom state when an error was encountered when pulling data for the Timeline
* HealthKit backfills a maximum of 3 days
* Light sensor value formatted to show fractional digit when less than 10

Fixes:

* Fixed issue where HealthKit would fail to sync if no data exists locally
* Timeline no longer shows the loading indicator indefinitely when no data
* Temperature value in sensor detail properly obeys unit preferences

## 1.1.2.1

New:

* Timeline audio playback will now play even if phone is on silent
* Audio playback stops when view is dismissed

Fixes:

* Audio playback button properly scales away when scrolling
* Prevent sleep depth popup from appearing on top of event card
* Fix spike in sensor graph when data points are missing

## 1.1.2.0

New:

* Removed interaction with timeline events with no actions
* Removed scrolling dynamics in the backview
* Light sensor values now show 3 numbers max, including values below 1
* Debug option to change API URL, used together with Nonsense.app!
* Updated copy for 2nd pill / get app screen in onboarding
* Removed pressed state in tutorial icon in sensor detail screen
* Updated copy where the word sound is now noise
* App rating prompt enabled for release builds

Fixes:

* Trends graph now will display the localized day of week consistently
* Room check final color / image now reflects updated logic
* The info button in sensor detail screen will no longer be darkened
* Skipping a question directly from the feed will not cause odd text overlap
* Insights no longer will be shifted to the left upon coming to fg when the full insights detail screen is shown and brought to the bg
* Cards in the backview screens will no longer randomly animate without interaction, due to auto refresh of data

## 1.1.1.7

New:

* Updated animation for timeline sleep depth popup

Fixes:

* Fixed bug where sleep depth popup mask remains while scrolling

## 1.1.1.6

New:

* Added Pill Color explanation card in device settings
* App review prompt and app usage instrumentation
* Audio playback UI in timeline

Fixes:

* device warning about sense not connected to internet will no longer show if app was never able to connect to Sense over BLE to begin with
* timeline timestamps font change

## 1.1.1.5

New:

* Added visual feedback when tapping on / selecting event cards in timeline
* Improved sensor detail scrubbing

Fixes:

* 24 hour clock will now display with leading zero when appropriate
* insights with images no longer will reload when scrolling

## 1.1.1.4

New:

* Updated icons

## 1.1.1.3

New:

* Improved visual feedback when tapping on sleep bars on timeline
* WiFi connection statuses now processed and sent to mixpanel (req new fw)
* Cleaned up error analytics to reduce noise in mixpanel / geckoboard

## 1.1.1.2

New:

* Extend side of timeline when rubber banding the scrollview

## 1.1.1.1

New:

* Hide sleep timeline UI when views more than 1 level deep is pushed in the back view

Fixes:

* Fix time formatting for time displays to always include two digits for hours
* Tight up vertical padding of timeline breakdown metric cells
* Fix issue where tapping on Sign Out after pulling down the timeline should no longer cause the alert to not be dismissed
* Fix issue with factoy reset error messages not be able to be dismissed sometimes

Misc:

* Refactored onboarding code to be more maintainable
* Added a Rate the app hook in to the app
* Moved app color definitions from PaintCode to a category
* Alerts now dismiss itself rather than depending on caller

## 1.1.1.0

New:

* Hide the timeline top bar when back view pushes a new view on to the stack
* Code clean code of app colors.  Require a quick sanity check

## 1.1.0.6

New:

* Reduced size of app by compressing images used

Fixes:

* Timeline tooltip correctly points to the segment tapped on
* Updated copy for timeline breakdown
* Fix issue with device preferences conflicting with in-app preferences for time format style
* Pixel adjustments on timeline event cards

## 1.1.0.5

Fixes:

* Improved scrolling performance on Timeline
* Fixed issue where share icon would be disabled upon returning from bg
* Updated change time zone dialog button copy
* Upper cased custom action sheet global title
* Adjusted padding in various sleep summary / breakdown views
* Fixed issue where timeline tutorial dialogs would see incorrect title margins, consequently causing it to be scrollable when it should not after swiping left and right a few times
* Timeline feedback UI correctly labels the view based on the event being adjusted

## 1.1.0.4

Fixes:

* Minor timeline visual tweaks
* Fixed issue where tutorial content would not scroll on a 4s
* Tutorial dialogs will now flash a scrollbar when content requires scrolling
* Fade in breakdown metrics during initial animation
* Updated copy on current conditions tutorial dialog
* Timeline feedback UI numbers should no longer animate in place
* iPhone 4s titles during onboarding have been reduced to leave padding
* Tutorial dialogs will no longer show the screen beneath current when displayed
* Better handling on alarm shortcut button so that it will show when timeline isscrolled to the top
* Forgot password link should no longer show a 404
* No longer forcing timestamps in Timeline if insufficient data was returned between hours
* Zoomed out view will no longer crash when swiping all the way to the left due to changes in V2 API

## 1.1.0.3

New:

* Improved time zone list and ux
* copy channges to timeline tutorial dialogs
* copy changes to factory reset advanced option message
* pairing mode onboarding screen font style change
* Hooked up to Timeline v2 API (requires accounts to be feature flipped on)

Fixes:

* missing timestamp markers when no data is available
* share icon will no longer reappear when timeline is opened upon coming back from background

## 1.1.0.2

New:

* Swapped out guide.hello.is urls for support.hello.is urls
* Added analytics events for timeline adjustment actions

Fixes:

* Copy changes to Timeline
* Fixed issue where history view of timeline abruptly bounces back from the right edge
* Fixed issue where certain views are prematurely cut off behind the Timeline

Fixes:

*

## 1.1.0.1

New:

* Added analytics event for when timeline event time has been adjusted

Fixes:

* Breakdown presentation animation duration matches dismissal animation duration
* Air quality index text now reduced to Air quality
* Hide right border in zoomed out view mini graph for right most cell, similarly for left most cell
* Do not fade timeline event cards when scrolling up
* sleep summary text on timeline are now vertically centered
* Thank you text in event adjustment confirmation view is now lighter and vertically centered
* sleep summary text and chevron is now blue

## 1.1.0.0

New:

* Reverted timeline top bar back to being non-sticky

Fixes:

* Sleep score over time dots and label are centered for 1W display
* Visual tweaks to action sheet of options for timeline feedback
* Speed up the presentation of the action sheet
* Fixed issue where scrolling back to the very first day would jump to next day
* Increased timeline event string line spacing
* Improvements in timeline breakdown animation
* Fixed issue in regards to phone locale settings for time preference
* Alarm shortcut button will no longer disappear when scrolled to the very top

## 1.0.8.12

New:

* Added new transition for the timeline breakdown
* Prevent breakdown view from being shown if no data
* Displaying a one-time only message about Sense learns when action sheet for timeline events is shown

Fixes:

* Visual tweaks to tooltip for timeline sleep segments
* Fixed issue where 'lights out' text is cut off

## 1.0.8.11

New:

* Timeline top bar now scrolls with timeline as you change dates
* Timeline feedback UI updated to match alarm UI for cancel and save

Fixes:

* Custom action sheet now fades out rather than simply being dismissed

## 1.0.8.10

Fixes:

* On load, Timeline event cards and summary detail in as sleep score animates in
* Timeline event animation upon scroll is now anchored from bottom left
* The tooltip for sleep segments are shown above the bar with arrow pointing downwards
* Timeline date is now back to the gray color
* Fixed issue where last event in the timeline might not be at full opacity
* Smart alarm shortcut button position adjusted to have equal spacing from edge
* Adjusted event text in the card to have equal padding
* Support tickets in settings will now show a comment field
* Putting the phone to sleep when location permission dialog appears will no longer block the user (or previously cause user to tap twice again to proceed)
* switching tabs fast in the backview will not cause empty content
* connecting sense to wifi title on iphone 4s has proper padding
* backview top bar is shortened to match standard navigation bar
* fixed issue in the alarm screen where multiple repeat days (minus 1) would overlap with the label text

## 1.0.8.9

Fixes:

* Fixes issue with timeline events not showing when data not retrieved in time
* Reduced line width on timeline timestamp markers
* Adjusted timeline event shadow to better match design
* Make border between segments and summary more prominent

## 1.0.8.8

Fixes:

* Fixes issue where you cannot swipe left when there no data

## 1.0.8.7

Fixes:

* Fixes issue where timestamp line is drawn over the event card in timeline

## 1.0.8.6

New:

* Support topics now served from server
* Added confirmation views for one tap actions (actions coming soon)

Fixes:

* Fixed images being cut off in tutorial dialogs
* Fixed various Timeline issues with animations and visual styling

## 1.0.8.5

New:

* Timeline loading indicator
* Tweaked timeline animations and visual styling a bit
* Alerting user that alarm is set too early
* Added confirmation when saving an alarm

Fixes:

* Adjusted layout for action sheet to accommodate for the timeline
* copy changes

## 1.0.8.4

New:

* Visual tweaks to the Timeline
* Re-insert zoomed out view
* Re-enable share button for Timeline
* Added the year in the zoomed out view when applicable
* Shorten the back view bar to match standard navigation bar
* Zendesk topic is now sent as a custom field rather than a tag

Fixes:

* Copy change from Topic to Select a topic
* Fixes failure to pull Timeline data when system calendar is set to a non Gregorian calendar
* Fixes issue setting a user birthdate when system calendar is set to a non Gregorian calendar
* Fixes issue saving alarms when system calendar is set to a non Gregorian calendar
* Fixes issue with HealthKit trying to sync when system calendar is set to a non Gregorian calendar
* Fixes issue requesting new Sleep Questons to display when system calendar is set to a non Gregorian calendar

## 1.0.8.3

New:

* Tutorial demonstrating how to swipe between dates in the timeline view
* Update timeline layout, additional tweaks

Fixes:

* Fix issues which occur when putting the phone to sleep on the "Allow Location" prompt
* Fix "No internet" prompt briefly appearing on app launch


## 1.0.8.2

Fixes:

* Fixes issue where it can launch into a black screen after restoring from a backup
* Fixes jumpiness inside User guide within support
* Fixes issue where some tutorial images were cropped when displayed,
* Fixes issue where february 29 cannot be set, depending on current year

## 1.0.8.1

New:

* Zendesk integration
  * Search the User Guide
  * create tickets from inside the app
  * view tickets from inside the app

Fixes:

* smooth out animation in clock picker
* Insights date now properly displays correctly when it is 1 week ago

## 1.0.8.0

Updated timeline appearance

Known issues:

* share button does not work
* "times awake" in breakdown uses "m" as the unit
* "Zoom"/history view is unavailable
* Overlap between cells
* Various tweaks missing

## 1.0.7.5

Fixes:

* updated Health app image in onboarding

## 1.0.7.4

New:

* Moved the Health screen during onboarding
* Updated text in account settings to show Sync with Health

## 1.0.7.3

New:

* Updated visual design on the name settings screen
* Updated visual design on the email settings screen
* Updated visual design on the password settings screen

Fixes:

* Copy changes around WEP WiFi failures
* Fixed issue causing a WARNING on first try in syncing with Health app
* Added more analytics to understand WiFi set up

## 1.0.7.2

Fixes:

* Prevent Health saving sleep data multiple times on the same day
* Fix writing incorrect day to Health while app is in the background
* Prevent unauthorized requests sent from the app after signing out
* Additional analytics
* Fix typo in insights

## 1.0.7.1

New:

* Health integration screen in oboarding
* Instrumented manual time zone changes inside settings
* Instrumented healthkit sync
* Sync last nights data to Health app, even if timeline is not final, to prevent
  people from thinking its not working after set up.

Fixes:

* fixed typo in insights created date
* removed calls that are firing even if user is not authenticated
* no longer removing the Sense Id in analytics profile when unpairing

## 1.0.7.0

New:

* Timeline style, work in progress

Known issues:

* Overlap between close events
* Incomplete implementation of design
* Poor performance on lower-range devices

## 1.0.6.2

Fixes:

* Sleep score animation smoothing
* Play alarm preview audio when phone is muted
* Typo fixes

## 1.0.6.1

New:

* System alert when internet connection is lost
* Include the device id in analytics of the device removed from the in-app device settings

Fixes:

* Fixes the analytics race condition that causes people profiles to not appear
* Prevent user tapping on the dots of the Sense color screen
* Insight summary cards should no longer have overllapping text due to
cached calculated text heights

## 1.0.6.0

New:

* WiFi signal strength is now shown through the wifi icon when scanning for WiFi
* Link to the user guide is now made more prominent in Settings
* An alert is shown after successfully factory resetting sense to describe what to do next
* Updated protobuf definition to support additional Sense error codes
* Account email is now attached to the support emails triggered by the app

## 1.0.5.6

New:

* Added Timeline mp event for the alarm shortcut

Fixes:

* removed an extra call to set the LED after setting wifi credentials

## 1.0.5.5

New:

* Added Timeline data request and error mp events

Fixes:

* Fixes issue where Timeline for Last Night is not updated when app resumes from background to foreground.
* Adjusted loading text font on trends and current conditions to match
* Adjusted animation parameters on Room Check to fix choppiness on iOS 7

## 1.0.5.4

New:

* Room check animation and visual tweaks

Fixes:

* Fix issue with modal transitions on iOS 7 devices

## 1.0.5.3

New:

* Custom action sheet for debug options
* Moved factory reset and remove device options in to an action sheet, under Advanced
* Updated room check sensor icons

Fixes:

* time to sleep value will properly display in minutes
* pill pairing errors will no longer be swalloed by LED operations
* factory reset will now properly dismiss overlay if Sense unexpectedly disconnects during the process

## 1.0.5.2

New:

* Visual design tweaks to Timeline

Fixes:

* Layout tweaks to Attach Sleep Pill screen in onboarding
* Room check sensor value now matches value after animation completion
* Devices settings now is refreshed when Sense is paired from system alert
* Devices settings now is refreshed when Pill is paired from system alert

## 1.0.5.1

New:

* If linking account fails twice on the Sense pairing screen (WiFi is set), an option is provided to the user to edit the WiFi from the error dialog.
* Skip the room check during onboarding if sensor data is not available
* Alert dialogs containing links are now tappable.  Affects Sense and Pill settings screen.

Fixes:

* Unexpected disconnects during onboarding will have no effect if the screen in which is listening to such event is not currently visible
* Will now record the first sleep event and the last wake up event in HealthKit rather than just taking the first detected event for each type in case there are multiple of each.

## 1.0.5.0

New:

* Updated visual design of room check
* Updated visual design of timeline
* Added analytics event for retrying pill pairing during onboarding

Fixes:

* fixed analytics event not being prefixed with Onboarding for screens post pill pairing

## 1.0.4.6

New:

* Updated Sleep Pill setup screen
* Welcome dialogs animate in
* visual design tweaks to Settings
* Current conditions and Alarm view indicate when a Sense is not paired

Fixes

* time picker fixes for timeline feedback views

## 1.0.4.5

Fixes:

* back view icons were reversed

## 1.0.4.4

New:

* updated insights visual design
* removed sharing of insights
* updated alarm visual design
* if time zone is not properly set for your account, an alert will be shown
* updated copy
* added additional timeline analytics

Fixes:

* resolved issue with the app showing a black screen after adjusting timeline time on devices running iOS 7.1.  Does not affect other iOS versions.
* prevent app from freezing if trying to swipe to go back from the alarm view

## 1.0.4.3

New:

* Present time zone update screen modally and show current selection
* visual tweaks to Timeline, dialogs, loading indicators, trends, settings, and welcome screen

Fixes:

* share icon on Timeline will no longer reappear when its been opened and app is brought back in to the foreground

## 1.0.4.2

New:

* Added / updated timeline analytics events
* Added / updated wifi scanning analytics events
* Firing analytics events for screens that are reused from Onboarding as normal events.

Fixes:

* Resolved issue where launch image was not properly synced with the Timeline when app is launched
* Resolved issue where WEP passwords with 00 will fail (depends on new firmware)

## 1.0.4.1

Fixes:

* processing available time zones in settings in background to speed up transition
* fixed issue where 1 of the time zone option was covered by the navigation bar

## 1.0.4.0

New:

* Change the time zone used by the system
* global in-app alert is now shown when Sleep Pill battery is low
* Sleep Pill settings will now show a warning if battery is low

Fixes:

* Prevents mp events from the core part of the app from firing when not visible
* Edigint Timeline events should update the timeline after saving
* Changed the order of action buttons in the delete alarm confirmation dialog
* Resolved possible crasher that can occur when syncing with HealthKit if the wake up time was manually adjusted to be before the sleep time
* Fixed issue where HealthKit may not automatically sync
* Adding additional events for when global in-app alerts are fired.

## 1.0.3.7

Fixes:

* fixes layout issues when the in-call status bar is visible
* setting the device id of Sense on mixpanel as soon as an attempt to pair is triggered to help diagnose problems
* resolved Sense WiFi connectivity issue when network uses WEP security
* wait until all operations are finished to dismiss activity so that error messages do not appear to be delayed
* added more information to BLE errors returned and logged
* adding additional analytics properties and events around setting up WiFi
* instrumented alarms UI in Mixpanel

## 1.0.3.6

Fixes:

* tapping on account preferences will not show the update name modal screen
* editing name will use the default keyboard and capitalize words
* updated copy on how to attach your Sleep Pill to the pillow

## 1.0.3.5

Fixes:

* adding missing device action events
* fixed bug where devices will alert the user that something is wrong, even its simply a warning, like the pill is not paired
* sense in device settings should no longer say that the last seen is 45 years ago
* ensuring response is returned before the timeline feedback screen is dismissed

## 1.0.3.4

New:

* logging usage of the press-n-hold Timeline action
* enabling surveys through MP

Fixes:

* updated action button text for wifi warning in Sense settings
* reload device settings screen as soon as a new Sense has been paired from it

## 1.0.3.3

New:

* Added transition for Sleep Questions screen
* Added transition for Timeline Feedback screen
* Including app version, devie model, and iOS version in email message body when sending feedback / support inquiry
* Added new screen to onboarding to ensure user has a Sense before starting

Fixes:

* various copy changes
* updated various images
* fixed settings layout and shadows
* fixed issue where Current Conditions would show old data when actually there is no data to show
* fixed missing hour marker in Timeline

## 1.0.3.2

New:

* Added ability to update your Name
* Added ability to send us feedback by email through settings screen
* Visual design update on Sense settings screen to separate out Factory Reset
* Updated how Sleep Questions are animated in and dismissed
* Alarm shortcut button will now reappear if you stop dragging / scrolling

## 1.0.3.1

New:

* Improved the loading of Sleep Pill info in device settings
* Turning on the LED on Sense when doing a factory reset

Fixes

* updated various copy

## 1.0.3.0

New:

* Added help link to bottom of device settings to explain setting up second pill
* when sense or the pill has not uploaded data for over a day, an alert will be
displayed to let you know, giving you a link to help troubleshoot the problem
* Updated how we complete a factory reset, which will now also properly remove
any other accounts linked to that Sense and remove your pill as well.
* updated confirmation and alert dialogs throughout the app to match othes used

Fixes:

* fixed layout in alarms screen when no alarms have been set
* fixed layout in timeline to center information between sleep score and tabs
* removed reference to sense-api in today extension
* removed unused copy in app

## 1.0.2.10

New:

* updated visual design of the audio player in the Timeline

Fixes:

* updated room check message attributes
* properly scale Sleep Pill image in onboarding
* healthKit preference will now remember your preference if you sign out and
sign back in as the same user
* changed order of gender buttons in gender picker screen to match text order
* updated copy on sign out / sign in screen
* better handling of enhanced audio clips
* fixed issue with updating temperature unit preference

## 1.0.2.9

* Log API version for support requests
* Fix iPad layout in landscape mode
* Update timeline with time adjustments after sending feedback

## 1.0.2.8

Fixes:

* reduced size of app by reducing size of images and removing old ones
* fixed layout bug in Sensor screen that causes it to be off by 20px

## 1.0.2.7

Fixes:

* added additional analytics to help troubleshoot issues
* fix crasher that can occur by sharing an insight that has no content
* better handling of intermittent network failures
* fix issue that can occassionally cause Timeline to show a blank screen
* minor visual and copy changes

## 1.0.2.6

Fixes:

* signing out of app no longer resets server path

## 1.0.2.5

Fixes:

* questions UI showing a back button unintentionally
* shortening the message in the Timeline segment popup
* updated copy in the set up another pill onboarding screen
* updated sensor view text attributes

## 1.0.2.4

Fixes:

* updated sleep score share text

## 1.0.2.3

New:

* Timeline description on bars, triggered by long press
* Pill color in device settings will now show a value when the cloud returns it

Fixes:

* fix issue where questions and timeline feedback screens were showing a navigation bar with separator unintentionally
* fix timeline feedback feature by using latest api
* fix issue where password update would fail if email is updated right before
* fix issue where account settings would show grams rather than kg for weight
* fix insight summary alignment issue on iOS 7 and when app goes in to foreground from background, while insight full view is shown
* fix issue where notification preferences were cut off prematurely if you scroll

## 1.0.2.2

New:

* support links now point to appropriate topic when appropriate

Fixes:

* fixed Timeline event layouts
* fixed issue with zoomed out view of Timeline not going back to Last Night
* fixed layout issues in Sensor views
* when connection fails while loading device info in Sense and Sleep Pill, an alert is shown to indicate so rather than silently failing
* fixed layout issue for Insight summaries when content contains bullet points
* fixed crasher that can occur if you quickly move from one tab to another in the back view of the app
* various copy changes

Fixes:

* various copy changes

## 1.0.2.1

New:

* Added option to provide feedback to event times on your Timeline
* Before you Sleep onboarding screen are broken up in to slides to better illustrate what colors on Sense mean

Fixes:

* fixed issue during wifi scan that would prevent user from restarting a scan if Sense disconnects during the scan
* Pill pairing screen will not ask to shake the pill until Sense is ready to listen for the action

## 1.0.2.0

New:

* added a floating shortcut button to setting alarms
* showing day of week in place of a date for days within the week
* added support for insight images when available
* added smart alarm info card to describe how it works
* notification settings are now at the top level of Settings

Fixes:

* fixed issue with a temporary flash of the same data after being retrieved
* fixed issue with the type size of the empty alarm state
* fixed issue with timeline information card appearing in wrong place after signing in
* updated icons for sleep movement events
* current conditions update more frequently
* updated read more copy on insight summary cards

## 1.0.1.9

Fixes:

* rebuild with App Store scheme

## 1.0.1.8

New:

* Added link to forgot password to sign in screen

## 1.0.1.7

Fixes:

* Show sensor view tutorials automatically at first viewing
* Added shadow to insights screen when content requires scrolling
* Fixed issue where communication with Sense may not properly time out
* Fixed issue to make sure keyboard is not shown above activity when setting up wifi
* Ensure LED is turned off when done
* smooth out sleep score loading / counting animation
* Added shadow to to welcome dialogs for content that requires scrolling
* remove icons in timeline tabs
* added title to sign in screen
* images in onboarding screens are vertically centered within whitespace
* various copy and link updates

## 1.0.1.6

New:

* Dim screen in-app at night

Fixes:

* added pairing mode image to onboarding
* make sure keyboard is dismissed when activity is showing during wifi setup
* various UI adjustments to accommodate for iphone 4s size
* Fix missing data not being obvious for Light and Sound sensors

## 1.0.1.5

Fixes:

* fix sleep score breakdown animation
* change order of preferences in account settings
* clearing old push notifications after opening app
* fix textfield jumpiness in sign in screen
* fix alarm duplication issue when saving alarms
* factory reset now shows a successful state
* factory reset no longer kicks you out of app
* turning up volume when playing sounds in alarm sound preview

## 1.0.1.4

New:

* Timeline sleep score breakdown
* Push notification preferences
* Sleep Pill description screen in onboarding
* Will not ask to Add Another Sleep Pill if Sense has been paired to more than 1 account already.
* Welcome / explanation dialogs
* Timeline shows generic motion
* Font scaling based on device

Fixes:

* height picker animation direction hints direction to increase or decrease
* clear current conditions upon signing out of account
* alarm picker time now cycles
* upon sign out, reset to default menu
* timeline zoomed out view no longer show previous month if swiping back and forth
* various onboarding screen design updates

## 1.0.1.3

New:

* Sensor detail highlights current condition and insight

Fixes:

* fixed issue where Timeline dates are off and Last Night was not referring to yesterday
* skipping pill pairing will ask you to confirm, skipping the pill placement instruction screen as well
* updated support link
* proceed to next onboarding screen while activity is still showing to remove unintended confusion that something went wrong
* fixed issue with Insight summary date being truncated for today
* update devices list faster, after removing Sense or Sleep Pill from account
* removed Thank You message after answering Questions
* fixed issue where textfields in sign in / sign up screens might cause content to temporarily hide
* fixed an issue where re-pairing a Sleep Pill may leave Sense LED on
* fixed an issue where re-pairing a Sense may leave Sense LED on
* updated title of devices screen to reflect what is shown in settings
* updated various onboarding screen vx
* updated birthdate format in account settings
* fixed issue where birthdate might be off by 1
* fixed issue with Room Check title being missing

## 1.0.1.2

New:

* Prompt user to turn on BLE when navigating to devices settings, if BLE is off (once per session)
* Allow skipping Pill pairing after two failed attempts
* Improve handling of error states during Pill pairing
* Visual update to trends, alarms, and insights
* Show wifi password in plain text during onboarding

Fixes:

* Show all message text for timeline events
* Show sleep times in timeline in correct timezone
* Fix drawer display after onboarding
* Fix trends display on 4S
* Fix failing to re-register for remote notifications after signing out and in again

## 1.0.1.1

New:

* Moved sign out option in to Account settings

Fixes:

* errors encountered when saving alarms are now more descriptive
* fixed issue where saving an alarm can sometimes cause it to fail on iphone 5 and 4s.
* fixed issue where you cannot cancel out of Pill pairing from settings
* fixed issue where insight summary was being truncated
* fixed issue during onboarding where the no BLE screen does not properly detect fast state changes
* errors when creating an account are more descriptive
* fixed issue where SSID shown initially in devices may not reflect what Sense is currently configured to at the moment.
* when you sign in, your time and temperature preferences are now pulled down
* general speed improvements
* general visual improvements

## 1.0.1.0

New:


* Timeline sleep summary / before sleep tabs
* Added support for edge pan gesture for back view drawer tabs
* HealthKit integration.  Turn it on in Account settings.

Fixes:

* layout issues in sensor detail views
* various visual fixes in Timeline

## 1.0.0.62

New:

* Settings design overhaul
* Enable enhanced audio through settings
* Changing time and temperature preferences in settings will be stored in the cloud
* Speed up account information loading in settings
* Reload sensor views instantly when temperature preferences change
* Speed up alarm sound loading
* New images and styling for sleep timeline
* More informative errors during alarm changing/saving
* Added Sense not yet paired alert

Fixes:

* Fixed issue where menu bar would be shown over account settings after updating password
* Remove unecessary background scanning for Sense

## 1.0.0.61

New:

* Updated height selector design
* Updated weight selector design

Fixes:

* Better error handling for creating and updating Smart Alarm

## 1.0.0.60

fixes:

* hide debug menu for non beta

## 1.0.0.59 (APP STORE SUBMISSION!)

New:

* See expert insight information by tapping on the summary card

Fixes:

* Current conditions text is no longer cut off
* Error message titles are no longer cut off when too long
* The Echo sound will now play when selecting it in alarms
* While setting up wifi, unexpected disconnects are handled
* editing wifi from settings will no longer leave sense LED on
* fixed crasher when tapping on missing data trends graph

## 1.0.0.58

New:

* Trends!  Pull down the Timeline and tap on the Trends tab
* Enable enhanced audio from onboarding
* Simpler second pill setup flow in onboarding
* Updated Before you sleep screen

Fixes:

* crasher when saving alarms on iOS 7
* app freezing on iOS 7 and iPhone 5 running iOS 8
* sporadic blank screen on the Last Night timeline

## 1.0.0.57

Fixes:

* Fixed issue with saving alarm during onboarding
* Fixed crasher within the alarms view
* Fixed crasher in Room Check during onboarding
* Setting timezone when pairing with Sense as a second user

## 1.0.0.56

New:

* Onboarding flow design overhaul
* Updated alarm styling
* Updated sensor view styling

Fixes:

* better handling for errors during onboarding
* fixed issue where menu button was not responding in 6+

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
