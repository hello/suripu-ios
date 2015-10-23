DEFAULT_TASK=xcodebuild -workspace Sense.xcworkspace -scheme Sense
CI_TASK=$(DEFAULT_TASK) -sdk iphonesimulator -destination "platform=iOS Simulator,name=iPhone 6,OS=9.0"

.PHONY:

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

ci_deps:
	gem install xcpretty --no-ri --no-rdoc -v 0.1.12

ci:
	set -o pipefail && $(CI_TASK) test | tee $(CIRCLE_ARTIFACTS)/xcodebuild.log | xcpretty --color --report junit --output $(CIRCLE_TEST_REPORTS)/xcode/results.xml
	./Scripts/pods_project_fmt_checker.sh

ipa:
	ipa build

upload:
	deliver testflight

generate:
	ovaltine -p Sense.xcodeproj -o SleepModel/ --prefix HEM --auto-add --auto-replace --copyright 'Hello Inc' SleepModel/

deploy:
	./Scripts/deploy.sh
