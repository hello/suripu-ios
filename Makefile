PROJECT_NAME=Sense
DEFAULT_BUILD_ARGS=-workspace Sense.xcworkspace -scheme Sense
BUILD_TOOL=xcodebuild

default: build

bootstrap:
	gem install xcpretty ovaltine shenzhen deliver --quiet --no-ri --no-rdoc

build:
	$(BUILD_TOOL) $(DEFAULT_BUILD_ARGS) | xcpretty -c

clean:
	$(BUILD_TOOL) $(DEFAULT_BUILD_ARGS) clean | xcpretty -c

deploy: ipa upload

test: test_ios8

test_ios7:
	$(BUILD_TOOL) $(DEFAULT_BUILD_ARGS) -sdk iphonesimulator7.1 test | xcpretty -c

test_ios8:
	$(BUILD_TOOL) $(DEFAULT_BUILD_ARGS) -sdk iphonesimulator8.4 test | xcpretty -c

ci:
	set -o pipefail && $(BUILD_TOOL) $(DEFAULT_BUILD_ARGS) -sdk iphonesimulator8.3 test | tee $CIRCLE_ARTIFACTS/xcodebuild.log | xcpretty --color --report junit --output $CIRCLE_TEST_REPORTS/xcode/results.xml

ipa:
	ipa build

upload:
	deliver testflight

generate:
	ovaltine -p Sense.xcodeproj -o SleepModel/ --prefix HEM --auto-add --auto-replace --copyright 'Hello Inc' SleepModel/

deploy:
	./Scripts/deploy.sh
