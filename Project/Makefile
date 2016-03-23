PROJECT_NAME=SQKDataKit
WORKSPACE=$(PROJECT_NAME).xcworkspace
SCHEME=$(PROJECT_NAME)
SDK=iphonesimulator
TESTING_TOOL=xcodebuild
OUTPUT_PATH=test-report

DEFAULT_TASK=xcodebuild -workspace $(WORKSPACE) -scheme $(SCHEME) -sdk $(SDK) clean test | xcpretty --color ; exit ${PIPESTATUS[0]}

test:
	$(DEFAULT_TASK)

travis-test:
	# travis-ci.org uses xctool rather than xcodebuild
	xctool -workspace $(WORKSPACE) -scheme $(SCHEME) test -sdk $(SDK) ONLY_ACTIVE_ARCH=NO

report-junit:
	$(DEFAULT_TASK) -r junit --output $(OUTPUT_PATH).xml

report-html:
	$(DEFAULT_TASK) -r html --output $(OUTPUT_PATH).html; open $(OUTPUT_PATH).html

install:
	gem install cocoapods --no-ri --no-rdoc
	gem install xcpretty  --no-ri --no-rdoc
	pod install