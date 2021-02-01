//
//  PhotosPresentationCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 1/23/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit

class PhotosPresentationCell: UITableViewCell {

    let photosLabel = UILabel()
    let photosContainer = UIView()
    let photosCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    
    let noPhotosImageView = UIImageView()
    let noPhotosLabel = UILabel()
    
    var collab: Collab?
    var block: Block?
    
    var photoIDs: [String]? {
        didSet {

            configureNoPhotosIndicator(photoIDs)

            photosCollectionView.reloadData()
        }
    }
    
    weak var cachePhotoDelegate: CachePhotoProtocol?
    weak var zoomInDelegate: ZoomInProtocol?
    weak var presentCopiedAnimationDelegate: PresentCopiedAnimationProtocol?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "photosPresentationCell")
        
        configurePhotosLabel()
        configurePhotosContainer()
        configureCollectionView(photosCollectionView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configurePhotosLabel () {
        
        self.contentView.addSubview(photosLabel)
        photosLabel.configureTitleLabelConstraints()
        
        photosLabel.font = UIFont(name: "Poppins-SemiBold", size: 15)
        photosLabel.text = "Photos"
        photosLabel.textColor = .black
        photosLabel.textAlignment = .left
    }
    
    private func configurePhotosContainer () {
        
        self.contentView.addSubview(photosContainer)
        photosContainer.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            photosContainer.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
            photosContainer.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20),
            photosContainer.topAnchor.constraint(equalTo: photosLabel.bottomAnchor, constant: 10),
            photosContainer.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0),
            
        ].forEach({ $0.isActive = true })
        
        photosContainer.backgroundColor = .white
        
        photosContainer.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
        photosContainer.layer.borderWidth = 1

        photosContainer.layer.cornerRadius = 10
        photosContainer.layer.cornerCurve = .continuous
        photosContainer.clipsToBounds = true
    }
    
    private func configureCollectionView (_ collectionView: UICollectionView) {
        
        self.photosContainer.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            collectionView.leadingAnchor.constraint(equalTo: photosContainer.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: photosContainer.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: photosContainer.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: photosContainer.bottomAnchor)
        
        ].forEach({ $0.isActive = true })
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.backgroundColor = .white
        collectionView.isScrollEnabled = false
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: itemSize - 1, height: itemSize - 1)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.scrollDirection = .vertical
        
        collectionView.collectionViewLayout = layout
        
        collectionView.register(PhotosPresentationCollectionViewCell.self, forCellWithReuseIdentifier: "photosPresentationCollectionViewCell")
    }
    
    private func configureNoPhotosIndicator (_ photoIDs: [String]?) {
        
        if photoIDs?.count ?? 0 == 0 {
            
            self.contentView.addSubview(noPhotosImageView)
            noPhotosImageView.translatesAutoresizingMaskIntoConstraints = false
            
            self.contentView.addSubview(noPhotosLabel)
            noPhotosLabel.translatesAutoresizingMaskIntoConstraints = false
            
            [
                noPhotosImageView.leadingAnchor.constraint(equalTo: photosContainer.leadingAnchor, constant: 0),
                noPhotosImageView.trailingAnchor.constraint(equalTo: photosContainer.trailingAnchor, constant: 0),
                noPhotosImageView.topAnchor.constraint(equalTo: photosContainer.topAnchor, constant: 0),
                noPhotosImageView.bottomAnchor.constraint(equalTo: noPhotosLabel.topAnchor, constant: 5),
                
                noPhotosLabel.leadingAnchor.constraint(equalTo: photosContainer.leadingAnchor, constant: 0),
                noPhotosLabel.trailingAnchor.constraint(equalTo: photosContainer.trailingAnchor, constant: 0),
                noPhotosLabel.bottomAnchor.constraint(equalTo: photosContainer.bottomAnchor, constant: -12),
                noPhotosLabel.heightAnchor.constraint(equalToConstant: 15)
                
            ].forEach({ $0.isActive = true })

            noPhotosImageView.image = UIImage(named: "Landscape-Gray")
            noPhotosImageView.contentMode = .scaleAspectFit
            
            noPhotosLabel.text = "No Photos Yet"
            noPhotosLabel.textColor = UIColor(hexString: "222222")
            noPhotosLabel.textAlignment = .center
            noPhotosLabel.font = UIFont(name: "Poppins-SemiBold", size: 14)
        }
        
        else {
            
            noPhotosImageView.removeFromSuperview()
            noPhotosLabel.removeFromSuperview()
        }
    }
}

extension PhotosPresentationCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return photoIDs?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photosPresentationCollectionViewCell", for: indexPath) as! PhotosPresentationCollectionViewCell
        
        if block == nil {
            
            cell.collabID = collab?.collabID
            cell.photoID = collab?.photoIDs[indexPath.row]
            cell.photo = collab?.photos[collab!.photoIDs[indexPath.row]] ?? nil
        }
        
        else {
            
            cell.collabID = collab?.collabID
            cell.blockID = block?.blockID
            cell.photoID = block?.photoIDs?[indexPath.row]
            cell.photo = block?.photos?[block!.photoIDs?[indexPath.row] ?? ""] ?? nil
        }
        
        cell.imageViewCornerRadius = 8
        
        cell.cachePhotoDelegate = cachePhotoDelegate
        cell.presentCopiedAnimationDelegate = presentCopiedAnimationDelegate
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! PhotosPresentationCollectionViewCell
        
        if let viewController = zoomInDelegate as? CollabViewController {
            
            viewController.zoomingMethods = ZoomingImageViewMethods(on: cell.photoImageView, cornerRadius: 8)
            viewController.zoomingMethods?.performZoom()
        }
        
        else if let viewController = zoomInDelegate as? SelectedBlockViewController {
            
            viewController.zoomingMethods = ZoomingImageViewMethods(on: cell.photoImageView, cornerRadius: 8)
            viewController.zoomingMethods?.performZoom()
        }
    }
}
