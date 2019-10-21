package:
	xcodebuild -workspace WhatsApp\ Faker.xcworkspace -scheme WhatsApp\ Faker clean archive -configuration release -sdk iphoneos -archivePath wafaker.xcarchive
	rm -r WhatsApp\ Faker.app || true
	mv wafaker.xcarchive/Products/Applications/WhatsApp\ Faker.app/ .	
	python3 sign.py
install:
	rsync -rv WhatsApp\ Faker.app root@${THEOS_DEVICE_IP}:/Applications/
