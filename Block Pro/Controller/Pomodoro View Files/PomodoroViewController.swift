//
//  PomodoroViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 9/9/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit
import AVFoundation

class PomodoroViewController: UIViewController, AVAudioPlayerDelegate {

    @IBOutlet weak var play_pauseAnimationButton: UIButton!
    @IBOutlet weak var countDownLabel: UILabel!
    
    @IBOutlet weak var testView: UIView!
    
    var audioPlayer: AVAudioPlayer!
    var soundURL: URL!
    
    let trackLayer = CAShapeLayer()
    let shapeLayer = CAShapeLayer()
    
    var sessionTracker: String = "none"
    var play_pauseTracker: String = ""
    
    let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
    
    var pomodoroTimer: Timer?
    var soundEffectTimer: Timer?
    var soundEffectTracker: String = ""
    
    var timerStartedCount: Int = 3
    
    var minutes: Int = 25
    var seconds: Int = 0
    
    var sessionTask: DispatchWorkItem?
    var breakTask1: DispatchWorkItem?
    var breakTask2: DispatchWorkItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let circlePosition: CGPoint = CGPoint(x: 0, y: 0)
        
        let circularPath = UIBezierPath(arcCenter: testView.center, radius: 100, startAngle:  (-CGFloat.pi * 3) / 4, endAngle: -CGFloat.pi / 4, clockwise: false)
        
        //UIBezierPath(arcCenter: view.center, radius: 100, startAngle: -CGFloat.pi / 2, endAngle: CGFloat.pi * 2, clockwise: true)
        
        trackLayer.path = circularPath.cgPath
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = UIColor.white.cgColor
        //trackLayer.strokeEnd = 0
        trackLayer.lineWidth = 10
        trackLayer.lineCap = CAShapeLayerLineCap.round
        
        
        view.layer.addSublayer(trackLayer)
        
        shapeLayer.path = circularPath.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.strokeEnd = 0
        shapeLayer.lineWidth = 10
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        
        
        view.layer.addSublayer(shapeLayer)
        
        view.backgroundColor = UIColor.flatMint.lighten(byPercentage: 0.25)
        //testView.backgroundColor = UIColor.flatMint.lighten(byPercentage: 0.1)
        
        play_pauseAnimationButton.setTitle("Animate", for: .normal)
        
        countDownLabel.textColor = .white
        
        print(testView.center.x, testView.center.y)
    }
    
//    @objc func handleTap () {
//        print("animate stroke")
//
//        if sessionTracker == "start" {
//
//            let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
//
//            basicAnimation.fromValue = 0
//            basicAnimation.toValue = 1
//            basicAnimation.duration = 30
//            basicAnimation.fillMode = CAMediaTimingFillMode.forwards
//            basicAnimation.isRemovedOnCompletion = false
//
//            shapeLayer.add(basicAnimation, forKey: "key")
//
//        }
//        else {
//            let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
//            let basicAnimationPosition = basicAnimation.toValue
//
//
//            basicAnimation.toValue = basicAnimationPosition
//            basicAnimation.duration = 0
//            basicAnimation.fillMode = CAMediaTimingFillMode.forwards
//            basicAnimation.isRemovedOnCompletion = false
//
//            shapeLayer.add(basicAnimation, forKey: "key")
//
//        }
//    }
    
    func pauseSession () {
        
        let pausedTime = shapeLayer.convertTime(CACurrentMediaTime(), from: nil)
        shapeLayer.speed = 0.0
        shapeLayer.timeOffset = pausedTime
        
        audioPlayer.stop()
        
        pomodoroTimer?.invalidate()
        soundEffectTimer?.invalidate()
    }
    
    func resumeSession () {
        
        let pausedTime = shapeLayer.timeOffset
        shapeLayer.speed = 1.0
        shapeLayer.timeOffset = 0.0
        shapeLayer.beginTime = 0.0
        
        //might be used to adjust the shapeLayer's position after a pause
        //print(shapeLayer.presentation()?.value(forKey: "strokeEnd"))

        let timeSincePause = shapeLayer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        shapeLayer.beginTime = timeSincePause
        
        var date = Date()
        pomodoroTimer = Timer(fireAt: date, interval: 1, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
        RunLoop.main.add(pomodoroTimer!, forMode: .common)
        
        date = Date()
        
        soundEffectTimer = Timer(fireAt: date, interval: 0, target: self, selector: #selector(playSoundEffect), userInfo: nil, repeats: false)
        RunLoop.main.add(soundEffectTimer!, forMode: .common)
    }
    
    @objc func countDown () {
        
        if minutes == 0 && seconds == 0 {
            
            if sessionTracker != "break" {
                
                pomodoroTimer?.invalidate()
                soundEffectTimer?.invalidate()
                
                audioPlayer.stop()
                
                breakTime()
            }
            
            else {
                
                pomodoroTimer?.invalidate()
                soundEffectTimer?.invalidate()
                
                audioPlayer.stop()
                
                soundEffectTracker = "End Break"
                
                playSoundEffect()
                
            }
            
        }
        
        else {
            
            //If the countDownLabel has already counted down from 3
            if timerStartedCount <= 0 {
                
                //If it is not a time like 19:00
                if seconds != 0 {
                
                    //If it is not a time like 19:06
                    if seconds > 10 {

                        seconds -= 1
                        countDownLabel.text = "\(minutes):\(seconds)"
                    }

                        //If it is a time like 19:06
                    else {

                        seconds -= 1
                        countDownLabel.text = "\(minutes):0\(seconds)"
                    }
                    
                    
                }
                    
                    //If it is a time like 19:00
                else {
                    
                    //Displays 25:00 on the count down label to signify the start of the timer
                    if timerStartedCount == 0 {
                        
                        countDownLabel.text = "\(minutes):0\(seconds)"
                        timerStartedCount -= 1
                    }
                        
                        //Starts a new minute
                    else {
                        
                        seconds = 59
                        minutes -= 1
                        countDownLabel.text = "\(minutes):\(seconds)"
                    }
                }
            }
                
                //If the countDownLabel hasn't already counted down from 3
            else {
                
                countDownLabel.text = "\(timerStartedCount)"
                timerStartedCount -= 1
            }
            
        }
            
      
    }
    
    @objc func playSoundEffect () {
        
        print(11)
        print(soundEffectTracker)
        
        if soundEffectTracker == "Start Timer" {
        
            soundURL = Bundle.main.url(forResource: soundEffectTracker, withExtension: "wav")
            
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL!)
            }
            
            catch {
                print(error)
            }
            
            audioPlayer.play()
            
            let calendar = Calendar.current
            let startDate = Date()
            let date = calendar.date(byAdding: .second, value: Int(audioPlayer!.duration), to: startDate)
            
            soundEffectTimer = Timer(fireAt: date ?? startDate, interval: 0, target: self, selector: #selector(playSoundEffect), userInfo: nil, repeats: false)
            RunLoop.main.add(soundEffectTimer!, forMode: .common)
            
            soundEffectTracker = "Timer Running"
            
            print(audioPlayer.duration)
            
            }
        
        else if soundEffectTracker == "Timer Running" {
            
            soundURL = Bundle.main.url(forResource: soundEffectTracker, withExtension: "wav")
            
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL!)
            }
                
            catch {
                print(error)
            }
            
            audioPlayer.play()
            
            let calendar = Calendar.current
            let startDate = Date()
            let date = calendar.date(byAdding: .second, value: Int(audioPlayer!.duration), to: startDate)
            
            soundEffectTimer = Timer(fireAt: date ?? startDate, interval: audioPlayer.duration, target: self, selector: #selector(playSoundEffect), userInfo: nil, repeats: false)
            RunLoop.main.add(soundEffectTimer!, forMode: .common)
            
            print("check", seconds)
            
            //print(shapeLayer.presentation()?.value(forKey: "strokeEnd"))
            
        }
        
        else if soundEffectTracker == "Start Break" {
            print("checkerssss")
            soundURL = Bundle.main.url(forResource: soundEffectTracker, withExtension: "wav")
            
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL!)
            }
                
            catch {
                print(error)
            }
            
            audioPlayer.play()
            
            let calendar = Calendar.current
            let startDate = Date()
            let date = calendar.date(byAdding: .second, value: Int(audioPlayer!.duration) + 1, to: startDate)
            
            soundEffectTimer = Timer(fireAt: date ?? startDate, interval: 0, target: self, selector: #selector(playSoundEffect), userInfo: nil, repeats: false)
            RunLoop.main.add(soundEffectTimer!, forMode: .common)
            
            soundEffectTracker = "Break Timer Running"
            
            print(audioPlayer.duration)
            
        }
        
        else if soundEffectTracker == "Break Timer Running" {
            
            soundURL = Bundle.main.url(forResource: soundEffectTracker, withExtension: "wav")
            
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL!)
            }
                
            catch {
                print(error)
            }
            
            audioPlayer.play()
            
            let calendar = Calendar.current
            let startDate = Date()
            let date = calendar.date(byAdding: .second, value: Int(audioPlayer!.duration), to: startDate)
            
            soundEffectTimer = Timer(fireAt: date ?? startDate, interval: audioPlayer.duration, target: self, selector: #selector(playSoundEffect), userInfo: nil, repeats: false)
            RunLoop.main.add(soundEffectTimer!, forMode: .common)
            
            print("check", seconds)
        }
        
        else if soundEffectTracker == "End Break" {
            
            soundURL = Bundle.main.url(forResource: soundEffectTracker, withExtension: "wav")
            
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL!)
            }
                
            catch {
                print(error)
            }
            
            audioPlayer.play()
            
//            let calendar = Calendar.current
//            let startDate = Date()
//            let date = calendar.date(byAdding: .second, value: Int(audioPlayer!.duration), to: startDate)
//
//            soundEffectTimer = Timer(fireAt: date ?? startDate, interval: audioPlayer.duration, target: self, selector: #selector(playSoundEffect), userInfo: nil, repeats: false)
//            RunLoop.main.add(soundEffectTimer!, forMode: .common)
            
            print("check", seconds)
            
        }
    
    }
    
    @objc func breakTime () {
        
        sessionTracker = "break"
        soundEffectTracker = "Start Break"
        
        basicAnimation.fromValue = 1
        basicAnimation.toValue = 0
        basicAnimation.duration = 30//1500
        
        //shapeLayer.add(basicAnimation, forKey: "breakKey")
        
        playSoundEffect()
        
        timerStartedCount = 3
        minutes = 5
        seconds = 0
        
        breakTask1 = DispatchWorkItem(block: {
            let now = Date()
            self.pomodoroTimer = Timer(fireAt: now, interval: 1, target: self, selector: #selector(self.countDown), userInfo: nil, repeats: true)
            RunLoop.main.add(self.pomodoroTimer!, forMode: .common)
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 6, execute: breakTask1!)
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
//            let now = Date()
//            self.pomodoroTimer = Timer(fireAt: now, interval: 1, target: self, selector: #selector(self.countDown), userInfo: nil, repeats: true)
//            RunLoop.main.add(self.pomodoroTimer!, forMode: .common)
//        }
        
        breakTask2 = DispatchWorkItem(block: {
            self.shapeLayer.add(self.basicAnimation, forKey: "breakKey")
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.75, execute: breakTask2!)
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 8.75) {
//            self.shapeLayer.add(self.basicAnimation, forKey: "breakKey")
//        }
        
    }
    
    @IBAction func play_pauseAnimation(_ sender: Any) {
        
        if sessionTracker == "none" {
            
            sessionTracker = "session"
            
            basicAnimation.fromValue = 0
            basicAnimation.toValue = 1
            basicAnimation.duration = 1500
            basicAnimation.fillMode = CAMediaTimingFillMode.forwards
            basicAnimation.isRemovedOnCompletion = false
            
            shapeLayer.speed = 1.0
            
            soundEffectTracker = "Start Timer"
            playSoundEffect()
            
            let now = Date()
            pomodoroTimer = Timer(fireAt: now, interval: 1, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
            RunLoop.main.add(pomodoroTimer!, forMode: .common)
            
            sessionTask = DispatchWorkItem(block: {
                self.shapeLayer.add(self.basicAnimation, forKey: "sessionKey")
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: sessionTask!)
            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
//                self.shapeLayer.add(self.basicAnimation, forKey: "sessionKey")
//            }
            

            
            play_pauseAnimationButton.setTitle("Pause", for: .normal)
            play_pauseTracker = "pause"
        }
        
        else if play_pauseTracker == "pause" {
            
            pauseSession()
            play_pauseAnimationButton.setTitle("Resume", for: .normal)
            play_pauseTracker = "play"
        }
            
        else if play_pauseTracker == "play" {
            
            resumeSession()
            play_pauseAnimationButton.setTitle("Pause", for: .normal)
            play_pauseTracker = "pause"
        }
    }
    
    
    @IBAction func stopAnimation(_ sender: Any) {
        
        countDownLabel.text = "New Session"
        
        timerStartedCount = 3
        
        minutes = 25
        seconds = 0
        
        shapeLayer.removeAllAnimations()
        play_pauseAnimationButton.setTitle("Animate", for: .normal)
        sessionTracker = "none"
        
        audioPlayer.stop()
        
        pomodoroTimer?.invalidate()
        soundEffectTimer?.invalidate()
        
        sessionTask?.cancel()
        breakTask1?.cancel()
        breakTask2?.cancel()
        
        //DispatchQueue.main.
    }
    
    @IBAction func test(_ sender: Any) {
        
        basicAnimation.fromValue = 1
        basicAnimation.toValue = 0
        basicAnimation.duration = 10

        shapeLayer.add(basicAnimation, forKey: "key")
    }
    
}

