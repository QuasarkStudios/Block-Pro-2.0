//
//  VoiceMemoCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 11/15/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import iProgressHUD

class VoiceMemoCell: UICollectionViewCell {
    
    let cancelButton = UIButton(type: .system)
    let voiceMemoImage = UIImageView(image: UIImage(named: "voice-memo"))
    
    let iProgressView = UIView()
    var progressCircles: ProgressCircles?
    
    let nameTextField = UITextField()
    
    var voiceMemo: VoiceMemo?
    
    var showCancelButton: Bool = true
    var recordingPlaying: Bool?
    
    let itemSize = floor((UIScreen.main.bounds.width - (40 + 10 + 20)) / 3)
    
    var playbackWorkItem: DispatchWorkItem?
    
    weak var parentCell: CreateCollabVoiceMemoCell? {
        didSet {
            
            nameTextField.delegate = parentCell
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        configureCell()
        configureCancelButton()
        configureVoiceMemoImage()
        configureIProgressView()
        configureProgressCircles()
        configureNameTextField()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureCell () {
        
        self.layer.cornerRadius = 10
        
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
    }
    
    private func configureCancelButton () {
        
        if showCancelButton {
            
            self.contentView.addSubview(cancelButton)
            cancelButton.translatesAutoresizingMaskIntoConstraints = false
            
            [
            
                cancelButton.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 3),
                cancelButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -3),
                cancelButton.widthAnchor.constraint(equalToConstant: 23),
                cancelButton.heightAnchor.constraint(equalToConstant: 23)
            
            ].forEach({ $0.isActive = true })
            
            cancelButton.tintColor = UIColor(hexString: "222222")
            cancelButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
            
            cancelButton.addTarget(self, action: #selector(cancelButtonPressed), for: .touchUpInside)
        }
    }
    
    private func configureVoiceMemoImage () {
        
        self.contentView.addSubview(voiceMemoImage)
        voiceMemoImage.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            voiceMemoImage.widthAnchor.constraint(equalToConstant: itemSize - 50),
            voiceMemoImage.heightAnchor.constraint(equalToConstant: itemSize - 50),
            voiceMemoImage.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            voiceMemoImage.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor, constant: -2)
        
        ].forEach({ $0.isActive = true })
        
        voiceMemoImage.contentMode = .scaleAspectFill
        
        voiceMemoImage.isUserInteractionEnabled = true
        
        voiceMemoImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(visualizerTapped)))
    }
    
    private func configureIProgressView () {
        
        self.contentView.addSubview(iProgressView)
        iProgressView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            iProgressView.widthAnchor.constraint(equalToConstant: itemSize - 50),
            iProgressView.heightAnchor.constraint(equalToConstant: itemSize - 50),
            iProgressView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            iProgressView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor, constant: -2)
        
        ].forEach({ $0.isActive = true })
        
        iProgressView.backgroundColor = UIColor(hexString: "D8D8D8", withAlpha: 0.65)
        iProgressView.alpha = 0
        
        iProgressView.layer.cornerRadius = (itemSize - 50) * 0.5
        iProgressView.clipsToBounds = true
        
        iProgressView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(visualizerTapped)))
    }
    
    private func configureProgressCircles () {
        
        progressCircles = ProgressCircles(radius: (itemSize - 50) / 2, lineWidth: 2.5, trackLayerStrokeColor: UIColor.clear.cgColor, strokeColor: UIColor.black.cgColor, strokeEnd: 0)
        
        self.contentView.addSubview(progressCircles!)
        progressCircles?.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            progressCircles?.widthAnchor.constraint(equalToConstant: itemSize - 50),
            progressCircles?.heightAnchor.constraint(equalToConstant: itemSize - 50),
            progressCircles?.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            progressCircles?.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor, constant: -2)
        
        ].forEach({ $0?.isActive = true })
        
        progressCircles?.isUserInteractionEnabled = false
    }
    
    private func configureNameTextField () {
        
        self.contentView.addSubview(nameTextField)
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            nameTextField.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -3),
            nameTextField.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 5),
            nameTextField.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -5),
            nameTextField.heightAnchor.constraint(equalToConstant: 15)
        
        ].forEach({ $0.isActive = true })
        
        nameTextField.borderStyle = .none
        nameTextField.font = UIFont(name: "Poppins-SemiBold", size: 13)
        
        nameTextField.textAlignment = .center
        
        nameTextField.returnKeyType = .done
        
        nameTextField.addTarget(self, action: #selector(nameTextChanged), for: .editingChanged)
    }
    
    private func attachProgress () {
        
        let iProgress: iProgressHUD = iProgressHUD()
        
        iProgress.isShowModal = false
        iProgress.isShowCaption = false
        iProgress.isTouchDismiss = false
        iProgress.boxColor = .clear
        iProgress.indicatorColor = .black
        iProgress.indicatorSize = 100
        
        iProgress.attachProgress(toView: iProgressView)
        
        iProgressView.updateIndicator(style: .lineScalePulseOut)
    }
    
    private func beginRecordingPlayBack () {
        
        self.parentCell?.stopRecordingPlaybackOfVoiceMemoCell() //Stops the recording playback of other "voiceMemoCells"
        
        if recordingPlaying == nil {
            
            attachProgress()
        }
        
        iProgressView.showProgress()

        recordingPlaying = true
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {

            self.voiceMemoImage.alpha = 0
            self.iProgressView.alpha = 1
        }
        
        self.parentCell?.playbackRecording(self.voiceMemo?.voiceMemoID ?? "")
        
        if let recordingLength = voiceMemo?.length {
            
            playbackWorkItem = DispatchWorkItem(block: {
                
                self.stopRecordingPlayack()
            })
            
            beginProgressCircleAnimation() //Calling here allows for the animation to be completed at a better time
            DispatchQueue.main.asyncAfter(deadline: .now() + recordingLength, execute: playbackWorkItem!)
        }
    }
    
    func stopRecordingPlayack () {
        
        recordingPlaying = false
        
        self.parentCell?.stopRecordingPlayback()
        playbackWorkItem?.cancel()
        
        endProgressCircleAnimation()
        
        UIView.transition(with: contentView, duration: 0.3, options: .transitionCrossDissolve) {
            
            self.voiceMemoImage.alpha = 1
            self.iProgressView.alpha = 0
            
        } completion: { (finished: Bool) in
            
            self.iProgressView.dismissProgress()
        }
    }
    
    private func beginProgressCircleAnimation () {
        
        if let length = voiceMemo?.length {
            
            let strokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
            strokeAnimation.fromValue = 0
            strokeAnimation.toValue = 1
            strokeAnimation.duration = length
            strokeAnimation.fillMode = .forwards
            strokeAnimation.isRemovedOnCompletion = false
            
            progressCircles?.shapeLayer.removeAnimation(forKey: "colorAnimation")
            progressCircles?.shapeLayer.add(strokeAnimation, forKey: nil)
        }
    }
    
    private func endProgressCircleAnimation () {
        
        let colorAnimation = CABasicAnimation(keyPath: "strokeColor")
        colorAnimation.fromValue = UIColor.black.cgColor
        colorAnimation.toValue = UIColor.clear.cgColor
        colorAnimation.duration = 0.3
        colorAnimation.fillMode = .forwards
        colorAnimation.isRemovedOnCompletion = false
        
        progressCircles?.shapeLayer.add(colorAnimation, forKey: "colorAnimation")
    }
    
    @objc private func cancelButtonPressed () {
        
        if let memo = voiceMemo {
            
            if recordingPlaying ?? false {
                
                parentCell?.stopRecordingPlayback()
            }
            
            parentCell?.deleteVoiceMemo(memo)
        }
    }
    
    @objc private func visualizerTapped () {
        
        if recordingPlaying ?? false {
            
            stopRecordingPlayack()
        }
        
        else {
            
            //Ensures that a recording isn't going to start and that a recording isn't ongoing
            if !(parentCell?.willBeginRecording ?? false) && !(parentCell?.recording ?? false) {
                
                beginRecordingPlayBack()
            }
        }
    }
    
    @objc private func nameTextChanged () {
        
        parentCell?.createCollabVoiceMemosCellDelegate?.voiceMemoNameChanged(voiceMemo?.voiceMemoID ?? "", nameTextField.text)
    }
}
