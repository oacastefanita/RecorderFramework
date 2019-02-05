//
//  NewRecordViewController.swift
//  RecorderFramework_Example
//
//  Created by Stefanita Oaca on 2/4/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import RecorderFramework
import AVFoundation
import FDWaveformView

class NewRecordViewController: UIViewController, AVAudioRecorderDelegate{
    
    @IBOutlet weak var txtChanels: UITextField!
    @IBOutlet weak var txtSampleRate: UITextField!
    @IBOutlet weak var recordingTimeLabel: UILabel!
    @IBOutlet weak var btnRecord: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var file: RecordItem!
    var folder: RecordFolder!
    var recording = false
    
    //Variables
    var audioRecorder: AVAudioRecorder!
    var meterTimer:Timer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fillView()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(noti:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(noti:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fillView(){
        txtChanels.text = "2"
        txtSampleRate.text = "44100"
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }

    
    @IBAction func audioRecorderAction(_ sender: UIButton) {
        if recording{
            btnRecord.setTitle("Record", for: .normal)
            finishAudioRecording(success: true)
        }else{
            btnRecord.setTitle("Stop", for: .normal)
            //Create the session.
            let session = AVAudioSession.sharedInstance()
            
            do {
                //Configure the session for recording and playback.
                try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
                try session.setActive(true)
                //Set up a high-quality recording session.
                var sample = Float(txtSampleRate.text!)
                var chanels = Int(txtChanels.text!)
                let settings = [
                    AVFormatIDKey:Int(kAudioFormatLinearPCM),
                    AVSampleRateKey:sample,
                    AVNumberOfChannelsKey:chanels,
                    AVLinearPCMBitDepthKey:8,
                    AVLinearPCMIsFloatKey:false,
                    AVLinearPCMIsBigEndianKey:false,
                    AVEncoderAudioQualityKey:AVAudioQuality.max.rawValue
                    ] as [String : Any]
                //Create audio file name URL
                let fileManager = FileManager.default
                let sharedContainer = fileManager.containerURL(forSecurityApplicationGroupIdentifier: RecorderFrameworkManager.sharedInstance.containerName)
                let path = sharedContainer?.appendingPathComponent("Recording1.wav")
                //Create the audio recording, and assign ourselves as the delegate
                audioRecorder = try AVAudioRecorder(url: path!, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.isMeteringEnabled = true
                audioRecorder.record()
                meterTimer = Timer.scheduledTimer(timeInterval: 0.1, target:self, selector:#selector(self.updateAudioMeter(timer:)), userInfo:nil, repeats:true)
            }
            catch let error {
                print("Error for start audio recording: \(error.localizedDescription)")
            }
        }
        recording = !recording
    }
    
    func finishAudioRecording(success: Bool) {
        
        audioRecorder.stop()
        audioRecorder = nil
        meterTimer.invalidate()
        
        if success {
            print("Recording finished successfully.")
        } else {
            print("Recording failed :(")
        }
        self.navigationController?.popViewController(animated: true);
    }
    
    @objc func updateAudioMeter(timer: Timer) {
        
        if audioRecorder.isRecording {
            let hr = Int((audioRecorder.currentTime / 60) / 60)
            let min = Int(audioRecorder.currentTime / 60)
            let sec = Int(audioRecorder.currentTime.truncatingRemainder(dividingBy: 60))
            let totalTimeString = String(format: "%02d:%02d:%02d", hr, min, sec)
            recordingTimeLabel.text = totalTimeString
            audioRecorder.updateMeters()
        }
    }
    
    //MARK:- Audio recoder delegate methods
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
        if !flag {
            finishAudioRecording(success: false)
        }
    }
    
    @objc func keyboardWillHide(noti: Notification) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func keyboardWillShow(noti: Notification) {
        
        guard let userInfo = noti.userInfo else { return }
        guard var keyboardFrame: CGRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset
    }
}
