# RecorderFramework
<img src="https://github.com/oacastefanita/RecorderFramework/blob/master/Example/RecorderFramework/Images.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5%402x.png" alt="RecorderFramework"/>

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
To set up a shared app group open the Capabilities tab of your project in Xcode.
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
To enable push notifications open the Capabilities tab of your project in Xcode. Enable the Push notifications capability.

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

All public methods of the Framework have XCode standard documentation, use alt + click on any method to see it's documentation

### Register Example
```swift
RecorderFrameworkManager.sharedInstance.register("+15417543010", completionHandler: { (success, data) -> Void in
  if success {
    //handle successfull registration
  }else {
    //display error
  }
})
```
After a successfull registration a SMS,containing the registration code, will be sent to the registered phone number. Send registration code to the server.
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
### Sync 
After a successfull registration call the mainSync in order to retrieve all necessary data from the server

```swift
RecorderFrameworkManager.sharedInstance.mainSync { (success) -> Void in
  if success {

  }else{
      //display error
  }
}
```
### Other sync methods
```swift
RecorderFrameworkManager.sharedInstance.defaultFolderSync { (success) -> Void in
  if success {

  }else{
      //display error
  }  
}
```


### Folder methods
Retrieve folders from server 
```swift
RecorderFrameworkManager.sharedInstance.getFolders({ (success, data) -> Void in
  if success {

  }else{
      //display error
  }
})
```

In order to create a folder use the createFolder method of the Framework
```swift
RecorderFrameworkManager.sharedInstance.createFolder(title, localID: "", completionHandler: { (success, data) -> Void in
  if success {

  }else{
      //display error
  }
})
```

Add password to folder
```swift
if let selectedFolder = RecordingsManager.sharedInstance.getFolderWithId(folderId){
  selectedFolder.password = "MyPassword"
  RecorderFrameworkManager.sharedInstance.addPasswordToFolder(selectedFolder)
  RecorderFrameworkManager.sharedInstance.saveData()
}
NOTE: in order to remove password from folder set the password to empty string

```

Rename folder
```swift
if let selectedFolder = RecordingsManager.sharedInstance.getFolderWithId(folderId){
  selectedFolder.title = "NewName"
  RecorderFrameworkManager.sharedInstance.renameFolder(selectedFolder)
  RecorderFrameworkManager.sharedInstance.saveData()
}
```

Star folder
```swift
if let selectedFolder = RecordingsManager.sharedInstance.getFolderWithId(folderId){
  RecorderFrameworkManager.sharedInstance.star(true, entityId: selectedFolder.id, isFile: false, completionHandler: { (success, data) -> Void in
    if success {

    }else{
      //display error
    }
  })
}
```

Delete folder
```swift
if let selectedFolder = RecordingsManager.sharedInstance.getFolderWithId(folderId){
  RecorderFrameworkManager.sharedInstance.deleteFolder(selectedFolder, moveToFolder: "")
  RecordingsManager.sharedInstance.recordFolders.remove(at:     RecordingsManager.sharedInstance.recordFolders.indexOf(selectedFolder)!)
}
```

### File methods
Retrieve files from server 
```swift
RecorderFrameworkManager.sharedInstance.getRecordings(folderId, completionHandler: ({ (success, data) -> Void in
  if success {

  }else{
      //display error
  }         
}))
```
Delete file
```swift
if let selectedItem = RecordingsManager.sharedInstance.getRecordingById(recordingId) as? RecordItem{
  RecorderFrameworkManager.sharedInstance.deleteRecording(selectedItem,forever: true)
  RecorderFrameworkManager.sharedInstance.startProcessingActions()
}
```

Rename recording
```swift
if let selectedItem = RecordingsManager.sharedInstance.getRecordingById(recordingId) as? RecordItem{
  selectedItem.text = "NewTitle"
  RecorderFrameworkManager.sharedInstance.renameRecording(selectedItem)
  RecorderFrameworkManager.sharedInstance.saveData()
}
```

Move recording
```swift
if let selectedItem = RecordingsManager.sharedInstance.getRecordingById("recordingId") as? RecordItem{
  if let selectedFolder = RecordingsManager.sharedInstance.getFolderWithId("folderId"){
    RecorderFrameworkManager.sharedInstance.moveRecording(selectedItem, folderId: selectedFolder.id)
    RecorderFrameworkManager.sharedInstance.saveData()
  }
}
```

Recover recording
```swift
if let selectedItem = RecordingsManager.sharedInstance.getRecordingById("recordingId") as? RecordItem{
  if let selectedFolder = RecordingsManager.sharedInstance.getFolderWithId("folderId"){
    RecorderFrameworkManager.sharedInstance.recoverRecording(selectedItem, folderId: selectedFolder.id)
    RecorderFrameworkManager.sharedInstance.saveData()
  }
}
```

Star recording
```swift
if let selectedItem = RecordingsManager.sharedInstance.getRecordingById(recordingId) as? RecordItem{
  RecorderFrameworkManager.sharedInstance.star(true, entityId: selectedItem.id, isFile: true, completionHandler: { (success, data) -> Void in
    if success {

    }else{
      //display error
    }
  })
}
```

Upload recording
```swift
file.fileDownloaded = true
let fileManager = FileManager.default
let sharedContainer = fileManager.containerURL(forSecurityApplicationGroupIdentifier: RecorderFrameworkManager.sharedInstance.containerName)
let oldPath = sharedContainer?.appendingPathComponent("Recording1.wav")
var newPath = "/" + (RecordingsManager.sharedInstance.recordFolders.first?.title)! + "/" + file.id
if !FileManager.default.fileExists(atPath: (sharedContainer?.path)! + newPath) {
  do {
    try FileManager.default.createDirectory(atPath: (sharedContainer?.path)! + newPath, withIntermediateDirectories: true, attributes: nil)
  } catch _ {
  }
}
newPath = newPath + "/" + file.id + ".wav"
 do {
  try fileManager.moveItem(atPath: (oldPath?.path)!, toPath: (sharedContainer?.path)! + newPath)
  file.localFile = newPath
  } catch let error as NSError {
    print("Ooops! Something went wrong: \(error)")
  }
RecorderFrameworkManager.sharedInstance.uploadRecording(file)
RecorderFrameworkManager.sharedInstance.saveData()
 ```  
        
## Author

Samer Bazzi
Selectinventory, Inc
380 N Old Woodward Ave #240
Birmingham, MI MI 48009
United States
Tel. 1-313-522-5710
selectinventory@gmail.com

## License

RecorderFramework is available under the MIT license. See the LICENSE file for more info.
