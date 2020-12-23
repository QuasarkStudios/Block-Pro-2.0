//
//  CollabHomeLinksCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 12/13/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import FavIcon

class CollabHomeLinksCell: UITableViewCell {

    let linkContainer = UIView()
    let linkCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    let linkPageControl = UIPageControl()
    
    lazy var noLinksImageView = UIImageView(image: UIImage(named: "link")?.withRenderingMode(.alwaysTemplate))
    lazy var noLinksLabel = UILabel()
    
    var links: [Link]? {
        didSet {
            
            //Sorting the links by either the name of the link if it's available or the text of the URL
            links = links?.sorted(by: { ($0.name ?? $0.url)! < ($1.name ?? $1.url)! })
            
            reconfigureCell()
        }
    }
    
    weak var cacheIconDelegate: CacheIconProtocol?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "collabHomeLinksCell")
        
        configureLinkContainer()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Configure Link Container
    
    private func configureLinkContainer () {
        
        self.contentView.addSubview(linkContainer)
        linkContainer.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            linkContainer.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
            linkContainer.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20),
            linkContainer.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10),
            linkContainer.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10)
        
        ].forEach({ $0.isActive = true })
        
        linkContainer.backgroundColor = .white
        
        linkContainer.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
        linkContainer.layer.borderWidth = 1

        linkContainer.layer.cornerRadius = 10
        linkContainer.layer.cornerCurve = .continuous
        linkContainer.clipsToBounds = true
    }
    
    
    //MARK: - Configure Memo CollectionView
    
    private func configureLinkCollectionView () {
        
        linkContainer.addSubview(linkCollectionView)
        linkCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            linkCollectionView.leadingAnchor.constraint(equalTo: linkContainer.leadingAnchor, constant: 0),
            linkCollectionView.trailingAnchor.constraint(equalTo: linkContainer.trailingAnchor, constant: 0),
            linkCollectionView.topAnchor.constraint(equalTo: linkContainer.topAnchor, constant: 10),
            linkCollectionView.heightAnchor.constraint(equalToConstant: 80)
    
        ].forEach({ $0.isActive = true })
        
        linkCollectionView.dataSource = self
        linkCollectionView.delegate = self
        
        linkCollectionView.backgroundColor = .white
        linkCollectionView.showsHorizontalScrollIndicator = false
        linkCollectionView.isPagingEnabled = true
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 40, height: 80) //Width is the entire width of the linkContainer
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.scrollDirection = .horizontal
        
        linkCollectionView.collectionViewLayout = layout
        
        linkCollectionView.register(CollabHomeLinkCollectionViewCell.self, forCellWithReuseIdentifier: "collabHomeLinkCollectionViewCell")
    }
    
    
    //MARK: - Configure Link Page Control
    
    private func configureLinkPageControl () {
        
        if links?.count ?? 0 > 2 {
            
            if linkPageControl.superview == nil {
                
                linkContainer.addSubview(linkPageControl)
                linkPageControl.translatesAutoresizingMaskIntoConstraints = false
                
                [
                
                    linkPageControl.topAnchor.constraint(equalTo: linkCollectionView.bottomAnchor, constant: 7.5),
                    linkPageControl.centerXAnchor.constraint(equalTo: linkContainer.centerXAnchor),
                    linkPageControl.widthAnchor.constraint(equalToConstant: 125),
                    linkPageControl.heightAnchor.constraint(equalToConstant: 27.5)
                
                ].forEach({ $0.isActive = true })
                
                if links?.count ?? 0 >= 3 && links?.count ?? 0 < 5 {
                    
                    linkPageControl.numberOfPages = 2
                }
                
                else if links?.count ?? 0 >= 5 {
                    
                    linkPageControl.numberOfPages = 3
                }
                
                linkPageControl.pageIndicatorTintColor = UIColor(hexString: "D8D8D8")
                linkPageControl.currentPageIndicatorTintColor = UIColor(hexString: "222222")
                linkPageControl.currentPage = linkCollectionView.indexPathsForVisibleItems.first?.row ?? 0
                
                linkPageControl.addTarget(self, action: #selector(pageSelected), for: .valueChanged)
            }
        }
        
        else {
            
            linkPageControl.removeFromSuperview()
        }
    }
    
    
    //MARK: - Reconfigure Cell
    
    private func reconfigureCell () {
        
        if links?.count ?? 0 == 0 {
            
            configureNoLinksCell()
        }
        
        else {
            
            configureLinkCollectionView()
            configureLinkPageControl()
        }
    }
    
    
    //MARK: - Configure No Voice Memos Cell
    
    private func configureNoLinksCell () {
        
        linkCollectionView.removeFromSuperview()
        linkPageControl.removeFromSuperview()
        
        self.contentView.addSubview(noLinksImageView)
        noLinksImageView.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView.addSubview(noLinksLabel)
        noLinksLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            noLinksImageView.leadingAnchor.constraint(equalTo: linkContainer.leadingAnchor, constant: 0),
            noLinksImageView.trailingAnchor.constraint(equalTo: linkContainer.trailingAnchor, constant: 0),
            noLinksImageView.topAnchor.constraint(equalTo: linkContainer.topAnchor, constant: 16),
            noLinksImageView.bottomAnchor.constraint(equalTo: noLinksLabel.topAnchor, constant: -18),
            
            noLinksLabel.leadingAnchor.constraint(equalTo: linkContainer.leadingAnchor, constant: 0),
            noLinksLabel.trailingAnchor.constraint(equalTo: linkContainer.trailingAnchor, constant: 0),
            noLinksLabel.bottomAnchor.constraint(equalTo: linkContainer.bottomAnchor, constant: -12),
            noLinksLabel.heightAnchor.constraint(equalToConstant: 15)
        
        ].forEach({ $0.isActive = true })
        
        noLinksImageView.contentMode = .scaleAspectFit
        noLinksImageView.tintColor = UIColor(hexString: "A9A9A9")
        
        noLinksLabel.text = "No Links Yet"
        noLinksLabel.textColor = UIColor(hexString: "222222")
        noLinksLabel.textAlignment = .center
        noLinksLabel.font = UIFont(name: "Poppins-SemiBold", size: 14)
    }
    
    
    //MARK: - Page Selected
    
    @objc private func pageSelected () {
        
        linkCollectionView.scrollToItem(at: IndexPath(item: linkPageControl.currentPage, section: 0), at: .centeredHorizontally, animated: true)
    }
}


//MARK: - CollectionView Extension

extension CollabHomeLinksCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let links = links {
            
            if links.count == 0 {
                
                return 0
            }
            
            else if links.count < 3 {
                
                return 1
            }
            
            else if links.count < 5 {
                
                return 2
            }
            
            else {
                
                return 3
            }
        }
        
        else {
            
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collabHomeLinkCollectionViewCell", for: indexPath) as! CollabHomeLinkCollectionViewCell
        
        cell.cacheIconDelegate = cacheIconDelegate
        
        if indexPath.row == 0 {
            
            cell.leftLink = links?[0]
            cell.rightLink = links?.count ?? 0 > 1 ? links?[1] : nil
        }
        
        else if indexPath.row == 1 {
            
            cell.leftLink = links?[2]
            cell.rightLink = links?.count ?? 0 > 3 ? links?[3] : nil
        }
        
        else if indexPath.row == 2 {
            
            cell.leftLink = links?[4]
            cell.rightLink = links?.count ?? 0 > 5 ? links?[5] : nil
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

        linkPageControl.currentPage = indexPath.row
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        //Backup check in case the paging of collectionView wasn't completed and the collectionView returned to the index it was at before it was scrolled
        linkPageControl.currentPage = linkCollectionView.indexPathsForVisibleItems.first?.row ?? 0
    }
}
