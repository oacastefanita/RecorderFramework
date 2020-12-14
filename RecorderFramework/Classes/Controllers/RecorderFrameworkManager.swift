import Foundation

public class RecorderFrameworkManager : NSObject {
    @objc public static let sharedInstance = RecorderFrameworkManager()
    
    public var isRecorder = false
    public var isNoizTube = false
    public var containerName:String!
    public var macSN:String!
    
    override public init() {
        super.init()
        #if os(iOS) || os(watchOS)
        WatchKitController.sharedInstance
        #endif
        AnalyticsManager.sharedInstance
        AppPersistentData.sharedInstance.loadData()
    }
    
    /// Upload profile picture
    ///
    /// - Parameters:
    ///   - path: picture path
    ///   - completionHandler: block to be called upon receiving the server's response
    public func uploadProfilePicture(path:String, completionHandler:((Bool, Any?) -> Void)?) {
        APIClient.sharedInstance.uploadProfilePicture(path: path, completionHandler: completionHandler)
    }
    
    /// Get recordings
    ///
    /// - Parameter completionHandler: block to be called upon receiving the server's response
    public func getRecordings(_ completionHandler:((Bool) -> Void)?) {
        APIClient.sharedInstance.getRecordings(completionHandler)
    }
    
    /// Get audio file tags
    ///
    /// - Returns: Array containing AudiTag objects
    public func getAudioFileTags() -> NSMutableArray!{
        return AudioFileTagManager.sharedInstance.audioFileTags
    }
    
    /// Update token
    ///
    /// - Parameters:
    ///   - token: token string
    ///   - completionHandler: block to be called upon receiving the server's response
    public func updateToken(_ token:String, completionHandler:((Bool, Any?) -> Void)?) {
        APIClient.sharedInstance.updateToken(token, completionHandler: completionHandler)
    }
    
    /// Start processing actions
    public func startProcessingActions(){
        ActionsSyncManager.sharedInstance.startProcessingActions()
    }
    
    /// Update local files
    public func updateLocalFiles(){
        LocalFilesManager.sharedInstance.updateLocalFiles()
    }
    
    /// Remove metadata file
    ///
    /// - Parameter filePath: metadata file path
    public func removeMetadataFile(_ filePath:String){
        AudioFileTagManager.sharedInstance.removeMetadataFile(filePath)
    }
    
    /// Get metadata file path
    ///
    /// - Parameter filePath: file path of the recording
    /// - Returns: metadata file path
    public func getMetadataFilePath(_ filePath:String) -> String{
        return AudioFileTagManager.sharedInstance.getMetadataFilePath(filePath)
    }
    
    /// Setup with file
    ///
    /// - Parameter filePath: filepath of the file
    public func setupWithFile(_ filePath:String) {
        AudioFileTagManager.sharedInstance.setupWithFile(filePath)
    }
    
    /// Save to file
    public func saveToFile(){
        AudioFileTagManager.sharedInstance.saveToFile()
    }
    
    /// Update wave render values
    ///
    /// - Parameter waveRenderVals: new wave render values
    public func updateWaveRenderVals(_ waveRenderVals:NSArray){
        AudioFileTagManager.sharedInstance.updateWaveRenderVals(waveRenderVals)
    }
    
    /// Get current translations language
    ///
    /// - Returns: current translations language
    public func getCurrentLanguage() -> String{
        return TranslationManager.sharedInstance.currentLanguage
    }
    
    /// Set current language
    ///
    /// - Parameter language: new language
    public func setCurrentLanguage(_ language: String){
        TranslationManager.sharedInstance.currentLanguage = language
    }
    
    /// Get translations
    ///
    /// - Returns: NSDictionary containing translations
    public func getTranslations() -> NSDictionary{
        return TranslationManager.sharedInstance.translations
    }
    
    /// Get languages
    ///
    /// - Returns: Array of Languge objects
    public func getLanguages() -> Array<Language>{
        return TranslationManager.sharedInstance.languages
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
    
    /// Create NSDictionary from User object
    ///
    /// - Parameter user: user object
    /// - Returns: NSDictionary with user data
    public func createDictFromUser(_ user: User) -> NSMutableDictionary{
        return RecorderFactory.createDictFromUser(user)
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
    public func getUser() -> User!{
        return AppPersistentData.sharedInstance.user!
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
        #if os(iOS)
        WatchKitController.sharedInstance.sendApiKey()
        #endif
    }
    
    /// Set new default phone
    ///
    /// - Parameter key: new API Key
    public func setDefaultPhone(_ phone:String){
        AppPersistentData.sharedInstance.phone = phone
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
    
    /// Get Plan
    ///
    /// - Returns: plan
    public func getPlan() -> Int{
        return AppPersistentData.sharedInstance.user.plan
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
    
    /// Get Phone numbers
    ///
    /// - Returns: PhoneNumber objects array
    public func getPhoneNumbers() -> Array<PhoneNumber>{
        return AppPersistentData.sharedInstance.phoneNumbers
    }
    
    /// Get folders
    ///
    /// - Returns: Folder Objects Array
    public func getFolders() -> Array<RecordFolder>{
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
        APIClient.sharedInstance.register(number, completionHandler: completionHandler)
    }
    
    /// Send the verification code received via SMS
    ///
    /// - Parameters:
    ///   - code: code received via sms
    ///   - completionHandler: block to be called upon receiving the server's response
    public func sendVerificationCode(_ code:String, completionHandler:((Bool, Any?) -> Void)?) {
        APIClient.sharedInstance.sendVerificationCode(code, completionHandler: completionHandler)
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
    public func getRecordings(_ folderId:String!, lastFileId: String! = nil, less: Bool = false, q:String! = nil, completionHandler:((Bool, Any?) -> Void)?) {
        APIClient.sharedInstance.getRecordings(folderId, lastFileId: lastFileId, less:less, q:q, completionHandler: completionHandler)
    }
    
    /// Search recordings
    ///
    /// - Parameters:
    ///   - q: search string
    ///   - completionHandler: block to be called upon receiving the server's response
    public func searchRecordings(query: String, completionHandler:((Bool, Any?) -> Void)?){
        APIClient.sharedInstance.searchRecordings(query, completionHandler: completionHandler)
    }
    
    /// Get phone numbers
    ///
    /// - Parameter completionHandler: block to be called upon receiving the server's response
    public func getPhoneNumbers(_ completionHandler:((Bool, Any?) -> Void)?) {
        APIClient.sharedInstance.getPhoneNumbers(completionHandler)
    }
    
    /// Save data
    @objc public func saveData(){
        AppPersistentData.sharedInstance.saveData()
    }
    
    /// Load data
    public func loadData(){
        AppPersistentData.sharedInstance.loadData()
    }
    
    /// Clear data
    public func clearRecordingsData(){
        RecordingsManager.sharedInstance.clearData()
    }
    
    /// Create folder
    ///
    /// - Parameters:
    ///   - name: folder name
    ///   - localID: local id of folder
    ///   - completionHandler: block to be called upon receiving the server's response
    public func createFolder(_ name:String!, localID:String!, color:String = "0", completionHandler:((Bool, Any?) -> Void)?){
        APIClient.sharedInstance.createFolder(name, localID: localID, color:color, completionHandler: completionHandler)
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
    
    /// Reorder folders or files
    ///
    /// - Parameters:
    ///   - file: bool file or folder
    ///   - id: file or folder id
    ///   - folderId: in case of a file reorder
    ///   - topId: id of the top item
    ///   - completionHandler: block to be called upon receiving the server's response
    public func reorderItems(_ file:Bool, id:String, folderId:String = "", topId:String, completionHandler:((Bool, Any?) -> Void)?) {
        let parameters = NSMutableDictionary(dictionary: ["type":file ? "file" : "folder","id":id, "top_id":topId])
        if file {
            parameters["folder_id"] = folderId
        }
        ActionsSyncManager.sharedInstance.reorderFolders(parameters)
    }
    
    /// Rename folder
    ///
    /// - Parameters:
    ///   - folderId: folder id
    ///   - name: new folder name
    ///   - completionHandler: block to be called upon receiving the server's response
    public func renameFolder(_ folderId:String, name:String, color:String, completionHandler:((Bool, Any?) -> Void)?) {
        APIClient.sharedInstance.renameFolder(folderId, name: name, color: color, completionHandler: completionHandler)
    }
    
    /// Add pass to folder
    ///
    /// - Parameters:
    ///   - folderId: folderId
    ///   - pass: new password
    ///   - completionHandler: block to be called upon receiving the server's response
    public func addPasswordToFolder(_ folderId:String, pass:String, hint:String, completionHandler:((Bool, Any?) -> Void)?) {
        APIClient.sharedInstance.addPasswordToFolder(folderId, pass: pass, hint:hint, completionHandler: completionHandler)
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
        ActionsSyncManager.sharedInstance.starItem(star, entityId: entityId, isFile: isFile)
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
    
    /// Download File
    ///
    /// - Parameters:
    ///   - fileUrl: file url for download
    ///   - localPath: local path of the file
    ///   - completionHandler: block to be called upon receiving the server's response
    public func downloadFile(_ fileUrl:String, localPath:String, completionHandler:((Bool) -> Void)?){
        APIClient.sharedInstance.downloadFile(fileUrl, localPath: localPath, completionHandler: completionHandler)
    }
    
    /// Download audio file
    ///
    /// - Parameters:
    ///   - recordItem: the RecordItem object that the file belongs to
    ///   - toFolder: RecordFolder that the RecordItem belongs to
    ///   - completionHandler: block to be called upon receiving the server's response
    public func downloadAudioFile(_ recordItem:RecordItem, toFolder:String, completionHandler:((Bool) -> Void)?) {
        APIClient.sharedInstance.downloadAudioFile(recordItem, toFolder: toFolder, completionHandler: completionHandler)
    }
    
    /// Update settings
    ///
    /// - Parameters:
    ///   - playBeep: Boolean indicator of playbeep value
    ///   - completionHandler: block to be called upon receiving the server's response
    public func updateSettings(_ playBeep:Bool, filesPersmission:Bool = true, completionHandler:((Bool, Any?) -> Void)?) {
        APIClient.sharedInstance.updateSettings(playBeep, filesPersmission:filesPersmission, completionHandler: completionHandler)
    }
    
    /// Update user
    ///
    /// - Parameters:
    ///   - free: bollean indicator of free user
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
    
    /// Buy Credits
    ///
    /// - Parameters:
    ///   - credits: number of credits
    ///   - reciept: in app purchase id
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
    ///   - userInfo: NSDictionary containing new user info
    public func updateUserProfile(userInfo:NSMutableDictionary) {
        ActionsSyncManager.sharedInstance.updateUserProfile(userInfo: userInfo)
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
    
    /// New Recordings Sync
    ///
    /// - Parameter completionHandler: block to be called upon receiving the server's response
    public func defaultFolderSync(_ completionHandler:((Bool) -> Void)?) {
        APIClient.sharedInstance.defaultFolderSync(completionHandler)
    }
    
    /// Main Sync
    ///
    /// - Parameter completionHandler: block to be called upon receiving the server's response
    public func mainSync(_ completionHandler:((Bool) -> Void)?) {
        APIClient.sharedInstance.mainSync(completionHandler)
    }
    
    /// Get documents path
    ///
    /// - Returns: documents path string
    public func getPath() -> String{
        let fileManager = FileManager.default
        var path = fileManager.containerURL(forSecurityApplicationGroupIdentifier: RecorderFrameworkManager.sharedInstance.containerName)!.path 
        return path
    }
    
    /// Get photo file path
    ///
    /// - Parameters:
    ///   - filePath: recording file path
    ///   - time: tag time
    /// - Returns: string value of file path
    public func getPhotoFilePath(_ filePath:String,time:TimeInterval) -> String{
        return AudioFileTagManager.sharedInstance.getPhotoFilePath(filePath, time: time)
    }
    
    /// Get photo file path
    ///
    /// - Parameters:
    ///   - filePath: recording file path
    ///   - time: tag time
    ///   - index: image index
    /// - Returns: string value of file path
    public func getPhotoFilePath(_ filePath:String,time:TimeInterval, index: Int) -> String{
        return AudioFileTagManager.sharedInstance.getPhotoFilePath(filePath, time: time, index: index)
    }
    
    /// Update recording metadata
    ///
    /// - Parameter recordItem: record item to be updated
    public func updateRecordingMetadata(_ recordItem:RecordItem) {
        ActionsSyncManager.sharedInstance.updateRecordingMetadata(recordItem)
    }
    
    /// Download file
    ///
    /// - Parameters:
    ///   - fromURL: file URL address
    ///   - atPath: path for file
    ///   - completionHandler: block to be called upon receiving the server's response
    public func downloadFile(_ fromURL:String, atPath:String, completionHandler:((Bool, String) -> Void)?) {
        APIClient.sharedInstance.api.downloadFile(fromURL, atPath: atPath, completionHandler: completionHandler)
    }
    
    /// Upload metadata image file
    ///
    /// - Parameters:
    ///   - imagePath: local path of the image
    ///   - fileId: file id of the image
    ///   - completionHandler: block to be called upon receiving the server's response
    public func uploadMetadataImageFile(_ imagePath:String, fileId: String, completionHandler:((Bool, Any?) -> Void)?) {
        APIClient.sharedInstance.uploadMetadataImageFile(imagePath, fileId: fileId, completionHandler: completionHandler)
    }
    
    /// Delete metadata file
    ///
    /// - Parameters:
    ///   - fileId: id of the file to be deleted
    ///   - completionHandler: block to be called upon receiving the server's response
    public func deleteMetadataFile(_ fileId:String, completionHandler:((Bool, Any?) -> Void)?){
        APIClient.sharedInstance.deleteMetadataFile(fileId, completionHandler:completionHandler)
    }
    
    /// Folder for item
    ///
    /// - Parameter itemId: folder id
    /// - Returns: RecordFolder object with desired id
    public func folderForItem(_ itemId: String) -> RecordFolder{
        return RecordingsManager.sharedInstance.folderForItem(itemId)
    }
    
    /// Create NSDictionary from record item
    ///
    /// - Parameter file: RecordItem to create NSDictionary from
    /// - Returns: NSDictionary object filled with data from RecordItem
    public func createDictFromRecordItem(_ file: RecordItem) -> NSMutableDictionary{
        return RecorderFactory.createDictFromRecordItem(file)
    }
    
    /// Verify folder Password
    ///
    /// - Parameters:
    ///   - pass: password to verify
    ///   - folderId: folder id
    ///   - completionHandler: block to be called upon receiving the server's response
    public func verifyFolderPass(_ pass:String, folderId:String, completionHandler:((Bool, Any?) -> Void)?) {
        APIClient.sharedInstance.verifyFolderPass(pass, folderId: folderId, completionHandler: completionHandler)
    }
}
