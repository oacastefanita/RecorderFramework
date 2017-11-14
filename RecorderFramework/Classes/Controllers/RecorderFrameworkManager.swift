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
    /// Search Recordings
    ///
    /// - Parameter name: search string
    /// - Returns: array of SearchResult objects
    public func searchRecordings(_ name:String) -> Array<SearchResult> {
        return RecordingsManager.sharedInstance.searchRecordings(name)
    }
    
    /// Delete recording
    ///
    /// - Parameter recordItemId: id of the item to be deleted
    public func deleteRecordingItem(_ recordItemId:String) {
        RecordingsManager.sharedInstance.deleteRecordingItem(recordItemId)
    }
    
    /// Buy 100 credits
    ///
    /// - Parameter reciept: in app purchase id
    public func buy100(reciept:String){
        AppPersistentData.sharedInstance.credits = AppPersistentData.sharedInstance.credits + 100
        AppPersistentData.sharedInstance.saveData()
            
        // server call
        ActionsSyncManager.sharedInstance.buyCredits(100, reciept: reciept)
        ActionsSyncManager.sharedInstance.startProcessingActions()
    }
    
    /// Buy 300 credits
    ///
    /// - Parameter reciept: in app purchase id
    public func buy300(reciept:String){
        AppPersistentData.sharedInstance.credits = AppPersistentData.sharedInstance.credits + 300
        AppPersistentData.sharedInstance.saveData()
            // server call
        ActionsSyncManager.sharedInstance.buyCredits(300, reciept: reciept)
        ActionsSyncManager.sharedInstance.startProcessingActions()
    }
    
    /// Buy 1000 credits
    ///
    /// - Parameter reciept: in app purchase id
    public func buy1000(reciept:String){
        AppPersistentData.sharedInstance.credits = AppPersistentData.sharedInstance.credits + 1000
        AppPersistentData.sharedInstance.saveData()
        // server call
        ActionsSyncManager.sharedInstance.buyCredits(1000, reciept: reciept)
        ActionsSyncManager.sharedInstance.startProcessingActions()
    }
    
    /// Create User object from NSDictionary
    ///
    /// - Parameter dict: dict with data
    /// - Returns: populated User object
    public func createUserFromDict(_ dict: NSDictionary) -> User{
        return RecorderFactory.createUserFromDict(dict)
    }
    
    /// Create User object from NSDictionary
    ///
    /// - Parameter dict: dict with data
    /// - Returns: populated RecordFolder object
    public func createRecordFolderFromDict(_ dict: NSDictionary) -> RecordFolder{
        return RecorderFactory.createRecordFolderFromDict(dict)
    }
    
    /// Get current user
    ///
    /// - Returns: current user
    public func getUser() -> User{
        #if os(iOS)
        WatchKitController.sharedInstance.sendUser()
        #endif
        return AppPersistentData.sharedInstance.user
    }
    
    /// Set current user
    ///
    /// - Parameter user: new current user
    public func setUser(_ user:User){
        return AppPersistentData.sharedInstance.user = user
    }
    
    /// Set new folders
    ///
    /// - Parameter folders: new folders
    public func setFolders(_ folders: Array<RecordFolder>!){
        RecordingsManager.sharedInstance.recordFolders = folders
        for folder in folders{
            RecordingsManager.sharedInstance.syncItem(folder)
        }
    }
    
    /// Set new API Key
    ///
    /// - Parameter key: new API Key
    public func setApiKey(_ key:String){
        AppPersistentData.sharedInstance.apiKey = key
    }
    
    /// Get file permission
    ///
    /// - Returns: file permission
    public func getFilePermission() -> String?{
        return AppPersistentData.sharedInstance.filePermission
    }
    
    /// Get app
    ///
    /// - Returns: app
    public func getApp() -> String?{
        return AppPersistentData.sharedInstance.app
    }
    
    /// Get Credits
    ///
    /// - Returns: credits
    public func getCredits() -> Int{
        return AppPersistentData.sharedInstance.credits
    }
    
    /// Get API Key
    ///
    /// - Returns: API Key
    public func getApiKey() -> String?{
        return AppPersistentData.sharedInstance.apiKey
    }
    
    /// Set new files
    ///
    /// - Parameter files: new files
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
    
    /// Get translations
    ///
    /// - Returns: translations dictionary
    public func getTranslations() -> NSDictionary{
        return TranslationManager.sharedInstance.translations
    }
    
    /// Get Phone numbers
    ///
    /// - Returns: PhoneNumber objects array
    public func getPhoneNumbers() -> Array<PhoneNumber>{
        return AppPersistentData.sharedInstance.phoneNumbers
    }
    
    /// Get Languages
    ///
    /// - Returns: Language objects array
    public func getLanguages() -> Array<Language>{
        return TranslationManager.sharedInstance.languages
    }
    
    /// Get folders
    ///
    /// - Returns: Folder Objects Array
    public func getFolders() -> Array<RecordFolder>{
        #if os(iOS)
        WatchKitController.sharedInstance.sendFolders()
        WatchKitController.sharedInstance.sendApiKey()
        #endif
        return RecordingsManager.sharedInstance.recordFolders
    }
    
    /// Get Recordings Manager singleton
    ///
    /// - Returns: Recordings Manager singleton
    public func getRecordingsManager() -> RecordingsManager{
        return RecordingsManager.sharedInstance
    }
    
    /// Register phone number
    ///
    /// - Parameters:
    ///   - number: phone number to be registered
    ///   - completionHandler: block to be called upon receiving the server's response
    public func register(_ number:String, completionHandler:((Bool, Any?) -> Void)?){
        APIClient.sharedInstance.register(number as! NSString, completionHandler: completionHandler)
    }
    
    /// Send the verification code received via SMS
    ///
    /// - Parameters:
    ///   - code: code received via sms
    ///   - completionHandler: block to be called upon receiving the server's response
    public func sendVerificationCode(_ code:String, completionHandler:((Bool, Any?) -> Void)?) {
        APIClient.sharedInstance.sendVerificationCode(code as! NSString, completionHandler: completionHandler)
    }
    
    /// Get folders
    ///
    /// - Parameter completionHandler: block to be called upon receiving the server's response
    public func getFolders(_ completionHandler:((Bool, Any?) -> Void)?) {
        APIClient.sharedInstance.getFolders(completionHandler)
    }
    
    /// Get recordings for folder
    ///
    /// - Parameters:
    ///   - folderId: folder id
    ///   - completionHandler: block to be called upon receiving the server's response
    public func getRecordings(_ folderId:String!, completionHandler:((Bool, Any?) -> Void)?) {
        APIClient.sharedInstance.getRecordings(folderId, completionHandler: completionHandler)
    }
    
    /// Get phone numbers
    ///
    /// - Parameter completionHandler: block to be called upon receiving the server's response
    public func getPhoneNumbers(_ completionHandler:((Bool, Any?) -> Void)?) {
        APIClient.sharedInstance.getPhoneNumbers(completionHandler)
    }
    
    /// Save data
    public func saveData(){
        AppPersistentData.sharedInstance.saveData()
    }
    
    /// Create folder
    ///
    /// - Parameters:
    ///   - name: folder name
    ///   - localID: local id of folder
    ///   - completionHandler: block to be called upon receiving the server's response
    public func createFolder(_ name:String, localID:String, completionHandler:((Bool, Any?) -> Void)?){
        APIClient.sharedInstance.createFolder(name as NSString, localID: localID as NSString, completionHandler: completionHandler)
    }
    
    /// Delete folder
    ///
    /// - Parameters:
    ///   - folderId: folderId
    ///   - moveTo: folderId of the folder to move to
    ///   - completionHandler: block to be called upon receiving the server's response
    public func deleteFolder(_ folderId:String, moveTo:String!, completionHandler:((Bool, Any?) -> Void)?) {
        APIClient.sharedInstance.deleteFolder(folderId, moveTo: moveTo, completionHandler: completionHandler)
    }
    
    /// Reorder folders
    ///
    /// - Parameters:
    ///   - parameters: reorder parameters
    ///   - completionHandler: block to be called upon receiving the server's response
    public func reorderFolders(_ parameters:[String:Any], completionHandler:((Bool, Any?) -> Void)?) {
        APIClient.sharedInstance.reorderFolders(parameters, completionHandler: completionHandler)
    }
    
    /// Rename folder
    ///
    /// - Parameters:
    ///   - folderId: folder id
    ///   - name: new folder name
    ///   - completionHandler: block to be called upon receiving the server's response
    public func renameFolder(_ folderId:String, name:String, completionHandler:((Bool, Any?) -> Void)?) {
        APIClient.sharedInstance.renameFolder(folderId, name: name, completionHandler: completionHandler)
    }
    
    /// Add pass to folder
    ///
    /// - Parameters:
    ///   - folderId: folderId
    ///   - pass: new password
    ///   - completionHandler: block to be called upon receiving the server's response
    public func addPasswordToFolder(_ folderId:String, pass:String, completionHandler:((Bool, Any?) -> Void)?) {
        APIClient.sharedInstance.addPasswordToFolder(folderId, pass: pass, completionHandler: completionHandler)
    }
    
    /// Delete Recording
    ///
    /// - Parameters:
    ///   - recordItemId: recordId
    ///   - removeForever: boolean indicator, true moves to trash folder
    ///   - completionHandler: block to be called upon receiving the server's response
    public func deleteRecording(_ recordItemId:String, removeForever:Bool, completionHandler:((Bool, Any?) -> Void)?) {
        APIClient.sharedInstance.deleteRecording(recordItemId, removeForever: removeForever, completionHandler: completionHandler)
    }
    
    /// Move Recording
    ///
    /// - Parameters:
    ///   - recordItem: record item to be moved
    ///   - folderId: folderId of the folder where the record item will be moved
    ///   - completionHandler: block to be called upon receiving the server's response
    public func moveRecording(_ recordItem:RecordItem, folderId:String, completionHandler:((Bool, Any?) -> Void)?) {
        APIClient.sharedInstance.moveRecording(recordItem, folderId: folderId, completionHandler: completionHandler)
    }
    
    /// Recover Recording
    ///
    /// - Parameters:
    ///   - recordItem: record item to be recovered
    ///   - folderId:  folderId of the folder where the record item will be moved
    ///   - completionHandler: block to be called upon receiving the server's response
    public func recoverRecording(_ recordItem:RecordItem, folderId:String, completionHandler:((Bool, Any?) -> Void)?) {
        APIClient.sharedInstance.recoverRecording(recordItem, folderId: folderId, completionHandler: completionHandler)
    }
    
    /// Update recording info
    ///
    /// - Parameters:
    ///   - recordItem: record item to be updated
    ///   - parameters: new parameters
    ///   - completionHandler: block to be called upon receiving the server's response
    public func updateRecordingInfo(_ recordItem:RecordItem ,parameters:[String:Any], completionHandler:((Bool, Any?) -> Void)?) {
        APIClient.sharedInstance.updateRecordingInfo(recordItem, parameters: parameters, completionHandler: completionHandler)
    }
    
    /// Star
    ///
    /// - Parameters:
    ///   - star: boolean parameter for star
    ///   - entityId: recordItem
    ///   - isFile: boolean indicator of file type
    ///   - completionHandler: block to be called upon receiving the server's response
    public func star(_ star:Bool, entityId:String, isFile:Bool, completionHandler:((Bool, Any?) -> Void)?) {
        APIClient.sharedInstance.star(star, entityId: entityId, isFile: isFile, completionHandler: completionHandler)
    }
    
    /// Clone file
    ///
    /// - Parameters:
    ///   - entityId: recordItemId
    ///   - completionHandler: block to be called upon receiving the server's response
    public func cloneFile(entityId:String, completionHandler:((Bool, Any?) -> Void)?) {
        APIClient.sharedInstance.cloneFile(entityId: entityId, completionHandler: completionHandler)
    }
    
    /// Rename Recording
    ///
    /// - Parameters:
    ///   - recordItem: item to be renamed
    ///   - name: new name
    ///   - completionHandler: block to be called upon receiving the server's response
    public func renameRecording(_ recordItem:RecordItem, name:String, completionHandler:((Bool, Any?) -> Void)?) {
        APIClient.sharedInstance.renameRecording(recordItem, name: name, completionHandler: completionHandler)
    }
    
    /// Upload Recording
    ///
    /// - Parameters:
    ///   - recordItem: Record Item to be updated
    ///   - completionHandler: block to be called upon receiving the server's response
    public func uploadRecording(_ recordItem:RecordItem, completionHandler:((Bool, Any?) -> Void)?) {
        APIClient.sharedInstance.uploadRecording(recordItem, completionHandler: completionHandler)
    }
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - fileUrl: <#fileUrl description#>
    ///   - localPath: <#localPath description#>
    ///   - completionHandler: block to be called upon receiving the server's response
    public func downloadFile(_ fileUrl:String, localPath:String, completionHandler:((Bool) -> Void)?){
        APIClient.sharedInstance.downloadFile(fileUrl, localPath: localPath, completionHandler: completionHandler)
    }
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - recordItem: <#recordItem description#>
    ///   - toFolder: <#toFolder description#>
    ///   - completionHandler: block to be called upon receiving the server's response
    public func downloadAudioFile(_ recordItem:RecordItem, toFolder:String, completionHandler:((Bool) -> Void)?) {
        APIClient.sharedInstance.downloadAudioFile(recordItem, toFolder: toFolder, completionHandler: completionHandler)
    }
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - playBeep: <#playBeep description#>
    ///   - completionHandler: block to be called upon receiving the server's response
    public func updateSettings(_ playBeep:Bool, completionHandler:((Bool, Any?) -> Void)?) {
        APIClient.sharedInstance.updateSettings(playBeep, completionHandler: completionHandler)
    }
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - free: <#free description#>
    ///   - completionHandler: block to be called upon receiving the server's response
    public func updateUser(_ free:Bool, completionHandler:((Bool, Any?) -> Void)?) {
        APIClient.sharedInstance.updateUser(free, completionHandler: completionHandler)
    }
    
    /// Get Settings
    ///
    /// - Parameter completionHandler: block to be called upon receiving the server's response
    public func getSettings(_ completionHandler:((Bool, Any?) -> Void)?){
        APIClient.sharedInstance.getSettings(completionHandler)
    }
    
    /// Get Translations
    ///
    /// - Parameters:
    ///   - language: language of the translation
    ///   - completionHandler: block to be called upon receiving the server's response
    public func getTranslations(_ language:String,completionHandler:((Bool, Any?) -> Void)?){
        APIClient.sharedInstance.getTranslations(language, completionHandler: completionHandler)
    }
    
    /// Get languages
    ///
    /// - Parameter completionHandler: block to be called upon receiving the server's response
    public func getLanguages(_ completionHandler:((Bool, Any?) -> Void)?){
        APIClient.sharedInstance.getLanguages(completionHandler)
    }
    
    /// Get messages
    ///
    /// - Parameter completionHandler: block to be called upon receiving the server's response
    @objc public func getMessages(_ completionHandler:((Bool, Any?) -> Void)?){
        APIClient.sharedInstance.getMessages(completionHandler)
    }
    
    /// Get profile
    ///
    /// - Parameter completionHandler: block to be called upon receiving the server's response
    public func getProfile(_ completionHandler:((Bool, Any?) -> Void)?){
        APIClient.sharedInstance.getProfile(completionHandler)
    }
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - credits: <#credits description#>
    ///   - reciept: <#reciept description#>
    public func buyCredits(_ credits:Int, reciept:String!) {
        ActionsSyncManager.sharedInstance.buyCredits(credits, reciept:reciept)
    }
    
    /// Create Folder
    ///
    /// - Parameter recordFolder: record folder object
    public func createFolder(_ recordFolder:RecordFolder) {
        ActionsSyncManager.sharedInstance.createFolder(recordFolder)
    }
    
    /// Delete folder
    ///
    /// - Parameters:
    ///   - recordFolder: record fodler to be deleted
    ///   - moveToFolder: folderIf of the folder it should be moved to
    public func deleteFolder(_ recordFolder:RecordFolder, moveToFolder:String!) {
        ActionsSyncManager.sharedInstance.deleteFolder(recordFolder, moveToFolder: moveToFolder)
    }
    
    /// Rename folder
    ///
    /// - Parameter recordFolder: record fodler object to be renamed
    public func renameFolder(_ recordFolder:RecordFolder) {
        ActionsSyncManager.sharedInstance.renameFolder(recordFolder)
    }
    
    /// Add password to folder
    ///
    /// - Parameter recordFolder: record folder to add the pass to
    public func addPasswordToFolder(_ recordFolder:RecordFolder) {
        ActionsSyncManager.sharedInstance.addPasswordToFolder(recordFolder)
    }
    
    /// Delete record item
    ///
    /// - Parameters:
    ///   - recordItem: record item object
    ///   - forever: bollean indicator of deleting or moving to
    public func deleteRecording(_ recordItem:RecordItem, forever:Bool) {
        ActionsSyncManager.sharedInstance.deleteRecording(recordItem, forever: forever)
    }
    
    /// Delete recordings
    ///
    /// - Parameters:
    ///   - recordItemIds: ids of the
    ///   - forever:boolean indicator, true moves to trash folder
    public func deleteRecordings(_ recordItemIds:String, forever:Bool) {
        ActionsSyncManager.sharedInstance.deleteRecordings(recordItemIds, forever: forever)
    }
    
    /// Move recording
    ///
    /// - Parameters:
    ///   - recordItem: record item to be moved
    ///   - folderId: folderId of the folder you are moving to
    public func moveRecording(_ recordItem:RecordItem, folderId:String) {
        ActionsSyncManager.sharedInstance.moveRecording(recordItem, folderId: folderId)
    }
    
    /// Recover recording
    ///
    /// - Parameters:
    ///   - recordItem: record item to be recovered
    ///   - folderId: folderId of where to recover
    public func recoverRecording(_ recordItem:RecordItem, folderId:String) {
        ActionsSyncManager.sharedInstance.recoverRecording(recordItem, folderId: folderId)
    }
    
    /// Rename Recording
    ///
    /// - Parameter recordItem: RecordItem object to be renamed
    public func renameRecording(_ recordItem:RecordItem) {
        ActionsSyncManager.sharedInstance.renameRecording(recordItem)
    }
    
    /// Upload Recording
    ///
    /// - Parameter recordItem: RecordItem object to be uploaded
    @objc public func uploadRecording(_ recordItem:RecordItem) {
        ActionsSyncManager.sharedInstance.uploadRecording(recordItem)
    }
    
    /// Upadate Recording Info
    ///
    /// - Parameters:
    ///   - recordItem: RecordItem object to be update
    ///   - fileInfo: NSDictionary containing file info
    public func updateRecordingInfo(_ recordItem:RecordItem, fileInfo:NSMutableDictionary) {
        ActionsSyncManager.sharedInstance.updateRecordingInfo(recordItem, fileInfo: fileInfo)
    }
    
    /// Update user profile
    ///
    /// - Parameters:
    ///   - user: User object to be updated
    ///   - userInfo: NSDictionary containing new user info
    public func updateUserProfile(_ user:User, userInfo:NSMutableDictionary) {
        ActionsSyncManager.sharedInstance.updateUserProfile(user, userInfo: userInfo)
    }
    
    /// Reorder folders
    ///
    /// - Parameter parameters: folder reorder parameters
    public func reorderFolders(_ parameters:NSMutableDictionary) {
        ActionsSyncManager.sharedInstance.reorderFolders(parameters)
    }
    
    /// Sync item
    ///
    /// - Parameter recordFolder: RecordeFolder object to be synced
    /// - Returns: RecordeFolder object after sync
    public func syncItem(_ recordFolder:RecordFolder) -> RecordFolder {
        return RecordingsManager.sharedInstance.syncItem(recordFolder)
    }
    
    /// Sync Recording item
    ///
    /// - Parameters:
    ///   - recordItem:RecordItem object to be synced
    ///   - folder: RecordFolder object where the recordItem will be found
    /// - Returns: RecordItem object after sync
    public func syncRecordingItem(_ recordItem:RecordItem, folder:RecordFolder) -> RecordItem {
        return RecordingsManager.sharedInstance.syncRecordingItem(recordItem, folder:folder)
    }
    
    /// Main Sync
    ///
    /// - Parameter completionHandler: block to be called upon receiving the server's response
    public func mainSync(_ completionHandler:((Bool) -> Void)?) {
        APIClient.sharedInstance.mainSync(completionHandler)
    }
}
