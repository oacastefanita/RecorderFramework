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

public class APIRequestParametersController: NSObject {
    
    public class func createRegisterParameters(phone: String, token:String) -> [String : Any]{
        return ["phone": phone, "token": token]
    }
    
    public class func createSendVerificationCodeParameters(code: String) -> [String : Any]{
        // either recorder or reminder
        var appCode = "rec"
        if RecorderFrameworkManager.sharedInstance.isRecorder{
            appCode = "rem"
        }
        
        //no notifications on iOS simulator
        let deviceToken =  AppPersistentData.sharedInstance.notificationToken == nil ? "Simulator" : AppPersistentData.sharedInstance.notificationToken! //used for push notifications
        var parameters = ["phone": AppPersistentData.sharedInstance.phone!,"mcc":"300" ,"code": code, "token": "55942ee3894f51000530894", "app": appCode, "device_token":deviceToken] as [String : Any]
        //default token used by server = 55942ee3894f51000530894
        #if os(iOS)
        // find country code by using the phone carrie, default value 300
        let tn = CTTelephonyNetworkInfo();
        let carrier = tn.subscriberCellularProvider
        var mcc = "300"
        if carrier != nil && carrier!.mobileCountryCode != nil{
            mcc = (carrier != nil && !carrier!.mobileCountryCode!.isEmpty) ? carrier!.mobileCountryCode! : "300"
        }
        parameters["mcc"] = mcc
        parameters["device_type"] = "ios"
        parameters["device_id"] = deviceToken
        #elseif os(OSX)
        parameters["device_type"] = "mac"
        parameters["device_id"] = RecorderFrameworkManager.sharedInstance.macSN // device identifier for pn
        #elseif os(tvOS)
        parameters["mcc"] = "300"
        parameters["device_type"] = "ios"
        #endif
        parameters["time_zone"] = TimeZone.current.secondsFromGMT() / 60 // used to determine when to send pn for remind date
        return parameters
    }
    
    public class func createGetRecordingsParameters( folderId:String!, lastFileId: String! = nil, less: Bool = false, pass:String! = nil, q:String! = nil) -> [String : Any]{
        var parameters:[String : Any] = ["api_key": AppPersistentData.sharedInstance.apiKey!, "reminder":"true"]
        if folderId != nil {
            parameters.updateValue(folderId!, forKey: "folder_id")
        }
        
        parameters["source"] = "all"
        if lastFileId != nil{
            parameters["id"] = lastFileId!
            parameters["op"] = less ? "less" : "grater"
        }
        if pass != nil{
            parameters["pass"] = pass!
        }
        
        if q != nil{
            parameters["q"] = q!
        }
        return parameters
    }
    
    public class func createSearchRecordingsParameters(q:String) -> [String : Any]{
        var parameters:[String : Any] = ["api_key": AppPersistentData.sharedInstance.apiKey!, "reminder":"true"]
        parameters["q"] = q
        return parameters
    }
    
    public class func createDefaultParameters() -> [String : Any]{
        return ["api_key": AppPersistentData.sharedInstance.apiKey!]
    }
    
    public class func createCreateFolderParameters(name:String, localID:String , pass:String! = nil) -> [String : Any]{
        var parameters = ["api_key": AppPersistentData.sharedInstance.apiKey!, "name" : name] as [String : Any]
        if pass != nil{
            parameters["pass"] = pass
        }
        return parameters
    }
    
    public class func createDeleteFoldersParameters(folderId:String, moveTo:String!) -> [String : Any]{
        var parameters:[String:Any] = ["api_key": AppPersistentData.sharedInstance.apiKey!, "id" : folderId]
        if moveTo != nil && moveTo != ""{
            parameters["move_to"] = moveTo
        }
        return parameters
    }
    
    public class func createRenameFolderParameters(folderId:String, name:String) -> [String : Any]{
        let parameters:[String:Any] = ["api_key": AppPersistentData.sharedInstance.apiKey!, "id" : folderId, "name" : name]
        return parameters
    }
    
    public class func createDeleteRecordingParameters(recordItemId:String, removeForever:Bool) -> [String : Any]{
        let parameters:[String:Any] = ["api_key": AppPersistentData.sharedInstance.apiKey!, "ids" : recordItemId, "action" : removeForever ? "remove_forever" : ""]
        return parameters
    }
    
    public class func createAddPassToFolderParameters(folderId:String, pass:String) -> [String : Any]{
        let parameters:[String:Any] = ["api_key": AppPersistentData.sharedInstance.apiKey!, "id" : folderId, "pass" : pass]
        return parameters
    }
    
    public class func createMoveRecordingParameters(recordItem:RecordItem, folderId:String) -> [String : Any]{
        let parameters:[String:Any] = ["api_key": AppPersistentData.sharedInstance.apiKey!, "id" : recordItem.id!, "folder_id" : folderId]
        return parameters
    }
    
    public class func createRecoverRecordingParameters(recordItem:RecordItem, folderId:String) -> [String : Any]{
        let parameters:[String:Any] = ["api_key": AppPersistentData.sharedInstance.apiKey!, "id" : recordItem.id, "folder_id" : folderId]
        return parameters
    }
    
    public class func createStarItemParameters(star:Bool, entityId:String, isFile:Bool) -> [String : Any]{
        var params = [String:Any]()
        params["api_key"] = AppPersistentData.sharedInstance.apiKey!
        params["type"] = isFile ? "file" : "folder"
        params["id"] = entityId
        params["star"] = star ? 1 : 0
        return params
    }
    
    public class func createCloneFileParameters(entityId:String) -> [String : Any]{
        var params = [String:Any]()
        params["api_key"] = AppPersistentData.sharedInstance.apiKey!
        params["id"] = entityId
        return params
    }
    
    public class func createRenameRecordingParameters(recordItem:RecordItem, name:String) -> [String : Any]{
        let parameters:[String:Any] = ["api_key": AppPersistentData.sharedInstance.apiKey!, "id" : recordItem.id!, "name":name]
        return parameters
    }
}
