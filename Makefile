PROJECT_NAME=Sense
DEFAULT_TASK=xcodebuild -workspace Sense.xcworkspace -scheme Sense

default: build

bootstrap:
	gem install xcpretty ovaltine shenzhen deliver --quiet --no-ri --no-rdoc

build:
	$(DEFAULT_TASK) | xcpretty -c

clean:
	$(DEFAULT_TASK) clean | xcpretty -c

deploy: ipa upload

test: test_ios9

test_ios9:
	$(DEFAULT_TASK) -sdk iphonesimulator9.0 test | xcpretty -c

ci:
	set -o pipefail && $(DEFAULT_TASK) -sdk iphonesimulator8.3 test | tee $CIRCLE_ARTIFACTS/xcodebuild.log | xcpretty --color --report junit --output $CIRCLE_TEST_REPORTS/xcode/results.xml

ipa:
	ipa build

upload:
	deliver testflight

generate:
	ovaltine -p Sense.xcodeproj -o SleepModel/ --prefix HEM --auto-add --auto-replace --copyright 'Hello Inc' SleepModel/

deploy:
	./Scripts/deploy.sh
