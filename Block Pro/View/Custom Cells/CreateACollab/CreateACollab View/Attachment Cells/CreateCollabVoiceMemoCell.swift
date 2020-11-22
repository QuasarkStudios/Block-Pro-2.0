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
    
    func voiceMemoSaved(_ voiceMemo: VoiceMemo)
    
    func voiceMemoDeleted (_ voiceMemo: VoiceMemo)
}

class CreateCollabVoiceMemoCell: UITableViewCell {

    let memosLabel = UILabel()
    let memosCountLabel = UILabel()
    let memosContainer = UIView()
    
    let memoCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    
    let visualizerStackView = UIStackView()
    
    let attachMemoButton = UIButton()
    let micImage = UIImageView(image: UIImage(systemName: "mic.circle"))
    let attachMemoLabel = UILabel()
    
    let memoLengthLabel = UILabel()
    
    let record_stopButton = UIButton()
    let record_stopButtonIndicator = UIView()
    
    var voiceMemoRecorder: VoiceMemoRecorder?
    
    var voiceMemos: [VoiceMemo]? {
        didSet {
            
            reconfigureCell()
            
//            setMemosCountLabel(voiceMemos)
        }
    }
    
    let calendar = Calendar.current
    var memoLengthTimer: Timer?
    var memoStartTime: Date?
    
    var idForVoiceMemoBeingRecorded: String = ""
    
    var willBeginRecording: Bool = false
    var recording: Bool = false
    
    var visualizerStackViewTopAnchorWithContainer: NSLayoutConstraint?
    var visualizerStackViewTopAnchorWithCollectionView: NSLayoutConstraint?
    
    var attachMemoButtonLeadingAnchor: NSLayoutConstraint?
    var attachMemoButtonTrailingAnchor: NSLayoutConstraint?
    var attachMemoButtonTopAnchorWithContainer: NSLayoutConstraint?
    var attachMemoButtonTopAnchorWithCollectionView: NSLayoutConstraint?
    var attachMemoButtonBottomAnchor: NSLayoutConstraint?
    
    weak var createCollabVoiceMemosCellDelegate: CreateCollabVoiceMemosCellProtocol?
    
    let itemSize = (UIScreen.main.bounds.width - (40 + 10 + 20)) / 3
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "createCollabVoiceMemmoCell")
        
        configureMemosLabel()
        configureMemosCountLabel()
        configureMemosContainer()
        configureCollectionView()
        configureAttachButton()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    
    private func reconfigureCell () {
        
        if voiceMemos?.count ?? 0 == 0 {

            if willBeginRecording || recording {
                
                memoCollectionView.constraints.forEach { (constraint) in
                    
                    if constraint.firstAttribute == .height {
                        
                        constraint.constant = 0
                    }
                }
                
                self.visualizerStackViewTopAnchorWithCollectionView?.isActive = false
                
                self.visualizerStackViewTopAnchorWithContainer?.isActive = true
                
                UIView.transition(with: memosContainer, duration: 0.3, options: .transitionCrossDissolve) {
                    
                    self.memoCollectionView.layoutIfNeeded()
                    
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
            
            visualizerStackView.removeFromSuperview()
            memoLengthLabel.removeFromSuperview()
            
            memoCollectionView.alpha = 0
            
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
                
            self.attachMemoButton.backgroundColor = .clear
            
            UIView.transition(with: memosContainer, duration: 0.3, options: .transitionCrossDissolve) {
                
                self.memosCountLabel.alpha = 0

                self.micImage.tintColor = .black
                self.micImage.isUserInteractionEnabled = false

                self.attachMemoLabel.text = "Attach Voice Memos"
                self.attachMemoLabel.textColor = .black
                self.attachMemoLabel.textAlignment = .center
                self.attachMemoLabel.font = UIFont(name: "Poppins-SemiBold", size: 14)
                self.attachMemoLabel.isUserInteractionEnabled = false
            }
        }
    }
    
    private func configurePartialMemoCell () {
        
        memosCountLabel.text = "\(voiceMemos?.count ?? 0)/3"
        
        attachMemoButton.alpha = attachMemoButton.superview != nil ? 1 : 0
        
        memosContainer.addSubview(attachMemoButton)
        
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
        
        memoCollectionView.constraints.forEach { (constraint) in
            
            if constraint.firstAttribute == .height {
                
                constraint.constant = itemSize
            }
        }
        
        UIView.transition(with: memosContainer, duration: 0.3, options: .transitionCrossDissolve) {

            self.visualizerStackView.removeFromSuperview()
            self.memoLengthLabel.removeFromSuperview()
            self.record_stopButton.removeFromSuperview()

            self.memosCountLabel.alpha = 1
            self.memoCollectionView.alpha = 1
            self.attachMemoButton.alpha = 1

        } completion: { (finished: Bool) in


        }
    }
    
    private func configureFullMemoCell () {
        
        memosCountLabel.text = "3/3"
        
        memoCollectionView.reloadData()
        
        UIView.transition(with: memosContainer, duration: 0.3, options: .transitionCrossDissolve) {

            self.visualizerStackView.removeFromSuperview()
            self.memoLengthLabel.removeFromSuperview()
            self.record_stopButton.removeFromSuperview()

        } completion: { (finished: Bool) in


        }
    }
    
    private func configureRecordingCell () {
            
        willBeginRecording = true
        
        configureAudioVisualizer()

        configureMemoLengthLabel()

        configureRecordButton()
        
        UIView.animate(withDuration: 0.3) {

            self.attachMemoButton.alpha = 0
        }
    }
    
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
        
        memoCollectionView.register(VoiceMemoCell.self, forCellWithReuseIdentifier: "voiceMemoCell")
    }
    
    private func configureAttachButton () {
        
        memosContainer.addSubview(attachMemoButton)
        attachMemoButton.addSubview(micImage)
        attachMemoButton.addSubview(attachMemoLabel)
        
        attachMemoButton.translatesAutoresizingMaskIntoConstraints = false
        micImage.translatesAutoresizingMaskIntoConstraints = false
        attachMemoLabel.translatesAutoresizingMaskIntoConstraints = false
        
//        attachMemoButtonLeadingAnchor = attachMemoButton.leadingAnchor.constraint(equalTo: memosContainer.leadingAnchor, constant: 0)
//        attachMemoButtonTrailingAnchor = attachMemoButton.trailingAnchor.constraint(equalTo: memosContainer.trailingAnchor, constant: 0)
//        attachMemoButtonTopAnchorWithContainer = attachMemoButton.topAnchor.constraint(equalTo: memosContainer.topAnchor, constant: 0)
//        attachMemoButtonTopAnchorWithCollectionView = attachMemoButton.topAnchor.constraint(equalTo: memoCollectionView.bottomAnchor, constant: 12.5)
//        attachMemoButtonBottomAnchor = attachMemoButton.bottomAnchor.constraint(equalTo: memosContainer.bottomAnchor, constant: 0)
//
//        attachMemoButtonLeadingAnchor?.isActive = true
//        attachMemoButtonTrailingAnchor?.isActive = true
//        attachMemoButtonTopAnchorWithContainer?.isActive = true
//        attachMemoButtonTopAnchorWithCollectionView?.isActive = false
//        attachMemoButtonBottomAnchor?.isActive = true
        
        [

            attachMemoButton.leadingAnchor.constraint(equalTo: memosContainer.leadingAnchor, constant: 0),
            attachMemoButton.trailingAnchor.constraint(equalTo: memosContainer.trailingAnchor, constant: 0),
//            attachMemoButton.topAnchor.constraint(equalTo: memosContainer.topAnchor, constant: 0),
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
    
    private func configureAudioVisualizer () {
        
        memosContainer.addSubview(visualizerStackView)
        visualizerStackView.translatesAutoresizingMaskIntoConstraints = false
        
//        [
//
//            visualizerStackView.topAnchor.constraint(equalTo: memosContainer.topAnchor, constant: 25),
//            visualizerStackView.leadingAnchor.constraint(equalTo: memosContainer.leadingAnchor, constant: 5),
//            visualizerStackView.trailingAnchor.constraint(equalTo: memosContainer.trailingAnchor, constant: -5),
//            visualizerStackView.heightAnchor.constraint(equalToConstant: 50)
//
//        ].forEach({ $0.isActive = true })
        
        visualizerStackViewTopAnchorWithContainer = visualizerStackView.topAnchor.constraint(equalTo: memosContainer.topAnchor, constant: 25)
        visualizerStackViewTopAnchorWithContainer?.isActive = voiceMemos?.count ?? 0 == 0  //true

        
        visualizerStackViewTopAnchorWithCollectionView = visualizerStackView.topAnchor.constraint(equalTo: memoCollectionView.bottomAnchor, constant: 10)
        visualizerStackViewTopAnchorWithCollectionView?.isActive = voiceMemos?.count ?? 0 > 0 //false
    
        [

//            visualizerStackView.topAnchor.constraint(equalTo: memosContainer.topAnchor, constant: 25),
            visualizerStackView.leadingAnchor.constraint(equalTo: memosContainer.leadingAnchor, constant: 5),
            visualizerStackView.trailingAnchor.constraint(equalTo: memosContainer.trailingAnchor, constant: -5),
            visualizerStackView.heightAnchor.constraint(equalToConstant: 50)

        ].forEach({ $0.isActive = true })
        
        visualizerStackView.alignment = .center
        visualizerStackView.distribution = .equalSpacing
        visualizerStackView.axis = .horizontal
        visualizerStackView.spacing = 5
                
        if visualizerStackView.arrangedSubviews.count == 0 {
            
            var count = 0
            
            while count < Int(memosContainer.frame.width / 8.5) - 2 {
                
                let bar = UIView() //frame: CGRect(x: 0, y: 0, width: 5, height: 40)
            
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
        
        record_stopButtonIndicator.transform = CGAffineTransform(rotationAngle: -45)
        
        record_stopButtonIndicator.isUserInteractionEnabled = false
    }
    

    
    private func animateAudioVisualizer () {
        
        visualizerStackView.arrangedSubviews.forEach { (subview) in
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                
                subview.backgroundColor = self.recording ? UIColor.systemRed : UIColor(hexString: "222222")
            }
        }
    }
    
    private func animateRecordButton () {
        
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
            
            self.record_stopButtonIndicator.transform = CGAffineTransform(rotationAngle: self.recording ? 0 : -45)
            
            self.record_stopButtonIndicator.layer.cornerRadius = self.recording ? 4 : 16
        }
        
        let borderAnimation = CABasicAnimation(keyPath: "borderColor")
        borderAnimation.fromValue = recording ? UIColor(hexString: "D8D8D8")?.cgColor : UIColor.systemRed.cgColor
        borderAnimation.toValue = recording ? UIColor.systemRed.cgColor : UIColor(hexString: "D8D8D8")?.cgColor
        borderAnimation.duration = 0.3
        borderAnimation.fillMode = .forwards
        borderAnimation.isRemovedOnCompletion = false
        
        record_stopButton.layer.add(borderAnimation, forKey: nil)
    }

    
    private func normalizeSoundLevel (level: Float) -> CGFloat {
        
        let level = max(10, CGFloat(level) + 50) / 2
        
        return CGFloat(level * (50 / 25))
    }
    
    @objc private func attachButtonPressed () {

        createCollabVoiceMemosCellDelegate?.attachMemoSelected()
        
//        reconfigureCell(willBeginRecording: true)
        
        configureRecordingCell()
        
        
        let numberOfSamples: Int = Int(memosContainer.frame.width / 8.5) - 2
        
        voiceMemoRecorder = VoiceMemoRecorder(voiceMemoCell: self, numberOfSamples: numberOfSamples)
    }
    
    //called from audio class 
    func updateAudioVisualizer (_ soundSamples: [Float]) {
        
        var count = 0//visualizerStackView.arrangedSubviews.count
        
        visualizerStackView.arrangedSubviews.forEach { (subview) in
            
            subview.constraints.forEach { (constraint) in
                
                if constraint.firstAttribute == .height {
                    
                    constraint.constant = normalizeSoundLevel(level: soundSamples[count])
                }
            }
            
            count += 1
        }
    }
    
    private func startMemoTimer () {
        
        memoStartTime = Date()
        
        memoLengthTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] (timer) in
            
            if let time = self?.memoStartTime {
                
                //If at least 1 minute has passed
                if self?.calendar.dateComponents([.minute], from: time, to: Date()).minute ?? 0 >= 1 {
                    
                    if let minutes = self?.calendar.dateComponents([.minute], from: time, to: Date()).minute, let seconds = self?.calendar.dateComponents([.second], from: time, to: Date()).second {
                        
                        //Limit for a voice memo
                        if minutes == 5 {
                            
                            self?.voiceMemoRecorder?.stopRecording()
                            self?.memoLengthTimer?.invalidate()
                            
                            //finish ending the recording here
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
    
    private func getDocumentsDirectory () -> URL {
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    @objc private func record_stopButtonPressed () {
        
        willBeginRecording = false
        recording = !recording
        
        if recording {
            
            idForVoiceMemoBeingRecorded = UUID().uuidString
            voiceMemoRecorder?.startRecording(idForVoiceMemoBeingRecorded)
            startMemoTimer()
            
            //            do {
            //
            //                let itemURL = "\(getDocumentsDirectory().path)/temporaryAudioRecording.m4a"
            //                try FileManager.default.removeItem(at: URL(fileURLWithPath: itemURL, isDirectory: true))
            //
            //            } catch {
            //
            //                print("didnt work")
            //            }
        }
        
        else {
            
            voiceMemoRecorder?.stopRecording()
            memoLengthTimer?.invalidate()
        
            if voiceMemos == nil {
                
                voiceMemos = []
            }
            
            var newVoiceMemo = VoiceMemo()
            newVoiceMemo.voiceMemoID = idForVoiceMemoBeingRecorded
            newVoiceMemo.dateCreated = Date()
//            newVoiceMemo.length =
            
            voiceMemos?.append(newVoiceMemo)
            createCollabVoiceMemosCellDelegate?.voiceMemoSaved(newVoiceMemo)
            
//            reconfigureCell()
            
//            do {
//
//                print("\(getDocumentsDirectory().path)/VoiceMemos")
//
//                let itemURL = "\(getDocumentsDirectory().path)/VoiceMemos" //+ voiceMemos!.first! + ".m4a"
//                let items = try FileManager.default.contentsOfDirectory(atPath: itemURL)
//
//
//                print(items)
//
//                try FileManager.default.removeItem(at: URL(fileURLWithPath: itemURL, isDirectory: true))
//
//            } catch {
//
//                print("didnt work")
//            }
        }
        
        animateAudioVisualizer()
        animateRecordButton()
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            
            self.memoLengthLabel.alpha = self.recording ? 1 : 0
            
        } completion: { (finished: Bool) in
            
            self.memoLengthLabel.text = "0:00"
        }
    }
    
//    private func setMemosCountLabel (_ memos: [VoiceMemo]?) {
//
//        if memos?.count ?? 0 == 0 {
//
//            memosCountLabel.isHidden = true
//        }
//
//        else {
//
//            memosCountLabel.isHidden = false
//            memosCountLabel.text = "\(memos?.count ?? 0)/3"
//        }
//    }
}

extension CreateCollabVoiceMemoCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return voiceMemos?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "voiceMemoCell", for: indexPath) as! VoiceMemoCell
        cell.voiceMemo = voiceMemos?[indexPath.row]
        cell.createCollabVoiceMemosCellDelegate = createCollabVoiceMemosCellDelegate
        
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
