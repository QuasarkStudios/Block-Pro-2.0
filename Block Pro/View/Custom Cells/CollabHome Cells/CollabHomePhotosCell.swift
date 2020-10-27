//
//  CollabHomePhotosCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 10/14/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class CollabHomePhotosCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionViewContainer: UIView!
    @IBOutlet weak var photosCollectionView: UICollectionView!
    
    let noPhotosImageView = UIImageView()
    let noPhotosLabel = UILabel()
    
//    var collabID: String?
//
//    var photoIDs: [String]? {
//        didSet {
//
//            configureNoPhotosIndicator(photoIDs)
//
//            photosCollectionView.reloadData()
//        }
//    }
    
    var collab: Collab? {
        didSet {
            
            configureNoPhotosIndicator(collab?.photoIDs)
            
            photosCollectionView.reloadData()
        }
    }
    
    weak var cachePhotoDelegate: CachePhotoProtocol?
    weak var zoomInDelegate: ZoomInProtocol?
    weak var presentCopiedAnimationDelegate: PresentCopiedAnimationProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionViewContainer.backgroundColor = .white
        
        collectionViewContainer.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
        collectionViewContainer.layer.borderWidth = 1

        collectionViewContainer.layer.cornerRadius = 10
        collectionViewContainer.layer.cornerCurve = .continuous
        collectionViewContainer.clipsToBounds = true
        
        configureCollectionView(photosCollectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return collab?.photoIDs.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collabPhotoCollectionViewCell", for: indexPath) as! CollabPhotoCollectionViewCell
        
//        cell.conversationID = conversationID
//        cell.collabID = collabID
//
//        cell.message = messages?[indexPath.row]
        
        cell.collabID = collab?.collabID
        cell.photoID = collab?.photoIDs[indexPath.row]
        cell.photo = collab?.photos[collab!.photoIDs[indexPath.row]] ?? nil
        
        cell.imageViewCornerRadius = 8
        
        cell.cachePhotoDelegate = cachePhotoDelegate
        cell.presentCopiedAnimationDelegate = presentCopiedAnimationDelegate
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! CollabPhotoCollectionViewCell
        
        if let viewController = zoomInDelegate as? CollabViewController {
            
//            viewController.editCoverButton.removeTarget(nil, action: nil, for: .allEvents)
//            viewController.deleteCoverButton.removeTarget(nil, action: nil, for: .allEvents)
//            
//            viewController.editCoverButton.addTarget(viewController, action: #selector(viewController.editCollabPhotoButtonPressed), for: .touchUpInside)
//            viewController.deleteCoverButton.addTarget(viewController, action: #selector(viewController.deleteCollabPhotoButtonPressed), for: .touchUpInside)
            
            viewController.zoomingMethods = ZoomingImageViewMethods(on: cell.imageView, cornerRadius: 8)
            viewController.zoomingMethods?.performZoom()
        }
    }
    
    private func configureCollectionView (_ collectionView: UICollectionView) {
        
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
        
        collectionView.register(UINib(nibName: "CollabPhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "collabPhotoCollectionViewCell")
    }
    
    private func configureNoPhotosIndicator (_ photoIDs: [String]?) {
        
        if photoIDs?.count ?? 0 == 0 {
            
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
