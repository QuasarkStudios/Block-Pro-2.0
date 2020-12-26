//
//  ConversationPhotosViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 7/10/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import SVProgressHUD

class ConversationPhotosViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var photosCollectionView: UICollectionView!
    
    var copiedAnimationView: CopiedAnimationView?
    
    let firebaseMessaging = FirebaseMessaging.sharedInstance
    
    var conversationID: String?
    var collabID: String?
    
    var photoMessages: [Message] = []
    
    var zoomingMethods: ZoomingImageViewMethods?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navBar.configureNavBar()
        
        configureCollectionView(collectionView: photosCollectionView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        monitorPersonalConversationMessages()
        monitorCollabConversationMessages()
        
        //Initializing here allows the animationView to be removed and readded multiple times 
        copiedAnimationView = CopiedAnimationView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        copiedAnimationView?.removeCopiedAnimation(remove: true)
        
        firebaseMessaging.messageListener?.remove()
    }
    
    override func didReceiveMemoryWarning() {
        
        var count = 0
        
        while count < photoMessages.count {
            
            photoMessages[count].messagePhoto?["photo"] = nil
            
            count += 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return photoMessages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "convoPhotoCollectionViewCell", for: indexPath) as! ConvoPhotoCollectionViewCell
        
        cell.conversationID = conversationID
        cell.collabID = collabID
        
        cell.message = photoMessages[indexPath.row]
        
        cell.imageViewCornerRadius = 0
        
        cell.cachePhotoDelegate = self
        cell.presentCopiedAnimationDelegate = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! ConvoPhotoCollectionViewCell
        
        zoomingMethods = ZoomingImageViewMethods(on: cell.imageView, cornerRadius: 0)
        zoomingMethods?.performZoom()
    }
    
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
    }
    
    private func monitorPersonalConversationMessages () {
        
        guard let conversation = conversationID else { return }
        
            firebaseMessaging.retrieveAllPersonalMessages(conversationID: conversation) { [weak self] (messages, error) in
                
                if error != nil {
                    
                    SVProgressHUD.showError(withStatus: error?.localizedDescription)
                }
                
                else {
                    
                    let photoMessages = self?.firebaseMessaging.filterPhotoMessages(messages: messages)
                    
                    if photoMessages?.count != self?.photoMessages.count ?? 0 {
                        
                        for message in photoMessages ?? [] {
                            
                            if self?.photoMessages.contains(where: { $0.messageID == message.messageID }) == false {
                                
                                self?.photoMessages.append(message)
                            }
                        }
                        
                        if let sortedMessages = self?.photoMessages.sorted(by: { $0.timestamp > $1.timestamp }) {
                            
                            self?.photoMessages = sortedMessages
                            
                            self?.photosCollectionView.reloadData()
                        }
                    }
                }
            }
    }
    
    private func monitorCollabConversationMessages () {
        
        guard let conversation = collabID else { return }
        
            firebaseMessaging.retrieveAllCollabMessages(collabID: conversation) { [weak self] (messages, error) in
                
                if error != nil {
                    
                    SVProgressHUD.showError(withStatus: error?.localizedDescription)
                }
                
                else {
                    
                    let photoMessages = self?.firebaseMessaging.filterPhotoMessages(messages: messages)
                    
                    if photoMessages?.count != self?.photoMessages.count ?? 0 {
                        
                        for message in photoMessages ?? [] {
                            
                            if self?.photoMessages.contains(where: { $0.messageID == message.messageID }) == false {
                                
                                self?.photoMessages.append(message)
                            }
                        }
                        
                        if let sortedMessages = self?.photoMessages.sorted(by: { $0.timestamp > $1.timestamp }) {
                            
                            self?.photoMessages = sortedMessages
                            
                            self?.photosCollectionView.reloadData()
                        }
                    }
                }
            }
    }
    
    @IBAction func doneButton(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
}

extension ConversationPhotosViewController: CachePhotoProtocol {
    
    func cacheMessagePhoto(messageID: String, photo: UIImage?) {
        
        if let messageIndex = photoMessages.firstIndex(where: { $0.messageID == messageID }) {
            
            photoMessages[messageIndex].messagePhoto?["photo"] = photo
        }
    }
    
    func cacheCollabPhoto(photoID: String, photo: UIImage?) {
    }
}

//MARK: - PresentCopiedAnimation Protocol Extension

extension ConversationPhotosViewController: PresentCopiedAnimationProtocol {
    
    func presentCopiedAnimation() {
        
        let navBarFrame = navBar.convert(navBar.frame, to: keyWindow)
        
        //20 is equal to 10 point top anchor the photosCollectionView has from the navBar plus an extra 10 point buffer
        copiedAnimationView?.presentCopiedAnimation(topAnchor: navBarFrame.maxY + 20)
    }
}
