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

    
    @IBOutlet weak var gradientView: RadialGradients!
    @IBOutlet weak var gradientViewTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var gradientViewBottomAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var controlViewContainer: UIView!
    @IBOutlet weak var controlContainerTopAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var controlView: UIView!
    
    @IBOutlet weak var gestureView: UIView!
    @IBOutlet weak var gestureViewTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var gestureViewHeightConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var dismissIndicator: UIView!
    
    @IBOutlet weak var countDownLabel: UILabel!
    @IBOutlet weak var countDownLabelTopAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var pomodoroProgressAnimationView: UIView!
    @IBOutlet weak var progressAnimationViewTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var progressAnimationViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var iProgressView: UIView!
    @IBOutlet weak var progressViewCenterYAnchor: NSLayoutConstraint!
    
    
    @IBOutlet weak var play_pauseButton: UIButton!
    
    @IBOutlet weak var play_pauseCenterXAnchor: NSLayoutConstraint!
    @IBOutlet weak var play_pauseButtonTopAnchor: NSLayoutConstraint!
    
    
    @IBOutlet weak var play_pauseButtonLeadingAnchor: NSLayoutConstraint!
    @IBOutlet weak var play_pauseButtonBottomAnchor: NSLayoutConstraint!
    @IBOutlet weak var play_pauseButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var play_pauseButtonHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var stopButtonTopAnchor: NSLayoutConstraint!
    
    
    @IBOutlet weak var stopButtonCenterXAnchor: NSLayoutConstraint!
    @IBOutlet weak var stopButtonTrailingAnchor: NSLayoutConstraint!
    @IBOutlet weak var stopButtonBottomAnchor: NSLayoutConstraint!
    @IBOutlet weak var stopButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var stopButtonHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var sessionInfoContainer: UIView!
    @IBOutlet weak var sessionContainerTopAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var sessionLabelContainer: UIView!
    @IBOutlet weak var sessionLabel: UILabel!
    
    @IBOutlet weak var pomodoroCountAnimationView: UIView!
    @IBOutlet weak var pomodoroCountLabel: UILabel!
    
    let defaults = UserDefaults.standard
    
    var viewIntiallyLoaded: Bool = false //Variable that tracks if the view has been loaded at least once
    
    let progressTrackLayer = CAShapeLayer()
    let progressShapeLayer = CAShapeLayer()
    let progressBasicAnimation = CABasicAnimation(keyPath: "strokeEnd") //Object that will add animation capabilities to the "progressShapeLayer"
    
    let countTrackLayer = CAShapeLayer()
    let countShapeLayer = CAShapeLayer()
    let countBasicAnimation = CABasicAnimation(keyPath: "strokeEnd") //Object that will add animation capabilities to the "countShapeLayer"
    
    var pomodoroTimer: Timer? //Timer used for the Pomodoro and break sessions
    var sessionTracker: String = "none" //Variable that tracks what session a user is on
    
    var totalPomodoroCount: Int = 0 //Variable that holds the total amount of Pomodoro sessions
    var pomodoroMinutes: Int = 0 //Variable that holds the amount of minutes remaining in a session
    var pomodoroSeconds: Int = 0 //Variable that holds the amounts of seconds remaining in a session
    
    var currentPomodoroCount: Int = 0 //Variable that holds which Pomodoro session a user is currently on
    
    var pomodoroCountStops: [CGFloat] = [] //Array that holds all the stops the Pomodoro count animation will animate to
    
    var timerStartedCount: Int = 0 //Variable that will decrement down to 0 once a session is started
    
    var soundEffectTimer: Timer? //Timer used to run Pomodoro Sound effects on a loop
    var soundEffectTracker: String = "" //Variable used to track which sound effect should be playing
    var audioPlayer: AVAudioPlayer? //An audio player that provides playback of audio data from a file or memory
    var soundURL: URL!
    
    var play_pauseTracker: String = "" //Variable used to track whether the Pomodoro is paused or playing
    
    var sessionTask: DispatchWorkItem? //A task that will be exectued after a delay when a new session starts
    var breakTask1: DispatchWorkItem? //A task that will be exectued after a delay when a break starts
    var breakTask2: DispatchWorkItem? //A task that will be exectued after a delay when a break starts
    
    var resumeFromBackground: Bool = false //Variable that tracks whether or not this view is returning to the foreground
    
    var originalStopButtonBottomAnchor: CGFloat = 0 //Variable that hold the original bottom constraint constant of the stop button
    
//    var controlViewOriginAnchor: CGFloat = 0
//    var gestureViewOriginAnchor: CGFloat = 0
    
    var gradientViewOrigin: CGFloat = 0
    var controlViewOrigin: CGFloat = 0
    var gestureViewOrigin: CGFloat = 0
    
    var gradientViewAnimatedPosition: CGFloat = 0
    var progressAnimatedPosition: CGFloat = 0
    var controlViewAnimatedPosition: CGFloat = 0
    var gestureViewAnimatedPosition: CGFloat = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        //configureConstraints()
        
        play_pauseCenterXAnchor.constant = 0
        stopButtonCenterXAnchor.constant = 0
        
        print("controlView height didLoad", controlView.frame.height)
        
//        controlViewOriginAnchor = controlContainerTopAnchor.constant
//        gestureViewOriginAnchor = gestureViewTopAnchor.constant
        
        
        print(controlView.frame.height)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //Watches for when the app becomes active again from the background
        NotificationCenter.default.addObserver(self, selector: #selector(configurePomodoro), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        //Watches for when this view will resign its active state
        NotificationCenter.default.addObserver(self, selector: #selector(viewResignedActive), name: UIApplication.willResignActiveNotification, object: nil)
        
        //Removes the pending notification that would be scheduled if a user leaves this view during a active Pomodoro session
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [defaults.value(forKey: "pomodoroNotificationID") as? String ?? ""])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //If the view hasn't been loaded up at least once before
        if viewIntiallyLoaded == false {
            
            configureConstraints2()
            
            configurePomodoroProgressAnimation()
            configureiProgress()
            configurePomodoro()
            
            viewIntiallyLoaded = true
        }
            
        //If the view has already been loaded up before
        else {
            configurePomodoro()
        }
        
        print("controlView height didAppear", controlView.frame.height)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        viewResignedActive()
        
        NotificationCenter.default.removeObserver(self)

    }
    
    
    //MARK: - App Resigned Active Function
    
    @objc func viewResignedActive () {

        //If a Pomodoro or break session is active
        if pomodoroTimer?.isValid == true {
            
            scheduleNotification()
            
            timerStartedCount = 0
        }
         
        //If a Pomodoro or break session isn't active
        else {
            
            //If the "timerStartedCount" hasn't finished decrementing to 0
            if timerStartedCount > 0 {
                
                //Required if statement because the "pomodoroTimer" isn't active until the "timerStartedCount" reaches 0 for breaks 
                if sessionTracker == "5MinBreak" || sessionTracker == "30MinBreak" {
                    
                    scheduleNotification()
                }
            }
            
            else {
                
                //If the user left the view right when a 5 minute break ended
                if sessionTracker == "5MinBreak" && pomodoroMinutes == 0 && pomodoroSeconds == 0 {
                    
                    sessionTracker = "session"
                    setSessionLabelText(sessionTracker)
                    
                    soundEffectTracker = "Start Timer"
                }
            }
        }
        
        savePomodoroData()
        
        sessionTask?.cancel()
        breakTask1?.cancel()
        breakTask2?.cancel()
        
        soundEffectTimer?.invalidate()
        pomodoroTimer?.invalidate()
        
        progressShapeLayer.removeAllAnimations()
        countShapeLayer.removeAllAnimations()
        //pomodoroProgressAnimationView.dismissProgress()
        iProgressView.dismissProgress()
        
        audioPlayer?.stop()
    }
    
    
    //MARK: - Configure View Function
    
    func configureView () {
        
        //controlView.isHidden = true
        
        //view.backgroundColor = UIColor.flatMint().lighten(byPercentage: 0.25)
        
        iProgressView.backgroundColor = .clear
        
//        print(progressShapeLayer.actions?["position"])
//
//        let layerActions = ["position": NSNull()]
//        progressTrackLayer.actions = layerActions
//        progressShapeLayer.actions = ["position" : nil] as? [String : CAAction]//layerActions
//
//        print(progressShapeLayer.actions?["position"])
        
        
        controlViewContainer.backgroundColor = UIColor(hexString: "f2f2f2")?.darken(byPercentage: 0.05)//UIColor(hexString: "f2f2f2")?.darken(byPercentage: 0.1)
        controlViewContainer.layer.cornerRadius = 0.065 * controlViewContainer.bounds.size.width
        controlViewContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] //Top left corner and top right corner respectively
        controlViewContainer.clipsToBounds = true
       
        controlView.layer.cornerRadius = 0.065 * controlView.bounds.size.width
        controlView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] //Top left corner and top right corner respectively
        controlView.clipsToBounds = true
        
        dismissIndicator.backgroundColor = UIColor(hexString: "f2f2f2")?.darken(byPercentage: 0.05)
        dismissIndicator.layer.cornerRadius = 0.075 * 50
        dismissIndicator.clipsToBounds = true
        
        gestureView.backgroundColor = .lightGray
        
        
        
        
        pomodoroProgressAnimationView.backgroundColor = .clear//.white
        
        countDownLabel.backgroundColor = .blue
        countDownLabel.adjustsFontSizeToFitWidth = true
        
        play_pauseButton.layer.cornerRadius = 0.1 * play_pauseButton.bounds.size.width
        play_pauseButton.clipsToBounds = true
        play_pauseButton.backgroundColor = UIColor.flatMint().lighten(byPercentage: 0.35)//?.withAlphaComponent(0.75)
        
        stopButton.layer.cornerRadius = 0.1 * stopButton.bounds.size.width
        stopButton.clipsToBounds = true
        stopButton.backgroundColor = .flatRed()
        
        sessionInfoContainer.backgroundColor = UIColor.flatMint().lighten(byPercentage: 0.35)
        
  //      sessionLabelContainer.backgroundColor = UIColor.flatMint().lighten(byPercentage: 0.25)
  //      sessionLabelContainer.layer.cornerRadius = 0.08 * sessionLabel.bounds.size.width
    //    sessionLabelContainer.clipsToBounds = true
        
        sessionLabel.backgroundColor = .white//UIColor.flatMint().lighten(byPercentage: 0.25)
        sessionLabel.layer.cornerRadius = 0.075 * sessionLabel.bounds.size.width
        sessionLabel.clipsToBounds = true
        
        sessionLabel.adjustsFontSizeToFitWidth = true
        
        pomodoroCountAnimationView.backgroundColor = .white//UIColor.flatMint().lighten(byPercentage: 0.25)
        pomodoroCountAnimationView.layer.cornerRadius = 0.5 * pomodoroCountAnimationView.bounds.size.width
        pomodoroCountAnimationView.clipsToBounds = true
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:)))
        gestureView.addGestureRecognizer(pan)
        
    }
    
    
    //MARK: - Configure Constraints Function
    
    func configureConstraints2 () {
        
        gradientViewOrigin = gradientViewTopAnchor.constant
        
        //iPhone XS Max & iPhone XR
        if UIScreen.main.bounds.width == 414.0 && UIScreen.main.bounds.height == 896.0 {
            
            progressViewCenterYAnchor.constant = -7.5
            
            controlContainerTopAnchor.constant += 50
            
            gestureViewTopAnchor.constant += 35
            gestureViewHeightConstraint.constant += 36
            
            gradientViewOrigin = gradientViewTopAnchor.constant
            
            gradientViewAnimatedPosition = gradientViewOrigin + 82.5
            progressAnimatedPosition = 82.5
            
            
            
            sessionContainerTopAnchor.constant = (controlView.frame.height - 50) - (sessionInfoContainer.frame.height + 5)
            
            gestureViewAnimatedPosition = (view.frame.height - (view.safeAreaInsets.top + view.safeAreaInsets.bottom)) - (gestureView.frame.height + 36)
            controlViewAnimatedPosition = (controlContainerTopAnchor.constant) + ((controlView.frame.height - 50) - 82)
            
        }
            
        //iPhone XS
        else if UIScreen.main.bounds.width == 375.0 && UIScreen.main.bounds.height == 812.0 {
            
            gradientViewAnimatedPosition = gradientViewOrigin + 82.5
            progressAnimatedPosition = 82.5
            
            controlViewOrigin = controlContainerTopAnchor.constant
            gestureViewOrigin = gestureViewTopAnchor.constant
            
            gestureViewAnimatedPosition = (view.frame.height - (view.safeAreaInsets.top + view.safeAreaInsets.bottom)) - (gestureView.frame.height) //Setting the gesture view to be at the bottom of the screen after it's animated
            controlViewAnimatedPosition = (controlContainerTopAnchor.constant) + ((controlView.frame.height - 0) - 82) //Setting the controlView to only show the count down label plus a little buffer after its animated
            

              
            

        }
            
        //iPhone 8 Plus
        else if UIScreen.main.bounds.width == 414.0 && UIScreen.main.bounds.height == 736.0 {
            
            controlContainerTopAnchor.constant += 25
            
            sessionContainerTopAnchor.constant = (controlView.frame.height - 25) - (sessionInfoContainer.frame.height + 5)
            
        }
            
        //iPhone 8
        else if UIScreen.main.bounds.width == 375.0 && UIScreen.main.bounds.height == 667.0 {
            

        }
            
        //iPhone SE
        else {

        }
        
        
        

        

        
//        controlViewAnimatedPosition = 556
//        gestureViewAnimatedPosition = 515
    }
    
    func configureConstraints () {
        
        
        
        print(controlView.frame.height)
        
        
        
        //iPhone XS Max & iPhone XR
        if UIScreen.main.bounds.width == 414.0 && UIScreen.main.bounds.height == 896.0 {
            
            //Tweaking layout
            
            progressViewCenterYAnchor.constant = -7.5
            
            controlContainerTopAnchor.constant += 35
            
            gestureViewTopAnchor.constant += 35
            gestureViewHeightConstraint.constant += 36
            
            play_pauseButtonTopAnchor.constant += 20//17.5
            stopButtonTopAnchor.constant += 20//17.5
            
            //sessionContainerTopAnchor.constant += 20//17.5
            
            //Setting the origins
            gradientViewOrigin = gradientViewTopAnchor.constant
            
            controlViewOrigin = controlContainerTopAnchor.constant //391
            gestureViewOrigin = 350
            
            gradientViewAnimatedPosition = gradientViewOrigin + 82.5
            progressAnimatedPosition = 82.5
    
            controlViewAnimatedPosition = 640//556 + 35
            gestureViewAnimatedPosition = 564//515 + 49
            
            print(controlView.frame.height)
            
            sessionContainerTopAnchor.constant = (controlView.frame.height + 49) - (sessionInfoContainer.frame.height + 3.5)
            
        }
            
        //iPhone XS
        else if UIScreen.main.bounds.width == 375.0 && UIScreen.main.bounds.height == 812.0 {
            
            gradientViewOrigin = gradientViewTopAnchor.constant
            
            controlViewOrigin = controlContainerTopAnchor.constant //391
            gestureViewOrigin = gestureViewTopAnchor.constant //350
            
            gradientViewAnimatedPosition = gradientViewOrigin + 82.5
            progressAnimatedPosition = 82.5
    
            controlViewAnimatedPosition = 556
            gestureViewAnimatedPosition = 515
            
            sessionContainerTopAnchor.constant = (controlView.frame.height) - (sessionInfoContainer.frame.height + 3.5)
        }
            
        //iPhone 8 Plus
        else if UIScreen.main.bounds.width == 414.0 && UIScreen.main.bounds.height == 736.0 {
            
            progressViewCenterYAnchor.constant = -65
            
            controlContainerTopAnchor.constant -= 17.5
            
            gradientViewOrigin = gradientViewTopAnchor.constant
            
            controlViewOrigin = controlContainerTopAnchor.constant //391
            gestureViewOrigin = gestureViewTopAnchor.constant //350
            
            gradientViewAnimatedPosition = gradientViewOrigin + 82.5
            progressAnimatedPosition = 82.5
    
            controlViewAnimatedPosition = 556
            gestureViewAnimatedPosition = 515
            
//            progressAnimationViewTopAnchor.constant = 30
//
//            play_pauseButtonLeadingAnchor.constant = 52.5
//            stopButtonTrailingAnchor.constant = 52.5
            
            
            
            sessionContainerTopAnchor.constant = (controlView.frame.height) - (sessionInfoContainer.frame.height + 3.5)
            
        }
            
        //iPhone 8
        else if UIScreen.main.bounds.width == 375.0 && UIScreen.main.bounds.height == 667.0 {
            
                    gradientViewOrigin = gradientViewTopAnchor.constant
                    
                    controlViewOrigin = controlContainerTopAnchor.constant //391
                    gestureViewOrigin = gestureViewTopAnchor.constant //350
                    
                    gradientViewAnimatedPosition = gradientViewOrigin + 82.5
                    progressAnimatedPosition = 82.5
            
                    controlViewAnimatedPosition = 556
                    gestureViewAnimatedPosition = 515
            
//            countDownLabelTopAnchor.constant = 20
//
//            progressAnimationViewTopAnchor.constant = 10
//
//            play_pauseButtonBottomAnchor.constant = 45
//            stopButtonBottomAnchor.constant = 45
        }
            
        //iPhone SE
        else if UIScreen.main.bounds.width == 320.0 {
            
                    gradientViewOrigin = gradientViewTopAnchor.constant
                    
                    controlViewOrigin = controlContainerTopAnchor.constant //391
                    gestureViewOrigin = gestureViewTopAnchor.constant //350
                    
                    gradientViewAnimatedPosition = gradientViewOrigin + 82.5
                    progressAnimatedPosition = 82.5
            
                    controlViewAnimatedPosition = 556
                    gestureViewAnimatedPosition = 515
            
//            countDownLabelTopAnchor.constant = 10
//
//            progressAnimationViewTopAnchor.constant = -15
//
//            play_pauseButtonLeadingAnchor.constant = 30
//            play_pauseButtonBottomAnchor.constant = 20
//
//            stopButtonTrailingAnchor.constant = 30
//            stopButtonBottomAnchor.constant = 20
        }
        
        
        //originalStopButtonBottomAnchor = stopButtonBottomAnchor.constant
    }
    

    //MARK: - Configure Pomodoro Function
    
    @objc func configurePomodoro () {
        
        navigationItem.title = defaults.value(forKey: "pomodoroName") as? String ?? "Pomodoro"
        
        totalPomodoroCount = defaults.value(forKey: "totalPomodoroCount") as? Int ?? 4
        currentPomodoroCount = defaults.value(forKey: "currentPomodoro") as? Int ?? 0
        configurePomodoroCountAnimation() //Must call after loading "totalPomodoroCount" and "currentPomodoroCount" from User Defaults
        
        //If the value from the key "pomodoroActive" is not nil
        if let pomodoroActive = defaults.value(forKey: "pomodoroActive") as? Bool {
            
            //If a Pomodoro session was active when the user last left the view
            if pomodoroActive == true {
                
                let now = Date()
                let pomodoroEndTime = defaults.value(forKey: "currentPomodoroEndTime") as? Date ?? now
                
                //If the calculated end time of the Pomodoro session hasn't been reached yet
                if pomodoroEndTime > now {
                    
                    //Removes the pending notification that would be scheduled if a user leaves this view during a active Pomodoro session
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [defaults.value(forKey: "pomodoroNotificationID") as? String ?? ""])
                    
                    sessionTracker = defaults.value(forKey: "currentPomodoroSession") as? String ?? "none"
                    soundEffectTracker = defaults.value(forKey: "currentPomodoroSoundEffect") as? String ?? ""
                    timerStartedCount = 0
                    
                    let calendar = Calendar.current
                    
                    pomodoroMinutes = calendar.dateComponents([.minute], from: now, to: pomodoroEndTime).minute! //Calculating how many minutes remain
                    pomodoroSeconds = calendar.dateComponents([.second], from: now, to: pomodoroEndTime).second! % 60 //Calculating how many seconds remain
                    
                    animateButton("grow", duration: 0)
                    
                    //If statement changing the type of indicator that will be used bases on what type of session is active
                    if sessionTracker == "session" {
                        //pomodoroProgressAnimationView.updateIndicator(style: .ballScaleMultiple)
                        iProgressView.updateIndicator(style: .ballScaleMultiple)
                    }
                    else if sessionTracker == "5MinBreak" || sessionTracker == "30MinBreak" {
                        //pomodoroProgressAnimationView.updateIndicator(style: .ballScale)
                        iProgressView.updateIndicator(style: .ballScale)
                    }
                    
                    if currentPomodoroCount > 0 {
                        animatePomodoroCount(true) //Animating Pomodoro count from 0
                    }
                    
                    resumeSession()
                }
                
                //If the calculated end time of the Pomodoro session has already been reached
                else {
                    
                    sessionTracker = defaults.value(forKey: "currentPomodoroSession") as? String ?? "none"
                    
                    resumeFromBackground = true
                    
                    progressBasicAnimation.duration = 0
                    progressBasicAnimation.fillMode = CAMediaTimingFillMode.forwards
                    progressBasicAnimation.isRemovedOnCompletion = false
                    
                    animateButton("shrink", duration: 0)
                    
                    play_pauseButton.isEnabled = true
                    play_pauseButton.setTitle("Start", for: .normal)
                   
                    //If it is time for a 30 minute break
                    if currentPomodoroCount + 1 == totalPomodoroCount && sessionTracker == "session" {
                        
                        sessionTracker = "30MinBreak"
                        soundEffectTracker = "Start Break"
                        
                        countDownLabel.text = "Start your 30 minute break"
                        
                        progressBasicAnimation.fromValue = 1
                        progressBasicAnimation.toValue = 1
                        
                        progressShapeLayer.add(progressBasicAnimation, forKey: "pomodoroKey")
        
                        currentPomodoroCount = totalPomodoroCount
                        animatePomodoroCount()
                        
                    }
                    
                    //If it is time for a 5 minute break
                    else if sessionTracker == "session" {
                        
                        countDownLabel.text = "Start your 5 minute break"
                        
                        sessionTracker = "5MinBreak"
                        soundEffectTracker = "Start Break"
                        
                        progressBasicAnimation.fromValue = 1
                        progressBasicAnimation.toValue = 1
                        
                        progressShapeLayer.add(progressBasicAnimation, forKey: "pomodoroKey")
        
                        if currentPomodoroCount > 0 {
                            animatePomodoroCount(nil) //Animating the Pomodoro count without any animation
                        }

                    }
                    
                    //If it is time for another Pomodoro
                    else if sessionTracker == "5MinBreak" {
                        
                        countDownLabel.text = "Start your next Pomodoro session"
                        
                        sessionTracker = "session"
                        soundEffectTracker = "Start Timer"
                        
                        progressBasicAnimation.fromValue = 0
                        progressBasicAnimation.toValue = 0
                        
                        progressShapeLayer.add(progressBasicAnimation, forKey: "pomodoroKey")
                        
                        currentPomodoroCount += 1
                        animatePomodoroCount()
                    }
                    
                    //If the user just finished their 30 minute break ending their round of Pomodoro sessions
                    else if sessionTracker == "30MinBreak" {
                        
                        resumeFromBackground = false
                        
                        defaults.set(0, forKey: "currentPomodoro")
                        
                        currentPomodoroCount = 0
                        
                        countDownLabel.text = "Start A New Pomodoro"
                        
                        progressShapeLayer.removeAllAnimations()
                        
                        countShapeLayer.removeAllAnimations()
                        pomodoroCountLabel.textColor = UIColor.flatMint().lighten(byPercentage: 0.25)
                        pomodoroCountLabel.text = "0"
                        
                        sessionTracker = "none"
                        
                        animateButton("shrink")
                        
                        play_pauseButton.setTitle("Start", for: .normal)
                        
                        endBreak {
                            self.soundEffectTracker = ""
                        }
                    }
                }
            }
            
            //If a Pomodoro session was not active when the user left the view
            else if pomodoroActive == false {
                
                sessionTracker = defaults.value(forKey: "currentPomodoroSession") as? String ?? "none"
                
                animateButton("shrink", duration: 0)
                
                play_pauseButton.isEnabled = true
                play_pauseButton.setTitle("Start", for: .normal)
            
                if sessionTracker == "session" {
                    
                    resumeFromBackground = true
                    
                    countDownLabel.text = "Start your next Pomodoro session"
                    
                    progressBasicAnimation.duration = 0
                    progressBasicAnimation.fillMode = CAMediaTimingFillMode.forwards
                    progressBasicAnimation.isRemovedOnCompletion = false

                    progressBasicAnimation.fromValue = 0
                    progressBasicAnimation.toValue = 0

                    progressShapeLayer.add(progressBasicAnimation, forKey: "pomodoroKey")
                    
                    if currentPomodoroCount > 0 {
                        animatePomodoroCount(nil) //Animating the Pomodoro count without any animation
                    }

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
                
                    if currentPomodoroCount > 0 {
                        animatePomodoroCount(nil) //Animating the Pomodoro count without any animation
                    }
                }
            }
        }
        
        //If a Pomodoro wasn't even yet configured
        else {
            
            navigationItem.title = defaults.value(forKey: "pomodoroName") as? String ?? "Pomodoro"
            countDownLabel.text = "Start A Pomodoro"
            
            resumeFromBackground = false
            sessionTracker = "none"
        }
    
        setSessionLabelText(sessionTracker)
    }
    
    //MARK: Configure Pomdoro Progress Animation Function
    
    func configurePomodoroProgressAnimation () {
        
        //Centers the trackLayer and the shapeLayer's position to be in the center of the "pomodoroProgressAnimationView"
        
        
        let circlePosition: CGPoint?
        
        //iPhone XS Max & iPhone XR
        if UIScreen.main.bounds.width == 414.0 && UIScreen.main.bounds.height == 896.0 {
            
            circlePosition = CGPoint(x: pomodoroProgressAnimationView.center.x, y: pomodoroProgressAnimationView.center.y - 7.5)
        }
            
        //iPhone XS
        else if UIScreen.main.bounds.width == 375.0 && UIScreen.main.bounds.height == 812.0 {
            circlePosition = CGPoint(x: pomodoroProgressAnimationView.center.x, y: pomodoroProgressAnimationView.center.y - 30)
        }
            
        //iPhone 8 Plus
        else if UIScreen.main.bounds.width == 414.0 && UIScreen.main.bounds.height == 736.0 {

            circlePosition = CGPoint(x: pomodoroProgressAnimationView.center.x, y: pomodoroProgressAnimationView.center.y - 65)
        }
            
        //iPhone 8
        else if UIScreen.main.bounds.width == 375.0 && UIScreen.main.bounds.height == 667.0 {
            
            circlePosition = CGPoint(x: pomodoroProgressAnimationView.center.x, y: pomodoroProgressAnimationView.center.y - 30)
        }
            
        //iPhone SE
        else {

            circlePosition = CGPoint(x: pomodoroProgressAnimationView.center.x, y: pomodoroProgressAnimationView.center.y - 30)
        }
        
        
        let circularPath: UIBezierPath //A path that consists of straight and curved line segments rendered into views
        
        //If statements that adjust the radius and line width of the circle depending on the iPhone/screen size
        if UIScreen.main.bounds.width == 375.0 && UIScreen.main.bounds.height == 667.0 { //iPhone 8
            
            circularPath = UIBezierPath(arcCenter: circlePosition!, radius: 115, startAngle:  (-CGFloat.pi * 3) / 4, endAngle: -CGFloat.pi / 4, clockwise: false)
            
            progressTrackLayer.lineWidth = 12//15
            progressShapeLayer.lineWidth = 10
        }
            
        else if UIScreen.main.bounds.width == 320.0  { //iPhone SE
            
            circularPath = UIBezierPath(arcCenter: circlePosition!, radius: 100, startAngle:  (-CGFloat.pi * 3) / 4, endAngle: -CGFloat.pi / 4, clockwise: false)
            
            progressTrackLayer.lineWidth = 13
            progressShapeLayer.lineWidth = 8
        }
            
            
        else { //Every other iPhone
            circularPath = UIBezierPath(arcCenter: circlePosition!, radius: 123.5, startAngle:  (-CGFloat.pi) / 2, endAngle: -(2.5 * CGFloat.pi), clockwise: false)
            
            progressTrackLayer.lineWidth = 12
            progressShapeLayer.lineWidth = 10
        }
        
        progressTrackLayer.path = circularPath.cgPath
        progressTrackLayer.fillColor = UIColor.clear.cgColor
        //progressTrackLayer.strokeColor = UIColor.white.withAlphaComponent(0.01).cgColor
        progressTrackLayer.strokeColor = UIColor.white.withAlphaComponent(0.1).cgColor //UIColor.clear.cgColor
        
        progressTrackLayer.lineCap = CAShapeLayerLineCap.round
        
        view.layer.addSublayer(progressTrackLayer)
        
        progressShapeLayer.path = circularPath.cgPath
        progressShapeLayer.fillColor = UIColor.clear.cgColor
        progressShapeLayer.strokeColor = UIColor.red.withAlphaComponent(0.85).cgColor
        progressShapeLayer.strokeEnd = 0
        
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
        
        
        //iProgress.indicatorView.bounds = CGRect(x: pomodoroProgressAnimationView.bounds.size.width / 2, y: (pomodoroProgressAnimationView.bounds.size.height / 2) - 17.5, width: 50, height: 50)
        
        //If statement that tweaks the size of the iProgress indicator
        if UIScreen.main.bounds.width == 375.0 && UIScreen.main.bounds.height == 667.0 { //iPhone 8
            iProgress.indicatorSize = 195
        }
            
        else if  UIScreen.main.bounds.width == 320.0 { //iPhone SE
            iProgress.indicatorSize = 210
        }
            
        else { //Every other iPhone
            iProgress.indicatorSize = 200
        }
        
        iProgress.attachProgress(toView: iProgressView)
        //iProgress.attachProgress(toView: pomodoroProgressAnimationView)
    }
    
    //MARK: - Configure Pomodoro Count Animation
    
    func configurePomodoroCountAnimation () {
        
        //Centers the trackLayer and the shapeLayer's position to be in the center of the "pomodoroCountAnimationView"
        let circlePosition: CGPoint = CGPoint(x: pomodoroCountAnimationView.center.x, y: pomodoroCountAnimationView.center.y)
        
        //A path that consists of straight and curved line segments rendered into views
        let circularPath = UIBezierPath(arcCenter: circlePosition, radius: 20, startAngle: -CGFloat.pi / 2, endAngle: -((5 * CGFloat.pi) / 2), clockwise: false)
        var count: Int = 1
        
        countTrackLayer.path = circularPath.cgPath
        countTrackLayer.fillColor = UIColor.clear.cgColor
        countTrackLayer.strokeColor = UIColor.flatMint().lighten(byPercentage: 0.35)?.cgColor//UIColor.white.cgColor
        countTrackLayer.lineWidth = 5

        sessionInfoContainer.layer.addSublayer(countTrackLayer)

        countShapeLayer.path = circularPath.cgPath
        countShapeLayer.fillColor = UIColor.clear.cgColor
        countShapeLayer.strokeColor = UIColor.red.cgColor
        countShapeLayer.strokeEnd = 0
        countShapeLayer.lineWidth = 5//3
        countShapeLayer.lineCap = CAShapeLayerLineCap.round

        sessionInfoContainer.layer.addSublayer(countShapeLayer)
        
        //If the currentPomodoroCount is 0, make the countLabel invisiible
        if currentPomodoroCount == 0 {
            pomodoroCountLabel.textColor = .white //UIColor.flatMint().lighten(byPercentage: 0.25)
        }
        else {
            pomodoroCountLabel.textColor = UIColor.flatMint().lighten(byPercentage: 0.25) //.white
        }
        
        pomodoroCountStops.removeAll() //Cleans the pomodoroCountStops array
        
        while count <= totalPomodoroCount {
            //If this is the first run of the loop, add 0 to index 0 of the array
            if count == 1 {
                pomodoroCountStops.append(0)
            }
            
            //Append the different stops the animation should animate to to the array
            pomodoroCountStops.append(CGFloat((1.0 / Double(totalPomodoroCount)) * Double(count)))
            
            count += 1
        }
    }
    
    
    //MARK: - Start Session Function
    
    //Function that starts a Pomodoro Session
    func startSession () {

        pomodoroMinutes = defaults.value(forKey: "pomodoroMinutes") as? Int ?? 25
        pomodoroSeconds = 0
        
        timerStartedCount = 3
        
        sessionTracker = "session"
        setSessionLabelText(sessionTracker)
        
        //pomodoroProgressAnimationView.updateIndicator(style: .ballScaleMultiple)
        iProgressView.updateIndicator(style: .ballScaleMultiple)
        
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
            //self.pomodoroProgressAnimationView.showProgress()
            self.iProgressView.showProgress()
        })

        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: sessionTask!) //Executes the session task after a 3 second delay

        play_pauseButton.setTitle("Pause", for: .normal)
        play_pauseTracker = "pause"
    }
    
    
    //MARK: - Pause Session Function
    
    func pauseSession () {
        
        let pausedTime = progressShapeLayer.convertTime(CACurrentMediaTime(), from: nil)
        progressShapeLayer.speed = 0.0
        progressShapeLayer.timeOffset = pausedTime
        
        //pomodoroProgressAnimationView.dismissProgress()
        iProgressView.dismissProgress()
        
        audioPlayer?.stop()
        
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
        
        var sessionLengthInSecs: Double = 0 //The initial pomodoro session or break session length in seconds
        
        var remainingSessionLengthInSecs: Double = 0 //The remaining pomodoro session or break session length in seconds
        
        var progressAnimationPart: Double = 0 //The amount the animation increments by
        
        if sessionTracker == "session" {
            
            sessionLengthInSecs = ((defaults.value(forKey: "pomodoroMinutes") as? Double ?? 25.0) * 60.0)
            remainingSessionLengthInSecs = sessionLengthInSecs - (Double(pomodoroMinutes * 60) + Double(pomodoroSeconds))
            progressAnimationPart = (1.0 / sessionLengthInSecs)
            
            progressBasicAnimation.fromValue = progressAnimationPart * remainingSessionLengthInSecs
            progressBasicAnimation.toValue = 1
        }
        else if sessionTracker == "5MinBreak" {
            
            sessionLengthInSecs = (5 * 60.0)
            remainingSessionLengthInSecs = (Double(pomodoroMinutes * 60) + Double(pomodoroSeconds))
            progressAnimationPart = (1.0 / sessionLengthInSecs)
            
            progressBasicAnimation.fromValue = progressAnimationPart * remainingSessionLengthInSecs
            progressBasicAnimation.toValue = 0
        }
        else if sessionTracker == "30MinBreak" {
            
            sessionLengthInSecs = (30 * 60.0)
            remainingSessionLengthInSecs = (Double(pomodoroMinutes * 60) + Double(pomodoroSeconds))
            progressAnimationPart = (1.0 / sessionLengthInSecs)
            
            progressBasicAnimation.fromValue = progressAnimationPart * remainingSessionLengthInSecs
            progressBasicAnimation.toValue = 0
        }

        progressBasicAnimation.duration = CFTimeInterval((pomodoroMinutes * 60) + pomodoroSeconds) //Finding the remaining duration of the animation
        progressBasicAnimation.fillMode = CAMediaTimingFillMode.forwards
        progressBasicAnimation.isRemovedOnCompletion = false
        
        progressShapeLayer.add(progressBasicAnimation, forKey: "pomodoroKey")
        
        //pomodoroProgressAnimationView.showProgress()
        iProgressView.showProgress()

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
            
            startSession()
        }
        
        else if sessionTracker == "5MinBreak" || sessionTracker == "30MinBreak" {
            
            startBreak()
        }
        
        play_pauseButton.setTitle("Pause", for: .normal)
    }
    
    
    //MARK: - Stop Session Function
    
    func stopSession () {
        
        defaults.set(nil, forKey: "pomodoroActive")
        defaults.set("none", forKey: "currentPomodoroSession")
        defaults.set(0, forKey: "currentPomodoro")
        defaults.set(nil, forKey: "currentPomodoroEndTime")
        
        resumeFromBackground = false
        
        sessionTracker = "none"
        setSessionLabelText(sessionTracker)
        
        currentPomodoroCount = 0
        
        countDownLabel.text = "Start A Pomodoro"
        
        play_pauseButton.setTitle("Start", for: .normal)
        
        pomodoroTimer?.invalidate()
        soundEffectTimer?.invalidate()
        
        progressShapeLayer.removeAllAnimations()
        //pomodoroProgressAnimationView.dismissProgress()
        iProgressView.dismissProgress()
        
        countShapeLayer.removeAllAnimations()
        pomodoroCountLabel.textColor = .white //UIColor.flatMint().lighten(byPercentage: 0.25)
        pomodoroCountLabel.text = "0"
        
        sessionTask?.cancel()
        breakTask1?.cancel()
        breakTask2?.cancel()
        
        audioPlayer?.stop()
    }
    
    
    //MARK: - Start Break Function
    
    @objc func startBreak () {

        //pomodoroProgressAnimationView.updateIndicator(style: .ballScale)
        iProgressView.updateIndicator(style: .ballScale)
        
        play_pauseButton.isEnabled = false
        play_pauseTracker = "pause"
        
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
            pomodoroSeconds = 0
            
            progressBasicAnimation.fromValue = 1
            progressBasicAnimation.toValue = 0
            progressBasicAnimation.duration = 1800
        }
        
        breakTask1 = DispatchWorkItem(block: {

            let now = Date()
            self.pomodoroTimer = Timer(fireAt: now, interval: 1, target: self, selector: #selector(self.countDown), userInfo: nil, repeats: true)
            RunLoop.main.add(self.pomodoroTimer!, forMode: .common)
        })

        DispatchQueue.main.asyncAfter(deadline: .now() + 6, execute: breakTask1!) //Executes the first break task after a 6 second delay

        breakTask2 = DispatchWorkItem(block: {
            self.progressShapeLayer.add(self.progressBasicAnimation, forKey: "breakKey")
            //self.pomodoroProgressAnimationView.showProgress()
            self.iProgressView.showProgress()
        })

        DispatchQueue.main.asyncAfter(deadline: .now() + 8.75, execute: breakTask2!) //Executes the second break task after a 8.75 second delay
    }
    
    
    //MARK: - End Break Function
    
    func endBreak (completion: @escaping () -> ()) {
        
        pomodoroTimer?.invalidate()
        soundEffectTimer?.invalidate()
        
        audioPlayer?.stop()
        
        soundEffectTracker = "End Break"
        
        playSoundEffect()
        
        //pomodoroProgressAnimationView.dismissProgress()
        iProgressView.dismissProgress()
        
        breakTask1 = DispatchWorkItem(block: {
            completion()
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: breakTask1!)
    }
    
    
    //MARK: - Set Session Label Text
    
    func setSessionLabelText (_ session: String) {
        
        if session == "session" {
            
            sessionLabel.textColor = UIColor.flatMint().lighten(byPercentage: 0.25) //.white
            sessionLabel.text = "Pomodoro Session"
        }
        else if session == "5MinBreak" {
            
            sessionLabel.textColor = UIColor.flatMint().lighten(byPercentage: 0.25) //.white
            sessionLabel.text = "5 Minute Break"
        }
        else if session == "30MinBreak" {
            
            sessionLabel.textColor = UIColor.flatMint().lighten(byPercentage: 0.25) //.white
            sessionLabel.text = "30 Minute Break"
        }
        else if session == "none" {
            
            sessionLabel.textColor = .white //UIColor.flatMint().lighten(byPercentage: 0.25)
        }
    }
    
    
    //MARK: - Count Down Function
    
    @objc func countDown () {
        
        //If a session or a break has ended
        if pomodoroMinutes == 0 && pomodoroSeconds == 0 {
            
            //If this was the last Pomodoro before a 30 min break
            if currentPomodoroCount + 1 == totalPomodoroCount && sessionTracker == "session" {
                
                currentPomodoroCount += 1
                animatePomodoroCount()
                
                pomodoroTimer?.invalidate()
                soundEffectTimer?.invalidate()
                
                audioPlayer?.stop()
                
                //pomodoroProgressAnimationView.dismissProgress()
                iProgressView.dismissProgress()
                
                sessionTracker = "30MinBreak"
                setSessionLabelText(sessionTracker)
                
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
                //pomodoroProgressAnimationView.dismissProgress()
                iProgressView.dismissProgress()
                
                countShapeLayer.removeAllAnimations()
                pomodoroCountLabel.textColor = UIColor.flatMint().lighten(byPercentage: 0.25)
                pomodoroCountLabel.text = "0"
                
                sessionTracker = "none"
                setSessionLabelText(sessionTracker)
                
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
                    
                    audioPlayer?.stop()
                    
                    //pomodoroProgressAnimationView.dismissProgress()
                    iProgressView.dismissProgress()
                    
                    sessionTracker = "5MinBreak"
                    setSessionLabelText(sessionTracker)
                    
                    startBreak()
                }
                    
                //If a 5 min break just ended
                else if sessionTracker == "5MinBreak" {
                    
                    play_pauseButton.isEnabled = false
                    
                    currentPomodoroCount += 1
                    animatePomodoroCount()
                    
                    endBreak {
                        
                        self.soundEffectTracker = "Start Timer"
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
        
        //If the sound effect tracker is not empty
        if soundEffectTracker != "" {
            
            //Initializing the soundURL to the audio file with the name matching the "soundEffectTracker"
            soundURL = Bundle.main.url(forResource: soundEffectTracker, withExtension: "wav")
            
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL!)
            }
                
            catch {
                print(error.localizedDescription)
            }
            
            //If the user has enabled sound effect or hasn't yet disabled them
            if defaults.value(forKey: "playPomodoroSoundEffects") as? Bool ?? true == true {
            
                audioPlayer?.play()
            }
            
            
            //If statement used on every sound effect except "End Break"
            if soundEffectTracker != "End Break" {
                
                let calendar = Calendar.current
                let startDate = Date()
                let date = calendar.date(byAdding: .second, value: Int(audioPlayer!.duration), to: startDate)
                
                //Adding the soundEffectTimer to the RunLoop enabling the sound effect to be played continuously
                soundEffectTimer = Timer(fireAt: date ?? startDate, interval: 0, target: self, selector: #selector(playSoundEffect), userInfo: nil, repeats: false)
                RunLoop.main.add(soundEffectTimer!, forMode: .common)
                
                if soundEffectTracker == "Start Timer" {
                    soundEffectTracker = "Timer Running"
                }
                else if soundEffectTracker == "Start Break" {
                    soundEffectTracker = "Break Timer Running"
                }
            }
        }
        

    }
    
    
    //MARK: - Animate Pomodoro Count
    
    func animatePomodoroCount (_ startFromZero: Bool? = false) {
        
        //Animates the text and text color change for the "pomodoroCountLabel"
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
        
        //If the count animation should animate from 0
        if startFromZero == true {
            
            countBasicAnimation.fromValue = pomodoroCountStops[0]
            countBasicAnimation.toValue = pomodoroCountStops[currentPomodoroCount]
            
        }
            
        //If the count animation shouldn't animate from 0 but instead the stop before it
        else if startFromZero == false {
            
            countBasicAnimation.fromValue = pomodoroCountStops[currentPomodoroCount - 1]
            countBasicAnimation.toValue = pomodoroCountStops[currentPomodoroCount]
        }
            
        //If the count animation shouldn't animate at all and simply appear in the correct position
        else if startFromZero == nil {
            
            countBasicAnimation.fromValue = pomodoroCountStops[currentPomodoroCount]
            countBasicAnimation.toValue = pomodoroCountStops[currentPomodoroCount]
        }
        
        countShapeLayer.add(countBasicAnimation, forKey: "countKey")
    }
    
    
    //MARK: - Save Pomodoro Data Function
    
    func savePomodoroData () {
        
        let date = Date()
        let calendar = Calendar.current
        var pomodoroEndTime: Date?
        
        //Calculating the end time of the current session; in a more complicated way than is neccasary smh
        pomodoroEndTime = calendar.date(byAdding: .minute, value: pomodoroMinutes, to: date)
        pomodoroEndTime = calendar.date(byAdding: .second, value: pomodoroSeconds + timerStartedCount, to: pomodoroEndTime!)
        
        //If a Pomodoro or a break session is currently running
        if pomodoroTimer?.isValid == true {
            defaults.set(true, forKey: "pomodoroActive")
            defaults.set(pomodoroEndTime, forKey: "currentPomodoroEndTime")
        }
            
        //If a Pomodoro or a break session isn't currently running
        else {
            
            if sessionTracker == "5MinBreak" || sessionTracker == "30MinBreak" {
                
                //If the "timerStartedCount" is greater than 0 for a break, the break has been started but the timer has not yet been activated
                if timerStartedCount > 0 {
                    defaults.set(true, forKey: "pomodoroActive")
                    defaults.set(pomodoroEndTime, forKey: "currentPomodoroEndTime")
                    timerStartedCount = 0
                }
                else {
                    defaults.set(false, forKey: "pomodoroActive")
                }
            }
                
            else if sessionTracker == "session" {
                defaults.set(false, forKey: "pomodoroActive")
            }
                
            else if sessionTracker == "none" {
                defaults.set(nil, forKey: "pomodoroActive")
            }
        }
        
        defaults.set(totalPomodoroCount, forKey: "totalPomodoroCount")
        defaults.set(currentPomodoroCount, forKey: "currentPomodoro")
        defaults.set(sessionTracker, forKey: "currentPomodoroSession")
        defaults.set(soundEffectTracker, forKey: "currentPomodoroSoundEffect")
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
            content.body = "Great job completing a full Pomodoro. Check in on Block Pro to start another one!!"
        }
        
        content.sound = UNNotificationSound.default
        
        trigger = UNCalendarNotificationTrigger(dateMatching: calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: notificationTime!), repeats: false)
        
        request = UNNotificationRequest(identifier: notificationID, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
        defaults.setValue(notificationID, forKey: "pomodoroNotificationID") //Saving the notificationID of the scheduled notification to UserDefaults
    }
    
    
    //MARK: - Animate Button Function
    
    func animateButton (_ animation: String, duration: Double = 1) {
        
        if animation == "grow" {
            
//            play_pauseButtonWidthConstraint.constant = 130
//            play_pauseButtonHeightConstraint.constant = 65
//
//            stopButtonWidthConstraint.constant = 100
//            stopButtonHeightConstraint.constant = 50
//            stopButtonBottomAnchor.constant = originalStopButtonBottomAnchor + 7
            
            play_pauseCenterXAnchor.constant = -90
            stopButtonCenterXAnchor.constant = 90
            
            UIView.animate(withDuration: duration) {
                
                self.view.layoutIfNeeded()
            }
        }
            
        else if animation == "shrink" {
            
//            play_pauseButtonWidthConstraint.constant = 110
//            play_pauseButtonHeightConstraint.constant = 55
//
//            stopButtonWidthConstraint.constant = 110
//            stopButtonHeightConstraint.constant = 55
//            stopButtonBottomAnchor.constant = originalStopButtonBottomAnchor
            
            play_pauseCenterXAnchor.constant = 0
            stopButtonCenterXAnchor.constant = 0
            
            UIView.animate(withDuration: duration) {
                
                self.view.layoutIfNeeded()
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
    
    @IBAction func resetPomodoroButton(_ sender: Any) {
        
        defaults.set(nil, forKey: "pomodoroActive")
        defaults.set(nil, forKey: "pomodoroName")
        
        defaults.set(nil, forKey: "currentPomodoroSession")
        defaults.set(nil, forKey: "currentPomodoroSoundEffect")
        defaults.set(nil, forKey: "currentPomodoroEndTime")
        defaults.set(nil, forKey: "currentPomodoro")
        defaults.set(nil, forKey: "totalPomodoroCount")
        
        defaults.set(nil, forKey: "pomodoroMinutes")
        
        defaults.set(nil, forKey: "pomodoroNotificationID")
        
        resumeFromBackground = false
        
        countDownLabel.text = "Start A Pomodoro"
        
        animateButton("shrink")
        play_pauseButton.setTitle("Start", for: .normal)
        play_pauseButton.isEnabled = true
        
        pomodoroTimer?.invalidate()
        soundEffectTimer?.invalidate()
        
        progressShapeLayer.removeAllAnimations()
        //pomodoroProgressAnimationView.dismissProgress()
        iProgressView.dismissProgress()
        
        countShapeLayer.removeAllAnimations()
        pomodoroCountLabel.textColor = UIColor.flatMint().lighten(byPercentage: 0.25)
        pomodoroCountLabel.text = "0"
        
        sessionTask?.cancel()
        breakTask1?.cancel()
        breakTask2?.cancel()
        
        configurePomodoro()
        
        audioPlayer?.stop()
    }
    
    
    @IBAction func editButton(_ sender: Any) {
        
        //If statement checking to see if a user is attempting to edit a Pomodoro while one is already active
        if pomodoroTimer?.isValid == true {
            
            let editAlert = UIAlertController(title: "Edit Pomodoro", message: "To edit another Pomodoro session, your current one must be ended. Would you still like to edit a new Pomodoro session?", preferredStyle: .alert)
            
            let editAction = UIAlertAction(title: "Edit", style: .default) { (editAction) in
                
                self.animateButton("shrink")
                self.stopSession()
                self.performSegue(withIdentifier: "moveToEditView", sender: self)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            editAlert.addAction(editAction)
            editAlert.addAction(cancelAction)
            
            present(editAlert, animated: true, completion: nil)
            
        }
        else {
            performSegue(withIdentifier: "moveToEditView", sender: self)
        }
        
    }
    
    @IBAction func play_pauseButton(_ sender: Any) {
        
        play_pauseVibration()

        animateButton("grow")

        //If the user is resuming a session from the background
        if resumeFromBackground == true {
            
            resumeSessionFromBackground()
            resumeFromBackground = false
        }
        
        else {
            
            if sessionTracker == "none" {
                
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
    
    @IBAction func stopButton(_ sender: Any) {
        
        stopVibration()
        animateButton("shrink")
        stopSession()
        
        play_pauseButton.isEnabled = true
    }
}

//Pan gesture functions
extension PomodoroViewController {
    
    @objc func handlePan (sender: UIPanGestureRecognizer) {
        

        
        switch sender.state {
            
        case .began, .changed:
            
            moveViewWithPan (sender: sender)
        
        case .ended:
            
            
            if controlView.frame.height > 180 {
                
                returnToOrigin()
            }
            
            else {
                
                shrinkView()
            }
        
        default:
            break
        }
    }
    
    func moveViewWithPan (sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: view)
        
        if controlContainerTopAnchor.constant + translation.y > controlViewOrigin - 25/* 391 */{

            
            //control view difference 165
            gradientViewTopAnchor.constant += translation.y / ((controlViewAnimatedPosition - controlViewOrigin) / (gradientViewAnimatedPosition - gradientViewOrigin))  //2
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            
            progressTrackLayer.frame.origin.y += translation.y / ((controlViewAnimatedPosition - controlViewOrigin) / (gradientViewAnimatedPosition - gradientViewOrigin)) //2
            progressShapeLayer.frame.origin.y += translation.y / ((controlViewAnimatedPosition - controlViewOrigin) / (gradientViewAnimatedPosition - gradientViewOrigin)) //2
            
            CATransaction.commit()
            
        
            
            controlContainerTopAnchor.constant += translation.y
            gestureViewTopAnchor.constant += translation.y
            
        }
        
        sender.setTranslation(CGPoint.zero, in: view)
    }
    
    func returnToOrigin () {
        
        gradientViewTopAnchor.constant = gradientViewOrigin
        
        progressTrackLayer.frame.origin.y = 0
        progressShapeLayer.frame.origin.y = 0
        
        controlContainerTopAnchor.constant = controlViewOrigin//391
        gestureViewTopAnchor.constant = gestureViewOrigin//350
        
        UIView.animate(withDuration: 0.15) {
            
            self.view.layoutIfNeeded()
        }
        
    }
    
    func shrinkView () {
        
        gradientViewTopAnchor.constant = gradientViewAnimatedPosition
        
        progressTrackLayer.frame.origin.y = progressAnimatedPosition
        progressShapeLayer.frame.origin.y = progressAnimatedPosition
        
        controlContainerTopAnchor.constant = controlViewAnimatedPosition//556
        gestureViewTopAnchor.constant = gestureViewAnimatedPosition//515
        

        
        UIView.animate(withDuration: 0.15, animations: {
            self.view.layoutIfNeeded()
        }) { (finished: Bool) in
            
            //print(self.controlView.frame.height) //iPhone XS = 84
            
        }
    }
    
    
  
}
