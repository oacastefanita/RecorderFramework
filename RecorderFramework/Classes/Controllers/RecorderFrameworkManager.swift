import Foundation

public class RecorderFrameworkManager : NSObject {
    @objc public static let sharedInstance = RecorderFrameworkManager()
    
    public var isFree = false
    
    override public init() {
        super.init()
    }
    
    public func getFolders() -> Array<RecordFolder>{
        return RecordingsManager.sharedInstance.recordFolders
    }
    
    public func register(_ number:String, completionHandler:((Bool, Any?) -> Void)?){
        APIClient.sharedInstance.register(number as NSString, completionHandler: completionHandler)
    }
    
    public func sendVerificationCode(_ code:String, completionHandler:((Bool, Any?) -> Void)?) {
        APIClient.sharedInstance.sendVerificationCode(code as NSString, completionHandler: completionHandler)
    }
    
    public func getFolders(_ completionHandler:((Bool, Any?) -> Void)?) {
        APIClient.sharedInstance.getFolders(completionHandler)
    }
    
    public func getRecordings(_ folderId:String!, completionHandler:((Bool, Any?) -> Void)?) {
        APIClient.sharedInstance.getRecordings(folderId, completionHandler: completionHandler)
    }
    
    public func getPhoneNumbers(_ completionHandler:((Bool, Any?) -> Void)?) {
        APIClient.sharedInstance.getPhoneNumbers(completionHandler)
    }
    
    public func createFolder(_ name:String, localID:String, completionHandler:((Bool, Any?) -> Void)?){
        APIClient.sharedInstance.createFolder(name as NSString, localID: localID as NSString, completionHandler: completionHandler)
    }
    
    public func deleteFolder(_ folderId:String, moveTo:String!, completionHandler:((Bool, Any?) -> Void)?) {
        APIClient.sharedInstance.deleteFolder(folderId, moveTo: moveTo, completionHandler: completionHandler)
    }
    
    public func reorderFolders(_ parameters:[String:Any], completionHandler:((Bool, Any?) -> Void)?) {
        APIClient.sharedInstance.reorderFolders(parameters, completionHandler: completionHandler)
    }
    
    public func renameFolder(_ folderId:String, name:String, completionHandler:((Bool, Any?) -> Void)?) {
        APIClient.sharedInstance.renameFolder(folderId, name: name, completionHandler: completionHandler)
    }
    
    public func addPasswordToFolder(_ folderId:String, pass:String, completionHandler:((Bool, Any?) -> Void)?) {
        APIClient.sharedInstance.addPasswordToFolder(folderId, pass: pass, completionHandler: completionHandler)
    }
    
    public func deleteRecording(_ recordItemId:String, removeForever:Bool, completionHandler:((Bool, Any?) -> Void)?) {
        APIClient.sharedInstance.deleteRecording(recordItemId, removeForever: removeForever, completionHandler: completionHandler)
    }
    
    public func moveRecording(_ recordItem:RecordItem, folderId:String, completionHandler:((Bool, Any?) -> Void)?) {
        APIClient.sharedInstance.moveRecording(recordItem, folderId: folderId, completionHandler: completionHandler)
    }
    
    public func recoverRecording(_ recordItem:RecordItem, folderId:String, completionHandler:((Bool, Any?) -> Void)?) {
        APIClient.sharedInstance.recoverRecording(recordItem, folderId: folderId, completionHandler: completionHandler)
    }
    
    public func updateRecordingInfo(_ recordItem:RecordItem ,parameters:[String:Any], completionHandler:((Bool, Any?) -> Void)?) {
        APIClient.sharedInstance.updateRecordingInfo(recordItem, parameters: parameters, completionHandler: completionHandler)
    }
    
    public func star(_ star:Bool, entityId:String, isFile:Bool, completionHandler:((Bool, Any?) -> Void)?) {
        APIClient.sharedInstance.star(star, entityId: entityId, isFile: isFile, completionHandler: completionHandler)
    }
    
    public func cloneFile(entityId:String, completionHandler:((Bool, Any?) -> Void)?) {
        APIClient.sharedInstance.cloneFile(entityId: entityId, completionHandler: completionHandler)
    }
    
    public func renameRecording(_ recordItem:RecordItem, name:String, completionHandler:((Bool, Any?) -> Void)?) {
        APIClient.sharedInstance.renameRecording(recordItem, name: name, completionHandler: completionHandler)
    }
    
    public func uploadRecording(_ recordItem:RecordItem, completionHandler:((Bool, Any?) -> Void)?) {
        APIClient.sharedInstance.uploadRecording(recordItem, completionHandler: completionHandler)
    }
    
    public func downloadFile(_ fileUrl:String, localPath:String, completionHandler:((Bool) -> Void)?){
        APIClient.sharedInstance.downloadFile(fileUrl, localPath: localPath, completionHandler: completionHandler)
    }
    
    public func downloadAudioFile(_ recordItem:RecordItem, toFolder:String, completionHandler:((Bool) -> Void)?) {
        APIClient.sharedInstance.downloadAudioFile(recordItem, toFolder: toFolder, completionHandler: completionHandler)
    }
    
    public func updateSettings(_ playBeep:Bool, completionHandler:((Bool, Any?) -> Void)?) {
        APIClient.sharedInstance.updateSettings(playBeep, completionHandler: completionHandler)
    }
    
    public func updateUser(_ free:Bool, completionHandler:((Bool, Any?) -> Void)?) {
        APIClient.sharedInstance.updateUser(free, completionHandler: completionHandler)
    }
    
    public func getSettings(_ completionHandler:((Bool, Any?) -> Void)?){
        APIClient.sharedInstance.getSettings(completionHandler)
    }
    
    public func getTranslations(_ language:String,completionHandler:((Bool, Any?) -> Void)?){
        APIClient.sharedInstance.getTranslations(language, completionHandler: completionHandler)
    }
    
    public func getLanguages(_ completionHandler:((Bool, Any?) -> Void)?){
        APIClient.sharedInstance.getLanguages(completionHandler)
    }
    
    @objc public func getMessages(_ completionHandler:((Bool, Any?) -> Void)?){
        APIClient.sharedInstance.getMessages(completionHandler)
    }
    
    public func getProfile(_ completionHandler:((Bool, Any?) -> Void)?){
        APIClient.sharedInstance.getProfile(completionHandler)
    }
}
