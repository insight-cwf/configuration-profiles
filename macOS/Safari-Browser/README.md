# Safari Browser

## WSO

Copy the contents of `com.apple.Safari-WSO.plist` from `<dict> ... to ... </dict>` and paste it in a custom payload in the WSO console for macOS.

```xml
<dict>
    <key>PayloadOrganization</key>
    <string>Avengers</string>
    <key>PayloadType</key>
    <string>com.apple.Safari</string>
    <key>PayloadUUID</key>
    <string>2be25ac7-139d-4794-9c91-37d4e1e448b4</string>
    <key>label</key>
    <string>com.apple.Safari</string>
    <key>HomePage</key>
    <string>https://duckduckgo.com</string>
    <key>NewWindowBehavior</key>
    <integer>0</integer>
    <key>AXFullScreen</key>
    <true/>
</dict>
```

### Other

The `com.apple.Safari.plist` file contains all the keys that I have come across recently.
