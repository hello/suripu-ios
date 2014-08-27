PROJECT_NAME=Sense
DEFAULT_BUILD_ARGS=-workspace Sense.xcworkspace -scheme Sense
BUILD_TOOL=xcodebuild

default: build

bootstrap:
	gem install xcpretty ovaltine --no-ri --no-rdoc

build:
	$(BUILD_TOOL) $(DEFAULT_BUILD_ARGS) | xcpretty -c

test: test_ios7

test_ios7:
	$(BUILD_TOOL) $(DEFAULT_BUILD_ARGS) -sdk iphonesimulator7.1 test | xcpretty -c

test_ios8:
	$(BUILD_TOOL) $(DEFAULT_BUILD_ARGS) -sdk iphonesimulator8.0 test | xcpretty -c

generate:
	ovaltine -p Sense.xcodeproj -o SleepModel/ --prefix HEM --auto-add --auto-replace --copyright 'Hello Inc' SleepModel/
