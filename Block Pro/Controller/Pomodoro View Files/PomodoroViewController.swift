//
//  PomodoroViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 9/9/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit
import AVFoundation
import UserNotifications
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
    
    var totalPomodoroCount: Int = 0
    var pomodoroMinutes: Int = 0
    var pomodoroSeconds: Int = 0
    
    var currentPomodoroCount: Int = 0
    
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
    
    var pomodoroCountAnimationTracker: Int = 0
    
    var resumeFromBackground: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        configurePomodoroProgressAnimation()
        configureiProgress()
        
        //configurePomodoro()
        
        //appDidBecomeActive()
        
        NotificationCenter.default.addObserver(self, selector: #selector(configurePomodoro), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appResignedActive), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        configurePomodoro() // move later; clean this array when you move to be a protocol: pomodoroCountStops.removeAll(); reset pomodorostoptracker to 0
        configurePomodoroCountAnimation()
        
        
        print("view appeared")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        appResignedActive()
        
//        soundEffectTimer?.invalidate()
//
//        guard audioPlayer != nil else { return }
//            audioPlayer.stop()
    }
    
    //MARK: - App Resigned Active Function
    
    @objc func appResignedActive () {
        
        print("app resigned active")

        if pomodoroTimer?.isValid == true {
            
            //savePomodoroData()
            scheduleNotification()
            
            timerStartedCount = 0
        }
            
        else {
            
            print("checkersssshjdfmkf")
            
            if timerStartedCount > 0 {
                
                if sessionTracker == "5MinBreak" || sessionTracker == "30MinBreak" {
                    
                    //savePomodoroData()
                    scheduleNotification()
                    
                    timerStartedCount = 0
                }
            }
            
            else {
                
                if sessionTracker == "5MinBreak" && pomodoroMinutes == 0 && pomodoroSeconds == 0 {
                    
                    sessionTracker = "session"
                    soundEffectTracker = "Start Timer"
                    
                    timerStartedCount = 3
                }
                
                
            }
            
            //savePomodoroData()
        }
        
        savePomodoroData()
        
//        timerStartedCount = 0
        
        sessionTask?.cancel()
        breakTask1?.cancel()
        breakTask2?.cancel()
        
        soundEffectTimer?.invalidate()
        pomodoroTimer?.invalidate()
        progressShapeLayer.removeAllAnimations()
        pomodoroProgressAnimationView.dismissProgress()
        
        guard audioPlayer != nil else { return }
            audioPlayer.stop()
    }
    
    //MARK: - App Did Become Active Function - to be replaced and deleted
    
    @objc func appDidBecomeActive () {
        
        print("app becoming active")
        
        if defaults.value(forKey: "pomodoroActive") as? Bool ?? false == true {
            
            print("check 1")
            
            let now = Date()
            let pomodoroEndTime = defaults.value(forKey: "currentPomodoroEndTime") as? Date ?? now
            
            
            if pomodoroEndTime > now {
                
                print("check 2")
                
                let calendar = Calendar.current
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [defaults.value(forKey: "pomodoroNotificationID") as? String ?? ""])
                
                pomodoroMinutes = calendar.dateComponents([.minute], from: now, to: pomodoroEndTime).minute!
                pomodoroSeconds = calendar.dateComponents([.second], from: now, to: pomodoroEndTime).second! % 60

                //defaults.value(forKey: "pomodoroMinutes") as! Int * 60 - ((pomodoroMinutes * 60) + pomodoroSeconds)
                
                print(1.0 / (defaults.value(forKey: "pomodoroMinutes") as? Double ?? 25.0 * 60.0))
                
                let allProgressAnimationValues: Double = (defaults.value(forKey: "pomodoroMinutes") as? Double ?? 25.0 * 60.0)

                let progressAnimationPart: Double = (1.0 / allProgressAnimationValues)

                let pastProgressAnimationValues: Double = allProgressAnimationValues - (Double(pomodoroMinutes * 60) + Double(pomodoroSeconds))

                print(progressAnimationPart * pastProgressAnimationValues)

                progressBasicAnimation.duration = CFTimeInterval((pomodoroMinutes * 60) + pomodoroSeconds)
                progressBasicAnimation.fillMode = CAMediaTimingFillMode.forwards
                progressBasicAnimation.isRemovedOnCompletion = false

                progressBasicAnimation.fromValue = progressAnimationPart * pastProgressAnimationValues
                progressBasicAnimation.toValue = 1

                progressShapeLayer.add(progressBasicAnimation, forKey: "pomodoroKey")
                
                resumeSession()
            }
            
            else {
                
                print("check 3")
                
                resumeFromBackground = true
                
                progressBasicAnimation.duration = 0
                progressBasicAnimation.fillMode = CAMediaTimingFillMode.forwards
                progressBasicAnimation.isRemovedOnCompletion = false
                
                play_pauseButton.frame = CGRect(x: play_pauseButton.frame.origin.x, y: 583, width: 110, height: 55)
                stopButton.frame = CGRect(x: stopButton.frame.origin.x, y: 583, width: 110, height: 55)
                
                play_pauseButton.isEnabled = true
                play_pauseButton.setTitle("Start", for: .normal)
                
                if currentPomodoroCount + 1 == totalPomodoroCount && sessionTracker == "session" {
                    
                    sessionTracker = "30MinBreak"
                    soundEffectTracker = "Start Break"
                    
                    countDownLabel.text = "Start your 30 minute break"
                    
                    progressBasicAnimation.fromValue = 1
                    progressBasicAnimation.toValue = 1
                    
                    animatePomodoroCount()
                    
                    progressShapeLayer.add(progressBasicAnimation, forKey: "pomodoroKey")
                }
                
                else if sessionTracker == "session" {
                    
                    countDownLabel.text = "Start your 5 minute break"
                    
                    sessionTracker = "5MinBreak"
                    soundEffectTracker = "Start Break"
                    
                    progressBasicAnimation.fromValue = 1
                    progressBasicAnimation.toValue = 1
                    
                    progressShapeLayer.add(progressBasicAnimation, forKey: "pomodoroKey")
                }
                    
                else if sessionTracker == "5MinBreak" {
                    
                    animatePomodoroCount()
                    
                    countDownLabel.text = "Start your next Pomodoro session"
                    
                    sessionTracker = "session"
                    soundEffectTracker = "Start Timer"
                    
                    progressBasicAnimation.fromValue = 0
                    progressBasicAnimation.toValue = 0
                    
                    progressShapeLayer.add(progressBasicAnimation, forKey: "pomodoroKey")
                }
                
                else if sessionTracker == "30MinBreak" {
                    
                    defaults.set(0, forKey: "currentPomodoro")
                    configurePomodoro()
                    
                    countDownLabel.text = "Start A New Pomodoro"
                    
                    progressShapeLayer.removeAllAnimations()
                    
                    countShapeLayer.removeAllAnimations()
                    pomodoroCountLabel.textColor = UIColor.flatMint().lighten(byPercentage: 0.25)
                    pomodoroCountLabel.text = "0"
                    
                    sessionTracker = "none"
                    
                    timerStartedCount = 3
                    
                    animateButton("shrink")
                    
                    play_pauseButton.setTitle("Start", for: .normal)
                    
                    endBreak {
                        self.soundEffectTracker = ""
                    }
                }
                
            }
        }
        
        else {
            
            play_pauseButton.frame = CGRect(x: play_pauseButton.frame.origin.x, y: 583, width: 110, height: 55)
            stopButton.frame = CGRect(x: stopButton.frame.origin.x, y: 583, width: 110, height: 55)
            
            play_pauseButton.isEnabled = true
            play_pauseButton.setTitle("Start", for: .normal)
            
            if sessionTracker == "session" {
                
                print("heloooo")
                
                resumeFromBackground = true
                
                pomodoroMinutes = 0//defaults.value(forKey: "pomodoroMinutes") as? Int ?? 25
                pomodoroSeconds = 10
                
                countDownLabel.text = "Start your next Pomodoro session"
                
                progressBasicAnimation.duration = 0
                progressBasicAnimation.fillMode = CAMediaTimingFillMode.forwards
                progressBasicAnimation.isRemovedOnCompletion = false
                
                progressBasicAnimation.fromValue = 0
                progressBasicAnimation.toValue = 0
                
                progressShapeLayer.add(progressBasicAnimation, forKey: "pomodoroKey")
                
            }
            
            else if sessionTracker == "5MinBreak" || sessionTracker == "30MinBreak" {
                
                resumeFromBackground = true
                
                if sessionTracker == "5MinBreak" {
                    countDownLabel.text = "Start your 5 minute break"
                }
                else {
                    countDownLabel.text = "Start your 30 minute break"
                }
                
                progressBasicAnimation.duration = 0
                progressBasicAnimation.fillMode = CAMediaTimingFillMode.forwards
                progressBasicAnimation.isRemovedOnCompletion = false
                
                progressBasicAnimation.fromValue = 1
                progressBasicAnimation.toValue = 1
                
                progressShapeLayer.add(progressBasicAnimation, forKey: "pomodoroKey")
            }
            
        }
    
    }
    
    //MARK: - Configure View Function
    
    func configureView () {
        
        view.backgroundColor = UIColor.flatMint().lighten(byPercentage: 0.25)
        
        countDownLabel.adjustsFontSizeToFitWidth = true
        
        pomodoroProgressAnimationView.frame.origin.y += 40
        
        play_pauseButton.layer.cornerRadius = 0.1 * play_pauseButton.bounds.size.width
        play_pauseButton.clipsToBounds = true
        //play_pauseButton.backgroundColor = .flatWhite
        
        stopButton.layer.cornerRadius = 0.1 * stopButton.bounds.size.width
        stopButton.clipsToBounds = true
        stopButton.backgroundColor = .flatRed()
        
    }
    
    //MARK: Configure Pomdooro Progress Animation Function
    
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
    
    //MARK: - Configure iProgress Function
    
    func configureiProgress () {
        
        let iProgress: iProgressHUD = iProgressHUD()
        iProgress.isShowModal = false
        iProgress.isShowCaption = false
        iProgress.isTouchDismiss = false
        iProgress.boxColor = UIColor.clear
        
        iProgress.indicatorSize = 200
        
        iProgress.attachProgress(toView: pomodoroProgressAnimationView)
    }
    
    //MARK: - Configure Pomodoro Function
    
   @objc func configurePomodoro () {
        
        navigationItem.title = defaults.value(forKey: "pomodoroName") as? String ?? "Pomodoro"
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [defaults.value(forKey: "pomodoroNotificationID") as? String ?? ""])
        
        totalPomodoroCount = defaults.value(forKey: "pomodoroCount") as? Int ?? 4
        currentPomodoroCount = defaults.value(forKey: "currentPomodoro") as? Int ?? 0
//        pomodoroMinutes = defaults.value(forKey: "pomodoroMinutes") as? Int ?? 25
        //pomodoroSeconds = 10
        
    
        if let pomodoroActive = defaults.value(forKey: "pomodoroActive") as? Bool {
            
            if pomodoroActive == true {
                
                let now = Date()
                let pomodoroEndTime = defaults.value(forKey: "currentPomodoroEndTime") as? Date ?? now
                
                if pomodoroEndTime > now {
                    
                    sessionTracker = defaults.value(forKey: "currentPomodoroSession") as? String ?? "none"
                    soundEffectTracker = defaults.value(forKey: "currentPomodoroSoundEffect") as? String ?? ""
                    timerStartedCount = 0
                    
                    let calendar = Calendar.current
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [defaults.value(forKey: "pomodoroNotificationID") as? String ?? ""])
                    
                    pomodoroMinutes = calendar.dateComponents([.minute], from: now, to: pomodoroEndTime).minute!
                    pomodoroSeconds = calendar.dateComponents([.second], from: now, to: pomodoroEndTime).second! % 60
                    
                    pomodoroProgressAnimationView.updateIndicator(style: .ballScaleMultiple)
                    
                    self.play_pauseButton.frame = CGRect(x: self.play_pauseButton.frame.origin.x, y: 583, width: 130, height: 65)
                    self.stopButton.frame = CGRect(x: self.stopButton.frame.origin.x, y: 590, width: 100, height: 50)
                    
                    resumeSession()
                    
                    configurePomodoroCountAnimation()
                    
                    if currentPomodoroCount > 0 {
                        pomodoroCountAnimationTracker = currentPomodoroCount
                        animatePomodoroCount()
                    }
                    
                    //resumeSession()
                    
                }
                
                else {
                    
//                    totalPomodoroCount = defaults.value(forKey: "pomodoroCount") as? Int ?? 4
//                    currentPomodoroCount = defaults.value(forKey: "currentPomodoro") as? Int ?? 0
                    
                    sessionTracker = defaults.value(forKey: "currentPomodoroSession") as? String ?? "none"
                    
                    resumeFromBackground = true
                    
                    timerStartedCount = 3
                    
                    progressBasicAnimation.duration = 0
                    progressBasicAnimation.fillMode = CAMediaTimingFillMode.forwards
                    progressBasicAnimation.isRemovedOnCompletion = false
                    
                    play_pauseButton.frame = CGRect(x: play_pauseButton.frame.origin.x, y: 583, width: 110, height: 55)
                    stopButton.frame = CGRect(x: stopButton.frame.origin.x, y: 583, width: 110, height: 55)
                    
                    play_pauseButton.isEnabled = true
                    play_pauseButton.setTitle("Start", for: .normal)
                   
                    if currentPomodoroCount + 1 == totalPomodoroCount && sessionTracker == "session" {
                        
                        sessionTracker = "30MinBreak"
                        soundEffectTracker = "Start Break"
                        
                        countDownLabel.text = "Start your 30 minute break"
                        
                        progressBasicAnimation.fromValue = 1
                        progressBasicAnimation.toValue = 1
                        
                        progressShapeLayer.add(progressBasicAnimation, forKey: "pomodoroKey")
                        
                        configurePomodoroCountAnimation()
                        
                        if currentPomodoroCount > 0 {
                            pomodoroCountAnimationTracker = currentPomodoroCount
                        }
                        
                        animatePomodoroCount()
                    }
                    
                    else if sessionTracker == "session" {
                        
                        countDownLabel.text = "Start your 5 minute break"
                        
                        sessionTracker = "5MinBreak"
                        soundEffectTracker = "Start Break"
                        
                        progressBasicAnimation.fromValue = 1
                        progressBasicAnimation.toValue = 1
                        
                        progressShapeLayer.add(progressBasicAnimation, forKey: "pomodoroKey")
                    }
                    
                    else if sessionTracker == "5MinBreak" {
                        
                        print("frzsxdrcfbhjnklm;',''klmjnbhgvcfdx")
                        
                        pomodoroMinutes = 0//defaults.value(forKey: "currentPomodoroMinutes") as? Int ?? 25
                        pomodoroSeconds = 10
                        
                        countDownLabel.text = "Start your next Pomodoro session"
                        
                        sessionTracker = "session"
                        soundEffectTracker = "Start Timer"
                        
                        progressBasicAnimation.fromValue = 0
                        progressBasicAnimation.toValue = 0
                        
                        progressShapeLayer.add(progressBasicAnimation, forKey: "pomodoroKey")
                        
                        configurePomodoroCountAnimation()
                        
                        if currentPomodoroCount > 0 {
                            pomodoroCountAnimationTracker = currentPomodoroCount
                            print("pomodoroCountAnimationTracker1", pomodoroCountAnimationTracker)
                        }
                        
                        animatePomodoroCount()
                        print("pomodoroCountAnimationTracker1", pomodoroCountAnimationTracker)
                    }
                    
                    else if sessionTracker == "30MinBreak" {
                        
                        pomodoroMinutes = defaults.value(forKey: "currentPomodoroMinutes") as? Int ?? 25
                        
                        defaults.set(0, forKey: "currentPomodoro")
                        //configurePomodoro()
                        
                        countDownLabel.text = "Start A New Pomodoro"
                        
                        progressShapeLayer.removeAllAnimations()
                        
                        countShapeLayer.removeAllAnimations()
                        pomodoroCountLabel.textColor = UIColor.flatMint().lighten(byPercentage: 0.25)
                        pomodoroCountLabel.text = "0"
                        
                        sessionTracker = "none"
                        
                        timerStartedCount = 3
                        
                        animateButton("shrink")
                        
                        play_pauseButton.setTitle("Start", for: .normal)
                        
                        endBreak {
                            self.soundEffectTracker = ""
                        }
                    }
                    
                    
                }
            
                
            }
            
            else if pomodoroActive == false {
                
                print("pomodoro is not active")
                
                timerStartedCount = 3
                
                sessionTracker = defaults.value(forKey: "currentPomodoroSession") as? String ?? "none"
                //soundEffectTracker = defaults.value(forKey: "currentPomodoroSoundEffect") as? String ?? ""
                
                play_pauseButton.frame = CGRect(x: play_pauseButton.frame.origin.x, y: 583, width: 110, height: 55)
                stopButton.frame = CGRect(x: stopButton.frame.origin.x, y: 583, width: 110, height: 55)
                
                play_pauseButton.isEnabled = true
                play_pauseButton.setTitle("Start", for: .normal)
                
                if sessionTracker == "session" {
                    
                    print("not active, session")
                    
                    resumeFromBackground = true
                    
                    pomodoroMinutes = 0//defaults.value(forKey: "pomodoroMinutes") as? Int ?? 25
                    pomodoroSeconds = 10
                    
                    countDownLabel.text = "Start your next Pomodoro session"
                    
                    progressBasicAnimation.duration = 0
                    progressBasicAnimation.fillMode = CAMediaTimingFillMode.forwards
                    progressBasicAnimation.isRemovedOnCompletion = false

                    progressBasicAnimation.fromValue = 0
                    progressBasicAnimation.toValue = 0

                    progressShapeLayer.add(progressBasicAnimation, forKey: "pomodoroKey")
                    
                    configurePomodoroCountAnimation()
                    
                    //currentPomodoroCount -= 1
                    pomodoroCountAnimationTracker = currentPomodoroCount
                    
                    if currentPomodoroCount > 0 {
                        animatePomodoroCount()
                    }
                    
                }
                    
                else if sessionTracker == "5MinBreak" || sessionTracker == "30MinBreak" {
                    
                    print("not active, break")
                    
                    resumeFromBackground = true
                    
                    if sessionTracker == "5MinBreak" {
                        countDownLabel.text = "Start your 5 minute break"
                    }
                    else {
                        countDownLabel.text = "Start your 30 minute break"
                    }
                    
                    progressBasicAnimation.duration = 0
                    progressBasicAnimation.fillMode = CAMediaTimingFillMode.forwards
                    progressBasicAnimation.isRemovedOnCompletion = false
                    
                    progressBasicAnimation.fromValue = 1
                    progressBasicAnimation.toValue = 1
                    
                    progressShapeLayer.add(progressBasicAnimation, forKey: "pomodoroKey")
                    
                    configurePomodoroCountAnimation()
                    
                    if currentPomodoroCount > 0 {
                        pomodoroCountAnimationTracker = currentPomodoroCount
                    }
                    
                    animatePomodoroCount()
                    
                }
                
            }
        }
        
        else {
            
            pomodoroMinutes = 0//defaults.object(forKey: "currentPomodoroMinutes") as? Int ?? 25
            pomodoroSeconds = 10
        }
        
        print("count", totalPomodoroCount)
        print("minutes", pomodoroMinutes)
        
    }
    
    //MARK: - Configure Pomodoro Count Animation
    
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
        
        if currentPomodoroCount == 0 {
            pomodoroCountLabel.textColor = UIColor.flatMint().lighten(byPercentage: 0.25)
        }
        else {
            pomodoroCountLabel.textColor = .white
        }
        
        pomodoroCountStops.removeAll()
        
        print(totalPomodoroCount)
        
        while count <= totalPomodoroCount {
            
            pomodoroCountStops.append(CGFloat((1.0 / Double(totalPomodoroCount)) * Double(count)))
            count += 1
        }
        
    }
    
    //MARK: - Start Session Function
    
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
    
    //MARK: - Pause Session Function
    
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
    
    //MARK: - Resume Session Function
    
    func resumeSession () {
        
        let pausedTime = progressShapeLayer.timeOffset
        progressShapeLayer.speed = 1.0
        progressShapeLayer.timeOffset = 0.0
        progressShapeLayer.beginTime = 0.0
        
        let allProgressAnimationValues: Double = (defaults.value(forKey: "pomodoroMinutes") as? Double ?? 25.0 * 60.0)
        
        let progressAnimationPart: Double = (1.0 / allProgressAnimationValues)
        
        let pastProgressAnimationValues: Double = allProgressAnimationValues - (Double(pomodoroMinutes * 60) + Double(pomodoroSeconds))
        
        progressBasicAnimation.duration = CFTimeInterval((pomodoroMinutes * 60) + pomodoroSeconds)
        progressBasicAnimation.fillMode = CAMediaTimingFillMode.forwards
        progressBasicAnimation.isRemovedOnCompletion = false
        
        progressBasicAnimation.fromValue = progressAnimationPart * pastProgressAnimationValues
        progressBasicAnimation.toValue = 1
        
        progressShapeLayer.add(progressBasicAnimation, forKey: "pomodoroKey")
        
        
        
        
        
        //might be used to adjust the shapeLayer's position after a pause
        //print("progressShapLayerPosition", progressShapeLayer.presentation()?.value(forKey: "strokeEnd"))
        
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
    
    //MARK: - Resume Session From Background
    
    func resumeSessionFromBackground () {
        
        if sessionTracker == "session" {
            print("yessirirr")
            pomodoroProgressAnimationView.updateIndicator(style: .ballScaleMultiple)
            startSession()
        }
        
        else if sessionTracker == "5MinBreak" || sessionTracker == "30MinBreak" {
            
            pomodoroProgressAnimationView.updateIndicator(style: .ballScale)
            startBreak()
        }
        
        play_pauseButton.setTitle("Resume", for: .normal)
    }
    
    //MARK: - Stop Session Function
    
    #warning("reset defaults setting when a session is stopped")
    func stopSession () {
        
        countDownLabel.text = "Start Pomodoro"
        
        pomodoroTimer?.invalidate()
        soundEffectTimer?.invalidate()
        
        sessionTracker = "none"
        //soundEffectTracker = ""
        
        resumeFromBackground = false
        
        currentPomodoroCount = 0
        defaults.set(0, forKey: "currentPomodoro")
        
        pomodoroMinutes = defaults.value(forKey: "pomodoroMinutes") as? Int ?? 25
        pomodoroSeconds = 0
        timerStartedCount = 3
        
        progressShapeLayer.removeAllAnimations()
        pomodoroProgressAnimationView.dismissProgress()
        
        countShapeLayer.removeAllAnimations()
        pomodoroCountLabel.textColor = UIColor.flatMint().lighten(byPercentage: 0.25)
        //pomodoroCountLabel.text = "0"
        
        play_pauseButton.setTitle("Start", for: .normal)
        
        sessionTask?.cancel()
        breakTask1?.cancel()
        breakTask2?.cancel()
        
        guard audioPlayer != nil else { return }
            audioPlayer.stop()
    }
    
    //MARK: - Start Break Function
    
    @objc func startBreak () {

        play_pauseButton.isEnabled = false
        
        soundEffectTracker = "Start Break"
        playSoundEffect()

        timerStartedCount = 3

        if sessionTracker == "5MinBreak" {
            pomodoroMinutes = 0//5
            pomodoroSeconds = 10//10
            
            progressBasicAnimation.fromValue = 1
            progressBasicAnimation.toValue = 0
            progressBasicAnimation.duration = 300
        }
        else if sessionTracker == "30MinBreak" {
            pomodoroMinutes = 0//30
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
    
    //MARK: - End Break Function
    
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
    
    //MARK: - Count Down Function
    
    @objc func countDown () {
        
        //If a session or a break has ended
        if pomodoroMinutes == 0 && pomodoroSeconds == 0 {
            
            //If this was the last Pomodoro before a 30 min break
            if currentPomodoroCount + 1 == totalPomodoroCount && sessionTracker == "session" {
                
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
            else if currentPomodoroCount == totalPomodoroCount && sessionTracker == "30MinBreak" {
                
                defaults.set(0, forKey: "currentPomodoro")
                defaults.set(nil, forKey: "pomodoroActive")
                
                configurePomodoro()
                
                countDownLabel.text = "Start A New Pomodoro"
                
                pomodoroTimer?.invalidate()
                soundEffectTimer?.invalidate()
                
                progressShapeLayer.removeAllAnimations()
                pomodoroProgressAnimationView.dismissProgress()
                
                countShapeLayer.removeAllAnimations()
                pomodoroCountLabel.textColor = UIColor.flatMint().lighten(byPercentage: 0.25)
                pomodoroCountLabel.text = "0"
                
                sessionTracker = "none"
                
                timerStartedCount = 3
                
                pomodoroCountAnimationTracker = 0

                animateButton("shrink")

                play_pauseButton.setTitle("Start", for: .normal)

                endBreak {
                    self.soundEffectTracker = ""
                }
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
                
                play_pauseButton.isEnabled = false
                countDownLabel.text = "\(timerStartedCount)"
                timerStartedCount -= 1
            }
        }
    }
    
    //MARK: - Play Sound Effect Function
    
    @objc func playSoundEffect () {
        
        if defaults.value(forKey: "playPomodoroSoundEffects") as? Bool ?? true == true {
            
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
        

    }
    
    //MARK: - Animate Pomodoro Count
    
    func animatePomodoroCount () {
        
        currentPomodoroCount += 1
        
        UIView.animate(withDuration: 2, animations: {
            self.pomodoroCountLabel.textColor = UIColor.flatMint().lighten(byPercentage: 0.25)
        }) { (finished: Bool) in
            
            self.pomodoroCountLabel.text = "\(self.currentPomodoroCount)"
            
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
            countBasicAnimation.toValue = pomodoroCountStops[pomodoroCountAnimationTracker]
        }
            
        else if countBasicAnimation.fromValue as? CGFloat == 0 {
            
            countBasicAnimation.fromValue = pomodoroCountStops[pomodoroCountAnimationTracker]
            pomodoroCountAnimationTracker += 1
            countBasicAnimation.toValue = pomodoroCountStops[pomodoroCountAnimationTracker]
        }
        
        else {
           
            countBasicAnimation.fromValue = pomodoroCountStops[pomodoroCountAnimationTracker]
            pomodoroCountAnimationTracker += 1
            countBasicAnimation.toValue = pomodoroCountStops[pomodoroCountAnimationTracker]
        }
        
        countShapeLayer.add(countBasicAnimation, forKey: "countKey")
    }
    
    //MARK: - Save Pomodoro Data Function
    
    func savePomodoroData () {
        
        let date = Date()
        let calendar = Calendar.current
        var pomodoroEndTime: Date?
        
        pomodoroEndTime = calendar.date(byAdding: .minute, value: pomodoroMinutes, to: date)
        pomodoroEndTime = calendar.date(byAdding: .second, value: pomodoroSeconds + timerStartedCount, to: pomodoroEndTime!)
        
        if pomodoroTimer?.isValid == true {
            defaults.set(true, forKey: "pomodoroActive")
        }
        else {
            
            if sessionTracker == "5MinBreak" || sessionTracker == "30MinBreak" {
                defaults.set(true, forKey: "pomodoroActive")
            }
            else {
                defaults.set(false, forKey: "pomodoroActive")
            }
        }
        
        defaults.set(totalPomodoroCount, forKey: "totalPomodoroCount")
        
        defaults.set(currentPomodoroCount, forKey: "currentPomodoro")
        //defaults.set(pomodoroMinutes, forKey: "currentPomodoroMinutes")
        //defaults.set(pomodoroSeconds, forKey: "currentPomodoroSeconds")
        defaults.set(pomodoroEndTime, forKey: "currentPomodoroEndTime")
        
        defaults.set(sessionTracker, forKey: "currentPomodoroSession")
        defaults.set(soundEffectTracker, forKey: "currentPomodoroSoundEffect")
        
        
        //defaults.setValue(navigationItem.title, forKey: "pomodoroName")
        

    }
    
    //MARK: - Schedule Notification Function
    
    func scheduleNotification () {
        
        let date = Date()
        let calendar = Calendar.current
        var notificationTime: Date?
        
        let content = UNMutableNotificationContent()
        let trigger: UNCalendarNotificationTrigger
        let request: UNNotificationRequest
        
        let notificationID = UUID().uuidString
        
        notificationTime = calendar.date(byAdding: .minute, value: pomodoroMinutes, to: date)
        notificationTime = calendar.date(byAdding: .second, value: pomodoroSeconds + timerStartedCount, to: notificationTime!)
        
        if sessionTracker == "session" {
            
            content.title = "Time For A Break"
            content.body = "Check in on Block Pro to start your break. You've earned it!!"
        }
        else if sessionTracker == "5MinBreak" {
            
            content.title = "Your 5 Minute Break's Up"
            content.body = "Check in on Block Pro to start your next Pomodoro Session. Let's make it better than the last!!"
            
        }
        else if sessionTracker == "30MinBreak" {
            
            content.title = "Your 30 Minute Break's Up"
            content.title = "Great job completing a full Pomodoro. Check in on Block Pro to start another one!!"
            
        }
        
        content.sound = UNNotificationSound.default
        
        trigger = UNCalendarNotificationTrigger(dateMatching: calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: notificationTime!), repeats: false)
        
        request = UNNotificationRequest(identifier: notificationID, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
        defaults.setValue(notificationID, forKey: "pomodoroNotificationID")
        
    }
    
    //MARK: - Animate Button Function
    
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

        if resumeFromBackground == true {
            
            resumeSessionFromBackground()
            resumeFromBackground = false
        }
        
        else {
            
            if sessionTracker == "none" {
                
                //play_pauseButton.isEnabled = false
                startSession()
            }
                
            else if play_pauseTracker == "pause" {
                
                pauseSession()
            }
                
            else if play_pauseTracker == "play" {
                
                resumeSession()
            }
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

