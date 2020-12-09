//
//  VoiceMemoPlayer.swift
//  Block Pro
//
//  Created by Nimat Azeez on 12/4/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import AVFoundation

class VoiceMemoPlayer {
    
    private let audioSession = AVAudioSession.sharedInstance()
    private var audioPlayer: AVAudioPlayer?
    
    static let sharedInstance = VoiceMemoPlayer()
    
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
}
