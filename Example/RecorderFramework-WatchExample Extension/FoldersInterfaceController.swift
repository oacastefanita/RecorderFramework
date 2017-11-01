import WatchKit
import Foundation
import RecorderFramework

class FoldersInterfaceController: WKInterfaceController {

    @IBOutlet var lblNoData: WKInterfaceLabel!
    @IBOutlet var pollsTable: WKInterfaceTable!
    
    var array: [RecordFolder]!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        array = RecorderFrameworkManager.sharedInstance.getFolders()
        pollsTable.setNumberOfRows(array.count, withRowType: "foldersRow")
        for index in 0..<array.count {
            if let controller = pollsTable.rowController(at: index) as? FoldersRowController {
                controller.folder = array[index]
            }
        }
        
        lblNoData.setHidden(array.count != 0)

        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        self.pushController(withName: "FilesInterfaceController", context: array[rowIndex])
    }
}
