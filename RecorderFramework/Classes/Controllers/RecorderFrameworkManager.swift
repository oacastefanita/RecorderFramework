import Foundation

public class RecorderFrameworkManager : NSObject {
    @objc public static let sharedInstance = RecorderFrameworkManager()
    
    public var isFree = false
    public var containerName:String!
    
    override public init() {
        super.init()
        #if os(iOS) || os(watchOS)
        WatchKitController.sharedInstance
        #endif
        AppPersistentData.sharedInstance.loadData()
    }
    public func searchRecordings(_ name:String) -> Array<SearchResult> {
        return RecordingsManager.sharedInstance.searchRecordings(name)
    }
    
    public func deleteRecordingItem(_ recordItemId:String) {
        RecordingsManager.sharedInstance.deleteRecordingItem(recordItemId)
    }
    
    public func buy100(reciept:String){
        AppPersistentData.sharedInstance.credits = AppPersistentData.sharedInstance.credits + 100
        AppPersistentData.sharedInstance.saveData()
            
        // server call
        ActionsSyncManager.sharedInstance.buyCredits(100, reciept: reciept)
        ActionsSyncManager.sharedInstance.startProcessingActions()
    }
    
    public func buy300(reciept:String){
        AppPersistentData.sharedInstance.credits = AppPersistentData.sharedInstance.credits + 300
        AppPersistentData.sharedInstance.saveData()
            // server call
        ActionsSyncManager.sharedInstance.buyCredits(300, reciept: reciept)
        ActionsSyncManager.sharedInstance.startProcessingActions()
    }
    
    public func buy1000(reciept:String){
        AppPersistentData.sharedInstance.credits = AppPersistentData.sharedInstance.credits + 1000
        AppPersistentData.sharedInstance.saveData()
        // server call
        ActionsSyncManager.sharedInstance.buyCredits(1000, reciept: reciept)
        ActionsSyncManager.sharedInstance.startProcessingActions()
    }
    
    public func createUserFromDict(_ dict: NSDictionary) -> User{
        return RecorderFactory.createUserFromDict(dict)
    }
    
    public func createRecordFolderFromDict(_ dict: NSDictionary) -> RecordFolder{
        return RecorderFactory.createRecordFolderFromDict(dict)
    }
    
    public func getUser() -> User{
        #if os(iOS)
        WatchKitController.sharedInstance.sendUser()
        #endif
        return AppPersistentData.sharedInstance.user
    }
    
    public func setUser(_ user:User){
        return AppPersistentData.sharedInstance.user = user
    }
    
    public func setFolders(_ folders: Array<RecordFolder>!){
        RecordingsManager.sharedInstance.recordFolders = folders
        for folder in folders{
            RecordingsManager.sharedInstance.syncItem(folder)
        }
    }
    
    public func setApiKey(_ key:String){
        AppPersistentData.sharedInstance.apiKey = key
    }
    
    public func getFilePermission() -> String?{
        return AppPersistentData.sharedInstance.filePermission
    }
    
    public func getApp() -> String?{
        return AppPersistentData.sharedInstance.app
    }
    
    public func getCredits() -> Int{
        return AppPersistentData.sharedInstance.credits
    }
    
    public func getApiKey() -> String?{
        return AppPersistentData.sharedInstance.apiKey
    }
    
    public func setFiles(_ files: Array<RecordItem>!){
        for file in files{
            for recFolder in RecordingsManager.sharedInstance.recordFolders {
                if recFolder.id == file.folderId {
                    RecordingsManager.sharedInstance.syncRecordingItem(file, folder: recFolder)
                    break
                }
            }
        }
    }
    
    public func getTranslations() -> NSDictionary{
        return TranslationManager.sharedInstance.translations
    }
    
    public func getPhoneNumbers() -> Array<PhoneNumber>{
        return AppPersistentData.sharedInstance.phoneNumbers
    }
    
    public func getLanguages() -> Array<Language>{
        return TranslationManager.sharedInstance.languages
    }
    
    public func getFolders() -> Array<RecordFolder>{
        #if os(iOS)
        WatchKitController.sharedInstance.sendFolders()
        WatchKitController.sharedInstance.sendApiKey()
        #endif
        return RecordingsManager.sharedInstance.recordFolders
    }
    
    public func getRecordingsManager() -> RecordingsManager{
        return RecordingsManager.sharedInstance
    }
    
    public func register(_ number:String, completionHandler:((Bool, Any?) -> Void)?){
        APIClient.sharedInstance.register(number as! NSString, completionHandler: completionHandler)
    }
    
    public func sendVerificationCode(_ code:String, completionHandler:((Bool, Any?) -> Void)?) {
        APIClient.sharedInstance.sendVerificationCode(code as! NSString, completionHandler: completionHandler)
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
    
    public func saveData(){
        AppPersistentData.sharedInstance.saveData()
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
    
    public func buyCredits(_ credits:Int, reciept:String!) {
        ActionsSyncManager.sharedInstance.buyCredits(credits, reciept:reciept)
    }
    
    public func createFolder(_ recordFolder:RecordFolder) {
        ActionsSyncManager.sharedInstance.createFolder(recordFolder)
    }
    
    public func deleteFolder(_ recordFolder:RecordFolder, moveToFolder:String!) {
        ActionsSyncManager.sharedInstance.deleteFolder(recordFolder, moveToFolder: moveToFolder)
    }
    
    public func renameFolder(_ recordFolder:RecordFolder) {
        ActionsSyncManager.sharedInstance.renameFolder(recordFolder)
    }
    
    public func addPasswordToFolder(_ recordFolder:RecordFolder) {
        ActionsSyncManager.sharedInstance.addPasswordToFolder(recordFolder)
    }
    
    public func deleteRecording(_ recordItem:RecordItem, forever:Bool) {
        ActionsSyncManager.sharedInstance.deleteRecording(recordItem, forever: forever)
    }
    
    public func deleteRecordings(_ recordItemIds:String, forever:Bool) {
        ActionsSyncManager.sharedInstance.deleteRecordings(recordItemIds, forever: forever)
    }
    
    public func moveRecording(_ recordItem:RecordItem, folderId:String) {
        ActionsSyncManager.sharedInstance.moveRecording(recordItem, folderId: folderId)
    }
    
    public func recoverRecording(_ recordItem:RecordItem, folderId:String) {
        ActionsSyncManager.sharedInstance.recoverRecording(recordItem, folderId: folderId)
    }
    
    public func renameRecording(_ recordItem:RecordItem) {
        ActionsSyncManager.sharedInstance.renameRecording(recordItem)
    }
    
    @objc public func uploadRecording(_ recordItem:RecordItem) {
        ActionsSyncManager.sharedInstance.uploadRecording(recordItem)
    }
    
    public func updateRecordingInfo(_ recordItem:RecordItem, fileInfo:NSMutableDictionary) {
        ActionsSyncManager.sharedInstance.updateRecordingInfo(recordItem, fileInfo: fileInfo)
    }
    
    public func updateUserProfile(_ user:User, userInfo:NSMutableDictionary) {
        ActionsSyncManager.sharedInstance.updateUserProfile(user, userInfo: userInfo)
    }
    
    public func reorderFolders(_ parameters:NSMutableDictionary) {
        ActionsSyncManager.sharedInstance.reorderFolders(parameters)
    }
    
    public func syncItem(_ recordFolder:RecordFolder) -> RecordFolder {
        return RecordingsManager.sharedInstance.syncItem(recordFolder)
    }
    
    public func syncRecordingItem(_ recordItem:RecordItem, folder:RecordFolder) -> RecordItem {
        return RecordingsManager.sharedInstance.syncRecordingItem(recordItem, folder:folder)
    }
    
    public func mainSync(_ completionHandler:((Bool) -> Void)?) {
        APIClient.sharedInstance.mainSync(completionHandler)
    }
}
