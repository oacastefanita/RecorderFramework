//
//  APIRequestParametersController
//  Pods
//
//  Created by Stefanita Oaca on 01/11/2018.
//
#if os(iOS)
import CoreTelephony
#elseif os(OSX)
import Cocoa
#endif

public enum ServerReuqestKeys : String {
    case phone = "phone"
    case token = "token"
    case mcc = "mcc"
    case app = "app"
    case deviceToken = "device_token"
    case deviceId = "device_id"
    case deviceType = "device_type"
    case timeZone = "time_zone"
    case apiKey = "api_key"
    case reminder = "reminder"
    case folderId = "folder_id"
    case source = "source"
    case id = "id"
    case operation = "op"
    case pass = "pass"
    case query = "q"
    case name = "name"
    case moveTo = "move_to"
    case ids = "ids"
    case action = "action"
    case type = "type"
    case star = "star"
    case play_beep = "play_beep"
    case files_permission = "files_permission"
    case reciept = "reciept"
    case title = "title"
    case body = "body"
    case language = "language"
    case parentId = "parent_id"
    case device = "device"
    case code = "code"
}

public class APIRequestParametersController: NSObject {
    
    public class func createRegisterParameters(phone: String, token:String) -> [String : Any]{
        return [ServerReuqestKeys.phone.rawValue: phone, ServerReuqestKeys.token.rawValue: token]
    }
    
    public class func createSendVerificationCodeParameters(code: String, phone:String? = nil, notificationToken:String? = nil) -> [String : Any]{
        // either recorder or reminder
        var appCode = "rec"
        if RecorderFrameworkManager.sharedInstance.isRecorder{
            appCode = "rem"
        }
        else if RecorderFrameworkManager.sharedInstance.isNoizTube {
            appCode = "nzt"
        }
        
        //no notifications on iOS simulator
        let deviceToken = notificationToken != nil ? notificationToken! : (AppPersistentData.sharedInstance.notificationToken == nil ? "Simulator" : AppPersistentData.sharedInstance.notificationToken!) //used for push notifications
        var parameters = [ServerReuqestKeys.phone.rawValue: phone != nil ? phone! : AppPersistentData.sharedInstance.phone!,ServerReuqestKeys.mcc.rawValue:"300" ,ServerReuqestKeys.code.rawValue: code, ServerReuqestKeys.token.rawValue: defaultToken, ServerReuqestKeys.app.rawValue: appCode, ServerReuqestKeys.deviceToken.rawValue:deviceToken] as [String : Any]
        //default token used by server = 55942ee3894f51000530894
        #if os(iOS)
        // find country code by using the phone carrie, default value 300
        let tn = CTTelephonyNetworkInfo();
        let carrier = tn.subscriberCellularProvider
        var mcc = "300"
        if carrier != nil && carrier!.mobileCountryCode != nil{
            mcc = (carrier != nil && !carrier!.mobileCountryCode!.isEmpty) ? carrier!.mobileCountryCode! : "300"
        }
        parameters[ServerReuqestKeys.mcc.rawValue] = mcc
        parameters[ServerReuqestKeys.deviceType.rawValue] = "ios"
        parameters[ServerReuqestKeys.deviceId.rawValue] = deviceToken
        #elseif os(OSX)
        parameters[ServerReuqestKeys.deviceType.rawValue] = "mac"
        parameters[ServerReuqestKeys.deviceId.rawValue] = RecorderFrameworkManager.sharedInstance.macSN // device identifier for pn
        #elseif os(tvOS)
        parameters[ServerReuqestKeys.mcc.rawValue] = "300"
        parameters[ServerReuqestKeys.deviceType.rawValue] = "ios"
        parameters[ServerReuqestKeys.deviceId.rawValue] = deviceToken
        #endif
        parameters[ServerReuqestKeys.timeZone.rawValue] = TimeZone.current.secondsFromGMT() / 60 // used to determine when to send pn for remind date
        return parameters
    }
    
    public class func createGetRecordingsParameters( folderId:String!, lastFileId: String! = nil, less: Bool = false, pass:String! = nil, q:String! = nil) -> [String : Any]{
        var parameters:[String : Any] = [ServerReuqestKeys.apiKey.rawValue: AppPersistentData.sharedInstance.apiKey!, ServerReuqestKeys.reminder.rawValue:"true"]
        if folderId != nil {
            parameters.updateValue(folderId!, forKey: ServerReuqestKeys.folderId.rawValue)
        }
        
        parameters[ServerReuqestKeys.source.rawValue] = "all"
        if lastFileId != nil{
            parameters[ServerReuqestKeys.id.rawValue] = lastFileId!
            parameters[ServerReuqestKeys.operation.rawValue] = less ? "less" : "grater"
        }
        if pass != nil{
            parameters[ServerReuqestKeys.pass.rawValue] = pass!
        }
        
        if q != nil{
            parameters[ServerReuqestKeys.query.rawValue] = q!
        }
        return parameters
    }
    
    public class func createSearchRecordingsParameters(q:String) -> [String : Any]{
        var parameters:[String : Any] = [ServerReuqestKeys.apiKey.rawValue: AppPersistentData.sharedInstance.apiKey!, ServerReuqestKeys.reminder.rawValue:"true"]
        parameters[ServerReuqestKeys.query.rawValue] = q
        return parameters
    }
    
    public class func createDefaultParameters() -> [String : Any]{
        return [ServerReuqestKeys.apiKey.rawValue: AppPersistentData.sharedInstance.apiKey!]
    }
    
    public class func createCreateFolderParameters(name:String, localID:String , pass:String! = nil) -> [String : Any]{
        var parameters = [ServerReuqestKeys.apiKey.rawValue: AppPersistentData.sharedInstance.apiKey!,ServerReuqestKeys.name.rawValue : name.encodedString()] as [String : Any]
        if pass != nil{
            parameters[ServerReuqestKeys.pass.rawValue] = pass
        }
        return parameters
    }
    
    public class func createDeleteFoldersParameters(folderId:String, moveTo:String!) -> [String : Any]{
        var parameters:[String:Any] = [ServerReuqestKeys.apiKey.rawValue: AppPersistentData.sharedInstance.apiKey!, ServerReuqestKeys.id.rawValue : folderId]
        if moveTo != nil && moveTo != ""{
            parameters[ServerReuqestKeys.moveTo.rawValue] = moveTo
        }
        return parameters
    }
    
    public class func createRenameFolderParameters(folderId:String, name:String) -> [String : Any]{
        let parameters:[String:Any] = [ServerReuqestKeys.apiKey.rawValue: AppPersistentData.sharedInstance.apiKey!, ServerReuqestKeys.id.rawValue : folderId, ServerReuqestKeys.name.rawValue : name.encodedString()]
        return parameters
    }
    
    public class func createDeleteRecordingParameters(recordItemId:String, removeForever:Bool) -> [String : Any]{
        let parameters:[String:Any] = [ServerReuqestKeys.apiKey.rawValue: AppPersistentData.sharedInstance.apiKey!, ServerReuqestKeys.ids.rawValue : recordItemId, ServerReuqestKeys.action.rawValue : removeForever ? "remove_forever" : ""]
        return parameters
    }
    
    public class func createAddPassToFolderParameters(folderId:String, pass:String) -> [String : Any]{
        let parameters:[String:Any] = [ServerReuqestKeys.apiKey.rawValue: AppPersistentData.sharedInstance.apiKey!, ServerReuqestKeys.id.rawValue : folderId, ServerReuqestKeys.pass.rawValue : pass]
        return parameters
    }
    
    public class func createMoveRecordingParameters(recordItem:RecordItem, folderId:String) -> [String : Any]{
        let parameters:[String:Any] = [ServerReuqestKeys.apiKey.rawValue: AppPersistentData.sharedInstance.apiKey!, ServerReuqestKeys.id.rawValue : recordItem.id!, ServerReuqestKeys.folderId.rawValue : folderId]
        return parameters
    }
    
    public class func createRecoverRecordingParameters(recordItem:RecordItem!, folderId:String) -> [String : Any]{
        let parameters:[String:Any] = [ServerReuqestKeys.apiKey.rawValue: AppPersistentData.sharedInstance.apiKey!, ServerReuqestKeys.id.rawValue : recordItem.id!, ServerReuqestKeys.folderId.rawValue : folderId]
        return parameters
    }
    
    public class func createStarItemParameters(star:Bool, entityId:String, isFile:Bool) -> [String : Any]{
        var params = [String:Any]()
        params[ServerReuqestKeys.apiKey.rawValue] = AppPersistentData.sharedInstance.apiKey!
        params[ServerReuqestKeys.type.rawValue] = isFile ? "file" : "folder"
        params[ServerReuqestKeys.id.rawValue] = entityId
        params[ServerReuqestKeys.star.rawValue] = star ? 1 : 0
        return params
    }
    
    public class func createCloneFileParameters(entityId:String) -> [String : Any]{
        var params = [String:Any]()
        params[ServerReuqestKeys.apiKey.rawValue] = AppPersistentData.sharedInstance.apiKey!
        params[ServerReuqestKeys.id.rawValue] = entityId
        return params
    }
    
    public class func createRenameRecordingParameters(recordItem:RecordItem, name:String) -> [String : Any]{
        let parameters:[String:Any] = [ServerReuqestKeys.apiKey.rawValue: AppPersistentData.sharedInstance.apiKey!, ServerReuqestKeys.id.rawValue : recordItem.id!, ServerReuqestKeys.name.rawValue:name.encodedString()]
        return parameters
    }
    
    public class func createUploadRecordingParameters(recordItem:RecordItem) -> [String : Any]{
        var data = RecorderFactory.createDictFromRecordItem(recordItem)
        var parametersId = ""
        if var id = data[ServerReuqestKeys.id.rawValue] as? String{
            if id.count > 6{
                
            }else{
                parametersId = id
            }
            
        }
        let jsonData = try! JSONSerialization.data(withJSONObject: data)
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)
        
        var parameters:[String:Any] = [ServerReuqestKeys.apiKey.rawValue: AppPersistentData.sharedInstance.apiKey!, "data": jsonString!]
        parameters[ServerReuqestKeys.id.rawValue] = parametersId
        var source = "rec"
        if RecorderFrameworkManager.sharedInstance.isRecorder{
            source = "rem"
        }
        parameters[ServerReuqestKeys.source.rawValue] = source
        return parameters
    }
    
    public class func createUpdateSettingsParameters(playBeep:Bool, filesPersmission:Bool = true) -> [String : Any]{
        let parameters:[String:Any] = [ServerReuqestKeys.apiKey.rawValue: AppPersistentData.sharedInstance.apiKey!, ServerReuqestKeys.play_beep.rawValue : playBeep ? "yes" : "no", ServerReuqestKeys.files_permission.rawValue : filesPersmission ? "public":"private"]
        return parameters
    }
    
    public class func createUpdateUserParameters(free:Bool, timezone:String! = nil) -> [String : Any]{
        var parameters:[String:Any] = [ServerReuqestKeys.apiKey.rawValue: AppPersistentData.sharedInstance.apiKey!, ServerReuqestKeys.app.rawValue : free ? "free" : "pro"]
        if timezone != nil{
            parameters[ServerReuqestKeys.timeZone.rawValue] = timezone
        }
        return parameters
    }
    
    public class func createBuyCreditsParameters(credits:Int, receipt:String) -> [String : Any]{
        var appCode = "rec"
        if RecorderFrameworkManager.sharedInstance.isRecorder{
            appCode = "rem"
        }
        
        let parameters:[String:Any] = [ServerReuqestKeys.apiKey.rawValue: AppPersistentData.sharedInstance.apiKey!, ServerReuqestKeys.app.rawValue:appCode, ServerReuqestKeys.reciept.rawValue : receipt] as [String : Any]
        return parameters
    }
    
    public class func createUpdateTokenParameters(token:String) -> [String : Any]{
        let parameters:[String:Any] = [ServerReuqestKeys.apiKey.rawValue: AppPersistentData.sharedInstance.apiKey!, ServerReuqestKeys.deviceToken.rawValue : token, ServerReuqestKeys.deviceType.rawValue : "ios"]
        return parameters
    }
    
    public class func createNotifyUserParameters(token:String) -> [String : Any]{
        let parameters:[String:Any] = [ServerReuqestKeys.apiKey.rawValue: AppPersistentData.sharedInstance.apiKey!, ServerReuqestKeys.device.rawValue : token, ServerReuqestKeys.title.rawValue : "Title", ServerReuqestKeys.body.rawValue : "body"]
        return parameters
    }
    
    public class func createGetTranslationsParameters(language:String) -> [String : Any]{
        let parameters:[String:Any] = [ServerReuqestKeys.apiKey.rawValue: AppPersistentData.sharedInstance.apiKey!, ServerReuqestKeys.language.rawValue: language]
        return parameters
    }
    
    public class func createUploadImageMetadataFileParameters(imagePath:String, fileId: String, oldId:String! = nil) -> [String : Any]{
        var parameters:[String:Any] = [ServerReuqestKeys.apiKey.rawValue: AppPersistentData.sharedInstance.apiKey!,ServerReuqestKeys.name.rawValue:fileId+"_metadata_" + UUID().uuidString, ServerReuqestKeys.parentId.rawValue:fileId]
        if oldId != nil{
            parameters[ServerReuqestKeys.id.rawValue] = oldId!
        }
        return parameters
    }
    
    public class func createUploadMetadataFileParameters(recordItem:RecordItem, oldId:String! = nil) -> [String : Any]{
        var parameters:[String:Any] = [ServerReuqestKeys.apiKey.rawValue: AppPersistentData.sharedInstance.apiKey!,ServerReuqestKeys.name.rawValue:(recordItem.text!)+"_metadata", ServerReuqestKeys.parentId.rawValue:(recordItem.id!)]
        if oldId != nil{
            parameters[ServerReuqestKeys.id.rawValue] = oldId!
        }
        return parameters
    }
    
    public class func createDeleteMetadataFileParameters(fileId:String, parentId: String! = nil) -> [String : Any]{
        var parameters:[String:Any] = [ServerReuqestKeys.apiKey.rawValue: AppPersistentData.sharedInstance.apiKey!, ServerReuqestKeys.ids.rawValue:fileId]
        if parentId != nil{
            parameters[ServerReuqestKeys.parentId.rawValue] = parentId
        }
        return parameters
    }
    
    public class func createGetMetadataFilesParameters(recordItem:RecordItem) -> [String : Any]{
        let parameters:[String:Any] = [ServerReuqestKeys.apiKey.rawValue: AppPersistentData.sharedInstance.apiKey!, ServerReuqestKeys.parentId.rawValue:(recordItem.id!)]
        return parameters
    }
    
    public class func createVerifyFolderPassParameters(pass:String, folderId:String) -> [String : Any]{
        var parameters:[String:Any] = [ServerReuqestKeys.apiKey.rawValue: AppPersistentData.sharedInstance.apiKey!]
        parameters[ServerReuqestKeys.id.rawValue] = folderId
        parameters[ServerReuqestKeys.pass.rawValue] = pass
        return parameters
    }
}
