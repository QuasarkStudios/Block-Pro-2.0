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
    
    let nameTextField = UITextField()
    
    var voiceMemo: VoiceMemo?
    
    var showCancelButton: Bool = true
    
    var showingProgress: Bool?// = false
    
    let itemSize = floor((UIScreen.main.bounds.width - (40 + 10 + 20)) / 3)
    
    weak var createCollabVoiceMemosCellDelegate: CreateCollabVoiceMemosCellProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        configureCell()
        configureCancelButton()
        configureVoiceMemoImage()
        configureIProgressView()
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
    
    @objc private func cancelButtonPressed () {
        
        if let memo = voiceMemo {
            
            createCollabVoiceMemosCellDelegate?.voiceMemoDeleted(memo)
        }
    }
    
    @objc private func visualizerTapped () {
        
        if showingProgress ?? false {
            
            showingProgress = false
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                
                self.voiceMemoImage.alpha = 1
                self.iProgressView.alpha = 0
                
            } completion: { (finished: Bool) in
    
                self.iProgressView.dismissProgress()
            }
            
        }
        
        else {
            
            if showingProgress == nil {
                
                attachProgress()
            }
            
            iProgressView.showProgress()
            showingProgress = true
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                
                self.voiceMemoImage.alpha = 0
                self.iProgressView.alpha = 1
            }
        }
    }
}
