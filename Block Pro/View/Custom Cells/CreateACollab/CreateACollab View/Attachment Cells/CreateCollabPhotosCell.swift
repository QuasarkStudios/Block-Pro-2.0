//
//  CreateCollabPhotosCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 10/16/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

protocol CreateCollabPhotosCellProtocol: AnyObject {
    
    func presentAddPhotoAlert ()
}

class CreateCollabPhotosCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let photosLabel = UILabel()
    let photoCountLabel = UILabel()
    let collectionViewContainer = UIView()
    let photosCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    
    let attachPhotoButton = UIButton()
    let cameraImage = UIImageView(image: UIImage(systemName: "camera.circle"))
    let attachPhotosLabel = UILabel()
    
    var selectedPhotos: [UIImage]? {
        didSet {
            
            reconfigureCell(selectedPhotos)
            
            setPhotoCountLabel(selectedPhotos)
            
            photosCollectionView.reloadData()
        }
    }
    
    weak var createCollabPhotosCellDelegate: CreateCollabPhotosCellProtocol?
    weak var zoomInDelegate: ZoomInProtocol?
    weak var presentCopiedAnimationDelegate: PresentCopiedAnimationProtocol?
    
    lazy var collectionViewHeightConstraint = photosCollectionView.constraints.first(where: { $0.firstAttribute == .height })
    
    lazy var attachButtonLeadingAnchor = collectionViewContainer.constraints.first(where: { $0.firstAttribute == .leading && $0.firstItem as? UIButton != nil })
    lazy var attachButtonTrailingAnchor = collectionViewContainer.constraints.first(where: { $0.firstAttribute == .trailing && $0.firstItem as? UIButton != nil })
    lazy var attachButtonTopAnchor = collectionViewContainer.constraints.first(where: { $0.firstAttribute == .top && $0.firstItem as? UIButton != nil })
    lazy var attachButtonBottomAnchor = collectionViewContainer.constraints.first(where: { $0.firstAttribute == .bottom && $0.firstItem as? UIButton != nil })
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configurePhotosLabel()
        configurePhotoCountLabel()
        configureCollectionViewContainer()
        configureCollectionView(photosCollectionView)
        configureAttachButton()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return selectedPhotos?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collabPhotoCollectionViewCell", for: indexPath) as! CollabPhotoCollectionViewCell
        
        cell.photo = selectedPhotos?[indexPath.row]
        
        cell.imageView.isHidden = false
        cell.imageViewCornerRadius = 8
        
        cell.presentCopiedAnimationDelegate = presentCopiedAnimationDelegate
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! CollabPhotoCollectionViewCell
        zoomInDelegate?.zoomInOnPhotoImageView(photoImageView: cell.imageView)
    }
    
    private func reconfigureCell (_ photos: [UIImage]?) {
        
        if photos?.count ?? 0 == 0 {

            configureNoPhotosCell()
        }

        else if photos?.count ?? 0 < 6 {

            configurePartialPhotosCell()
        }

        else {

            configureFullPhotosCell()
        }
    }
    
    private func configurePhotosLabel () {
        
        self.contentView.addSubview(photosLabel)
        photosLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            photosLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            photosLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            photosLabel.widthAnchor.constraint(equalToConstant: 52.5),
            photosLabel.heightAnchor.constraint(equalToConstant: 20)
        
        ].forEach({ $0.isActive = true })
        
        photosLabel.text = "Photos"
        photosLabel.textColor = .black
        photosLabel.textAlignment = .left
        photosLabel.font = UIFont(name: "Poppins-SemiBold", size: 15)
    }
    
    private func configurePhotoCountLabel () {
        
        self.contentView.addSubview(photoCountLabel)
        photoCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            photoCountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            photoCountLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            photoCountLabel.widthAnchor.constraint(equalToConstant: 52.5),
            photoCountLabel.heightAnchor.constraint(equalToConstant: 20)
        
        ].forEach({ $0.isActive = true })
        
        photoCountLabel.isHidden = true
        photoCountLabel.text = "0/6"
        photoCountLabel.textColor = .black
        photoCountLabel.textAlignment = .right
        photoCountLabel.font = UIFont(name: "Poppins-SemiBold", size: 15)
    }
    
    private func configureCollectionViewContainer () {
        
        self.contentView.addSubview(collectionViewContainer)
        collectionViewContainer.translatesAutoresizingMaskIntoConstraints = false
        
        collectionViewContainer.addSubview(photosCollectionView)
        photosCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            collectionViewContainer.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
            collectionViewContainer.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20),
            collectionViewContainer.topAnchor.constraint(equalTo: photosLabel.bottomAnchor, constant: 10),
            collectionViewContainer.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0),
            
            photosCollectionView.leadingAnchor.constraint(equalTo: collectionViewContainer.leadingAnchor, constant: 0),
            photosCollectionView.trailingAnchor.constraint(equalTo: collectionViewContainer.trailingAnchor, constant: 0),
            photosCollectionView.topAnchor.constraint(equalTo: collectionViewContainer.topAnchor, constant: 0),
            photosCollectionView.heightAnchor.constraint(equalToConstant: 0)
        
        ].forEach({ $0.isActive = true })
        
        collectionViewContainer.backgroundColor = .white
        
        collectionViewContainer.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
        collectionViewContainer.layer.borderWidth = 1

        collectionViewContainer.layer.cornerRadius = 10
        collectionViewContainer.layer.cornerCurve = .continuous
        collectionViewContainer.clipsToBounds = true
    }
    
    private func configureCollectionView (_ collectionView: UICollectionView) {
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.backgroundColor = .white
        collectionView.isScrollEnabled = false
        
        let itemSize = (UIScreen.main.bounds.width - (40 + 10 + 20)) / 3
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: floor(itemSize - 1), height: floor(itemSize - 1))
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.scrollDirection = .vertical
        
        collectionView.collectionViewLayout = layout
        
        collectionView.register(UINib(nibName: "CollabPhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "collabPhotoCollectionViewCell")
    }
    
    private func configureAttachButton () {
        
        collectionViewContainer.addSubview(attachPhotoButton)
        attachPhotoButton.addSubview(cameraImage)
        attachPhotoButton.addSubview(attachPhotosLabel)
        
        attachPhotoButton.translatesAutoresizingMaskIntoConstraints = false
        cameraImage.translatesAutoresizingMaskIntoConstraints = false
        attachPhotosLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            attachPhotoButton.leadingAnchor.constraint(equalTo: collectionViewContainer.leadingAnchor, constant: 0),
            attachPhotoButton.trailingAnchor.constraint(equalTo: collectionViewContainer.trailingAnchor, constant: 0),
            attachPhotoButton.topAnchor.constraint(equalTo: photosCollectionView.bottomAnchor, constant: 0),
            attachPhotoButton.bottomAnchor.constraint(equalTo: collectionViewContainer.bottomAnchor, constant: 0),
            
            cameraImage.leadingAnchor.constraint(equalTo: attachPhotoButton.leadingAnchor, constant: 20),
            cameraImage.centerYAnchor.constraint(equalTo: attachPhotoButton.centerYAnchor),
            cameraImage.widthAnchor.constraint(equalToConstant: 25),
            cameraImage.heightAnchor.constraint(equalToConstant: 25),
            
            attachPhotosLabel.leadingAnchor.constraint(equalTo: attachPhotoButton.leadingAnchor, constant: 10),
            attachPhotosLabel.trailingAnchor.constraint(equalTo: attachPhotoButton.trailingAnchor, constant: -10),
            attachPhotosLabel.centerYAnchor.constraint(equalTo: attachPhotoButton.centerYAnchor),
            attachPhotosLabel.heightAnchor.constraint(equalToConstant: 25)
        
        ].forEach({ $0.isActive = true })
        
        attachPhotoButton.backgroundColor = .clear
        attachPhotoButton.addTarget(self, action: #selector(attachButtonPressed), for: .touchUpInside)
        
        cameraImage.tintColor = .black
        cameraImage.isUserInteractionEnabled = false
        
        attachPhotosLabel.text = "Attach Photos"
        attachPhotosLabel.textColor = .black
        attachPhotosLabel.textAlignment = .center
        attachPhotosLabel.font = UIFont(name: "Poppins-SemiBold", size: 14)
        attachPhotosLabel.isUserInteractionEnabled = false
    }
    
    private func configureNoPhotosCell () {
        
        collectionViewHeightConstraint?.constant = 0
        
        if attachPhotoButton.superview == nil {
            
            self.contentView.addSubview(attachPhotoButton)
            
            attachButtonTopAnchor?.isActive = true
            attachButtonBottomAnchor?.isActive = true
            attachButtonLeadingAnchor?.isActive = true
            attachButtonTrailingAnchor?.isActive = true
        }
        
        attachButtonLeadingAnchor?.constant = 0
        attachButtonTrailingAnchor?.constant = 0
        attachButtonTopAnchor?.constant = 0
        attachButtonBottomAnchor?.constant = 0
        
        attachPhotoButton.backgroundColor = .clear
        attachPhotoButton.layer.cornerRadius = 0
        attachPhotoButton.clipsToBounds = true
        
        cameraImage.tintColor = .black
        
        attachPhotosLabel.text = "Attach Photos"
        attachPhotosLabel.textColor = .black
        attachPhotosLabel.font = UIFont(name: "Poppins-SemiBold", size: 14)
    }
    
    private func configurePartialPhotosCell () {
        
        let itemSize = (UIScreen.main.bounds.width - (40 + 10 + 20)) / 3
        
        if selectedPhotos?.count ?? 0 <= 3 {
            
            //The item size plus the top and bottom edge insets, i.e. 20 and the top and bottom anchors i.e. 10
            collectionViewHeightConstraint?.constant = itemSize + 20
        }
        
        else {
            
            //The height of the two rows of items that'll be displayed plus the edge insets, i.e. 20 and the line spacing i.e. 5
            collectionViewHeightConstraint?.constant = (itemSize * 2) + 20 + 5
        }
        
        if attachPhotoButton.superview == nil {
            
            self.contentView.addSubview(attachPhotoButton)
            
            attachButtonTopAnchor?.isActive = true
            attachButtonBottomAnchor?.isActive = true
            attachButtonLeadingAnchor?.isActive = true
            attachButtonTrailingAnchor?.isActive = true
        }
        
        attachButtonTopAnchor?.constant = 2.5
        attachButtonBottomAnchor?.constant = -12.5
        attachButtonLeadingAnchor?.constant = 32.5
        attachButtonTrailingAnchor?.constant = -32.5
        
        attachPhotoButton.backgroundColor = UIColor(hexString: "222222")
        attachPhotoButton.layer.cornerRadius = 20
        attachPhotoButton.clipsToBounds = true
        attachPhotoButton.addTarget(self, action: #selector(attachButtonPressed), for: .touchUpInside)
        
        cameraImage.tintColor = .white
        cameraImage.isUserInteractionEnabled = false
        
        attachPhotosLabel.text = "Attach"
        attachPhotosLabel.textColor = .white
        attachPhotosLabel.textAlignment = .center
        attachPhotosLabel.font = UIFont(name: "Poppins-SemiBold", size: 14)
        attachPhotosLabel.isUserInteractionEnabled = false
    }
    
    private func configureFullPhotosCell () {
        
        let itemSize = (UIScreen.main.bounds.width - (40 + 10 + 20)) / 3
            
        //The height of the two rows of items that'll be displayed plus the edge insets, i.e. 20 and the line spacing i.e. 5
        collectionViewHeightConstraint?.constant = (itemSize * 2) + 20 + 5
        
        attachPhotoButton.removeFromSuperview()
    }
    
    private func setPhotoCountLabel (_ photos: [UIImage]?) {
        
        if photos?.count ?? 0 == 0 {
            
            photoCountLabel.isHidden = true
        }
        
        else {
            
            photoCountLabel.isHidden = false
            photoCountLabel.text = "\(photos?.count ?? 0)/6"
        }
    }
    
    @objc private func attachButtonPressed () {
        
        createCollabPhotosCellDelegate?.presentAddPhotoAlert()
    }
}
