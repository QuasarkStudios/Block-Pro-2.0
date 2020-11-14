//
//  VoiceMemoRecorder.swift
//  Block Pro
//
//  Created by Nimat Azeez on 11/12/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import Foundation
import AVFoundation
import SVProgressHUD

class VoiceMemoRecorder {
    
    let audioSession = AVAudioSession.sharedInstance()
    
    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    
    private var currentSample: Int
    private let numberOfSamples: Int
    
    private var soundSamples: [Float]? {
        didSet {
            
            if let cell = voiceMemoCell as? CreateCollabVoiceMemoCell, let samples = soundSamples {
                    
                cell.updateAudioVisualizer(samples)
            }
        }
    }
    
    weak var voiceMemoCell: AnyObject?
    
    init(voiceMemoCell: AnyObject, numberOfSamples: Int) {
        
        self.voiceMemoCell = voiceMemoCell
        
        self.numberOfSamples = numberOfSamples
        self.soundSamples = Array(repeating: .zero, count: numberOfSamples)
        self.currentSample = 0
        
        
        //3
//        configureAudioSession()
        
        verifyRecordingPermission { (granted) in
            
            if granted {
                
                self.configureAudioRecorder()
            }
            
            else {
                
                //present alert
                print("false")
            }
        }
    }
    
//    (audioSession: AVAudioSession, completion: @escaping (() -> Void))
    private func verifyRecordingPermission (completion: @escaping ((_ granted: Bool) -> Void)) {
        
        if audioSession.recordPermission == .granted {
            
            completion(true)
        }
        
        else {
            
            audioSession.requestRecordPermission { (granted) in
                
                completion(granted)
            }
        }
    }
    
    private func configureAudioRecorder () {
        
        //4
//        let url = URL(fileURLWithPath: "/dev/null", isDirectory: true)
        
        let temporaryDirectoryURL = getDocumentsDirectory().appendingPathComponent("temporaryAudioRecording.m4a")
//            URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        
        let recorderSettings: [String : Any] = [
            AVFormatIDKey: NSNumber(value: kAudioFormatAppleLossless),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
        ]
        
        do {
            self.audioRecorder = try AVAudioRecorder(url: temporaryDirectoryURL, settings: recorderSettings)
            try self.audioSession.setCategory(.playAndRecord, mode: .default, options: [])
            
            self.startMonitoring()
            
        } catch {
            
            //present alert and stop the loading of the cell
        }

    }
    
    private func getDocumentsDirectory () -> URL {
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    private func startMonitoring () {
        
        audioRecorder?.isMeteringEnabled = true
        audioRecorder?.record()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true, block: { (timer) in
            
            self.audioRecorder?.updateMeters()
            
            self.currentSample = (self.currentSample + 1) % self.numberOfSamples
            
            if let power = self.audioRecorder?.averagePower(forChannel: 0) {
                
                self.soundSamples?[self.currentSample] = power
            }
        })
    }
    
    func startRecording () {
        
        audioRecorder?.stop()
        audioRecorder?.deleteRecording() //Deletes the "temporaryAudioRecording.m4a" file
        
//        do {
//
//            let items = try FileManager.default.contentsOfDirectory(atPath: getDocumentsDirectory().path)
//
//            print(items)
//
//
//            
//            //will be useful when i need to delete memos later
////            let itemURL = "\(getDocumentsDirectory().path)/temporaryAudioRecording.m4a"
////            try FileManager.default.removeItem(at: URL(fileURLWithPath: itemURL, isDirectory: true))
//
//        } catch {
//
//            print("didnt work")
//        }
    }
    
    deinit {
        
        timer?.invalidate()
        audioRecorder?.stop()
    }
}
