//
//  convoPhotoInfoCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 7/9/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class ConvoPhotoInfoCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionViewContainer: UIView!
    
    @IBOutlet weak var photosCollectionView: UICollectionView!
    
    let noPhotosImageView = UIImageView()
    let noPhotosLabel = UILabel()
    
    var conversationID: String?
    var collabID: String?
    
    var messages: [Message]? {
        didSet {
            
            configureNoPhotosIndicator(messages)
            
            photosCollectionView.reloadData()
        }
    }
    
    weak var cachePhotoDelegate: CachePhotoProtocol?
    weak var zoomInDelegate: ZoomInProtocol?
    weak var presentCopiedAnimationDelegate: PresentCopiedAnimationProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionViewContainer.backgroundColor = .white
        collectionViewContainer.layer.cornerRadius = 10
        collectionViewContainer.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
        collectionViewContainer.layer.borderWidth = 1
        
        if #available(iOS 13.0, *) {
            collectionViewContainer.layer.cornerCurve = .continuous
        }
        
        collectionViewContainer.clipsToBounds = true
        
        configureCollectionView(collectionView: photosCollectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if messages?.count ?? 0 < 6 {
            
            return messages?.count ?? 0
        }
        
        else {
            
            return 6
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "convoPhotoCollectionViewCell", for: indexPath) as! ConvoPhotoCollectionViewCell
        
        cell.conversationID = conversationID
        cell.collabID = collabID
        
        cell.message = messages?[indexPath.row]
        
        cell.imageViewCornerRadius = 8
        
        cell.cachePhotoDelegate = cachePhotoDelegate
        cell.presentCopiedAnimationDelegate = presentCopiedAnimationDelegate
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! ConvoPhotoCollectionViewCell
        zoomInDelegate?.zoomInOnPhotoImageView(photoImageView: cell.imageView)
    }
    
    private func configureCollectionView (collectionView: UICollectionView) {
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.isScrollEnabled = false
        
        let itemSize = (UIScreen.main.bounds.width - (40 + 10 + 20)) / 3
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: floor(itemSize - 1), height: floor(itemSize - 1))
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.scrollDirection = .vertical
        
        collectionView.collectionViewLayout = layout
        
        collectionView.register(UINib(nibName: "ConvoPhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "convoPhotoCollectionViewCell")
    }
    
    private func configureNoPhotosIndicator (_ messages: [Message]?) {
        
        if messages?.count ?? 0 == 0 {
            
            let imageViewFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 40, height: (UIScreen.main.bounds.width - (40 + 10 + 20)) / 3)
            
            noPhotosImageView.frame = imageViewFrame
            noPhotosImageView.image = UIImage(named: "Landscape-Gray")
            noPhotosImageView.contentMode = .scaleAspectFit
            
            collectionViewContainer.addSubview(noPhotosImageView)
            
            let labelFrame = CGRect(x: 0, y: ((UIScreen.main.bounds.width - (40 + 10 + 20)) / 3) - 6, width: UIScreen.main.bounds.width - 40, height: 15)
            
            noPhotosLabel.frame = labelFrame
            noPhotosLabel.text = "No Photos Yet"
            noPhotosLabel.textColor = UIColor(hexString: "222222")
            noPhotosLabel.textAlignment = .center
            noPhotosLabel.font = UIFont(name: "Poppins-SemiBold", size: 14)
            
            collectionViewContainer.addSubview(noPhotosLabel)
        }
        
        else {
            
            noPhotosImageView.removeFromSuperview()
            noPhotosLabel.removeFromSuperview()
        }
    }
}
