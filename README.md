# RecorderFramework

[![CI Status](http://img.shields.io/travis/oacastefanita/RecorderFramework.svg?style=flat)](https://travis-ci.org/oacastefanita/RecorderFramework)
[![Version](https://img.shields.io/cocoapods/v/RecorderFramework.svg?style=flat)](http://cocoapods.org/pods/RecorderFramework)
[![License](https://img.shields.io/cocoapods/l/RecorderFramework.svg?style=flat)](http://cocoapods.org/pods/RecorderFramework)
[![Platform](https://img.shields.io/cocoapods/p/RecorderFramework.svg?style=flat)](http://cocoapods.org/pods/RecorderFramework)

## Requirements
Minimum deployment target for iOS  is 10.0.

Minimum deployment target for watchOS  is 3.2.

Minimum deployment target for tvOS  is 10.13.

Minimum deployment target for macOS  is 10.12.


## Installation

RecorderFramework is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "RecorderFramework"
```

### Create App Group 
To set up a shared app group
Open the Capabilities tab of your project in Xcode.
Enable the App Groups capability. This adds an entitlement file (if needed) to the selected target and adds the com.apple.security.application-groups entitlement to that file.e information, see Configuring App Groups in App Distribution Guide.

Import RecorderFramework  in AppDelegate. 
```swift
import RecorderFramework
```
Add the following code to "didFinishLaunchingWithOptions" method in AppDelegate. 
```swift
RecorderFrameworkManager.sharedInstance.containerName = "group.com.codebluestudio.Recorder"
```
### Push notifications
To set up a shared app group.

Open the Capabilities tab of your project in Xcode.

Enable the Push notifications capability.


Import UserNotifications  in AppDelegate and request notification permission in "didFinishLaunchingWithOptions"
```swift
import UserNotifications
```
```swift
let center  = UNUserNotificationCenter.current()
center.delegate = self
center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in
  if error == nil{
    DispatchQueue.main.async {
      UIApplication.shared.registerForRemoteNotifications()
    }
  }
}
```

Add the following code to "didFailToRegisterForRemoteNotificationsWithError" method in AppDelegate
```swift
var newToken: String = ""
for i in 0..<deviceToken.count {
  newToken += String(format: "%02.2hhx", deviceToken[i] as CVarArg)
}
AppPersistentData.sharedInstance.notificationToken = newToken
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

# Register Example
```swift
RecorderFrameworkManager.sharedInstance.register("+15417543010", completionHandler: { (success, data) -> Void in
  if success {
    //handle successfull registration
  }else {
    //display error
  }
})
```
After a successfull registration a SMS,containing the registration code, will be sent to the registered phone number
```swift
RecorderFrameworkManager.sharedInstance.sendVerificationCode("12345", completionHandler: { (success, data) -> Void in
  if success {
    //Call main Sync to retrieve all the required data from the server
    RecorderFrameworkManager.sharedInstance.mainSync { (success) -> Void in
      if success {
      
      }else{
      //display error
      }
    }
  }else{
      //display error
  }
})
```

## Author

oacastefanita, oacastefanita@gmail.com

## License

RecorderFramework is available under the MIT license. See the LICENSE file for more info.
