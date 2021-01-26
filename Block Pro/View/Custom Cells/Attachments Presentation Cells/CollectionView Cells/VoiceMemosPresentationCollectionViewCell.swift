//
//  VoiceMemosPresentationCollectionViewCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 1/25/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit
import iProgressHUD
import SVProgressHUD

class VoiceMemosPresentationCollectionViewCell: UICollectionViewCell {
    
    let voiceMemoImage = UIImageView(image: UIImage(named: "voice-memo"))
    
    let iProgressView = UIView()
    var progressCircles: ProgressCircles?
    
    let nameLabel = UILabel()
    
    let firebaseStorage = FirebaseStorage()
    
    var collab: Collab?
    var block: Block?
    var voiceMemo: VoiceMemo?
    
    lazy var voiceMemoPlayer = VoiceMemoPlayer.sharedInstance
    
    var shouldPlayRecording: Bool = true
    var recordingPlaying: Bool?
    
    var playbackWorkItem: DispatchWorkItem?
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        configureCell()
        configureVoiceMemoImage()
        configureIProgressView()
        configureProgressCircles()
        configureNameLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureCell () {
        
        self.layer.cornerRadius = 10
        
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
    }
    
    private func configureVoiceMemoImage () {
        
        self.contentView.addSubview(voiceMemoImage)
        voiceMemoImage.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            voiceMemoImage.widthAnchor.constraint(equalToConstant: itemSize - 50),
            voiceMemoImage.heightAnchor.constraint(equalToConstant: itemSize - 50),
            voiceMemoImage.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            voiceMemoImage.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor, constant: -6)
        
        ].forEach({ $0.isActive = true })
        
        voiceMemoImage.contentMode = .scaleAspectFill
    }
    
    private func configureIProgressView () {
        
        self.contentView.addSubview(iProgressView)
        iProgressView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            iProgressView.widthAnchor.constraint(equalToConstant: itemSize - 50),
            iProgressView.heightAnchor.constraint(equalToConstant: itemSize - 50),
            iProgressView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            iProgressView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor, constant: -6)
        
        ].forEach({ $0.isActive = true })
        
        iProgressView.backgroundColor = UIColor(hexString: "D8D8D8", withAlpha: 0.65)
        iProgressView.alpha = 0
        
        iProgressView.layer.cornerRadius = (itemSize - 50) * 0.5
        iProgressView.clipsToBounds = true
    }
    
    private func configureProgressCircles () {
        
        progressCircles = ProgressCircles(radius: (itemSize - 50) / 2, lineWidth: 2.5, trackLayerStrokeColor: UIColor.clear.cgColor, strokeColor: UIColor.black.cgColor, strokeEnd: 0)
        
        self.contentView.addSubview(progressCircles!)
        progressCircles?.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            progressCircles?.widthAnchor.constraint(equalToConstant: itemSize - 50),
            progressCircles?.heightAnchor.constraint(equalToConstant: itemSize - 50),
            progressCircles?.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            progressCircles?.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor, constant: -6)
        
        ].forEach({ $0?.isActive = true })
        
        progressCircles?.isUserInteractionEnabled = false
    }
    
    private func configureNameLabel () {
        
        self.contentView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            nameLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -3),
            nameLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 5),
            nameLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -5),
            nameLabel.heightAnchor.constraint(equalToConstant: 17)
        
        ].forEach({ $0.isActive = true })
        
        
        nameLabel.font = UIFont(name: "Poppins-SemiBold", size: 13)
        nameLabel.textAlignment = .center
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
    
    private func retrieveVoiceMemo (_ collab: Collab?, _ block: Block?, _ voiceMemo: VoiceMemo?, _ completion: @escaping ((_ error: Error?) -> Void)) {
        
        if let collabID = collab?.collabID, let blockID = block?.blockID, let voiceMemoID = voiceMemo?.voiceMemoID {
            
            firebaseStorage.retrieveCollabBlockVoiceMemosFromStorage(collabID, blockID, voiceMemoID) { [weak self] (progress, error) in
                
                if error != nil {
                    
                    completion(error)
                }
                
                else if progress != nil {
                    
                    //If the voiceMemo hasn't finished being loaded yet
                    if progress! < 1 {

                        self?.nameLabel.text = "Loading..."

                        self?.progressCircles?.shapeLayer.strokeEnd = CGFloat(progress!) //Implicitly animates it to it's correct position
                    }

                    //If the voiceMemo has finished being loaded
                    else {

                        self?.progressCircles?.shapeLayer.strokeEnd = CGFloat(progress!) //Implicitly animates it to it's correct position

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {

                            //Implicitly animates it to 0 after a 0.3 sec delay to give to animation to 1 time to complete
                            self?.progressCircles?.shapeLayer.strokeEnd = 0
                        }

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {

                            //Calls the completion after a 0.6 sec delay to give the previous animations time to complete
                            completion(nil)
                        }
                    }
                }
            }
        }
        
        else if let collabID = collab?.collabID, let voiceMemoID = voiceMemo?.voiceMemoID {
            
            firebaseStorage.retrieveCollabVoiceMemoFromStorage(collabID, voiceMemoID) { [weak self] (progress, error) in

                if error != nil {

                    completion(error)
                }

                else if progress != nil {
                    
                    //If the voiceMemo hasn't finished being loaded yet
                    if progress! < 1 {

                        self?.nameLabel.text = "Loading..."

                        self?.progressCircles?.shapeLayer.strokeEnd = CGFloat(progress!) //Implicitly animates it to it's correct position
                    }

                    //If the voiceMemo has finished being loaded
                    else {

                        self?.progressCircles?.shapeLayer.strokeEnd = CGFloat(progress!) //Implicitly animates it to it's correct position

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {

                            //Implicitly animates it to 0 after a 0.3 sec delay to give to animation to 1 time to complete
                            self?.progressCircles?.shapeLayer.strokeEnd = 0
                        }

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {

                            //Calls the completion after a 0.6 sec delay to give the previous animations time to complete
                            completion(nil)
                        }
                    }
                }
            }
        }
    }
    
    private func beginRecordingPlayback () {
        
        if let voiceMemoID = voiceMemo?.voiceMemoID {
            
            voiceMemoPlayer.playbackRecording(voiceMemoID)
        }
        
        if recordingPlaying == nil {
            
            attachProgress()
        }
        
        iProgressView.showProgress()

        recordingPlaying = true
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {

            self.voiceMemoImage.alpha = 0
            self.iProgressView.alpha = 1
        }
        
        if let recordingLength = voiceMemo?.length {
            
            playbackWorkItem = DispatchWorkItem(block: {
                
                self.stopRecordingPlayback()
            })
            
            beginProgressCircleAnimation() //Calling here allows for the animation to be completed at a better time
            DispatchQueue.main.asyncAfter(deadline: .now() + recordingLength, execute: playbackWorkItem!)
        }
    }
    
    func stopRecordingPlayback () {
        
        voiceMemoPlayer.stopRecordingPlayback()
        
        recordingPlaying = false
        
        playbackWorkItem?.cancel()
        playbackWorkItem = nil
        
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
            progressCircles?.shapeLayer.add(strokeAnimation, forKey: "strokeAnimation")
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {

            self.progressCircles?.shapeLayer.strokeEnd = 0
            self.progressCircles?.shapeLayer.removeAnimation(forKey: "strokeAnimation")
            self.progressCircles?.shapeLayer.removeAnimation(forKey: "colorAnimation")
        }
    }
    
    //Called from the VoiceMemoPresentationCell
    func cellTapped () {
        
        if recordingPlaying ?? false {
            
            stopRecordingPlayback()
        }
        
        else {
            
            shouldPlayRecording = true
            
            //If the voiceMemo has been loaded
            if FileManager.default.fileExists(atPath: documentsDirectory.path + "/VoiceMemos" + "/\(voiceMemo?.voiceMemoID ?? "").m4a") {
                
                beginRecordingPlayback()
            }
            
            //If the voiceMemo hasn't been loaded
            else {
                
                retrieveVoiceMemo(collab, block, voiceMemo) { [weak self] (error) in
                    
                    if error != nil {
                        
                        print(error?.localizedDescription as Any)
                        
                        SVProgressHUD.showError(withStatus: "Sorry, an error occurred while loading this Voice Memo")
                    }
                    
                    else {
                        
                        //Ensures that another voiceMemo wasn't tapped after this one began loading and in turn should still play
                        if self?.shouldPlayRecording ?? false {
                            
                            self?.beginRecordingPlayback()
                        }
                        
                        self?.nameLabel.text = self?.voiceMemo?.name
                    }
                }
            }
        }
    }
}
