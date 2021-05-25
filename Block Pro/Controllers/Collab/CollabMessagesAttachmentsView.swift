//
//  CollabMessagesAttachmentsView.swift
//  Block Pro
//
//  Created by Nimat Azeez on 10/5/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import SVProgressHUD

class CollabMessagesAttachmentsView: UIViewController {
    
    @IBOutlet weak var photos_schedulesSegmentIndicator: UISegmentedControl!
    @IBOutlet weak var photos_schedulesCollectionView: UICollectionView!
    
    let noAttachmentsImageView = UIImageView()
    let noAttachmentsLabel = UILabel()
    
    var copiedAnimationView: CopiedAnimationView?
    
    let firebaseMessaging = FirebaseMessaging()
    
    let formatter = DateFormatter()
    
    var zoomingMethods: ZoomingImageViewMethods?
    
    var collab: Collab?
    var photoMessages: [Message] = []
    var scheduleMessages: [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.configureNavBar()
        
        configureCollectionView(collectionView: photos_schedulesCollectionView)
        configureNoAttachmentsImageView()
        configureNoAttachmentsLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        monitorCollabMessages()
        
        copiedAnimationView = CopiedAnimationView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        firebaseMessaging.messageListener?.remove()
        
        copiedAnimationView?.removeCopiedAnimation(remove: true)
    }
    
    override func didReceiveMemoryWarning() {
        
        var count = 0
        
        while count < photoMessages.count {
            
            photoMessages[count].messagePhoto?["photo"] = nil
            
            count += 1
        }
    }
    
    
    //MARK: - Configure Collection View
    
    private func configureCollectionView (collectionView: UICollectionView) {
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        //Appropriate item size based on factoring in the interitem and line spacing as well as the sections insets
        let itemSize = (UIScreen.main.bounds.size.width - 8) / 3
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        layout.sectionInset = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
        layout.scrollDirection = .vertical
        
        collectionView.collectionViewLayout = layout
        
        collectionView.register(UINib(nibName: "ConvoPhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "convoPhotoCollectionViewCell")
        collectionView.register(ConvoScheduleCollectionViewCell.self, forCellWithReuseIdentifier: "convoScheduleCollectionViewCell")
    }
    
    
    //MARK: - Configure No Attachments Image View
    
    private func configureNoAttachmentsImageView () {
        
        let imageViewDimensionsConstant = UIScreen.main.bounds.width - 50
        
        self.view.addSubview(noAttachmentsImageView)
        noAttachmentsImageView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            noAttachmentsImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
            noAttachmentsImageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? -50 : -35), //Guesstimating
            noAttachmentsImageView.widthAnchor.constraint(equalToConstant: imageViewDimensionsConstant),
            noAttachmentsImageView.heightAnchor.constraint(equalToConstant: imageViewDimensionsConstant)
            
        ].forEach({ $0.isActive = true })
        
        noAttachmentsImageView.alpha = photoMessages.count > 0 ? 0 : 1
        noAttachmentsImageView.contentMode = .scaleAspectFit
        noAttachmentsImageView.image = UIImage(named: "Landscape-Blue")
    }
    
    
    //MARK: - Configure No Attachments Label
    
    private func configureNoAttachmentsLabel () {
        
        self.view.addSubview(noAttachmentsLabel)
        noAttachmentsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            noAttachmentsLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            noAttachmentsLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            noAttachmentsLabel.topAnchor.constraint(equalTo: noAttachmentsImageView.bottomAnchor, constant: 0),
            noAttachmentsLabel.heightAnchor.constraint(equalToConstant: 70)
            
        ].forEach({ $0.isActive = true })
        
        noAttachmentsLabel.alpha = photoMessages.count > 0 ? 0 : 1
        noAttachmentsLabel.numberOfLines = 0
        noAttachmentsLabel.font = UIFont(name: "Poppins-SemiBold", size: 25)
        noAttachmentsLabel.textAlignment = .center
        noAttachmentsLabel.text = "No Photos\nYet"
    }
    
    
    //MARK: - Monitor Collab Messages
    
    private func monitorCollabMessages () {
        
        guard let collabID = collab?.collabID else { return }
        
            firebaseMessaging.retrieveAllCollabMessages(collabID: collabID) { [weak self] (messages, error) in
                
                if error != nil {
                    
                    SVProgressHUD.showError(withStatus: error?.localizedDescription)
                }
                
                else {
                    
                    self?.retrieveNewPhotoMessages(self?.firebaseMessaging.filterPhotoMessages(messages: messages))
                    self?.retrieveNewScheduleMessages(self?.firebaseMessaging.filterScheduleMessages(messages: messages))
                }
            }
    }
    
    
    //MARK: - Retrieve New Photo Messages
    
    private func retrieveNewPhotoMessages (_ updatedPhotoMessages: [Message]?) {
        
        //New photo messages retrieved
        if updatedPhotoMessages?.count != photoMessages.count {
            
            for message in updatedPhotoMessages ?? [] {
                
                //If a certain message isn't located in the array
                if photoMessages.contains(where: { $0.messageID == message.messageID }) == false {
                    
                    photoMessages.append(message)
                }
            }
            
            photoMessages.sort(by: { $0.timestamp > $1.timestamp })
            
            //If the collectionView is currently displaying photos
            if photos_schedulesSegmentIndicator.selectedSegmentIndex == 0 {
                
                //If this is the first photo sent in this conversation
                if noAttachmentsImageView.alpha == 1 {
                    
                    UIView.transition(with: self.view, duration: 0.3, options: .transitionCrossDissolve) {
                        
                        self.photos_schedulesCollectionView.reloadData()
                        
                        self.noAttachmentsImageView.alpha = 0
                        self.noAttachmentsLabel.alpha = 0
                    }
                }
                
                else {
                    
                    photos_schedulesCollectionView.reloadData()
                }
            }
        }
    }
    
    
    //MARK: - Retrieve New Schedule Messages
    
    private func retrieveNewScheduleMessages (_ updatedScheduleMessages: [Message]?) {
        
        //New schedule messages retrieved
        if updatedScheduleMessages?.count != scheduleMessages.count {
            
            if let messages = updatedScheduleMessages {
                
                scheduleMessages = messages.sorted(by: { $0.timestamp > $1.timestamp })
                
                //If the collectionView is currently displaying schedules
                if photos_schedulesSegmentIndicator.selectedSegmentIndex == 1 {
                    
                    //If this is the first schedule sent in this conversation
                    if noAttachmentsImageView.alpha == 1 {
                        
                        UIView.transition(with: self.view, duration: 0.3, options: .transitionCrossDissolve) {
                            
                            self.photos_schedulesCollectionView.reloadData()
                            
                            self.noAttachmentsImageView.alpha = 0
                            self.noAttachmentsLabel.alpha = 0
                        }
                    }
                    
                    else {
                        
                        photos_schedulesCollectionView.reloadData()
                    }
                }
            }
        }
    }
    
    
    //MARK: - Move to Schedule View
    
    private func moveToScheduleView (message: Message) {
        
        let scheduleVC = ScheduleMessageViewController()
        scheduleVC.message = message
        scheduleVC.members = collab?.historicMembers
        
        self.navigationController?.pushViewController(scheduleVC, animated: true)
        
        let backBarItem = UIBarButtonItem()
        backBarItem.title = ""
        self.navigationItem.backBarButtonItem = backBarItem
    }
    
    
    //MARK: - Segment Control Action
    
    @IBAction func photos_schedulesSegmentedControl (_ sender: Any) {
        
        if photos_schedulesSegmentIndicator.selectedSegmentIndex == 0 {
            
            UIView.transition(with: self.view, duration: 0.3, options: .transitionCrossDissolve) {
                
                self.photos_schedulesCollectionView.reloadData()
                
                self.noAttachmentsImageView.image = UIImage(named: "Landscape-Blue")
                self.noAttachmentsLabel.text = "No Photos\nYet"
                
                self.noAttachmentsImageView.alpha = self.photoMessages.count > 0 ? 0 : 1
                self.noAttachmentsLabel.alpha = self.photoMessages.count > 0 ? 0 : 1
            }
        }
        
        else {
            
            UIView.transition(with: self.view, duration: 0.3, options: .transitionCrossDissolve) {
                
                self.photos_schedulesCollectionView.reloadData()
                
                self.noAttachmentsImageView.image = UIImage(named: "schedule-1")
                self.noAttachmentsLabel.text = "No Schedules\nYet"
                
                self.noAttachmentsImageView.alpha = self.scheduleMessages.count > 0 ? 0 : 1
                self.noAttachmentsLabel.alpha = self.scheduleMessages.count > 0 ? 0 : 1
            }
        }
    }
    
    
    //MARK: - Cancel Button Pressed
    
    @IBAction func cancelButtonPressed (_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
}


//MARK: - CollectionView DataSource and Delegate Extension

extension CollabMessagesAttachmentsView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return photos_schedulesSegmentIndicator.selectedSegmentIndex == 0 ? photoMessages.count : scheduleMessages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //Photo cells should be used
        if photos_schedulesSegmentIndicator.selectedSegmentIndex == 0 {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "convoPhotoCollectionViewCell", for: indexPath) as! ConvoPhotoCollectionViewCell
            
            cell.collabID = collab?.collabID
            
            cell.message = photoMessages[indexPath.row]
            
            cell.imageViewCornerRadius = 0
            
            cell.cachePhotoDelegate = self
            cell.presentCopiedAnimationDelegate = self
            
            return cell
        }
        
        //Schedule cells should be used
        else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "convoScheduleCollectionViewCell", for: indexPath) as! ConvoScheduleCollectionViewCell
            
            cell.formatter = formatter
            cell.members = collab?.historicMembers
            cell.message = scheduleMessages[indexPath.row]
            
            cell.layer.cornerRadius = 0
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let cell = collectionView.cellForItem(at: indexPath) as? ConvoPhotoCollectionViewCell {
            
            zoomingMethods = ZoomingImageViewMethods(on: cell.imageView, cornerRadius: 0)
            zoomingMethods?.performZoom()
        }
        
        else {
            
            moveToScheduleView(message: scheduleMessages[indexPath.row])
        }
    }
}


//MARK: - CachePhotoProtocol Extension

extension CollabMessagesAttachmentsView: CachePhotoProtocol {
    
    func cacheMessagePhoto(messageID: String, photo: UIImage?) {
        
        if let messageIndex = photoMessages.firstIndex(where: { $0.messageID == messageID }) {
            
            photoMessages[messageIndex].messagePhoto?["photo"] = photo
        }
    }
    
    func cacheCollabPhoto(photoID: String, photo: UIImage?) {}
    
    func cacheBlockPhoto(photoID: String, photo: UIImage?) {}
}


//MARK: - PresentCopiedAnimationProtocol Extension

extension CollabMessagesAttachmentsView: PresentCopiedAnimationProtocol {
    
    func presentCopiedAnimation() {
        
        if let navBar = self.navigationController?.navigationBar {
            
            let navBarFrame = navBar.convert(navBar.frame, to: keyWindow)
            
            //15 is equal to 5 point top anchor the photosCollectionView has from the navBar plus an extra 10 point buffer
            copiedAnimationView?.presentCopiedAnimation(topAnchor: navBarFrame.maxY + 15)
        }
    }
}
