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
        
        
        verifyRecordingPermission { (granted) in
            
            if granted {
                
                self.configureTemporaryAudioRecorder()
            }
            
            else {
                
                //present alert
                print("false")
            }
        }
    }
    
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
    
    private func configureTemporaryAudioRecorder () {
        
        let temporaryDirectoryURL = getDocumentsDirectory().appendingPathComponent("temporaryAudioRecording.m4a")
        
        let recorderSettings: [String : Any] = [
            AVFormatIDKey: NSNumber(value: kAudioFormatAppleLossless),
            AVSampleRateKey: 16000.0,//44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue
        ]
        
        do {
            self.audioRecorder = try AVAudioRecorder(url: temporaryDirectoryURL, settings: recorderSettings)
            try self.audioSession.setCategory(.record, mode: .default, options: [])
            
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            
            startMonitoring()
            
        } catch {
            
            //present alert and stop the loading of the cell
        }

    }
    
    private func getDocumentsDirectory () -> URL {
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    private func startMonitoring () {
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true, block: { (timer) in
            
            self.audioRecorder?.updateMeters()
            
            self.currentSample = (self.currentSample + 1) % self.numberOfSamples
            
            if let power = self.audioRecorder?.averagePower(forChannel: 0) {
                
                self.soundSamples?[self.currentSample] = power
            }
        })
    }
    
    func startRecording (_ voiceMemoID: String) {
        
        audioRecorder?.stop()
        audioRecorder?.deleteRecording() //Deletes the "temporaryAudioRecording.m4a" file
        
        timer?.invalidate()
        
        let voiceMemoDirectoryURL = getDocumentsDirectory().appendingPathComponent("VoiceMemos", isDirectory: true).appendingPathComponent(voiceMemoID + ".m4a")
//            URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        
        let recorderSettings: [String : Any] = [
            AVFormatIDKey: NSNumber(value: kAudioFormatAppleLossless),
            AVSampleRateKey: 12000.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.low.rawValue
        ]
        
        do {
            
            //Creates a directory called "Voice Memos" if one doesn't exist
            if !FileManager.default.fileExists(atPath: getDocumentsDirectory().path + "/VoiceMemos") {
                
                try FileManager.default.createDirectory(atPath: getDocumentsDirectory().path + "/VoiceMemos", withIntermediateDirectories: true, attributes: nil)
            }
            
            self.audioRecorder = try AVAudioRecorder(url: voiceMemoDirectoryURL, settings: recorderSettings)
            try self.audioSession.setCategory(.playAndRecord, mode: .default, options: [])

            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()

//            configureTemporaryAudioRecorder()
            
            self.startMonitoring()
            
        } catch {
            
            print("tehee oops")
            
            //present alert and stop the loading of the cell
        }
        
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
    
    func stopRecording () {
        
        audioRecorder?.stop()
        
        timer?.invalidate()
        
//        configureTemporaryAudioRecorder()
    }
    
    deinit {
        
        timer?.invalidate()
        audioRecorder?.stop()
    }
}
