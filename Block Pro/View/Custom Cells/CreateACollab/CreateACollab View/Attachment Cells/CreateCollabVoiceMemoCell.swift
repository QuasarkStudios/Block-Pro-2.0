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
}

class CreateCollabVoiceMemoCell: UITableViewCell {

    let memosLabel = UILabel()
    let memosCountLabel = UILabel()
    let memosContainer = UIView()
    
    let visualizerStackView = UIStackView()
    
    let attachMemoButton = UIButton()
    let micImage = UIImageView(image: UIImage(systemName: "mic.circle"))
    let attachMemoLabel = UILabel()
    
    let record_stopButton = UIButton()
    let record_stopButtonIndicator = UIView()
    
    var voiceMemoRecorder: VoiceMemoRecorder?
    
//    var voiceMemos: [Any]? {
//        didSet {
//
//        }
//    }
    
    var recording: Bool = false
    
    weak var createCollabVoiceMemosCellDelegate: CreateCollabVoiceMemosCellProtocol?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "createCollabVoiceMemmoCell")
        
        configureMemosLabel()
        configureMemosCountLabel()
        configureMemosContainer()
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
        
//        if voiceMemos?.count ?? 0 == 0 {
//
//            if recording {
                
                UIView.animate(withDuration: 0.3) {
                    
                    self.attachMemoButton.alpha = 0
                }
                
                configureRecordButton()
//            }
//        }
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
        
        memosCountLabel.isHidden = true
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
    
    private func configureAttachButton () {
        
        memosContainer.addSubview(attachMemoButton)
        attachMemoButton.addSubview(micImage)
        attachMemoButton.addSubview(attachMemoLabel)
        
        attachMemoButton.translatesAutoresizingMaskIntoConstraints = false
        micImage.translatesAutoresizingMaskIntoConstraints = false
        attachMemoLabel.translatesAutoresizingMaskIntoConstraints = false
        
//        attachButtonLeadingAnchor = attachLocationButton.leadingAnchor.constraint(equalTo: locationContainer.leadingAnchor, constant: 0)
//        attachButtonTrailingAnchor = attachLocationButton.trailingAnchor.constraint(equalTo: locationContainer.trailingAnchor, constant: 0)
//        attachButtonTopAnchorWithContainer = attachLocationButton.topAnchor.constraint(equalTo: locationContainer.topAnchor, constant: 0)
//        attachButtonTopAnchorWithMapView = attachLocationButton.topAnchor.constraint(equalTo: mapViewContainer.bottomAnchor, constant: 12.5)
//        attachButtonTopAnchorWithPageControl = attachLocationButton.topAnchor.constraint(equalTo: locationPageControl.bottomAnchor, constant: 7.5)
//        attachButtonBottomAnchor = attachLocationButton.bottomAnchor.constraint(equalTo: locationContainer.bottomAnchor, constant: 0)
//
//        attachButtonLeadingAnchor?.isActive = true
//        attachButtonTrailingAnchor?.isActive = true
//        attachButtonTopAnchorWithContainer?.isActive = true
//        attachButtonTopAnchorWithMapView?.isActive = false
//        attachButtonTopAnchorWithPageControl?.isActive = false
//        attachButtonBottomAnchor?.isActive = true
        
        [

            attachMemoButton.leadingAnchor.constraint(equalTo: memosContainer.leadingAnchor, constant: 0),
            attachMemoButton.trailingAnchor.constraint(equalTo: memosContainer.trailingAnchor, constant: 0),
            attachMemoButton.topAnchor.constraint(equalTo: memosContainer.topAnchor, constant: 0),
            attachMemoButton.bottomAnchor.constraint(equalTo: memosContainer.bottomAnchor, constant: 0),
            
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
        
        [
        
            visualizerStackView.topAnchor.constraint(equalTo: memosContainer.topAnchor, constant: 25),
            visualizerStackView.leadingAnchor.constraint(equalTo: memosContainer.leadingAnchor, constant: 5),
            visualizerStackView.trailingAnchor.constraint(equalTo: memosContainer.trailingAnchor, constant: -5),
            visualizerStackView.heightAnchor.constraint(equalToConstant: 50)
            
        ].forEach({ $0.isActive = true })
        
        visualizerStackView.alignment = .center
        visualizerStackView.distribution = .equalSpacing
        visualizerStackView.axis = .horizontal
        visualizerStackView.spacing = 5
        
//        visualizerStackView.backgroundColor = .blue
        
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
    
    private func normalizeSoundLevel (level: Float) -> CGFloat {
        
        let level = max(10, CGFloat(level) + 50) / 2
        
        return CGFloat(level * (50 / 25))
    }
    
    @objc private func attachButtonPressed () {
        
        createCollabVoiceMemosCellDelegate?.attachMemoSelected()
        
        reconfigureCell()
        
        configureAudioVisualizer()
        
        let numberOfSamples: Int = Int(memosContainer.frame.width / 8.5) - 2
        
        voiceMemoRecorder = VoiceMemoRecorder(voiceMemoCell: self, numberOfSamples: numberOfSamples)
        
//        // 13 is equal to the width of each bar (w = 5) and the gap between the next bar (g = 8)
//        print (numberOfSamples - 2)
    }
    
    func updateAudioVisualizer (_ soundSamples: [Float]) {
        
        var count = 0//visualizerStackView.arrangedSubviews.count
        
        visualizerStackView.arrangedSubviews.forEach { (subview) in
            
//            print(normalizeSoundLevel(level: soundSamples[count]))
            
            subview.constraints.forEach { (constraint) in
                
                if constraint.firstAttribute == .height {
                    
                    constraint.constant = normalizeSoundLevel(level: soundSamples[count])
                }
            }
            
//            subview.frame = CGRect(x: 0, y: 0, width: 5, height: normalizeSoundLevel(level: soundSamples[count]))
            
//            subview.backgroundColor = .red
            
            count += 1
        }
    }
    
    private func getDocumentsDirectory () -> URL {
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    @objc private func record_stopButtonPressed () {
        
        recording = !recording
        
        if recording {
            
//            do {
//
//                let itemURL = "\(getDocumentsDirectory().path)/temporaryAudioRecording.m4a"
//                try FileManager.default.removeItem(at: URL(fileURLWithPath: itemURL, isDirectory: true))
//
//            } catch {
//
//                print("didnt work")
//            }
            
            voiceMemoRecorder?.startRecording()
        }
        
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
            
        } completion: { (finished: Bool) in
            
        }
        
        let borderAnimation = CABasicAnimation(keyPath: "borderColor")
        borderAnimation.fromValue = recording ? UIColor(hexString: "D8D8D8")?.cgColor : UIColor.systemRed.cgColor
        borderAnimation.toValue = recording ? UIColor.systemRed.cgColor : UIColor(hexString: "D8D8D8")?.cgColor
        borderAnimation.duration = 0.3
        borderAnimation.fillMode = .forwards
        borderAnimation.isRemovedOnCompletion = false
        
        record_stopButton.layer.add(borderAnimation, forKey: nil)
        
        visualizerStackView.arrangedSubviews.forEach { (subview) in
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                
                subview.backgroundColor = self.recording ? UIColor.systemRed : UIColor(hexString: "222222")
            }
        }
        
    }
}

//extension CreateCollabVoiceMemoCell: UICollectionViewDataSource, UICollectionViewDelegate {
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        
//        return Int.max
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        <#code#>
//    }
//}
