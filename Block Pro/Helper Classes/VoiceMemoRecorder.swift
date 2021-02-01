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
    
    private let audioSession = AVAudioSession.sharedInstance()
    
    var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    var monitoringTimer: Timer?
    
    private var currentSample: Int
    private let numberOfSamples: Int
    
    private var soundSamples: [Float]? {
        didSet {
            
            if let cell = parentCell as? VoiceMemosConfigurationCell, let samples = soundSamples {
                
                //Updates the audioVisualizer of the parentCell with the soundSamples configured in this class
                cell.updateAudioVisualizer(samples)
            }
            
            else if let cell = parentCell as? CreateCollabVoiceMemoCell, let samples = soundSamples {
                
                //Updates the audioVisualizer of the parentCell with the soundSamples configured in this class
                cell.updateAudioVisualizer(samples)
            }
        }
    }
    
    var microphoneAccessGranted: Bool?
    var beginMonitoring: Bool
    
    weak var parentCell: AnyObject?
    
    init(parentCell: AnyObject, numberOfSamples: Int, beginMonitoring: Bool = true) {
        
        self.parentCell = parentCell
        
        self.numberOfSamples = numberOfSamples
        self.soundSamples = Array(repeating: .zero, count: numberOfSamples)
        self.currentSample = 0
        
        self.beginMonitoring = beginMonitoring
        
        verifyRecordingPermission()
    }
    
    deinit {
        
        monitoringTimer?.invalidate()
        audioRecorder?.stop()
    }
    
    //MARK: - Verify Recording Permission
    
    private func verifyRecordingPermission () {
        
        //If the user has granted permission to use the microphone
        if audioSession.recordPermission == .granted {
            
            microphoneAccessGranted = true
            
            if beginMonitoring {
                
                configureTemporaryAudioRecorder()
            }
            
            if let cell = parentCell as? CreateCollabVoiceMemoCell {
                
                //Adds the notification that will be fired when the audio is interrupted, and attaches the "handleAudioInterruption" method from the "parentCell" to it
                NotificationCenter.default.addObserver(cell, selector: #selector(cell.handleAudioInterruption), name: AVAudioSession.interruptionNotification, object: nil)
            }
            
            else if let cell = parentCell as? VoiceMemosConfigurationCell {
                
                NotificationCenter.default.addObserver(cell, selector: #selector(cell.handleAudioInterruption), name: AVAudioSession.interruptionNotification, object: nil)
            }
        }
        
        else {
            
            //If the user hasn't granted permission to use the microphone
            audioSession.requestRecordPermission { (granted) in
                
                //If permission is granted
                if granted {
                    
                    self.microphoneAccessGranted = true
                    
                    if self.beginMonitoring {
                        
                        self.configureTemporaryAudioRecorder()
                    }
                    
                    if let cell = self.parentCell as? CreateCollabVoiceMemoCell {
                        
                        //Adds the notification that will be fired when the audio is interrupted, and attaches the "handleAudioInterruption" method from the "parentCell" to it
                        NotificationCenter.default.addObserver(cell, selector: #selector(cell.handleAudioInterruption), name: AVAudioSession.interruptionNotification, object: nil)
                        
                        //Performs all the layout modifications on the main thread
                        DispatchQueue.main.async {
                            
                            cell.attachButtonPressed()
                        }
                    }
                    
                    else if let cell = self.parentCell as? VoiceMemosConfigurationCell {
                        
                        //Adds the notification that will be fired when the audio is interrupted, and attaches the "handleAudioInterruption" method from the "parentCell" to it
                        NotificationCenter.default.addObserver(cell, selector: #selector(cell.handleAudioInterruption), name: AVAudioSession.interruptionNotification, object: nil)
                        
                        //Performs all the layout modifications on the main thread
                        DispatchQueue.main.async {
                            
                            cell.attachButtonPressed()
                        }
                    }
                }
                
                //If permission is denied
                else {
                    
                    if let cell = self.parentCell as? CreateCollabVoiceMemoCell {
                        
                        DispatchQueue.main.async {
                            
                            cell.presentDeniedAlert()
                        }
                    }
                    
                    else if let cell = self.parentCell as? VoiceMemosConfigurationCell {
                        
                        DispatchQueue.main.async {
                            
                            cell.presentDeniedAlert()
                        }
                    }
                }
            }
        }
    }
    
    
    //MARK: - Configure Temporary Audio Recorder
    
    func configureTemporaryAudioRecorder () {
        
        //Temporary URL where the temporary recording will be stored
        let temporaryDirectoryURL = documentsDirectory.appendingPathComponent("VoiceMemos", isDirectory: true).appendingPathComponent("temporaryAudioRecording.m4a")
        
        let recorderSettings: [String : Any] = [
            AVFormatIDKey: NSNumber(value: kAudioFormatAppleLossless),
            AVSampleRateKey: 16000.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue
        ]
        
        do {
            
            //Creates a directory called "Voice Memos" if one doesn't exist
            if !FileManager.default.fileExists(atPath: documentsDirectory.path + "/VoiceMemos") {
                
                try FileManager.default.createDirectory(atPath: documentsDirectory.path + "/VoiceMemos", withIntermediateDirectories: true, attributes: nil)
            }
            
            self.audioRecorder = try AVAudioRecorder(url: temporaryDirectoryURL, settings: recorderSettings)
            try self.audioSession.setCategory(.record, mode: .default, options: [])
            
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            
            startMonitoring()
            
        } catch {
            
            print("error configuring temporary recorder: ", error.localizedDescription)
        }

    }

    
    //MARK: - Monitoring Functions
    
    private func startMonitoring () {
        
        monitoringTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true, block: { (timer) in
            
            //Refreshes the average and peak power values for all channels of an audio recorder; allows me to get the average power for our sound channel
            self.audioRecorder?.updateMeters()
            
            if let power = self.audioRecorder?.averagePower(forChannel: 0) {
                
                //Updates soundSamples at the index cooresponding with the currentSample to be whatever averagePower give us
                self.soundSamples?[self.currentSample] = power
            }
            
            self.currentSample = (self.currentSample + 1) % self.numberOfSamples
        })
    }
    
    func stopMonitoring () {
        
        audioRecorder?.stop()
        audioRecorder?.deleteRecording() //Deletes the "temporaryAudioRecording.m4a" file
        
        monitoringTimer?.invalidate()
    }
    
    
    //MARK: - Recording Functions
    
    func startRecording (_ voiceMemoID: String) {
        
        stopMonitoring()
        
        //The URL where the recording/voice memo will be stored
        let url = documentsDirectory.appendingPathComponent("VoiceMemos", isDirectory: true).appendingPathComponent(voiceMemoID + ".m4a")
        
        let recorderSettings: [String : Any] = [
            AVFormatIDKey: NSNumber(value: kAudioFormatAppleLossless),
            AVSampleRateKey: 12000.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
        ]
        
        do {
            
            //Creates a directory called "Voice Memos" if one doesn't exist
            if !FileManager.default.fileExists(atPath: documentsDirectory.path + "/VoiceMemos") {
                
                try FileManager.default.createDirectory(atPath: documentsDirectory.path + "/VoiceMemos", withIntermediateDirectories: true, attributes: nil)
            }
            
            self.audioRecorder = try AVAudioRecorder(url: url, settings: recorderSettings)
            try self.audioSession.setCategory(.record, mode: .default, options: [])

            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            
            self.startMonitoring()
            
        } catch {
            
            print("error starting recording: ", error.localizedDescription)
        }
    }
    
    func stopRecording (voiceMemoID: String, completion: ((_ memoLength: Float64) -> Void)) {
        
        audioRecorder?.stop()
        
        monitoringTimer?.invalidate()
        
        //The URL where the recording/voice memo is stored
        let url = documentsDirectory.appendingPathComponent("VoiceMemos", isDirectory: true).appendingPathComponent(voiceMemoID + ".m4a")
        
        //Calculating the duration of the recording
        let asset = AVURLAsset(url: url)
        let audioDuration = asset.duration
        let audioDurationSeconds = CMTimeGetSeconds(audioDuration)
        
        completion(audioDurationSeconds) //For some reason you keep accidentally deleting this... so stop it
    }
    
    
    //MARK: - Recording Playback Functions
    
    func playbackRecording (_ voiceMemoID: String) {
        
        //The URL where the recording/voice memo is stored
        let url = documentsDirectory.appendingPathComponent("VoiceMemos", isDirectory: true).appendingPathComponent(voiceMemoID + ".m4a")
        
        do {
            
            audioPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.m4a.rawValue)
            try self.audioSession.setCategory(.playback, mode: .default, options: [])
            
            audioPlayer?.play()
            
        } catch {
            
            print("error playing back recording: ", error.localizedDescription)
        }
    }
    
    func stopRecordingPlayback () {
        
        audioPlayer?.stop()
    }
    
    
    //MARK: - Delete Recording
    
    func deleteRecording (_ voiceMemo: VoiceMemo) {
        
        if let voiceMemoID = voiceMemo.voiceMemoID {
            
            //The URL where the recording/voice memo is stored
            let url = documentsDirectory.appendingPathComponent("VoiceMemos", isDirectory: true).appendingPathComponent(voiceMemoID + ".m4a")
            
            do {
                
                try FileManager.default.removeItem(at: url)
                
            } catch {
                
                print("error deleting recording: ", error.localizedDescription)
            }
        }
    }
    
    
    //MARK: - Determine Audio Interuption Type
    
    //Used in the parentCell class
    func determineIfAudioInteruptionBegan(_ notification: NSNotification) -> Bool {
        
        if let userInfo = notification.userInfo, let typeValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt, let type = AVAudioSession.InterruptionType(rawValue: typeValue) {
            
            if type == .began {
                
                return true
            }
            
            else {
                
                return false
            }
        }
        
        else {
            
            return false
        }
    }
}
