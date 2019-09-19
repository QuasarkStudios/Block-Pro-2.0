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
    @IBOutlet weak var pomodoroProgressAnimationView: UIView!
    
    @IBOutlet weak var play_pauseButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var pomodoroCountAnimationView: UIView!
    @IBOutlet weak var pomodoroCountLabel: UILabel!
    
    
    let defaults = UserDefaults.standard
    
    let progressTrackLayer = CAShapeLayer()
    let progressShapeLayer = CAShapeLayer()
    let progressBasicAnimation = CABasicAnimation(keyPath: "strokeEnd")
    
    let countTrackLayer = CAShapeLayer()
    let countShapeLayer = CAShapeLayer()
    let countBasicAnimation = CABasicAnimation(keyPath: "strokeEnd")
    
    var pomodoroTimer: Timer?
    var sessionTracker: String = "none"
    
    var pomodoroCount: Int = 4
    var pomodoroMinutes: Int = 25
    var pomodoroSeconds: Int = 10
    
    var currentPomodoro: Int = 0
    
    var pomodoroCountStops: [CGFloat] = []
    
    var timerStartedCount: Int = 3
    
    var soundEffectTimer: Timer?
    var soundEffectTracker: String = ""
    var audioPlayer: AVAudioPlayer!
    var soundURL: URL!
    
    var play_pauseTracker: String = ""
    
    var sessionTask: DispatchWorkItem?
    var breakTask1: DispatchWorkItem?
    var breakTask2: DispatchWorkItem?
    
    var pomodoroCountTracker: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        configurePomodoroProgressAnimation()
        configureiProgress()
        
        NotificationCenter.default.addObserver(self, selector: #selector(doStuff), name: UIApplication.willResignActiveNotification, object: nil)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        configurePomodoro()
        configurePomodoroCountAnimation()
        
        if pomodoroTimer != nil {
            
            let date = Date()
            soundEffectTimer = Timer(fireAt: date, interval: 0, target: self, selector: #selector(playSoundEffect), userInfo: nil, repeats: false)
            RunLoop.main.add(soundEffectTimer!, forMode: .common)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        soundEffectTimer?.invalidate()
        
        guard audioPlayer != nil else { return }
            audioPlayer.stop()
    }
    
    @objc func doStuff () {
        
        print("stuff")
        soundEffectTimer?.invalidate()
        
        guard audioPlayer != nil else { return }
            audioPlayer.stop()
    }
    
    
    func configureView () {
        
        view.backgroundColor = UIColor.flatMint.lighten(byPercentage: 0.25)
        
        pomodoroProgressAnimationView.frame.origin.y += 40
        
        play_pauseButton.layer.cornerRadius = 0.1 * play_pauseButton.bounds.size.width
        play_pauseButton.clipsToBounds = true
        //play_pauseButton.backgroundColor = .flatWhite
        
        stopButton.layer.cornerRadius = 0.1 * stopButton.bounds.size.width
        stopButton.clipsToBounds = true
        stopButton.backgroundColor = .flatRed
        
    }
    
    func configurePomodoroProgressAnimation () {
        
        let circlePosition: CGPoint = CGPoint(x: pomodoroProgressAnimationView.center.x, y: pomodoroProgressAnimationView.center.y)
        
        let circularPath = UIBezierPath(arcCenter: circlePosition/*testView.center*/, radius: 120, startAngle:  (-CGFloat.pi * 3) / 4, endAngle: -CGFloat.pi / 4, clockwise: false)
        
        //UIBezierPath(arcCenter: view.center, radius: 100, startAngle: -CGFloat.pi / 2, endAngle: CGFloat.pi * 2, clockwise: true)
        
        progressTrackLayer.path = circularPath.cgPath
        progressTrackLayer.fillColor = UIColor.clear.cgColor
        progressTrackLayer.strokeColor = UIColor.white.cgColor
        //trackLayer.strokeEnd = 0
        progressTrackLayer.lineWidth = 15
        progressTrackLayer.lineCap = CAShapeLayerLineCap.round
        
        view.layer.addSublayer(progressTrackLayer)
        
        progressShapeLayer.path = circularPath.cgPath
        progressShapeLayer.fillColor = UIColor.clear.cgColor
        progressShapeLayer.strokeColor = UIColor.red.cgColor
        progressShapeLayer.strokeEnd = 0
        progressShapeLayer.lineWidth = 10
        progressShapeLayer.lineCap = CAShapeLayerLineCap.round
        
        
        view.layer.addSublayer(progressShapeLayer)
    }
    
    func configureiProgress () {
        
        let iProgress: iProgressHUD = iProgressHUD()
        iProgress.isShowModal = false
        iProgress.isShowCaption = false
        iProgress.isTouchDismiss = false
        iProgress.boxColor = UIColor.clear
        
        iProgress.indicatorSize = 200
        
        iProgress.attachProgress(toView: pomodoroProgressAnimationView)
    }
    
    func configurePomodoro () {
        
        if defaults.object(forKey: "pomodoroCustomized") as? Bool ?? false == true {
            
            print("cool")
            
            navigationItem.title = defaults.object(forKey: "pomodoroName") as? String ?? "Pomodoro"
            
            pomodoroCount = defaults.object(forKey: "pomodoroCount") as? Int ?? 4
            pomodoroMinutes = defaults.object(forKey: "pomodoroMinutes") as? Int ?? 25
            
            currentPomodoro = defaults.object(forKey: "currentPomdoro") as? Int ?? 0
        }
        else {
            
            navigationItem.title = "Pomodoro"
            
            pomodoroCount = 4
            pomodoroMinutes = 25
            currentPomodoro = defaults.object(forKey: "currentPomdoro") as? Int ?? 0
            
        }
        
        print("count", pomodoroCount)
        print("minutes", pomodoroMinutes)
        
    }
    
    func configurePomodoroCountAnimation () {
        
        let circlePosition: CGPoint = CGPoint(x: pomodoroCountAnimationView.center.x, y: pomodoroCountAnimationView.center.y)
        let circularPath = UIBezierPath(arcCenter: circlePosition, radius: 20, startAngle: -CGFloat.pi / 2, endAngle: -((5 * CGFloat.pi) / 2), clockwise: false)
        var count: Int = 1
        
        countTrackLayer.path = circularPath.cgPath
        countTrackLayer.fillColor = UIColor.clear.cgColor
        countTrackLayer.strokeColor = UIColor.white.cgColor
        countTrackLayer.lineWidth = 5

        view.layer.addSublayer(countTrackLayer)

        countShapeLayer.path = circularPath.cgPath
        countShapeLayer.fillColor = UIColor.clear.cgColor
        countShapeLayer.strokeColor = UIColor.red.cgColor
        countShapeLayer.strokeEnd = 0
        countShapeLayer.lineWidth = 3
        countShapeLayer.lineCap = CAShapeLayerLineCap.round

        view.layer.addSublayer(countShapeLayer)
        
        if currentPomodoro == 0 {
            pomodoroCountLabel.textColor = UIColor.flatMint.lighten(byPercentage: 0.25)
        }
        else {
            pomodoroCountLabel.textColor = .white
        }
        
        pomodoroCountStops.removeAll()
        
        while count <= pomodoroCount {
            
            pomodoroCountStops.append(CGFloat((1.0 / Double(pomodoroCount)) * Double(count)))
            count += 1
        }
        
    }
    
    func startSession () {

        sessionTracker = "session"

        soundEffectTracker = "Start Timer"
        playSoundEffect()
        
        let now = Date()
        pomodoroTimer = Timer(fireAt: now, interval: 1, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
        RunLoop.main.add(pomodoroTimer!, forMode: .common)

        progressBasicAnimation.fromValue = 0
        progressBasicAnimation.toValue = 1
        progressBasicAnimation.duration = CFTimeInterval(pomodoroMinutes * 60)
        progressBasicAnimation.fillMode = CAMediaTimingFillMode.forwards
        progressBasicAnimation.isRemovedOnCompletion = false

        progressShapeLayer.speed = 1.0

        sessionTask = DispatchWorkItem(block: {
            self.progressShapeLayer.add(self.progressBasicAnimation, forKey: "pomodoroKey")
            self.pomodoroProgressAnimationView.updateIndicator(style: .ballScaleMultiple)
            self.pomodoroProgressAnimationView.showProgress()
        })

        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: sessionTask!)

        play_pauseButton.setTitle("Pause", for: .normal)
        play_pauseTracker = "pause"
    }
    
    func pauseSession () {
        
        let pausedTime = progressShapeLayer.convertTime(CACurrentMediaTime(), from: nil)
        progressShapeLayer.speed = 0.0
        progressShapeLayer.timeOffset = pausedTime
        
        pomodoroProgressAnimationView.dismissProgress()
        
        audioPlayer.stop()
        
        pomodoroTimer?.invalidate()
        soundEffectTimer?.invalidate()
        
        play_pauseButton.setTitle("Resume", for: .normal)
        play_pauseTracker = "play"
    }
    
    func resumeSession () {
        
        let pausedTime = progressShapeLayer.timeOffset
        progressShapeLayer.speed = 1.0
        progressShapeLayer.timeOffset = 0.0
        progressShapeLayer.beginTime = 0.0
        
        //might be used to adjust the shapeLayer's position after a pause
        //print(shapeLayer.presentation()?.value(forKey: "strokeEnd"))
        
        pomodoroProgressAnimationView.showProgress()

        let timeSincePause = progressShapeLayer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        progressShapeLayer.beginTime = timeSincePause
        
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
        
        countDownLabel.text = "Start Pomodoro"
        
        pomodoroTimer?.invalidate()
        soundEffectTimer?.invalidate()
        
        sessionTracker = "none"
        
        pomodoroMinutes = 25
        pomodoroSeconds = 0
        timerStartedCount = 3
        
        progressShapeLayer.removeAllAnimations()
        
        pomodoroProgressAnimationView.dismissProgress()
        
        play_pauseButton.setTitle("Start", for: .normal)
        
        sessionTask?.cancel()
        breakTask1?.cancel()
        breakTask2?.cancel()
        
        guard audioPlayer != nil else { return }
            audioPlayer.stop()
    }
    
    @objc func startBreak () {

        soundEffectTracker = "Start Break"
        playSoundEffect()

        timerStartedCount = 3

        
        if sessionTracker == "5MinBreak" {
            pomodoroMinutes = 5
            pomodoroSeconds = 10
            
            progressBasicAnimation.fromValue = 1
            progressBasicAnimation.toValue = 0
            progressBasicAnimation.duration = 300
        }
        else if sessionTracker == "30MinBreak" {
            pomodoroMinutes = 30
            pomodoroSeconds = 10
            
            progressBasicAnimation.fromValue = 1
            progressBasicAnimation.toValue = 0
            progressBasicAnimation.duration = 1800
        }
        
        
        breakTask1 = DispatchWorkItem(block: {

            let now = Date()
            self.pomodoroTimer = Timer(fireAt: now, interval: 1, target: self, selector: #selector(self.countDown), userInfo: nil, repeats: true)
            RunLoop.main.add(self.pomodoroTimer!, forMode: .common)
        })

        DispatchQueue.main.asyncAfter(deadline: .now() + 6, execute: breakTask1!)

        breakTask2 = DispatchWorkItem(block: {
            self.progressShapeLayer.add(self.progressBasicAnimation, forKey: "breakKey")
            self.pomodoroProgressAnimationView.showProgress()
        })

        DispatchQueue.main.asyncAfter(deadline: .now() + 8.75, execute: breakTask2!)
    }
    
    func endBreak (completion: @escaping () -> ()) {
        
        pomodoroTimer?.invalidate()
        soundEffectTimer?.invalidate()
        
        audioPlayer.stop()
        
        soundEffectTracker = "End Break"
        
        playSoundEffect()
        
        pomodoroProgressAnimationView.dismissProgress()
        
        breakTask1 = DispatchWorkItem(block: {
            completion()
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: breakTask1!)
        
        //completion()
    }
    
    @objc func countDown () {
        
        //If a session or a break has ended
        if pomodoroMinutes == 0 && pomodoroSeconds == 0 {
            
            //If this was the last Pomodoro before a 30 min break
            if currentPomodoro + 1 == pomodoroCount && sessionTracker == "session" {
                
                animatePomodoroCount()
                
                pomodoroTimer?.invalidate()
                soundEffectTimer?.invalidate()
                
                audioPlayer.stop()
                
                pomodoroProgressAnimationView.dismissProgress()
                pomodoroProgressAnimationView.updateIndicator(style: .ballScale)
                
                sessionTracker = "30MinBreak"
                startBreak()
                
            }
                
            //If the final 30 min break just ended
            else if currentPomodoro == pomodoroCount && sessionTracker == "30MinBreak" {
                
                defaults.set(0, forKey: "currentPomodoro")
                configurePomodoro()
                
                countDownLabel.text = "Start A New Pomodoro"
                
                pomodoroTimer?.invalidate()
                soundEffectTimer?.invalidate()
                
                progressShapeLayer.removeAllAnimations()
                pomodoroProgressAnimationView.dismissProgress()
                
                countShapeLayer.removeAllAnimations()
                pomodoroCountLabel.textColor = UIColor.flatMint.lighten(byPercentage: 0.25)
                pomodoroCountLabel.text = "0"
                
                sessionTracker = "none"
                
                timerStartedCount = 3

                animateButton("shrink")

                play_pauseButton.setTitle("Start", for: .normal)

                endBreak {}
            }
            
            //If just a regular Pomodoro or break just ended
            else {
                
                //If a Pomodoro just ended
                if sessionTracker != "5MinBreak" {
                    
                    pomodoroTimer?.invalidate()
                    soundEffectTimer?.invalidate()
                    
                    audioPlayer.stop()
                    
                    pomodoroProgressAnimationView.dismissProgress()
                    pomodoroProgressAnimationView.updateIndicator(style: .ballScale)
                    
                    sessionTracker = "5MinBreak"
                    startBreak()
                }
                    
                //If a 5 min break just ended
                else if sessionTracker == "5MinBreak" {
                    
                    animatePomodoroCount()
                    
                    endBreak {
                        self.soundEffectTracker = "Start Timer"
                        
                        self.timerStartedCount = 3
                        
                        self.pomodoroMinutes = 0
                        self.pomodoroSeconds = 10
                        
                        self.startSession()
                    }
                }
            }
            
        }
        
        //If a Pomodoro or break is still running
        else {
            
            //If the countDownLabel has already counted down from 3
            if timerStartedCount <= 0 {
                
                play_pauseButton.isEnabled = true
                
                //If it is not a time like 19:00
                if pomodoroSeconds != 0 {
                    
                    //If it is not a time like 19:06
                    if pomodoroSeconds > 10 {
                        
                        pomodoroSeconds -= 1
                        countDownLabel.text = "\(pomodoroMinutes):\(pomodoroSeconds)"
                    }
                        
                    //If it is a time like 19:06
                    else {
                        
                        pomodoroSeconds -= 1
                        countDownLabel.text = "\(pomodoroMinutes):0\(pomodoroSeconds)"
                    }
                    
                    
                }
                    
                //If it is a time like 19:00
                else {
                    
                    //Displays 25:00 on the count down label to signify the start of the timer
                    if timerStartedCount == 0 {
                        
                        countDownLabel.text = "\(pomodoroMinutes):0\(pomodoroSeconds)"
                        timerStartedCount -= 1
                    }
                        
                    //Starts a new minute
                    else {
                        
                        pomodoroSeconds = 59
                        pomodoroMinutes -= 1
                        countDownLabel.text = "\(pomodoroMinutes):\(pomodoroSeconds)"
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
        }
        
        else if soundEffectTracker == "Start Break" {
            
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
        }
    }
    
    func animatePomodoroCount () {
        
        currentPomodoro += 1
        
        UIView.animate(withDuration: 2, animations: {
            self.pomodoroCountLabel.textColor = UIColor.flatMint.lighten(byPercentage: 0.25)
        }) { (finished: Bool) in
            
            self.pomodoroCountLabel.text = "\(self.currentPomodoro)"
            
            UIView.animate(withDuration: 2, animations: {
                self.pomodoroCountLabel.textColor = .white
            })
        }
        
        countBasicAnimation.duration = 1
        countBasicAnimation.fillMode = CAMediaTimingFillMode.forwards
        countBasicAnimation.isRemovedOnCompletion = false
        
        countShapeLayer.speed = 1.0
        
        if countBasicAnimation.fromValue == nil && countBasicAnimation.toValue == nil {
            
            countBasicAnimation.fromValue = 0
            countBasicAnimation.toValue = pomodoroCountStops[pomodoroCountTracker]
        }
            
        else if countBasicAnimation.fromValue as? CGFloat == 0 {
            
            countBasicAnimation.fromValue = pomodoroCountStops[pomodoroCountTracker]
            pomodoroCountTracker += 1
            countBasicAnimation.toValue = pomodoroCountStops[pomodoroCountTracker]
        }
        
        else {
           
            countBasicAnimation.fromValue = pomodoroCountStops[pomodoroCountTracker]
            pomodoroCountTracker += 1
            countBasicAnimation.toValue = pomodoroCountStops[pomodoroCountTracker]
        }
        
        countShapeLayer.add(countBasicAnimation, forKey: "countKey")
    }
    
    func animateButton (_ animation: String) {
        
        if animation == "grow" {
            UIView.animate(withDuration: 1) {
                self.play_pauseButton.frame = CGRect(x: self.play_pauseButton.frame.origin.x, y: 583, width: 130, height: 65)
                self.stopButton.frame = CGRect(x: self.stopButton.frame.origin.x, y: 590, width: 100, height: 50)
            }
        }
            
        else if animation == "shrink" {
            UIView.animate(withDuration: 1) {
                self.play_pauseButton.frame = CGRect(x: self.play_pauseButton.frame.origin.x, y: 583, width: 110, height: 55)
                self.stopButton.frame = CGRect(x: self.stopButton.frame.origin.x, y: 583, width: 110, height: 55)
            }
            
        }
    }
    
    func play_pauseVibration () {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    func stopVibration () {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveToEditView" {
            
            let cancelItem = UIBarButtonItem()
            cancelItem.title = "Cancel"
            navigationItem.backBarButtonItem = cancelItem
            
        }
    }
    
    @IBAction func editButton(_ sender: Any) {
        
        performSegue(withIdentifier: "moveToEditView", sender: self)
        
    }
    
    @IBAction func play_pauseButton(_ sender: Any) {
        
        play_pauseVibration()

        animateButton("grow")

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
        animateButton("shrink")
        stopSession()
        
        if play_pauseButton.isEnabled == false {
            play_pauseButton.isEnabled = true
        }
    }
    
}

