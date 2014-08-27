PROJECT_NAME=SQKDataKit
WORKSPACE=$(PROJECT_NAME).xcworkspace
DEFAULT_SCHEME=$(PROJECT_NAME)
DEFAULT_FLAGS=-sdk iphonesimulator
TESTING_TOOL=xcodebuild
OUTPUT_PATH=test-report

DEFAULT_TASK=$(TESTING_TOOL) -workspace $(WORKSPACE) -scheme $(DEFAULT_SCHEME) $(DEFAULT_FLAGS) test | xcpretty --color

test:
	$(DEFAULT_TASK)

report-junit:
	$(DEFAULT_TASK) -r junit --output $(OUTPUT_PATH).xml

report-html:
	$(DEFAULT_TASK) -r html --output $(OUTPUT_PATH).html; open $(OUTPUT_PATH).html

install:
	gem install cocoapods --no-ri --no-rdoc
	gem install xcpretty  --no-ri --no-rdoc
	pod install