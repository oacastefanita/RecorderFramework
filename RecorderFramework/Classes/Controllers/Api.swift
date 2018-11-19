//
//  Api.swift
//  CDPCore
//
//  Created by Marius Avram on 8/23/17.
//  Copyright © 2017 Codapper Software. All rights reserved.
//

import Alamofire

// all server response keys
public enum ServerResponseKeys : String {
    case message = "msg"
    case error = "error"
    case status = "status"
    case ok = "ok"
    case code = "code"
}

class Api: NSObject {
    var baseURL:String
    var completionHandlerLog:((String, String) -> Void)!// for loggin purposes
    
    init(baseURL:String) {
        self.baseURL = baseURL
    }
    
    func downloadFile(_ fromURL:String, atPath:String, completionHandler:((Bool, String) -> Void)?) {
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let url = URL(fileURLWithPath: atPath)
            return (url, [.removePreviousFile, .createIntermediateDirectories])
        }
        AnalyticsManager.sharedInstance.track("Download File", properties: ["file":fromURL])
        Alamofire.download(fromURL, to: destination).response { response in
            print(response)
            if response.error == nil {
                if completionHandler != nil {
                    completionHandler!(true, "")
                }
            }
            else {
               AnalyticsManager.sharedInstance.track("Donwload Failed \(fromURL)", properties: ["response":response.error.debugDescription, "file":fromURL])
                if completionHandler != nil {
                    completionHandler!(false, response.error.debugDescription)
                }
            }
        }
    }
    
    func upload(_ toUrl:String, imagesFiles:[String], fieldNames:[String]? = nil, parameters:[String:Any]? = nil, mimeType:String = "audio/wav", completionHandler:((Bool, Any) -> Void)?) {
        AnalyticsManager.sharedInstance.track("Upload \(toUrl)", properties: parameters)
        Alamofire.upload(multipartFormData: { (data) in
            var index = 0
            for filePath in imagesFiles {
                let name = (filePath as NSString).lastPathComponent
                var fieldName = String(index+1)
                if fieldNames != nil && fieldNames!.count > index {
                    fieldName = fieldNames![index]
                }
                data.append(URL(fileURLWithPath: filePath), withName: fieldName, fileName: name, mimeType: mimeType)
                index += 1
            }
            if parameters != nil {
                for (key, value) in parameters! {
                    let paramsData:Data = NSKeyedArchiver.archivedData(withRootObject: value)
                    data.append(paramsData, withName: key)
//                    data.append((value as! AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                }
            }
            self.completionHandlerLog!("REQUEST:\(toUrl)", " BODY:\(data)")
        }, to: toUrl, method:.post, headers:nil) { (result) in
            
            switch result {
            case .success(let upload, _, _):
                
                upload.responseJSON { response in
                    self.completionHandlerLog("UPLOAD RESPONSE:\(toUrl) \(Date())", "BODY:\(NSString(data: response.data!, encoding: String.Encoding.utf8.rawValue)! as String)")
                    
                    do {
                        let json = try JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as? [String:Any]
                        if completionHandler != nil {
                            completionHandler!(true, json as Any)
                        }
                        return
                    } catch {
                        print("Upload response not json formatted.")
                    }
                    if completionHandler != nil {
                        completionHandler!(true, "")
                    }
                }
                
            case .failure(let encodingError):
                self.completionHandlerLog("UPLOAD RESPONSE:\(toUrl) \(Date())", "ERROR:\(encodingError.localizedDescription)")
                AnalyticsManager.sharedInstance.track("Upload Failed \(toUrl)", properties: ["response":encodingError.localizedDescription])
                if completionHandler != nil {
                    completionHandler!(false, encodingError.localizedDescription)
                }
                break
            }
        }
    }
    
    func doRequest(_ url:String, method:HTTPMethod, parameters:[String : Any]!, storeAuthRequest:Bool = false, completionHandler:((Bool, [String : Any]?) -> Void)?) {
        
        //for loging purposes
        var jsonString = ""
        if parameters != nil {
            jsonString = "\(parameters!)"
        }
        self.completionHandlerLog!("\(method) REQUEST:\(self.baseURL + url) \(Date())", "BODY:\(jsonString)")
        AnalyticsManager.sharedInstance.track("Request \(url)", properties: parameters)
        
        //server request, componse url from base + relative path
        let request = Alamofire.request("\(self.baseURL)\(url)", method: method, parameters: parameters!, encoding: URLEncoding.default, headers:nil).responseJSON { response in
            
            //for loging purposes
            if let responseString = NSString(data: response.data!, encoding: String.Encoding.utf8.rawValue) as String? {
                self.completionHandlerLog("\(method) RESPONSE:\(self.baseURL + url) \(Date())", "BODY:\(responseString)")
            }
            
            if let callback = completionHandler {
                if !response.result.isSuccess {
                    AnalyticsManager.sharedInstance.track("Request Failed \(url)", properties: ["response":response.result.debugDescription])
                    callback(false, self.handleError(response.result))
                }
                else {
                    if let dict = response.result.value as? NSDictionary {
                        if dict[ServerResponseKeys.status.rawValue] != nil && (dict[ServerResponseKeys.status.rawValue] as? String) != ServerResponseKeys.ok.rawValue {
                            AnalyticsManager.sharedInstance.track("Request Failed \(url)", properties: dict as! [AnyHashable : Any])
                            callback(false,self.handleError(response.result))
                        }else {
                            callback(true,dict as? [String : Any])
                        }
                    }
                    else if let array = response.result.value as? NSArray {
                        callback(true,["root":array])
                    }
                    else if response.response?.statusCode == 204 {
                        callback(true,["root":"success"])
                    }
                    else {
                        AnalyticsManager.sharedInstance.track("Request Failed \(url)", properties: ["response":response.result.debugDescription])
                        callback(false,["error":"Invalid data format received from server."])
                    }

                }
            }
        }
    }

    //preety print the error returned by the server
    func handleError(_ result:Result<Any>) -> [String : Any]? {
        if let dict = result.value as? NSDictionary {
            if let code = dict[ServerResponseKeys.code.rawValue] as? String {
                if let message = dict[ServerResponseKeys.message.rawValue] as? String {
                    return ["error":"\(code) - \(message)"]
                }
                else {
                    return ["error":"Failed with Error Code: \(code)"]
                }
            }
            else if let message = dict[ServerResponseKeys.message.rawValue] as? String {
                return ["error":"\(message)"]
            }
        }
        
        return ["error": result.debugDescription]
    }

    
}
