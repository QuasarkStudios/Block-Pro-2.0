//
//  ConversationPhotosViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 7/10/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class ConversationPhotosViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var photosCollectionView: UICollectionView!
    
    let firebaseMessaging = FirebaseMessaging.sharedInstance
    
    var conversationID: String?
    var collabID: String?
    
    var photoMessages: [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navBar.configureNavBar()
        
        configureCollectionView(collectionView: photosCollectionView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        monitorPersonalConversationMessages()
    }
    
    override func didReceiveMemoryWarning() {
        
        var count = 0
        
        while count < photoMessages.count {
            
            photoMessages[count].messagePhoto?["photo"] = nil
            
            count += 1
        }
    }
    
    private func configureCollectionView (collectionView: UICollectionView) {
        
        photosCollectionView.dataSource = self
        photosCollectionView.delegate = self
        
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
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! ConvoPhotoCollectionViewCell
        
        performZoomOnPhotoImageView(photoImageView: cell.imageView)
    }
    
    private func monitorPersonalConversationMessages () {
        
        guard let conversation = conversationID else { return }
        
            firebaseMessaging.retrieveAllPersonalMessages(conversationID: conversation) { [weak self] (messages, error) in
                
                if error != nil {
                    
                    print(error as Any)
                }
                
                else {
                    
                    let photoMessages = self?.filterPhotoMessages(messages: messages)
                    
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
    
    private func filterPhotoMessages (messages: [Message]?) -> [Message] {
        
        var messagesWithPhotos: [Message] = []
        
        for message in messages ?? [] {
            
            if message.messagePhoto != nil {
                
                messagesWithPhotos.append(message)
            }
        }
        
        return messagesWithPhotos
    }
    
    var zoomedOutImageView: UIImageView?
    var zoomedOutImageViewFrame: CGRect?
    
    var blackBackground: UIView?
    var zoomedInImageView: UIImageView?
    var zoomedInImageViewFrame: CGRect?
    
    var panGesture: UIPanGestureRecognizer?
    
    private func performZoomOnPhotoImageView (photoImageView: UIImageView) {
        
        self.zoomedOutImageView = photoImageView
        
        blackBackground = UIView(frame: UIScreen.main.bounds)
        blackBackground?.backgroundColor = .clear
        
        blackBackground?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOutOnPhotoImageView)))
        
        UIApplication.shared.keyWindow?.addSubview(blackBackground!)
        
        if let startingFrame = photoImageView.superview?.convert(photoImageView.frame, to: blackBackground!) {
            
            zoomedOutImageViewFrame = startingFrame
            
            let zoomingImageView = UIImageView(frame: zoomedOutImageViewFrame!)
            zoomingImageView.contentMode = .scaleAspectFill
            zoomingImageView.image = photoImageView.image
            zoomingImageView.clipsToBounds = true
            
            zoomingImageView.isUserInteractionEnabled = true
            zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOutOnPhotoImageView)))
            
            UIApplication.shared.keyWindow?.addSubview(zoomingImageView)
            zoomedInImageView = zoomingImageView
            
            photoImageView.isHidden = true
            
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                
                self.blackBackground?.backgroundColor = .black
                
                let photoWidth = photoImageView.image?.size.width
                let photoHeight = photoImageView.image?.size.height
                let height = (photoHeight! / photoWidth!) * self.view.frame.width
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: height)
                zoomingImageView.center = self.blackBackground!.center
                
            }) { (finished: Bool) in
                
                self.zoomedInImageViewFrame = self.zoomedInImageView?.frame
                
                self.addPhotoImageViewPanGesture(imageView: self.zoomedInImageView)
            }
        }
    }
    
    @objc private func handleZoomOutOnPhotoImageView () {
        
        if let imageView = zoomedInImageView {
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                
                self.blackBackground?.backgroundColor = .clear
                
                imageView.frame = self.zoomedOutImageViewFrame!
                
            }) { (finished: Bool) in
                
                self.zoomedOutImageView?.isHidden = false
                self.blackBackground?.removeFromSuperview()
                imageView.removeFromSuperview()
            }
        }
    }
    
    private func addPhotoImageViewPanGesture (imageView: UIImageView?) {
        
        if imageView != nil {
            
            panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePhotoImageViewPan(sender:)))
            
            imageView?.addGestureRecognizer(panGesture!)
        }
    }
    
    @objc private func handlePhotoImageViewPan (sender: UIPanGestureRecognizer) {
        
        switch sender.state {
            
        case .began, .changed:
            
            movePhotoImageViewWithPan(sender: sender)
            
        case .ended:
            
            if (zoomedInImageView?.frame.minY ?? 0 > (self.blackBackground!.frame.height / 2)) {
                
                handleZoomOutOnPhotoImageView()
            }
            
            else if (zoomedInImageView?.frame.minY ?? 0 < (self.blackBackground!.frame.height / 2)) {
                
                handleZoomOutOnPhotoImageView()
            }
            
            else {
                
                returnPhotoImageViewToOrigin()
            }
            
        default:
            break
        }
    }
    
    private func movePhotoImageViewWithPan (sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: self.blackBackground ?? nil)
        
        if let imageView = zoomedInImageView {
            
            let translatedMinYCoord = imageView.frame.minY + translation.y
            let translatedMinXCoord = imageView.frame.minX + translation.x
            let translatedMaxYCoord = imageView.frame.maxY + translation.y
            
            imageView.frame = CGRect(x: translatedMinXCoord, y: translatedMinYCoord, width: imageView.frame.width, height: imageView.frame.height)
            
            if let backgroundView = blackBackground, let zoomedInMinYCoord = zoomedInImageViewFrame?.minY, let zoomedInMaxYCoord = zoomedInImageViewFrame?.maxY {
                
                if translatedMinYCoord > zoomedInMinYCoord {
                    
                    let originalMinYDistanceToBottom = view.frame.height - zoomedInMinYCoord
                    let adjustedMinYDistanceToBottom = abs((translatedMinYCoord - (view.frame.height - originalMinYDistanceToBottom)) - originalMinYDistanceToBottom) //tricky but it works
                    let alphaPart = (1 / originalMinYDistanceToBottom)
                    
                    backgroundView.backgroundColor = UIColor.black.withAlphaComponent(alphaPart * adjustedMinYDistanceToBottom)
                }
                
                else if translatedMinYCoord < zoomedInMinYCoord {
                    
                    let alphaPart = (1 / zoomedInMaxYCoord)
                    backgroundView.backgroundColor = UIColor.black.withAlphaComponent(alphaPart * translatedMaxYCoord)
                }
            }
            
            sender.setTranslation(CGPoint.zero, in: self.blackBackground ?? nil)
        }
    }
    
    private func returnPhotoImageViewToOrigin () {
        
        if let imageView = zoomedInImageView, let imageViewFrame = zoomedInImageViewFrame {
            
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                
                self.blackBackground?.backgroundColor = .black
                
                imageView.frame = imageViewFrame
            })
        }
    }
    
    @IBAction func doneButton(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
}

extension ConversationPhotosViewController: CachePhotoProtocol {
    
    func cachePhoto(messageID: String, photo: UIImage?) {
        
        if let messageIndex = photoMessages.firstIndex(where: { $0.messageID == messageID }) {
            
            photoMessages[messageIndex].messagePhoto?["photo"] = photo
        }
    }
}
