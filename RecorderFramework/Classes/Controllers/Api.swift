//
//  Api.swift
//  CDPCore
//
//  Created by Marius Avram on 8/23/17.
//  Copyright © 2017 Codapper Software. All rights reserved.
//

import Alamofire

open class Api: NSObject {
    
    var baseURL:String
    open var customHeaders:[String:String]?
    var authenticationRequest:Request!
    
    public var completionHandlerLog:((String, String) -> Void)!
    
    public init(baseURL:String) {
        self.baseURL = baseURL
    }
    
    open func downloadFile(_ fromURL:String, atPath:String, completionHandler:((Bool, String) -> Void)?) {
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let url = URL(fileURLWithPath: atPath)
            return (url, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        Alamofire.download(fromURL, to: destination).response { response in
            print(response)
            if response.error == nil {
                if completionHandler != nil {
                    completionHandler!(true, "")
                }
            }
            else {
                if completionHandler != nil {
                    completionHandler!(false, response.error.debugDescription)
                }
            }
        }
    }
    
    open func upload(_ toUrl:String, imagesFiles:[String], fieldNames:[String]? = nil, parameters:[String:Any]? = nil, completionHandler:((Bool, Any) -> Void)?) {
        Alamofire.upload(multipartFormData: { (data) in
            var index = 0
            for filePath in imagesFiles {
                let name = (filePath as NSString).lastPathComponent
                var fieldName = String(index+1)
                if fieldNames != nil && fieldNames!.count > index {
                    fieldName = fieldNames![index]
                }
                var mimeType = "image/jpeg"
                if fieldName == "video" {
                    mimeType = "video/quicktime"
                }
                data.append(URL(fileURLWithPath: filePath), withName: fieldName, fileName: name, mimeType: mimeType)
                index += 1
            }
            if parameters != nil {
                for (key, value) in parameters! {
                    data.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                }
            }
            
        }, to: toUrl, method:.post, headers:customHeaders) { (result) in
            
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
                if completionHandler != nil {
                    completionHandler!(false, encodingError.localizedDescription)
                }
                break
            }
        }
    }
    
    open func doRequest(_ url:String, method:HTTPMethod, parameters:[String : Any]!, storeAuthRequest:Bool = false, completionHandler:((Bool, [String : Any]?) -> Void)?) {
        
        var jsonString = ""
        if parameters != nil {
            jsonString = "\(parameters)"
            do {
                let postData : Data = try JSONSerialization.data(withJSONObject: parameters!, options: JSONSerialization.WritingOptions.prettyPrinted)
                jsonString = NSString(data: postData, encoding: String.Encoding.utf8.rawValue)! as String
            }
            catch {
                jsonString = ""
                print(error)
            }
        }
        
        if let headers = UserDefaults.standard.dictionary(forKey: "api_custom_headers") as? [String : String] {
            self.customHeaders = headers
        }
        if customHeaders != nil && customHeaders!["Connection"] == nil {
            customHeaders!["Connection"] = "close"
        }
        
        let strHeaders = self.customHeaders != nil ? "\(self.customHeaders!)" : ""
        self.completionHandlerLog!("\(method) REQUEST:\(self.baseURL + url) \(Date()) HEADER:\(strHeaders)", "BODY:\(jsonString)")
        
        let request = Alamofire.request("\(self.baseURL)\(url)", method: method, parameters: parameters, encoding: URLEncoding.default, headers:customHeaders).responseJSON { response in
            
            if let responseString = NSString(data: response.data!, encoding: String.Encoding.utf8.rawValue) as String? {
                self.completionHandlerLog("\(method) RESPONSE:\(self.baseURL + url) \(Date())", "BODY:\(responseString)")
            }
            
            if let callback = completionHandler {
                if self.handleError(response.result)!["error"] as! String == "Invalid authorization data!" || self.handleError(response.result)!["error"] as! String == "Invalid authorization data." || ( self.handleError(response.result)!["message"] != nil && self.handleError(response.result)!["message"] as! String == "Invalid authorization data!") {
                    Alamofire.request(self.authenticationRequest.request!).responseJSON { response in
                        
                        if !response.result.isSuccess {
                            callback(false, self.handleError(response.result))
                        }
                        else {
                            if let dict = response.result.value as? NSDictionary {
                                if (dict["success"] != nil && dict["success"] as! Bool == false) || dict["error"] != nil {
                                    callback(false,self.handleError(response.result))
                                }
                                else {
                                    callback(true,["authToken":dict["authToken"]! as Any])
                                }
                            }
                        }
                    }
                    return
                }
                
                if !response.result.isSuccess {
                    callback(false, self.handleError(response.result))
                }
                else {
                    if let dict = response.result.value as? NSDictionary {
                        if let code = dict["code"] as? NSNumber, code.intValue != 200 {
                            callback(false,self.handleError(response.result))
                        }
                        else if let success = dict["success"] as? Bool, !success {
                            callback(false,self.handleError(response.result))
                        }
                        else if let errors = dict["errors"] as? NSArray, errors.count > 0 {
                            callback(false,self.handleError(response.result))
                        }
                        else {
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
                        callback(false,["error":"Invalid data format received from server."])
                    }

                }
            }
        }
        if storeAuthRequest {
            authenticationRequest = request
        }

    }

    func handleError(_ result:Result<Any>) -> [String : Any]? {
        if let dict = result.value as? NSDictionary {
            if let code = dict["code"] as? NSNumber {
                if let message = dict["message"] as? String {
                    return ["error":"\(code) - \(message)"]
                }
                else {
                    return ["error":"Failed with Error Code: \(code)"]
                }
            }
            else if let message = dict["message"] as? String {
                return ["error":"\(message)"]
            }
            else if let errors = dict["errors"] as? NSArray, errors.count > 0 {
                if let error = errors.firstObject as? String {
                    return ["error":"\(error)"]
                }
            }
        }
        
        return ["error": result.debugDescription]
    }

    
}
