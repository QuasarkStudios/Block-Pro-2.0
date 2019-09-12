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
    
    
    let shapeLayer = CAShapeLayer()
    
    var animationTracker: String = ""
    
    let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
    
    var pomodoroTimer: Timer?
    var soundEffectTimer: Timer?
    var soundEffectTracker: String = ""
    
    var timerStartedCount: Int = 3
    
    var minutes: Int = 25
    var seconds: Int = 0
    
    var count: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let circlePosition: CGPoint = CGPoint(x: 0, y: 0)
        
        let circularPath = UIBezierPath(arcCenter: testView.center, radius: 100, startAngle:  (-CGFloat.pi * 3) / 4, endAngle: -CGFloat.pi / 4, clockwise: false)
        
        let trackLayer = CAShapeLayer()//UIBezierPath(arcCenter: view.center, radius: 100, startAngle: -CGFloat.pi / 2, endAngle: CGFloat.pi * 2, clockwise: true)
        
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
        
        animationTracker = "start"
        
        countDownLabel.textColor = .white
        
        print(testView.center.x, testView.center.y)
    }
    
    @objc func handleTap () {
        print("animate stroke")
        
        if animationTracker == "start" {
            
            let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
            
            basicAnimation.fromValue = 0
            basicAnimation.toValue = 1
            basicAnimation.duration = 30
            basicAnimation.fillMode = CAMediaTimingFillMode.forwards
            basicAnimation.isRemovedOnCompletion = false
            
            shapeLayer.add(basicAnimation, forKey: "key")
            
        }
        else {
            let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
            let basicAnimationPosition = basicAnimation.toValue
            
            
            basicAnimation.toValue = basicAnimationPosition
            basicAnimation.duration = 0
            basicAnimation.fillMode = CAMediaTimingFillMode.forwards
            basicAnimation.isRemovedOnCompletion = false
            
            shapeLayer.add(basicAnimation, forKey: "key")
            
        }
    }
    
    func pauseAnimation () {
        
        let pausedTime = shapeLayer.convertTime(CACurrentMediaTime(), from: nil)
        shapeLayer.speed = 0.0
        shapeLayer.timeOffset = pausedTime
        
        audioPlayer.stop()
        
        pomodoroTimer?.invalidate()
        soundEffectTimer?.invalidate()
    }
    
    func resumeAnimation () {
        
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
        
        //If the countDownLabel has already counted down from 3
        if timerStartedCount <= 0 {
            
            //If it is not a time like 19:00
            if count != 0 {
                
                //If it is not a time like 19:06
                if count > 10 {
                    
                    count -= 1
                    countDownLabel.text = "\(minutes):\(count)"
                }
                    
                //If it is a time like 19:06
                else {
                    
                    count -= 1
                    countDownLabel.text = "\(minutes):0\(count)"
                }
                
                
            }
                
            //If it is a time like 19:00
            else {
                
                //Displays 25:00 on the count down label to signify the start of the timer
                if timerStartedCount == 0 {
                    
                    countDownLabel.text = "\(minutes):0\(count)"
                    timerStartedCount -= 1
                }
                
                //Starts a new minute
                else {
                   
                    count = 59
                    minutes -= 1
                    countDownLabel.text = "\(minutes):\(count)"
                }
            }
        }
        
        //If the countDownLabel hasn't already counted down from 3
        else {
            
            countDownLabel.text = "\(timerStartedCount)"
            timerStartedCount -= 1
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
            
            soundEffectTimer = Timer(fireAt: date ?? startDate, interval: audioPlayer.duration, target: self, selector: #selector(playSoundEffect), userInfo: nil, repeats: false)
            RunLoop.main.add(soundEffectTimer!, forMode: .common)
            
            soundEffectTracker = "Timer Running"
            
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
            
            print("check", count)
            
            //print(shapeLayer.presentation()?.value(forKey: "strokeEnd"))
            
        }
    
    }
    
    @IBAction func play_pauseAnimation(_ sender: Any) {
        
        if animationTracker == "start" {
            
            basicAnimation.fromValue = 0
            basicAnimation.toValue = 1
            basicAnimation.duration = 33//1500
            basicAnimation.fillMode = CAMediaTimingFillMode.forwards
            basicAnimation.isRemovedOnCompletion = false
            
            shapeLayer.speed = 1.0
            shapeLayer.add(basicAnimation, forKey: "key")
            
            play_pauseAnimationButton.setTitle("Pause", for: .normal)
            animationTracker = "pause"
            
            soundEffectTracker = "Start Timer"
            playSoundEffect()
            
            let now = Date()
            pomodoroTimer = Timer(fireAt: now, interval: 1, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
            RunLoop.main.add(pomodoroTimer!, forMode: .common)
        }
        
        else if animationTracker == "pause" {
            
            pauseAnimation()
            play_pauseAnimationButton.setTitle("Resume", for: .normal)
            animationTracker = "resume"
        }
            
        else if animationTracker == "resume" {
            
            resumeAnimation()
            play_pauseAnimationButton.setTitle("Pause", for: .normal)
            animationTracker = "pause"
        }
    }
    
    
    @IBAction func stopAnimation(_ sender: Any) {
        
        countDownLabel.text = "New Session"
        
        timerStartedCount = 3
        
        minutes = 25
        seconds = 0

        count = 0
        
        shapeLayer.removeAllAnimations()
        play_pauseAnimationButton.setTitle("Animate", for: .normal)
        animationTracker = "start"
        
        audioPlayer.stop()
        
        pomodoroTimer?.invalidate()
        soundEffectTimer?.invalidate()
    }
    
    @IBAction func test(_ sender: Any) {
        
        basicAnimation.fromValue = 1
        basicAnimation.toValue = 0
        basicAnimation.duration = 10

        shapeLayer.add(basicAnimation, forKey: "key")
    }
    
}

