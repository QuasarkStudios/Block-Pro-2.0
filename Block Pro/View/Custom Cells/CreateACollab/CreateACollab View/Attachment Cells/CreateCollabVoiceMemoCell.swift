//
//  CreateCollabVoiceMemoCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 11/11/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

protocol CreateCollabVoiceMemosCellProtocol: AnyObject {
    
    func attachMemoSelected()
    
    func recordingCancelled()
    
    func voiceMemoSaved(_ voiceMemo: VoiceMemo)
    
    func voiceMemoNameChanged (_ voiceMemoID: String, _ name: String?)
    
    func voiceMemoDeleted (_ voiceMemo: VoiceMemo)
}

class CreateCollabVoiceMemoCell: UITableViewCell {

    let memosLabel = UILabel()
    let memosCountLabel = UILabel()
    let memosContainer = UIView()
    
    let attachMemoButton = UIButton()
    let micImage = UIImageView(image: UIImage(systemName: "mic.circle"))
    let attachMemoLabel = UILabel()
    
    let visualizerStackView = UIStackView()
    
    let memoLengthLabel = UILabel()
    
    let cancelRecordingButton = UIButton(type: .system)
    let record_stopButton = UIButton()
    let record_stopButtonIndicator = UIView()
    
    let memoCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    
    var voiceMemoRecorder: VoiceMemoRecorder?
    
    let calendar = Calendar.current
    var memoLengthTimer: Timer?
    var memoStartTime: Date?
    
    var willBeginRecording: Bool = false
    var recording: Bool = false
    
    var idForVoiceMemoBeingRecorded: String = ""
    
    var keyboardPresent: Bool = false
    var originalContentOffsetOfTableView: CGFloat = 0
    
    let itemSize = (UIScreen.main.bounds.width - (40 + 10 + 20)) / 3
    
    var voiceMemos: [VoiceMemo]? {
        didSet {
            
            reconfigureCell()
        }
    }
    
    var visualizerStackViewTopAnchorWithContainer: NSLayoutConstraint?
    var visualizerStackViewTopAnchorWithCollectionView: NSLayoutConstraint?
    
    var attachMemoButtonLeadingAnchor: NSLayoutConstraint?
    var attachMemoButtonTrailingAnchor: NSLayoutConstraint?
    var attachMemoButtonTopAnchorWithContainer: NSLayoutConstraint?
    var attachMemoButtonTopAnchorWithCollectionView: NSLayoutConstraint?
    var attachMemoButtonBottomAnchor: NSLayoutConstraint?
    
    weak var createCollabVoiceMemosCellDelegate: CreateCollabVoiceMemosCellProtocol?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "createCollabVoiceMemmoCell")
        
        configureMemosLabel()
        configureMemosCountLabel()
        configureMemosContainer()
        configureCollectionView()
        configureAttachButton()
        
        configureNotificationObservors()
    }
    
    deinit {
        
        for memoCell in memoCollectionView.visibleCells {
            
            //If a cell has had the playbackWorkItem added to the dispatchQueue, it will prevent the "CreateCollabMemoCollectionViewCell" from being deinitialized until after the playbackWorkItem was scheduled to be run. Therefore, canceling the playbackWorkItem and setting it to nil when "CreateCollabVoiceMemoCell" is denitialized is more reliable because this cell has so far always been deinitialized properly
            if let cell = memoCell as? CreateCollabMemoCollectionViewCell {
                
                cell.playbackWorkItem?.cancel()
                cell.playbackWorkItem = nil //Prevents memory leaks
            }
        }
        
        voiceMemoRecorder?.audioRecorder?.stop()
        voiceMemoRecorder?.monitoringTimer?.invalidate()
        
        NotificationCenter.default.removeObserver(self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Configure Memos Label
    
    private func configureMemosLabel () {
        
        self.contentView.addSubview(memosLabel)
        memosLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            memosLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            memosLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            memosLabel.widthAnchor.constraint(equalToConstant: 125),
            memosLabel.heightAnchor.constraint(equalToConstant: 20)
        
        ].forEach({ $0.isActive = true })
        
        memosLabel.text = "Voice Memos"
        memosLabel.textColor = .black
        memosLabel.textAlignment = .left
        memosLabel.font = UIFont(name: "Poppins-SemiBold", size: 15)
    }
    
    
    //MARK: - Configure Memos Count Label
    
    private func configureMemosCountLabel () {
        
        self.contentView.addSubview(memosCountLabel)
        memosCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            memosCountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            memosCountLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            memosCountLabel.widthAnchor.constraint(equalToConstant: 75),
            memosCountLabel.heightAnchor.constraint(equalToConstant: 20)
        
        ].forEach({ $0.isActive = true })
        
        memosCountLabel.alpha = 0
        memosCountLabel.text = "0/3"
        memosCountLabel.textColor = .black
        memosCountLabel.textAlignment = .right
        memosCountLabel.font = UIFont(name: "Poppins-SemiBold", size: 15)
    }
    
    
    //MARK: - Configure Memos Container
    
    private func configureMemosContainer () {
        
        self.contentView.addSubview(memosContainer)
        memosContainer.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            memosContainer.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
            memosContainer.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20),
            memosContainer.topAnchor.constraint(equalTo: memosLabel.bottomAnchor, constant: 10),
            memosContainer.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0),
        
        ].forEach({ $0.isActive = true })
        
        memosContainer.backgroundColor = .white
        
        memosContainer.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
        memosContainer.layer.borderWidth = 1

        memosContainer.layer.cornerRadius = 10
        memosContainer.layer.cornerCurve = .continuous
        memosContainer.clipsToBounds = true
    }
    
    
    //MARK: - Configure Attach Button
    
    private func configureAttachButton () {
        
        memosContainer.addSubview(attachMemoButton)
        attachMemoButton.addSubview(micImage)
        attachMemoButton.addSubview(attachMemoLabel)
        
        attachMemoButton.translatesAutoresizingMaskIntoConstraints = false
        micImage.translatesAutoresizingMaskIntoConstraints = false
        attachMemoLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [

            attachMemoButton.leadingAnchor.constraint(equalTo: memosContainer.leadingAnchor, constant: 0),
            attachMemoButton.trailingAnchor.constraint(equalTo: memosContainer.trailingAnchor, constant: 0),
            attachMemoButton.topAnchor.constraint(equalTo: memosContainer.topAnchor, constant: 0),
            attachMemoButton.heightAnchor.constraint(equalToConstant: 55),
            
            micImage.leadingAnchor.constraint(equalTo: attachMemoButton.leadingAnchor, constant: 20),
            micImage.centerYAnchor.constraint(equalTo: attachMemoButton.centerYAnchor),
            micImage.widthAnchor.constraint(equalToConstant: 25),
            micImage.heightAnchor.constraint(equalToConstant: 25),

            attachMemoLabel.leadingAnchor.constraint(equalTo: attachMemoButton.leadingAnchor, constant: 10),
            attachMemoLabel.trailingAnchor.constraint(equalTo: attachMemoButton.trailingAnchor, constant: -10),
            attachMemoLabel.centerYAnchor.constraint(equalTo: attachMemoButton.centerYAnchor),
            attachMemoLabel.heightAnchor.constraint(equalToConstant: 25)

        ].forEach({ $0.isActive = true })
        
        attachMemoButton.backgroundColor = .clear
        attachMemoButton.addTarget(self, action: #selector(attachButtonPressed), for: .touchUpInside)
        
        micImage.tintColor = .black
        micImage.isUserInteractionEnabled = false
        
        attachMemoLabel.text = "Attach Voice Memos"
        attachMemoLabel.textColor = .black
        attachMemoLabel.textAlignment = .center
        attachMemoLabel.font = UIFont(name: "Poppins-SemiBold", size: 14)
        attachMemoLabel.isUserInteractionEnabled = false
    }
    
    
    //MARK: - Configure Audio Visualizer
    
    private func configureAudioVisualizer () {
        
        memosContainer.addSubview(visualizerStackView)
        visualizerStackView.translatesAutoresizingMaskIntoConstraints = false
        
        //The stackView's topAnchor can either be in relation to the memoContainer or the memoCollectionView
        visualizerStackViewTopAnchorWithContainer = visualizerStackView.topAnchor.constraint(equalTo: memosContainer.topAnchor, constant: 25)
        visualizerStackViewTopAnchorWithContainer?.isActive = voiceMemos?.count ?? 0 == 0

        visualizerStackViewTopAnchorWithCollectionView = visualizerStackView.topAnchor.constraint(equalTo: memoCollectionView.bottomAnchor, constant: 10)
        visualizerStackViewTopAnchorWithCollectionView?.isActive = voiceMemos?.count ?? 0 > 0
    
        [
            
            visualizerStackView.leadingAnchor.constraint(equalTo: memosContainer.leadingAnchor, constant: 5),
            visualizerStackView.trailingAnchor.constraint(equalTo: memosContainer.trailingAnchor, constant: -5),
            visualizerStackView.heightAnchor.constraint(equalToConstant: 50)

        ].forEach({ $0.isActive = true })
        
        visualizerStackView.alignment = .center
        visualizerStackView.distribution = .equalSpacing
        visualizerStackView.axis = .horizontal
        visualizerStackView.spacing = 5
                
        //Ensures that the stackView hasn't already been populated with subviews
        if visualizerStackView.arrangedSubviews.count == 0 {
            
            var count = 0
            
            //8.5 should be equal to the spacing plus the width of each bar; no idea what 2 represents anymore :/
            while count < Int(memosContainer.frame.width / 8.5) - 2 {
                
                let bar = UIView()
            
                bar.translatesAutoresizingMaskIntoConstraints = false
                
                bar.widthAnchor.constraint(equalToConstant: 3.5).isActive = true
                bar.heightAnchor.constraint(equalToConstant: 10).isActive = true
                
                visualizerStackView.addArrangedSubview(bar)
                
                bar.backgroundColor = UIColor(hexString: "222222")
                bar.layer.cornerRadius = 1.5
                
                count += 1
            }
        }
    }
    
    
    //MARK: - Configure Memos Length Label
    
    private func configureMemoLengthLabel () {
        
        memosContainer.addSubview(memoLengthLabel)
        memoLengthLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            memoLengthLabel.topAnchor.constraint(equalTo: visualizerStackView.bottomAnchor, constant: 10),
            memoLengthLabel.leadingAnchor.constraint(equalTo: memosContainer.leadingAnchor, constant: 15),
            memoLengthLabel.trailingAnchor.constraint(equalTo: memosContainer.trailingAnchor, constant: -15),
            memoLengthLabel.heightAnchor.constraint(equalToConstant: 20)
        
        ].forEach({ $0.isActive = true })
        
        memoLengthLabel.font = UIFont(name: "Poppins-SemiBold", size: 15)
        memoLengthLabel.textColor = .black
        memoLengthLabel.textAlignment = .right
        memoLengthLabel.text = "0:00"
        memoLengthLabel.alpha = 0
    }
    
    
    //MARK: - Configure Cancel Recording Button
    
    private func configureCancelRecordingButton () {
        
        memosContainer.addSubview(cancelRecordingButton)
        cancelRecordingButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            cancelRecordingButton.leadingAnchor.constraint(equalTo: memosContainer.leadingAnchor, constant: 0),
            cancelRecordingButton.trailingAnchor.constraint(equalTo: record_stopButton.leadingAnchor, constant: 0),
            cancelRecordingButton.centerYAnchor.constraint(equalTo: record_stopButton.centerYAnchor),
            cancelRecordingButton.heightAnchor.constraint(equalToConstant: 25)
        
        ].forEach({ $0.isActive = true })
        
        cancelRecordingButton.alpha = 1
        cancelRecordingButton.setTitle("Cancel", for: .normal)
        cancelRecordingButton.titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 15)
        cancelRecordingButton.tintColor = .black
        
        cancelRecordingButton.addTarget(self, action: #selector(recordingCancelled), for: .touchUpInside)
    }
    
    
    //MARK: - Configure Record Button
    
    private func configureRecordButton () {
        
        memosContainer.addSubview(record_stopButton)
        record_stopButton.addSubview(record_stopButtonIndicator)
        
        record_stopButton.translatesAutoresizingMaskIntoConstraints = false
        record_stopButtonIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            record_stopButton.centerXAnchor.constraint(equalTo: memosContainer.centerXAnchor),
            record_stopButton.bottomAnchor.constraint(equalTo: memosContainer.bottomAnchor, constant: -10),
            record_stopButton.widthAnchor.constraint(equalToConstant: 44),
            record_stopButton.heightAnchor.constraint(equalToConstant: 44),
            
            record_stopButtonIndicator.centerXAnchor.constraint(equalTo: record_stopButton.centerXAnchor),
            record_stopButtonIndicator.centerYAnchor.constraint(equalTo: record_stopButton.centerYAnchor),
            record_stopButtonIndicator.widthAnchor.constraint(equalToConstant: 32),
            record_stopButtonIndicator.heightAnchor.constraint(equalToConstant: 32)
        
        ].forEach({ $0.isActive = true })
        
        record_stopButton.layer.cornerRadius = 22
        record_stopButton.layer.borderWidth = 2.5
        record_stopButton.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
        
        record_stopButton.clipsToBounds = true
        
        record_stopButton.addTarget(self, action: #selector(record_stopButtonPressed), for: .touchUpInside)
        
        record_stopButtonIndicator.backgroundColor = .systemRed
        
        record_stopButtonIndicator.layer.cornerRadius = 16
        record_stopButtonIndicator.clipsToBounds = true
        
        record_stopButtonIndicator.transform = CGAffineTransform(rotationAngle: -45) //For the animation
        
        record_stopButtonIndicator.isUserInteractionEnabled = false
    }
    
    
    //MARK: - Configure Collection View
    
    private func configureCollectionView () {
        
        memosContainer.addSubview(memoCollectionView)
        memoCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            memoCollectionView.topAnchor.constraint(equalTo: memosContainer.topAnchor, constant: 10),
            memoCollectionView.leadingAnchor.constraint(equalTo: memosContainer.leadingAnchor, constant: 0),
            memoCollectionView.trailingAnchor.constraint(equalTo: memosContainer.trailingAnchor, constant: 0),
            memoCollectionView.heightAnchor.constraint(equalToConstant: voiceMemos?.count ?? 0 > 0 ? itemSize : 0)
        
        ].forEach({ $0.isActive = true })
        
        memoCollectionView.dataSource = self
        memoCollectionView.delegate = self
        
        memoCollectionView.backgroundColor = .white
        memoCollectionView.isScrollEnabled = false
        
        memoCollectionView.alpha = 0
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: floor(itemSize - 1), height: floor(itemSize - 1))
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        layout.scrollDirection = .vertical
        
        memoCollectionView.collectionViewLayout = layout
        
        memoCollectionView.register(CreateCollabMemoCollectionViewCell.self, forCellWithReuseIdentifier: "createCollabMemoCollectionViewCell")
    }
    
    
    //MARK: - Configure Recording Cell
    
    private func configureRecordingCell () {
            
        willBeginRecording = true
        
        configureAudioVisualizer()

        configureMemoLengthLabel()

        configureRecordButton()

        configureCancelRecordingButton()

        UIView.animate(withDuration: 0.15) {

            self.attachMemoButton.alpha = 0
        }
    }
    
    //MARK: - Cell Reconfiguration Functions
    
    private func reconfigureCell () {
        
        if voiceMemos?.count ?? 0 == 0 {

            if willBeginRecording || recording {
                
                memoCollectionView.constraints.forEach { (constraint) in
                    
                    if constraint.firstAttribute == .height {
                        
                        constraint.constant = 0
                    }
                }
                
                visualizerStackViewTopAnchorWithCollectionView?.isActive = false
                visualizerStackViewTopAnchorWithContainer?.isActive = true
                
                UIView.transition(with: memosContainer, duration: 0.3, options: .transitionCrossDissolve) {
                    
                    self.memosCountLabel.alpha = 0
                    
                    self.memoCollectionView.reloadData()
                }
            }
            
            else {
                
                configureNoMemosCell()
            }
        }
        
        else if voiceMemos?.count ?? 0 < 3 {
            
            if willBeginRecording || recording {
                
                UIView.transition(with: contentView, duration: 0.2, options: .transitionCrossDissolve) {
                    
                    self.memosCountLabel.text = "\(self.voiceMemos?.count ?? 0)/3"
                    
                    self.memoCollectionView.reloadData()
                }
            }
            
            else {
                
                //makes the animations prettier
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    
                    self.configurePartialMemoCell()
                }
            }
        }
        
        else {
            
            configureFullMemoCell()
        }
    }
    
    private func configureNoMemosCell () {
        
        if !recording {
            
            memoCollectionView.alpha = 0
            
            //Resetting the constraints of the attachMemoButton
            memosContainer.constraints.forEach { (constraint) in
                
                if constraint.firstAttribute == .leading && constraint.firstItem as? UIButton != nil {
                    
                    constraint.constant = 0
                }
                
                else if constraint.firstAttribute == .trailing && constraint.firstItem as? UIButton != nil {
                    
                    constraint.constant = 0
                }
                
                else if constraint.firstAttribute == .top && constraint.firstItem as? UIButton != nil {
                    
                    constraint.constant = 0
                }
            }
            
            attachMemoButton.constraints.forEach { (constraint) in
                
                if constraint.firstAttribute == .height {
                    
                    constraint.constant = 55
                }
            }
            ////////////////////////////////////////////////////////////////////////
            
            self.attachMemoButton.backgroundColor = .clear
            
            UIView.transition(with: memosContainer, duration: 0.3, options: .transitionCrossDissolve) {
                
                self.memosCountLabel.alpha = 0

                self.attachMemoButton.alpha = 1
                
                self.micImage.tintColor = .black
                self.micImage.isUserInteractionEnabled = false

                self.attachMemoLabel.text = "Attach Voice Memos"
                self.attachMemoLabel.textColor = .black
                self.attachMemoLabel.textAlignment = .center
                self.attachMemoLabel.font = UIFont(name: "Poppins-SemiBold", size: 14)
                self.attachMemoLabel.isUserInteractionEnabled = false
                
                self.visualizerStackView.removeFromSuperview()
                self.cancelRecordingButton.removeFromSuperview()
                self.record_stopButton.removeFromSuperview()
            }
        }
    }
    
    private func configurePartialMemoCell () {
        
        memosCountLabel.text = "\(voiceMemos?.count ?? 0)/3"
        
        attachMemoButton.alpha = attachMemoButton.superview != nil ? 1 : 0 //Will allow the attachMemoButton to be animated if it isn't currently added as a subview
        
        memosContainer.addSubview(attachMemoButton)
        
        //Resetting the constraints of the attachMemoButton
        memosContainer.constraints.forEach { (constraint) in
            
            if constraint.firstAttribute == .leading && constraint.firstItem as? UIButton != nil {
                
                constraint.constant = 32.5
            }
            
            else if constraint.firstAttribute == .trailing && constraint.firstItem as? UIButton != nil {
                
                constraint.constant = -32.5
            }
            
            else if constraint.firstAttribute == .top && constraint.firstItem as? UIButton != nil {
                
                constraint.constant = itemSize + 10 + 12.5
            }
        }
        
        attachMemoButton.constraints.forEach { (constraint) in
            
            if constraint.firstAttribute == .height {
                
                constraint.constant = 40
            }
        }
        ////////////////////////////////////////////////////////////////////////
        
        attachMemoButton.backgroundColor = UIColor(hexString: "222222")
        attachMemoButton.layer.cornerRadius = 20
        attachMemoButton.clipsToBounds = true
        attachMemoButton.addTarget(self, action: #selector(attachButtonPressed), for: .touchUpInside)
        
        micImage.tintColor = .white
        micImage.isUserInteractionEnabled = false
        
        attachMemoLabel.text = "Attach"
        attachMemoLabel.textColor = .white
        attachMemoLabel.textAlignment = .center
        attachMemoLabel.font = UIFont(name: "Poppins-SemiBold", size: 14)
        attachMemoLabel.isUserInteractionEnabled = false
    
        memoCollectionView.reloadData()
        
        //Resetting the height of the memoCollectionView
        memoCollectionView.constraints.forEach { (constraint) in
            
            if constraint.firstAttribute == .height {
                
                constraint.constant = itemSize
            }
        }
        
        UIView.transition(with: memosContainer, duration: 0.3, options: .transitionCrossDissolve) {

            self.visualizerStackView.removeFromSuperview()
            self.memoLengthLabel.removeFromSuperview()
            self.cancelRecordingButton.removeFromSuperview()
            self.record_stopButton.removeFromSuperview()

            self.memosCountLabel.alpha = 1
            self.memoCollectionView.alpha = 1
            self.attachMemoButton.alpha = 1
        }
    }
    
    private func configureFullMemoCell () {
        
        memosCountLabel.text = "3/3"
        
        memoCollectionView.reloadData()
        
        UIView.transition(with: memosContainer, duration: 0.3, options: .transitionCrossDissolve) {

            self.visualizerStackView.removeFromSuperview()
            self.memoLengthLabel.removeFromSuperview()
            self.record_stopButton.removeFromSuperview()
        }
    }
    
    
    //MARK: - Configure Notification Observors
    
    private func configureNotificationObservors () {
        
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardBeingPresented), name: UIApplication.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardBeingDismissed), name: UIApplication.keyboardWillHideNotification, object: nil)
    }
    
    
    //MARK: - Present Denied Alert
    
    func presentDeniedAlert () {
        
        let deniedAlert = UIAlertController(title: "\"Block Pro\" doesn't have access to your microphone", message: "Would you like to change this in your settings?", preferredStyle: .alert)
        
        let goToSettingsAction = UIAlertAction(title: "Ok", style: .default) { (goToSettingsAction) in
            
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                
                UIApplication.shared.open(appSettings)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        deniedAlert.addAction(cancelAction)
        deniedAlert.addAction(goToSettingsAction)
        
        if let viewController = createCollabVoiceMemosCellDelegate as? CreateCollabViewController {
            
            viewController.present(deniedAlert, animated: true) //Has to be presented by a viewController
        }
    }
    
    
    //MARK: - Start Memo Timer
    
    private func startMemoTimer () {
        
        memoStartTime = Date()
        
        memoLengthTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] (timer) in
            
            if let time = self?.memoStartTime {
                
                //If at least 1 minute has passed
                if self?.calendar.dateComponents([.minute], from: time, to: Date()).minute ?? 0 >= 1 {
                    
                    if let minutes = self?.calendar.dateComponents([.minute], from: time, to: Date()).minute, let seconds = self?.calendar.dateComponents([.second], from: time, to: Date()).second {
                        
                        //Limit for a voice memo
                        if minutes == 5 {
                            
                            self?.endRecording()
                        }
                        
                        //The last 10 seconds before the limit
                        else if minutes == 4 && seconds - (minutes * 60) > 50 {
                            
                            let convertedSeconds = seconds - (minutes * 60)
                            
                            UIView.transition(with: self!.memoLengthLabel, duration: 0.2, options: .transitionCrossDissolve) {

                                self?.memoLengthLabel.textColor = .clear

                            } completion: { (finished: Bool) in
                                
                                self?.memoLengthLabel.text = "\(minutes):\(convertedSeconds)"

                                UIView.transition(with: self!.memoLengthLabel, duration: 0.2, options: .transitionCrossDissolve) {

                                    self?.memoLengthLabel.textColor = .black
                                }
                            }
                        }
                        
                        else {
                            
                            let convertedSeconds = seconds - (minutes * 60)
                            
                            //If the convertedSeconds is less than 10 seconds, add a 0 before the convertedSeconds
                            self?.memoLengthLabel.text = convertedSeconds < 10 ? "\(minutes):0\(convertedSeconds)" : "\(minutes):\(convertedSeconds)"
                            
                        }
                    }
                }
                
                //If 1 minute hasn't passed yet
                else {
                    
                    if let seconds = self?.calendar.dateComponents([.second], from: time, to: Date()).second {
                        
                        //If the voice memo length is less than 10 seconds, add a 0 before the duration of the voice memo
                        self?.memoLengthLabel.text = seconds < 10 ? "0:0\(seconds)" : "0:\(seconds)"
                    }
                }
            }
        })
    }
    
    
    //MARK: - Animate Audio Visualizer
    
    private func animateAudioVisualizer () {
        
        visualizerStackView.arrangedSubviews.forEach { (subview) in
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                
                subview.backgroundColor = self.recording ? UIColor.systemRed : UIColor(hexString: "222222")
            }
        }
    }
    
    
    //MARK: - Animate Record Button
    
    private func animateRecordButton () {
        
        //Resetting the constraints of the record/stop button indicator
        record_stopButtonIndicator.constraints.forEach { (constraint) in
            
            if constraint.firstAttribute == .width {
                
                constraint.constant = recording ? 22 : 32
            }
            
            else if constraint.firstAttribute == .height {
                
                constraint.constant = recording ? 22 : 32
            }
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            
            self.layoutIfNeeded()
            
            self.record_stopButtonIndicator.transform = CGAffineTransform(rotationAngle: self.recording ? 0 : -45) //Rotates the indicator
            
            self.record_stopButtonIndicator.layer.cornerRadius = self.recording ? 4 : 16
        }
        
        //Allows the border to gradually change colors
        let borderAnimation = CABasicAnimation(keyPath: "borderColor")
        borderAnimation.fromValue = recording ? UIColor(hexString: "D8D8D8")?.cgColor : UIColor.systemRed.cgColor
        borderAnimation.toValue = recording ? UIColor.systemRed.cgColor : UIColor(hexString: "D8D8D8")?.cgColor
        borderAnimation.duration = 0.3
        borderAnimation.fillMode = .forwards
        borderAnimation.isRemovedOnCompletion = false
        
        record_stopButton.layer.add(borderAnimation, forKey: nil)
    }

    
    //MARK: - Normalize Sound Level
    
    //Takes in the raw sound level given to it by the microphone monitor
    private func normalizeSoundLevel (level: Float) -> CGFloat {
        
        if level < 0.0 {
            
            let maxLevel = max(10, CGFloat(level) + 50) / 2 //Returns the larger of the values then divides it by 2
            
            return CGFloat(maxLevel * (50 / 25))
        }
        
        //If the level is equal to 0, likely because the microphone hasn't picked up any sounds yet
        else {
            
            return 10
        }
    }
    
    
    //MARK: - Update Audio Visualizer
    
    //Called from audio class; updates each bar in the audioVisualizer
    func updateAudioVisualizer (_ soundSamples: [Float]) {
        
        var count = 0
        
        visualizerStackView.arrangedSubviews.forEach { (subview) in
            
            subview.constraints.forEach { (constraint) in
                
                if constraint.firstAttribute == .height {
                    
                    constraint.constant = normalizeSoundLevel(level: soundSamples[count])
                }
            }
            
            count += 1
        }
    }
    
    
    //MARK: - Start Recording
    
    private func startRecording () {
        
        willBeginRecording = false
        recording = true
        
        idForVoiceMemoBeingRecorded = UUID().uuidString
        voiceMemoRecorder?.startRecording(idForVoiceMemoBeingRecorded)
        startMemoTimer()
        
        animateAudioVisualizer()
        animateRecordButton()
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            
            self.cancelRecordingButton.alpha = 0
            self.memoLengthLabel.alpha = 1

        } completion: { (finished: Bool) in

            self.cancelRecordingButton.removeFromSuperview()
        }
    }
    
    
    //MARK: - End Recording
    
    @objc func endRecording () {
        
        willBeginRecording = false
        recording = false
        
        //Creating a new voice memo
        voiceMemoRecorder?.stopRecording(voiceMemoID: idForVoiceMemoBeingRecorded, completion: { (audioDurationSeconds) in
            
            var newVoiceMemo = VoiceMemo()
            newVoiceMemo.voiceMemoID = idForVoiceMemoBeingRecorded
            newVoiceMemo.dateCreated = Date()
            newVoiceMemo.length = audioDurationSeconds
            
            if voiceMemos == nil {
                
                voiceMemos = [newVoiceMemo]
            }
            
            else {
                
                voiceMemos?.append(newVoiceMemo)
            }
            
            createCollabVoiceMemosCellDelegate?.voiceMemoSaved(newVoiceMemo)
        })
    
        memoLengthTimer?.invalidate()
        
        animateAudioVisualizer()
        animateRecordButton()
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            
            self.memoLengthLabel.alpha = 0
            
        } completion: { (finished: Bool) in
            
            self.memoLengthLabel.text = "0:00"
        }
    }
    
    
    //MARK: - Playback Recording
    
    func playbackRecording (_ voiceMemoID: String) {
        
        voiceMemoRecorder?.playbackRecording(voiceMemoID)
    }
    
    
    //MARK: - Stop Recording Playback
    
    func stopRecordingPlayback () {
        
        voiceMemoRecorder?.stopRecordingPlayback()
    }
    
    
    //MARK: - Stop Memo Cell Playback
    
    func stopRecordingPlaybackOfVoiceMemoCell () {
        
        for visibleCell in memoCollectionView.visibleCells {
            
            if let cell = visibleCell as? CreateCollabMemoCollectionViewCell {
                
                if cell.recordingPlaying ?? false {
                    
                    cell.stopRecordingPlayback()
                }
            }
        }
    }
    
    
    //MARK: - Delete Voice Memo
    
    func deleteVoiceMemo (_ voiceMemo: VoiceMemo) {
        
        voiceMemoRecorder?.deleteRecording(voiceMemo)
        
        createCollabVoiceMemosCellDelegate?.voiceMemoDeleted(voiceMemo)
    }
    
    
    //MARK: - Keyboard Being Presented
    
    @objc private func keyboardBeingPresented (notification: NSNotification) {
        
        if !keyboardPresent {
            
            var nameTextFieldSelected: Bool = false
            
            //Ensures that a voiceMemo cell's nameTextField is the textField that called the keyboard
            for visibleCell in memoCollectionView.visibleCells {
                    
                if let cell = visibleCell as? CreateCollabMemoCollectionViewCell {
                    
                    if cell.nameTextField.isFirstResponder {
                        
                        nameTextFieldSelected = true
                        break
                    }
                }
            }
            
            if nameTextFieldSelected {
                
                keyboardPresent = true
                
                if let viewController = createCollabVoiceMemosCellDelegate as? CreateCollabViewController, let tableView = viewController.details_attachmentsTableView {
                    
                    let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
                    let keyboardHeight = keyboardFrame.cgRectValue.height
                    
                    //y-coord for the createCollabVoiceMemoCell in the CreateCollabViewController
                    let createMemoCellMinY = tableView.rectForRow(at: IndexPath(row: 4, section: 0)).minY
                    
                    //Distance from the top of the createCollabVoiceMemoCell to the top of the VoiceMemo collection view cell, i.e. 40; + the itemSize; - (half the height of the nameTextField + the bottomAnchor of the nameTextField), i.e. 10.5
                    let nameTextFieldCenter = 40 + floor(itemSize) - 10.5
                    
                    //y-coord of the details_attachments table view in regards to the keyWindow
                    let tableViewMinY = viewController.view.convert(tableView.frame, to: keyWindow).minY
                    
                    let keyboardMinY = UIScreen.main.bounds.height - keyboardHeight
                    
                    let middleOfTableViewAndKeyboard = tableViewMinY.distance(to: keyboardMinY) / 2
                    
                    originalContentOffsetOfTableView = tableView.contentOffset.y
                    
                    UIView.animate(withDuration: 0.3) {
                        
                        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
                        tableView.contentOffset.y = (createMemoCellMinY + nameTextFieldCenter - middleOfTableViewAndKeyboard)
                    }
                }
            }
        }
    }
    
    
    //MARK: - Keyboard Being Dismissed
    
    @objc private func keyboardBeingDismissed (notification: NSNotification) {
        
        if keyboardPresent {
            
            keyboardPresent = false
            
            if let viewController = createCollabVoiceMemosCellDelegate as? CreateCollabViewController, let tableView = viewController.details_attachmentsTableView {
                
                UIView.animate(withDuration: 0.3) {
                    
                    tableView.contentOffset.y = self.originalContentOffsetOfTableView
                }
                
                viewController.updateTableViewContentInset()
            }
        }
    }
    
    
    //MARK: - App Did Become Active
    
    @objc private func appDidBecomeActive () {
        
        if willBeginRecording {
            
            voiceMemoRecorder?.configureTemporaryAudioRecorder()
        }
    }
    
    
    //MARK: - App Did Enter Background
    
    @objc private func appDidEnterBackground () {
        
        if recording {
            
            endRecording()
        }
        
        else if willBeginRecording {
            
            voiceMemoRecorder?.stopMonitoring()
        }
        
        voiceMemoRecorder?.stopRecordingPlayback()
        stopRecordingPlaybackOfVoiceMemoCell()
    }
    
    
    //MARK: - Handle Audio Interruption
    
    @objc func handleAudioInterruption (_ notification: NSNotification) {
        
        if recording {
            
            endRecording()
        }
        
        else if willBeginRecording {
            
            //Will only cancel the recording if the audio interuption began and not if it ended; causes problems when "Block Pro" is returning from the background state if this isn't included... specifically it will attempt to reconfigure the cell by calling the "recordingCancelled" func
            if voiceMemoRecorder?.determineIfAudioInteruptionBegan(notification) == true {
                
                recordingCancelled()
            }
        }
        
        else {
            
            stopRecordingPlaybackOfVoiceMemoCell()
        }
    }
    
    
    //MARK: - Attach Button Pressed
    
    @objc func attachButtonPressed () {
        
        let numberOfSamples: Int = Int(memosContainer.frame.width / 8.5) - 2
        voiceMemoRecorder = VoiceMemoRecorder(parentCell: self, numberOfSamples: numberOfSamples)
        
        //Should be called again from the voiceMemoRecorder class if access is later on granted by the user
        if voiceMemoRecorder?.microphoneAccessGranted ?? false {
            
            createCollabVoiceMemosCellDelegate?.attachMemoSelected()
            
            stopRecordingPlaybackOfVoiceMemoCell()
            
            configureRecordingCell()
        }
    }
    
    
    //MARK: - Recording Cancelled
    
    @objc private func recordingCancelled () {
        
        willBeginRecording = false
        
        voiceMemoRecorder?.stopMonitoring()
        
        reconfigureCell()
        
        createCollabVoiceMemosCellDelegate?.recordingCancelled()
    }
    
    
    //MARK: - Recording/Stop Button Pressed
    
    @objc private func record_stopButtonPressed () {
        
        if !recording {
            
            startRecording()
        }
        
        else {
            
            endRecording()
        }
    }
}


//MARK: - Collection View DataSource and Delegate Extension

extension CreateCollabVoiceMemoCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return voiceMemos?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "createCollabMemoCollectionViewCell", for: indexPath) as! CreateCollabMemoCollectionViewCell
        cell.voiceMemo = voiceMemos?[indexPath.row]
        
        cell.createCollabVoiceMemoCell = self
        
        if let name = voiceMemos?[indexPath.row].name {
            
            cell.nameTextField.text = name
        }
        
        else {
            
            let centeredParagraphStyle = NSMutableParagraphStyle()
            centeredParagraphStyle.alignment = .center
            
            cell.nameTextField.attributedPlaceholder = NSAttributedString(string: "Memo #\(indexPath.row + 1)", attributes: [NSAttributedString.Key.foregroundColor: UIColor(hexString: "AAAAAA") as Any, NSAttributedString.Key.paragraphStyle : centeredParagraphStyle])
        }
        
        return cell
    }
}


//MARK: - UITextFieldDelegate Extension

//Used for the "nameTextField" in the voiceMemoCell
extension CreateCollabVoiceMemoCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.endEditing(true)
        return true
    }
}
