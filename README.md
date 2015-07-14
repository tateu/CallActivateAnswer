# Call Activate Answer
An Activator listener to perform an action when a call is received from a specific set of phone numbers.

There is currently no Preference panel. You have to manually edit the plsit file: /var/mobile/Library/Preferences/net.tateu.callansweractivate.plist

```<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>numbers</key>
	<array>
		<dict>
			<key>enabled</key>
			<true/>
			<key>answerDelay</key>
			<real>0.0</real>
			<key>eventDelay</key>
			<real>0.0</real>
			<key>number</key>
			<string>5555555555</string>
		</dict>
	</array>
</dict>
</plist>```
