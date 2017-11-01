import WatchKit
import RecorderFramework

class FoldersRowController: NSObject {
    @IBOutlet var separator: WKInterfaceSeparator!
    @IBOutlet var titleLabel: WKInterfaceLabel!
    @IBOutlet var questionLabel: WKInterfaceLabel!
    
    var folder: RecordFolder? {
        
        didSet {
            if let folder = folder {
                titleLabel.setText(folder.title)
            }
        }
    }
}
