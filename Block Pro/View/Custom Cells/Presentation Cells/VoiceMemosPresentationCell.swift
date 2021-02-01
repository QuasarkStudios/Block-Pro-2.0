//
//  VoiceMemosPresentationCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 1/25/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit

class VoiceMemosPresentationCell: UITableViewCell {

    let memoLabel = UILabel()
    let memosContainer = UIView()
    let memoCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    
    lazy var noVoiceMemosImageView = UIImageView(image: UIImage(named: "no-voice-memos"))
    lazy var noVoiceMemosLabel = UILabel()
    
    var collab: Collab?
    var block: Block?
    
    var voiceMemos: [VoiceMemo]? {
        didSet {
            
            reconfigureCell(voiceMemos)
        }
    }
    
    override init (style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "voiceMemosPresentationCell")
        
        configureMemoLabel()
        configureMemoContainer()
        configureNotificationObservors()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        
        let voiceMemoPlayer = VoiceMemoPlayer.sharedInstance
        voiceMemoPlayer.stopRecordingPlayback()
        
        for memoCell in memoCollectionView.visibleCells {
            
            //If a cell has had the playbackWorkItem added to the dispatchQueue, it will prevent the "VoiceMemosPresentationCollectionViewCell" from being deinitialized until after the playbackWorkItem was scheduled to be run. Therefore, canceling the playbackWorkItem and setting it to nil when "VoiceMemosPresentationCell" is denitialized is more reliable because this cell has so far always been deinitialized properly
            if let cell = memoCell as? VoiceMemosPresentationCollectionViewCell {
                
                cell.playbackWorkItem?.cancel()
                cell.playbackWorkItem = nil //Prevents memory leaks
            }
        }
        
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Configure Memo Label
    
    private func configureMemoLabel () {
        
        self.contentView.addSubview(memoLabel)
        memoLabel.configureTitleLabelConstraints()
        
        memoLabel.font = UIFont(name: "Poppins-SemiBold", size: 15)
        memoLabel.text = "Voice Memos"
        memoLabel.textColor = .black
        memoLabel.textAlignment = .left
    }
    
    //MARK: - Configure Memo Container
    
    private func configureMemoContainer () {
        
        self.contentView.addSubview(memosContainer)
        memosContainer.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            memosContainer.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
            memosContainer.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20),
            memosContainer.topAnchor.constraint(equalTo: self.memoLabel.bottomAnchor, constant: 10),
            memosContainer.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
        
        memosContainer.backgroundColor = .white
        
        memosContainer.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
        memosContainer.layer.borderWidth = 1

        memosContainer.layer.cornerRadius = 10
        memosContainer.layer.cornerCurve = .continuous
        memosContainer.clipsToBounds = true
    }
    
    
    //MARK: - Configure Memo CollectionView
    
    private func configureMemoCollectionView () {
        
        memosContainer.addSubview(memoCollectionView)
        memoCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            memoCollectionView.leadingAnchor.constraint(equalTo: memosContainer.leadingAnchor, constant: 0),
            memoCollectionView.trailingAnchor.constraint(equalTo: memosContainer.trailingAnchor, constant: 0),
            memoCollectionView.topAnchor.constraint(equalTo: memosContainer.topAnchor, constant: 0),
            memoCollectionView.bottomAnchor.constraint(equalTo: memosContainer.bottomAnchor, constant: 0)
    
        ].forEach({ $0.isActive = true })
        
        memoCollectionView.dataSource = self
        memoCollectionView.delegate = self
        
        memoCollectionView.backgroundColor = .white
        memoCollectionView.isScrollEnabled = false
        memoCollectionView.delaysContentTouches = false
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: floor(itemSize - 1), height: floor(itemSize - 1))
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.scrollDirection = .vertical
        
        memoCollectionView.collectionViewLayout = layout
        
        memoCollectionView.register(VoiceMemosPresentationCollectionViewCell.self, forCellWithReuseIdentifier: "voiceMemosPresentationCollectionViewCell")
    }
    
    
    //MARK: - Reconfigure Cell
    
    private func reconfigureCell (_ voiceMemos: [VoiceMemo]?) {
        
        if voiceMemos?.count ?? 0 == 0 {
            
            configureNoVoiceMemosCell()
        }
        
        else {
            
            configureMemoCollectionView()
        }
    }
    
    
    //MARK: - Configure No Voice Memos Cell
    
    private func configureNoVoiceMemosCell () {
        
        self.contentView.addSubview(noVoiceMemosImageView)
        noVoiceMemosImageView.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView.addSubview(noVoiceMemosLabel)
        noVoiceMemosLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            noVoiceMemosImageView.leadingAnchor.constraint(equalTo: memosContainer.leadingAnchor, constant: 0),
            noVoiceMemosImageView.trailingAnchor.constraint(equalTo: memosContainer.trailingAnchor, constant: 0),
            noVoiceMemosImageView.topAnchor.constraint(equalTo: memosContainer.topAnchor, constant: 13),
            noVoiceMemosImageView.bottomAnchor.constraint(equalTo: noVoiceMemosLabel.topAnchor, constant: -15),
            
            noVoiceMemosLabel.leadingAnchor.constraint(equalTo: memosContainer.leadingAnchor, constant: 0),
            noVoiceMemosLabel.trailingAnchor.constraint(equalTo: memosContainer.trailingAnchor, constant: 0),
            noVoiceMemosLabel.bottomAnchor.constraint(equalTo: memosContainer.bottomAnchor, constant: -12),
            noVoiceMemosLabel.heightAnchor.constraint(equalToConstant: 15)
        
        ].forEach({ $0.isActive = true })
        
        noVoiceMemosImageView.contentMode = .scaleAspectFit
        
        noVoiceMemosLabel.text = "No Voice Memos Yet"
        noVoiceMemosLabel.textColor = UIColor(hexString: "222222")
        noVoiceMemosLabel.textAlignment = .center
        noVoiceMemosLabel.font = UIFont(name: "Poppins-SemiBold", size: 14)
    }
    
    //MARK: - Configure Notification Observors
    
    private func configureNotificationObservors () {
        
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    
    //MARK: - App Did Enter Background
    
    @objc private func appDidEnterBackground () {
        
        for memoCell in memoCollectionView.visibleCells {
            
            if let cell = memoCell as? VoiceMemosPresentationCollectionViewCell {
                
                cell.stopRecordingPlayback()
            }
        }
    }
}

//MARK: - CollectionView Extension

extension VoiceMemosPresentationCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return voiceMemos?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "voiceMemosPresentationCollectionViewCell", for: indexPath) as! VoiceMemosPresentationCollectionViewCell
        
        cell.collab = collab
        cell.block = block
        cell.voiceMemo = voiceMemos?[indexPath.row]
        
        if let name = voiceMemos?[indexPath.row].name {
            
            cell.nameLabel.text = name
        }
        
        else {
            
            cell.voiceMemo?.name = "Memo #\(indexPath.row + 1)" //If a voiceMemo doesn't have a name, the cell will be able to set the nameLabel back correctly after it was changed to the "Loading..." text
            cell.nameLabel.text = "Memo #\(indexPath.row + 1)"
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //Will stop the playback of voiceMemos for other cells if they are ongoing
        for indexPathForVisibleItem in collectionView.indexPathsForVisibleItems {
            
            if indexPathForVisibleItem != indexPath {
                
                let cell = collectionView.cellForItem(at: indexPathForVisibleItem) as! VoiceMemosPresentationCollectionViewCell
                
                cell.shouldPlayRecording = false
                
                if cell.recordingPlaying ?? false {
                    
                    cell.stopRecordingPlayback()
                }
            }
        }
        
        //Starts the process of playing the voiceMemo for the cell tapped
        let cell = collectionView.cellForItem(at: indexPath) as! VoiceMemosPresentationCollectionViewCell
        cell.cellTapped()
    }
}
