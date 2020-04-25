//
//  CollabPhotosCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/11/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

protocol CollabPhotosCellProtocol: AnyObject {
    
    func attachPhotosButtonPressed ()
    
    func addedPhotoSelected (photo: UIImage)
}

class CollabPhotosCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var buttonContainer: UIView!
    
    @IBOutlet weak var defaultAttachButton: UIButton!
    @IBOutlet weak var defaultAttachIcon: UIImageView!
    @IBOutlet weak var defaultAttachLabel: UILabel!
    
    @IBOutlet weak var photosCollectionView: UICollectionView!

    @IBOutlet weak var populatedAttachButtonContainer: UIView!
    
    
    var selectedPhotos: [UIImage] = []
    
    weak var collabPhotosCellDelegate: CollabPhotosCellProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureAttachmentContainer()
        configureCollectionView()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return selectedPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCell
        cell.photoImageView.image = selectedPhotos[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        var leftInset: CGFloat?

        if selectedPhotos.count == 1 {

            leftInset = (photosCollectionView.frame.size.width / 2) - 40
        }

        else if selectedPhotos.count == 2 {

            leftInset = (photosCollectionView.frame.size.width / 2) - (80 + 7.5)
        }

        else {

            leftInset = 0
        }

        return UIEdgeInsets(top: 0, left: leftInset!, bottom: 0, right: 0)

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collabPhotosCellDelegate?.addedPhotoSelected(photo: selectedPhotos[indexPath.row])
    }
    
    private func configureAttachmentContainer () {
        
        buttonContainer.backgroundColor = .white
        buttonContainer.layer.borderWidth = 1
        buttonContainer.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
        
        buttonContainer.layer.cornerRadius = 10
        buttonContainer.clipsToBounds = true
        
        populatedAttachButtonContainer.layer.cornerRadius = 21
        populatedAttachButtonContainer.clipsToBounds = true
        
        if #available(iOS 13.0, *) {
            buttonContainer.layer.cornerCurve = .continuous
            populatedAttachButtonContainer.layer.cornerCurve = .continuous
        }
        
        reconfigureAttachmentContainer(collectionViewPresent: false)
    }
    
    func reconfigureAttachmentContainer(collectionViewPresent: Bool) {
        
        if collectionViewPresent {
            
            defaultAttachButton.isHidden = true
            defaultAttachLabel.isHidden = true
            defaultAttachIcon.isHidden = true
            
            populatedAttachButtonContainer.isHidden = false
        }
        
        else {
            
            defaultAttachButton.isHidden = false
            defaultAttachLabel.isHidden = false
            defaultAttachIcon.isHidden = false
            
            populatedAttachButtonContainer.isHidden = true
        }
    }

    private func configureCollectionView () {
        
        photosCollectionView.dataSource = self
        photosCollectionView.delegate = self
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 80, height: 90)
        layout.minimumInteritemSpacing = 15
        layout.minimumLineSpacing = 15
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.scrollDirection = .horizontal
        
        photosCollectionView.collectionViewLayout = layout
        photosCollectionView.showsHorizontalScrollIndicator = false
        
        photosCollectionView.register(UINib(nibName: "PhotoCell", bundle: nil), forCellWithReuseIdentifier: "photoCell")
    }
    
    @IBAction func attachPhotosButton(_ sender: Any) {
        
        collabPhotosCellDelegate?.attachPhotosButtonPressed()
    }
}
