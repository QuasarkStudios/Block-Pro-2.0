//
//  SelectedBlockStatusCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 1/25/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit

class SelectedBlockStatusCell: UITableViewCell {

    let statusLabel = UILabel()
    let statusContainer = UIView()
    let statusCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    
    let firebaseBlock = FirebaseBlock()
    
    var collab: Collab?
    var block: Block? {
        didSet {
            
            statusCollectionView.reloadData()
        }
    }
    
    var statuses: [BlockStatus] = []
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "selectedBlockStatusCell")
        
        configureStatusLabel()
        configureStatusContainer()
        configureCollectionView(statusCollectionView)
        
        BlockStatus.allCases.forEach { (status) in
            
            statuses.append(status)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureStatusLabel () {
        
        self.contentView.addSubview(statusLabel)
        statusLabel.configureTitleLabelConstraints()
        
        statusLabel.font = UIFont(name: "Poppins-SemiBold", size: 15)
        statusLabel.textColor = .black
        statusLabel.textAlignment = .left
        statusLabel.text = "Status"
    }
    
    private func configureStatusContainer () {
        
        self.contentView.addSubview(statusContainer)
        statusContainer.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            statusContainer.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
            statusContainer.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20),
            statusContainer.topAnchor.constraint(equalTo: self.statusLabel.bottomAnchor, constant: 10),
            statusContainer.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
        
        statusContainer.backgroundColor = .white
        
        statusContainer.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
        statusContainer.layer.borderWidth = 1

        statusContainer.layer.cornerRadius = 10
        statusContainer.layer.cornerCurve = .continuous
        statusContainer.clipsToBounds = true
    }
    
    private func configureCollectionView (_ collectionView: UICollectionView) {
        
        statusContainer.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            collectionView.leadingAnchor.constraint(equalTo: statusContainer.leadingAnchor, constant: 0),
            collectionView.trailingAnchor.constraint(equalTo: statusContainer.trailingAnchor, constant: 0),
            collectionView.topAnchor.constraint(equalTo: statusContainer.topAnchor, constant: 0),
            collectionView.bottomAnchor.constraint(equalTo: statusContainer.bottomAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delaysContentTouches = false
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 120, height: 40)
        layout.minimumInteritemSpacing = 20
        layout.minimumLineSpacing = 20
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        layout.scrollDirection = .horizontal
        
        collectionView.collectionViewLayout = layout
        
        collectionView.register(BlockStatusCollectionViewCell.self, forCellWithReuseIdentifier: "blockStatusCollectionViewCell")
    }
}

extension SelectedBlockStatusCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "blockStatusCollectionViewCell", for: indexPath) as! BlockStatusCollectionViewCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        //Setting the status and selecting/deselecting each cell from here will ensure the cell is reset every time it is going to appear
        if let statusCell = cell as? BlockStatusCollectionViewCell {
            
            statusCell.status = statuses[indexPath.row]

            if block?.status == statuses[indexPath.row] {

                statusCell.selectContainer(animate: false)
                statusCell.statusSelected = true
            }

            else if statusCell.statusSelected {

                statusCell.deselectContainer(animate: false)
                statusCell.statusSelected = false
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! BlockStatusCollectionViewCell
        
        if !cell.statusSelected {
            
            cell.selectContainer(animate: true)
            cell.statusSelected = true
            
            if cell.status != nil {
                
                block?.status = cell.status!
                
                if let collabID = collab?.collabID, let blockID = block?.blockID, let status = block?.status {
                    
                    //Setting the block status
                    firebaseBlock.setCollabBlockStatus(collabID, blockID: blockID, status: status) { (error) in
                        
                        print(error?.localizedDescription as Any)
                    }
                }
            }
            
            //Deselecting all the other cells if they were selected
            for visibleCell in collectionView.visibleCells {
                
                if let cell = visibleCell as? BlockStatusCollectionViewCell {
                    
                    if cell.status != block?.status && cell.statusSelected == true {
                        
                        cell.deselectContainer(animate: true)
                        cell.statusSelected = false
                    }
                }
            }
        }
    }
}
