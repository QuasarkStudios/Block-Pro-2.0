//
//  PomodoroViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 9/9/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit
import AVFoundation
import iProgressHUD

class PomodoroViewController: UIViewController, AVAudioPlayerDelegate {

    @IBOutlet weak var countDownLabel: UILabel!
    @IBOutlet weak var animationView: UIView!
    
    @IBOutlet weak var play_pauseButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    let trackLayer = CAShapeLayer()
    let shapeLayer = CAShapeLayer()
    let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
    
    var pomodoroTimer: Timer?
    var sessionTracker: String = "none"
    
    var sessionMinutes: Int = 25
    var sessionSeconds: Int = 0
    var timerStartedCount: Int = 3
    
    var soundEffectTimer: Timer?
    var soundEffectTracker: String = ""
    var audioPlayer: AVAudioPlayer!
    var soundURL: URL!
    
    var play_pauseTracker: String = ""
    
    var sessionTask: DispatchWorkItem?
    var breakTask1: DispatchWorkItem?
    var breakTask2: DispatchWorkItem?
    
    var i = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        configureCircularAnimation()
        configureProgress()
        
    }
    
    func configureView () {
        
        view.backgroundColor = UIColor.flatMint.lighten(byPercentage: 0.25)
        
        countDownLabel.textColor = .white
        
        animationView.frame.origin.y += 40
        
        play_pauseButton.layer.cornerRadius = 0.1 * play_pauseButton.bounds.size.width
        play_pauseButton.clipsToBounds = true
        //play_pauseButton.backgroundColor = .flatWhite
        
        stopButton.layer.cornerRadius = 0.1 * stopButton.bounds.size.width
        stopButton.clipsToBounds = true
        stopButton.backgroundColor = .flatRed
        
    }
    
    func configureCircularAnimation () {
        
        let circlePosition: CGPoint = CGPoint(x: animationView.center.x, y: animationView.center.y)
        
        let circularPath = UIBezierPath(arcCenter: circlePosition/*testView.center*/, radius: 120, startAngle:  (-CGFloat.pi * 3) / 4, endAngle: -CGFloat.pi / 4, clockwise: false)
        
        //UIBezierPath(arcCenter: view.center, radius: 100, startAngle: -CGFloat.pi / 2, endAngle: CGFloat.pi * 2, clockwise: true)
        
        trackLayer.path = circularPath.cgPath
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = UIColor.white.cgColor
        //trackLayer.strokeEnd = 0
        trackLayer.lineWidth = 15
        trackLayer.lineCap = CAShapeLayerLineCap.round
        
        view.layer.addSublayer(trackLayer)
        
        shapeLayer.path = circularPath.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.strokeEnd = 0
        shapeLayer.lineWidth = 10
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        
        
        view.layer.addSublayer(shapeLayer)
    }
    
    func configureProgress () {
        
        let iProgress: iProgressHUD = iProgressHUD()
        iProgress.isShowModal = false
        iProgress.isShowCaption = false
        iProgress.isTouchDismiss = false
        iProgress.boxColor = UIColor.clear
        
        iProgress.indicatorSize = 200
        
        iProgress.attachProgress(toView: animationView)
    }
    
    func startSession () {
        
        sessionTracker = "session"

        soundEffectTracker = "Start Timer"
        playSoundEffect()
        
        let now = Date()
        pomodoroTimer = Timer(fireAt: now, interval: 1, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
        RunLoop.main.add(pomodoroTimer!, forMode: .common)

        basicAnimation.fromValue = 0
        basicAnimation.toValue = 1
        basicAnimation.duration = 1500
        basicAnimation.fillMode = CAMediaTimingFillMode.forwards
        basicAnimation.isRemovedOnCompletion = false

        shapeLayer.speed = 1.0

        sessionTask = DispatchWorkItem(block: {
            self.shapeLayer.add(self.basicAnimation, forKey: "sessionKey")
            self.animationView.updateIndicator(style: .ballScaleMultiple)
            self.animationView.showProgress()
        })

        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: sessionTask!)

        play_pauseButton.setTitle("Pause", for: .normal)
        play_pauseTracker = "pause"
    }
    
    func pauseSession () {
        
        let pausedTime = shapeLayer.convertTime(CACurrentMediaTime(), from: nil)
        shapeLayer.speed = 0.0
        shapeLayer.timeOffset = pausedTime
        
        animationView.dismissProgress()
        
        audioPlayer.stop()
        
        pomodoroTimer?.invalidate()
        soundEffectTimer?.invalidate()
        
        play_pauseButton.setTitle("Resume", for: .normal)
        play_pauseTracker = "play"
    }
    
    func resumeSession () {
        
        let pausedTime = shapeLayer.timeOffset
        shapeLayer.speed = 1.0
        shapeLayer.timeOffset = 0.0
        shapeLayer.beginTime = 0.0
        
        //might be used to adjust the shapeLayer's position after a pause
        //print(shapeLayer.presentation()?.value(forKey: "strokeEnd"))
        
        animationView.showProgress()

        let timeSincePause = shapeLayer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        shapeLayer.beginTime = timeSincePause
        
        var date = Date()
        pomodoroTimer = Timer(fireAt: date, interval: 1, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
        RunLoop.main.add(pomodoroTimer!, forMode: .common)
        
        date = Date()
        
        soundEffectTimer = Timer(fireAt: date, interval: 0, target: self, selector: #selector(playSoundEffect), userInfo: nil, repeats: false)
        RunLoop.main.add(soundEffectTimer!, forMode: .common)
        
        play_pauseButton.setTitle("Pause", for: .normal)
        play_pauseTracker = "pause"
    }
    
    func stopSession () {
        
        countDownLabel.text = "New Session"
        
        pomodoroTimer?.invalidate()
        soundEffectTimer?.invalidate()
        
        sessionTracker = "none"
        
        sessionMinutes = 25
        sessionSeconds = 0
        timerStartedCount = 3
        
        shapeLayer.removeAllAnimations()
        
        animationView.dismissProgress()
        
        play_pauseButton.setTitle("Start", for: .normal)
        
        sessionTask?.cancel()
        breakTask1?.cancel()
        breakTask2?.cancel()
        
        guard let audio = audioPlayer else { return }
        audio.stop()
    }
    
    @objc func breakTime () {
        
        sessionTracker = "break"
        
        soundEffectTracker = "Start Break"
        playSoundEffect()
        
        timerStartedCount = 3
        sessionMinutes = 5
        sessionSeconds = 0
        
        breakTask1 = DispatchWorkItem(block: {
            let now = Date()
            self.pomodoroTimer = Timer(fireAt: now, interval: 1, target: self, selector: #selector(self.countDown), userInfo: nil, repeats: true)
            RunLoop.main.add(self.pomodoroTimer!, forMode: .common)
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 6, execute: breakTask1!)
        
        basicAnimation.fromValue = 1
        basicAnimation.toValue = 0
        basicAnimation.duration = 300
        
        breakTask2 = DispatchWorkItem(block: {
            self.shapeLayer.add(self.basicAnimation, forKey: "breakKey")
            self.animationView.showProgress()
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.75, execute: breakTask2!)
    }
    
    @objc func countDown () {
        
        //If a session or a break has ended
        if sessionMinutes == 0 && sessionSeconds == 0 {
            
            //If a session just ended
            if sessionTracker != "break" {
                
                pomodoroTimer?.invalidate()
                soundEffectTimer?.invalidate()
                
                audioPlayer.stop()
                
                breakTime()
            }
            
            //If a break just ended
            else {
                
                pomodoroTimer?.invalidate()
                soundEffectTimer?.invalidate()
                
                audioPlayer.stop()
                
                soundEffectTracker = "End Break"
                
                playSoundEffect()
                
            }
            
            animationView.updateIndicator(style: .ballScale)
            animationView.dismissProgress()
            
        }
        
        //If a session or a break is still running
        else {
            
            //If the countDownLabel has already counted down from 3
            if timerStartedCount <= 0 {
                
                play_pauseButton.isEnabled = true
                
                //If it is not a time like 19:00
                if sessionSeconds != 0 {
                
                    //If it is not a time like 19:06
                    if sessionSeconds > 10 {

                        sessionSeconds -= 1
                        countDownLabel.text = "\(sessionMinutes):\(sessionSeconds)"
                    }

                    //If it is a time like 19:06
                    else {

                        sessionSeconds -= 1
                        countDownLabel.text = "\(sessionMinutes):0\(sessionSeconds)"
                    }
                    
                    
                }
                    
                //If it is a time like 19:00
                else {
                    
                    //Displays 25:00 on the count down label to signify the start of the timer
                    if timerStartedCount == 0 {
                        
                        countDownLabel.text = "\(sessionMinutes):0\(sessionSeconds)"
                        timerStartedCount -= 1
                    }
                        
                    //Starts a new minute
                    else {
                        
                        sessionSeconds = 59
                        sessionMinutes -= 1
                        countDownLabel.text = "\(sessionMinutes):\(sessionSeconds)"
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
            
            //print(audioPlayer.duration)
            
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
            
            //print("check", sessionSeconds)
            
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
            
            //print(audioPlayer.duration)
            
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
            
            //print("check", sessionSeconds)
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
            
            //print("check", sessionSeconds)
            
        }
    
    }
    
    func animateButton (button: UIButton) {
        
        if button.title(for: .normal) == "Start" || button.title(for: .normal) == "Resume" {
            
            UIView.animate(withDuration: 1) {
                self.play_pauseButton.frame = CGRect(x: self.play_pauseButton.frame.origin.x, y: 583, width: 130, height: 65)
                self.stopButton.frame = CGRect(x: self.stopButton.frame.origin.x, y: 590, width: 100, height: 50)
            }
        }
            
        else if button.title(for: .normal) == "Stop" {
            
            UIView.animate(withDuration: 1) {
                self.play_pauseButton.frame = CGRect(x: self.play_pauseButton.frame.origin.x, y: 583, width: 110, height: 55)
                self.stopButton.frame = CGRect(x: self.stopButton.frame.origin.x, y: 583, width: 110, height: 55)
            }
            
        }
    }
    
//    func vibrate () {
//
//        i += 1
//        print("Running \(i)")
//
//        switch i {
//        case 1:
//            let generator = UINotificationFeedbackGenerator()
//            generator.notificationOccurred(.error)
//
//        case 2:
//            let generator = UINotificationFeedbackGenerator()
//            generator.notificationOccurred(.success)
//
//        case 3:
//            let generator = UINotificationFeedbackGenerator()
//            generator.notificationOccurred(.warning)
//
//        case 4:
//            let generator = UIImpactFeedbackGenerator(style: .light)
//            generator.impactOccurred()
//
//        case 5:
//            let generator = UIImpactFeedbackGenerator(style: .medium)
//            generator.impactOccurred()
//
//        case 6:
//            let generator = UIImpactFeedbackGenerator(style: .heavy)
//            generator.impactOccurred()
//
//        default:
//            let generator = UISelectionFeedbackGenerator()
//            generator.selectionChanged()
//            i = 0
//        }
//    }
    
    func play_pauseVibration () {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    func stopVibration () {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    @IBAction func play_pauseButton(_ sender: Any) {
        
        play_pauseVibration()
        
        animateButton(button: sender as! UIButton)
        
        if sessionTracker == "none" {
            
            play_pauseButton.isEnabled = false
            startSession()
        }
        
        else if play_pauseTracker == "pause" {
            
            pauseSession()
        }
            
        else if play_pauseTracker == "play" {
            
            resumeSession()
        }
    }
    
    
    @IBAction func stopAnimation(_ sender: Any) {
        
        stopVibration()
        animateButton(button: sender as! UIButton)
        stopSession()
        
        if play_pauseButton.isEnabled == false {
            play_pauseButton.isEnabled = true
        }
    }
    
}

