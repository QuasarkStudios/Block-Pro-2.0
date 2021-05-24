//
//  ConvoScheduleInfoCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 5/22/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit

class ConvoScheduleInfoCell: UITableViewCell {

    let scheduleContainer = UIView()
    let noSchedulesImageView = UIImageView(image: UIImage(named: "no-schedule"))
    let noScheduleLabel = UILabel()
    let scheduleCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    
    var formatter: DateFormatter?
    
    var members: [Member]?
    
    var scheduleMessages: [Message]? {
        didSet {
            
            if scheduleMessages?.count ?? 0 == 0 {
                
                noSchedulesImageView.isHidden = false
                noScheduleLabel.isHidden = false
                
                scheduleCollectionView.isHidden = true
                scheduleCollectionView.reloadData()
            }
            
            else {
                
                noSchedulesImageView.isHidden = true
                noScheduleLabel.isHidden = true
                
                scheduleCollectionView.isHidden = false
                scheduleCollectionView.reloadData()
            }
        }
    }
    
    weak var scheduleDelegate: ScheduleProtocol?
    
    override init (style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "convoScheduleInfoCell")
        
        configureScheduleContainer()
        configureNoSchedulesImageView()
        configureNoScheduleLabel()
        configureCollectionView(scheduleCollectionView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Configure Schedule Container
    
    private func configureScheduleContainer () {
        
        self.contentView.addSubview(scheduleContainer)
        scheduleContainer.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            scheduleContainer.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
            scheduleContainer.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20),
            scheduleContainer.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10),
            scheduleContainer.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
        
        scheduleContainer.backgroundColor = .white
        scheduleContainer.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
        scheduleContainer.layer.borderWidth = 1
        scheduleContainer.layer.cornerCurve = .continuous
        scheduleContainer.layer.cornerRadius = 10
    }
    
    
    //MARK: - Configure No Schedules Image View
    
    private func configureNoSchedulesImageView () {
        
        scheduleContainer.addSubview(noSchedulesImageView)
        noSchedulesImageView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            noSchedulesImageView.leadingAnchor.constraint(equalTo: scheduleContainer.leadingAnchor, constant: 20),
            noSchedulesImageView.trailingAnchor.constraint(equalTo: scheduleContainer.trailingAnchor, constant: -20),
            noSchedulesImageView.topAnchor.constraint(equalTo: scheduleContainer.topAnchor, constant: 0),
            noSchedulesImageView.bottomAnchor.constraint(equalTo: scheduleContainer.bottomAnchor, constant: -15)
        
        ].forEach({ $0.isActive = true })
        
        noSchedulesImageView.contentMode = .scaleAspectFit
    }
    
    
    //MARK: - Configure No Schedule Label
    
    private func configureNoScheduleLabel () {
        
        scheduleContainer.addSubview(noScheduleLabel)
        noScheduleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            noScheduleLabel.leadingAnchor.constraint(equalTo: scheduleContainer.leadingAnchor, constant: 20),
            noScheduleLabel.trailingAnchor.constraint(equalTo: scheduleContainer.trailingAnchor, constant: -20),
            noScheduleLabel.topAnchor.constraint(equalTo: noSchedulesImageView.bottomAnchor, constant: -10),
            noScheduleLabel.heightAnchor.constraint(equalToConstant: 15)
        
        ].forEach({ $0.isActive = true })
        
        noScheduleLabel.font = UIFont(name: "Poppins-SemiBold", size: 14)
        noScheduleLabel.textAlignment = .center
        noScheduleLabel.textColor = UIColor(hexString: "222222")
        noScheduleLabel.text = "No Schedules Yet"
    }
    
    
    //MARK: - Configure Collection View
    
    private func configureCollectionView(_ collectionView: UICollectionView) {
        
        scheduleContainer.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            collectionView.leadingAnchor.constraint(equalTo: scheduleContainer.leadingAnchor, constant: 1),
            collectionView.trailingAnchor.constraint(equalTo: scheduleContainer.trailingAnchor, constant: -1),
            collectionView.topAnchor.constraint(equalTo: scheduleContainer.topAnchor, constant: 1),
            collectionView.bottomAnchor.constraint(equalTo: scheduleContainer.bottomAnchor, constant: -1)
        
        ].forEach({ $0.isActive = true })
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.backgroundColor = .white
        collectionView.isScrollEnabled = false
        collectionView.delaysContentTouches = false
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: floor(itemSize - 1), height: floor(itemSize - 1))
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.scrollDirection = .vertical
        
        collectionView.collectionViewLayout = layout
        
        collectionView.register(ConvoScheduleCollectionViewCell.self, forCellWithReuseIdentifier: "convoScheduleCollectionViewCell")
    }
}


//MARK: - UICollectionView DataSource and Delegate Extension

extension ConvoScheduleInfoCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return scheduleMessages?.count ?? 0 <= 6 ? scheduleMessages?.count ?? 0 : 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "convoScheduleCollectionViewCell", for: indexPath) as! ConvoScheduleCollectionViewCell
        
        cell.formatter = formatter
        cell.members = members
        cell.message = scheduleMessages?[indexPath.row]
        
        cell.layer.cornerRadius = 10
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let message = scheduleMessages?[indexPath.row] {
            
            scheduleDelegate?.moveToScheduleView(message: message)
        }
    }
}
