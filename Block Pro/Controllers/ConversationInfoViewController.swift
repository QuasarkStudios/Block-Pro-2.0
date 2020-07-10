//
//  MessagesInfoViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 6/16/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol MoveToConversationWithMemberProtcol: AnyObject {
    
    func moveToConversationWithMember (_ member: Friend)
}

class ConversationInfoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var messagingInfoTableView: UITableView!
    
    let editCoverButton = UIButton(type: .system)
    let deleteCoverButton = UIButton(type: .system)
    
    let currentUser = CurrentUser.sharedInstance
    let firebaseMessaging = FirebaseMessaging.sharedInstance
    
    var personalConversation: Conversation? {
        didSet {
            
            //messagingInfoTableView.reloadData()
        }
    }
    
    var collabConversation: Conversation? {
        didSet {
            
            //messagingInfoTableView.reloadData()
        }
    }
    
    //var selectedCoverPhoto: UIImage?
    
    var convoName: String?
    
    var membersExpanded: Bool = false
    
    weak var moveToConversationWithMemberDelegate: MoveToConversationWithMemberProtcol?
    
    var topBarHeight: CGFloat {

        return (UIApplication.shared.statusBarFrame.height) + (self.navigationController?.navigationBar.frame.height ?? 0.0)
    }
    
    var viewInitaillyLoaded: Bool = false
    
    var panGesture: UIPanGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundView.backgroundColor = UIColor(hexString: "222222")
        
        self.navigationController?.navigationBar.tintColor = .clear
        
        configureTableView(tableView: messagingInfoTableView)
        
        configureEditCoverButton()
        configureDeleteCoverButton()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.navigationController?.navigationBar.configureNavBar(barBackgroundColor: .clear, barTintColor: .white)
        
        viewInitaillyLoaded = true
            
        if let cell = self.messagingInfoTableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ConvoNameInfoCell {
            
            cell.textFieldContainerCenterYAnchor.constant = 0
            
            UIView.animate(withDuration: 0.3) {

                cell.self.layoutIfNeeded()
            }
        }
        
        messagingInfoTableView.beginUpdates()
        messagingInfoTableView.endUpdates()
        
        monitorPersonalConversation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        updateConversationName(name: convoName)
        
        firebaseMessaging.conversationListener?.remove()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            
            return 1
        }
        
        else if section == 1 {
            
            if let conversation = personalConversation {
                
                return (conversation.members.count - 1) > 1 ? 1 : 0
            }
            
            else if let conversation = collabConversation {
                
                return (conversation.members.count - 1) > 1 ? 1 : 0
            }
            
            return 0
        }
        
        else {
            
            if let conversation = personalConversation {
                
                return ((conversation.members.count - 1) * 2) + 1
            }
            
            else if let conversation = collabConversation {
                
                return ((conversation.members.count - 1) * 2) + 1
            }
                
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "convoCoverInfoCell", for: indexPath) as! ConvoCoverInfoCell
            cell.selectionStyle = .none
            
            cell.personalConversation = personalConversation
            cell.collabConversation = collabConversation
    
            return cell
        }
        
        else if indexPath.section == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "convoNameInfoCell", for: indexPath) as! ConvoNameInfoCell
            cell.selectionStyle = .none
            cell.personalConversation = personalConversation
            cell.collabConversation = collabConversation
            cell.nameEnteredDelegate = self
            
            if viewInitaillyLoaded {
                
                cell.textFieldContainerCenterYAnchor.constant = 0
            }
            
            return cell
        }
        
        else {
            
            if indexPath.row == 0 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "convoMemberHeaderInfoCell", for: indexPath) as! ConvoMemberHeaderInfoCell
                cell.selectionStyle = .none
                
                if let conversation = personalConversation {
                    
                    cell.seeAllLabel.isHidden = (conversation.members.count - 1) > 3 ? false : true
                    cell.arrowIndicator.isHidden = (conversation.members.count - 1) > 3 ? false : true
                }
                
                else if let conversation = collabConversation {
                    
                    cell.seeAllLabel.isHidden = (conversation.members.count - 1) > 3 ? false : true
                    cell.arrowIndicator.isHidden = (conversation.members.count - 1) > 3 ? false : true
                }
                
                return cell
            }
                
            else if indexPath.row % 2 == 0 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "convoMemberInfoCell", for: indexPath) as! ConvoMemberInfoCell
                cell.conversateWithMemberDelegate = self
                
                if let conversation = personalConversation {
                    
                    var filteredMembers = conversation.members
                    filteredMembers.removeAll(where: { $0.userID == currentUser.userID })
                    
                    cell.member = filteredMembers[(indexPath.row / 2) - 1]
                    cell.memberActivity = conversation.memberActivity?[filteredMembers[(indexPath.row / 2) - 1].userID]
                    cell.messageButton.isHidden = filteredMembers.count > 1 ? false : true
                }
                
                else if let conversation = collabConversation {
                    
                    var filteredMembers = conversation.members
                    filteredMembers.removeAll(where: { $0.userID == currentUser.userID })
                    
                    cell.member = filteredMembers[(indexPath.row / 2) - 1]
                    cell.memberActivity = conversation.memberActivity?[filteredMembers[(indexPath.row / 2) - 1].userID]
                    cell.messageButton.isHidden = filteredMembers.count > 1 ? false : true
                }
                
                return cell
            }
            
            else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "seperatorCell", for: indexPath)
                cell.isUserInteractionEnabled = false
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            
            if !viewInitaillyLoaded {
                
                return 0
            }
            
            else {
                
                if personalConversation?.coverPhotoID != nil {
                    
                    return 305
                }
                
                else if collabConversation?.coverPhotoID != nil {
                        
                    return 305
                }
                
                else {
                    
                    return 250
                }
            }
        }
        
        else if indexPath.section == 1 {
            
            return viewInitaillyLoaded ? 100 : 200
        }
        
        else {
            
            if indexPath.row == 0 {
                
                return 25
            }
                
            else if indexPath.row % 2 == 0 {
                
                if (indexPath.row / 2) - 1 < 3 {
                    
                    return 70
                }
                
                else {
                    
                    if membersExpanded {
                        
                        return 70
                    }
                    
                    else {
                        
                        return 0
                    }
                }
            }
            
            else {
                
                if indexPath.row == 1 {
                    
                    return 15
                }
                
                else {
                    
                    return 10
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            
            vibrate()
            
            if let conversation = personalConversation {
                
                if conversation.coverPhotoID != nil {
                    
                    let cell = messagingInfoTableView.cellForRow(at: indexPath) as! ConvoCoverInfoCell
                    
                    if let conversationIndex = firebaseMessaging.personalConversations.firstIndex(where: { $0.conversationID == conversation.conversationID }) {
                        
                        if firebaseMessaging.personalConversations[conversationIndex].conversationCoverPhoto != nil {
                            
                            performZoomOnCoverImageView(coverImageView: cell.coverPhotoImageView)
                        }
                        
                        else {
                            
                            
                        }
                    }
                }
                
                else {
                    
                    addCoverPhoto()
                }
            }
            
            else if let conversation = collabConversation {
                
                if conversation.coverPhotoID != nil {
                    
                    print("has cover")
                }
                
                else {
                    
                    addCoverPhoto()
                }
            }
        }
        
        else if indexPath.section == 2 {
            
            if indexPath.row == 0 {
                
                membersExpanded = !membersExpanded
                
                let cell = tableView.cellForRow(at: indexPath) as! ConvoMemberHeaderInfoCell
                cell.seeAllLabel.text = membersExpanded ? "See less" : "See all"
                cell.transformArrow(expand: membersExpanded)
                
                messagingInfoTableView.beginUpdates()
                messagingInfoTableView.endUpdates()
            }
            
            else {
                
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
    
    private func configureTableView (tableView: UITableView) {
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.separatorStyle = .none
        
        tableView.contentInset = UIEdgeInsets(top: -topBarHeight, left: 0, bottom: 0, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: -topBarHeight, left: 0, bottom: 0, right: 0)
        
        tableView.register(UINib(nibName: "ConvoCoverInfoCell", bundle: nil), forCellReuseIdentifier: "convoCoverInfoCell")
        tableView.register(UINib(nibName: "ConvoNameInfoCell", bundle: nil), forCellReuseIdentifier: "convoNameInfoCell")
        tableView.register(UINib(nibName: "ConvoMemberHeaderInfoCell", bundle: nil), forCellReuseIdentifier: "convoMemberHeaderInfoCell")
        tableView.register(UINib(nibName: "ConvoMemberInfoCell", bundle: nil), forCellReuseIdentifier: "convoMemberInfoCell")
    }
    
    private func monitorPersonalConversation () {
        
        if let conversation = personalConversation {
            
            firebaseMessaging.monitorPersonalConversation(conversationID: conversation.conversationID) { (updatedConvo) in
                
                if let error = updatedConvo["error"] {
                    
                    print(error as Any)
                }
                
                else {
                    
                    if updatedConvo.contains(where: { $0.key == "conversationName" }) {
                        
                        if updatedConvo["conversationName"] as? String != self.personalConversation?.conversationName {
                            
                            self.personalConversation?.conversationName = updatedConvo["conversationName"] as? String
                            
                            self.messagingInfoTableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .fade)
                        }
                    }
                    
                    if updatedConvo.contains(where: { $0.key == "coverPhotoID" }) {
                        
                        if updatedConvo["coverPhotoID"] as? String != self.personalConversation?.coverPhotoID {
                            
                            self.personalConversation?.coverPhotoID = updatedConvo["coverPhotoID"] as? String
                            
                            //print(updatedConvo["coverPhotoID"] as? String)
                            
                            self.personalConversation?.conversationCoverPhoto = nil
                            
                            self.messagingInfoTableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
                        }
                    }
                }
            }
        }
    }
    
    private func updateConversationName (name: String?) {
        
        if let conversation = personalConversation {
            
            if name?.leniantValidationOfTextEntered() ?? false && name != conversation.conversationName {
                
                firebaseMessaging.updateConversationName(conversationID: conversation.conversationID, members: conversation.members, name: name!) { (error) in
                    
                    if error != nil {
                        
                        SVProgressHUD.showError(withStatus: "Sorry, an error occured while changing this conversation's name")
                    }
                }
            }
            
            else if name?.leniantValidationOfTextEntered() == false && name != conversation.conversationName {
                
                firebaseMessaging.updateConversationName(conversationID: conversation.conversationID, members: conversation.members, name: nil) { (error) in
                    
                    if error != nil {
                        
                        SVProgressHUD.showError(withStatus: "Sorry, an error occured while changing this conversations name")
                    }
                }
            }
        }
    }
    
    private func addCoverPhoto () {
        
        let addCoverPhotoAlert = UIAlertController (title: nil, message: nil, preferredStyle: .actionSheet)
        
        let takePhotoAction = UIAlertAction(title: "    Take a Photo", style: .default) { (takePhotoAction) in
          
            self.takePhotoSelected()
        }
        
        let cameraImage = UIImage(named: "camera2")
        takePhotoAction.setValue(cameraImage, forKey: "image")
        takePhotoAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        
        let choosePhotoAction = UIAlertAction(title: "    Choose a Photo", style: .default) { (choosePhotoAction) in
            
            self.choosePhotoSelected()
        }
        
        let photoImage = UIImage(named: "image")
        choosePhotoAction.setValue(photoImage, forKey: "image")
        choosePhotoAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        addCoverPhotoAlert.addAction(takePhotoAction)
        addCoverPhotoAlert.addAction(choosePhotoAction)
        addCoverPhotoAlert.addAction(cancelAction)
        
        present(addCoverPhotoAlert, animated: true, completion: nil)
    }
    
    private func configureEditCoverButton () {
        
        editCoverButton.frame = CGRect(x: 15, y: 50, width: 75, height: 35)
        
        editCoverButton.setTitle("Edit", for: .normal)
        editCoverButton.titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 16)
        editCoverButton.contentHorizontalAlignment = .center
        editCoverButton.tintColor = .white
        editCoverButton.alpha = 0
        editCoverButton.addTarget(self, action: #selector(editCoverButtonPressed), for: .touchUpInside)
    }
    
    private func configureDeleteCoverButton () {
        
        let xCoord = self.view.frame.width - (75 + 20)
        deleteCoverButton.frame = CGRect(x: xCoord, y: 50, width: 75, height: 35)
        
        deleteCoverButton.setTitle("Delete", for: .normal)
        deleteCoverButton.titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 16)
        deleteCoverButton.contentHorizontalAlignment = .center
        deleteCoverButton.tintColor = .systemRed
        deleteCoverButton.alpha = 0
        deleteCoverButton.addTarget(self, action: #selector(deleteCoverButtonPressed), for: .touchUpInside)
    }
    
    @objc private func editCoverButtonPressed () {
        
        handleZoomOutWithCompletion {
            
            self.addCoverPhoto()
        }
    }
    
    @objc private func deleteCoverButtonPressed () {
        
        if let conversation = personalConversation {
            
            SVProgressHUD.show()
            
            firebaseMessaging.deletePersonalConversationCoverPhoto(conversationID: conversation.conversationID) { (error) in
                
                if error != nil {
                    
                    SVProgressHUD.showError(withStatus: error?.localizedDescription)
                }
                
                else {
                    
                    SVProgressHUD.dismiss()
                    
                    self.personalConversation?.coverPhotoID = nil
                    self.personalConversation?.conversationCoverPhoto = nil
                    self.messagingInfoTableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                    
                    self.zoomedOutImageView?.isHidden = false
                    
                    UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                        
                        self.blackBackground?.backgroundColor = .clear
                        self.editCoverButton.alpha = 0
                        self.deleteCoverButton.alpha = 0
                        self.zoomedInImageView?.alpha = 0
                        
                    }) { (finished: Bool) in
                        
                        self.blackBackground?.removeFromSuperview()
                        self.editCoverButton.removeFromSuperview()
                        self.deleteCoverButton.removeFromSuperview()
                        self.zoomedInImageView?.removeFromSuperview()
                    }
                }
            }
        }
        
        else if let conversation = collabConversation {
            
            
        }
    }
    
    var zoomedOutImageView: UIImageView?
    var zoomedOutImageViewFrame: CGRect?
    
    var blackBackground: UIView?
    var zoomedInImageView: UIImageView?
    var zoomedInImageViewFrame: CGRect?
    
    @objc private func performZoomOnCoverImageView (coverImageView: UIImageView) {
        
        self.zoomedOutImageView = coverImageView
        
        blackBackground = UIView(frame: self.view.frame)
        blackBackground?.backgroundColor = .clear
        
        blackBackground?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        UIApplication.shared.keyWindow?.addSubview(blackBackground!)
        
        if let startingFrame = coverImageView.superview?.convert(coverImageView.frame, to: self.view) {
            
            zoomedOutImageViewFrame = startingFrame
            
            let zoomingImageView = UIImageView(frame: zoomedOutImageViewFrame!)
            zoomingImageView.contentMode = .scaleAspectFill
            zoomingImageView.image = coverImageView.image
            zoomingImageView.layer.cornerRadius = 100
            zoomingImageView.clipsToBounds = true
            
            zoomingImageView.isUserInteractionEnabled = true
            zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
            
            UIApplication.shared.keyWindow?.addSubview(zoomingImageView)
            zoomedInImageView = zoomingImageView
            
            UIApplication.shared.keyWindow?.addSubview(editCoverButton)
            UIApplication.shared.keyWindow?.addSubview(deleteCoverButton)
            
            coverImageView.isHidden = true
            
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                
                self.blackBackground?.backgroundColor = .black
                self.editCoverButton.alpha = 1
                self.deleteCoverButton.alpha = 1
                
                let height = (startingFrame.height / startingFrame.width) * self.view.frame.width
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: height)
                zoomingImageView.center = self.view.center
                
                zoomingImageView.layer.cornerRadius = 0
                
            }) { (finished: Bool) in
                
                self.zoomedInImageViewFrame = self.zoomedInImageView?.frame
                
                self.addCoverPhotoPanGesture(imageView: self.zoomedInImageView)
            }
        }
    }
    
    @objc private func handleZoomOut () {
        
        if let imageView = zoomedInImageView {
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                
                self.blackBackground?.backgroundColor = .clear
                self.editCoverButton.alpha = 0
                self.deleteCoverButton.alpha = 0
                
                imageView.frame = self.zoomedOutImageViewFrame!
                imageView.layer.cornerRadius = 100
                imageView.clipsToBounds = true
                
            }) { (finished: Bool) in
                
                self.zoomedOutImageView?.isHidden = false
                self.blackBackground?.removeFromSuperview()
                self.editCoverButton.removeFromSuperview()
                self.deleteCoverButton.removeFromSuperview()
                imageView.removeFromSuperview()
            }
        }
    }
    
    func handleZoomOutWithCompletion (completion: @escaping (() -> Void)) {
        
        if let imageView = zoomedInImageView {
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                
                self.blackBackground?.backgroundColor = .clear
                self.editCoverButton.alpha = 0
                self.deleteCoverButton.alpha = 0
                
                imageView.frame = self.zoomedOutImageViewFrame!
                imageView.layer.cornerRadius = 100
                imageView.clipsToBounds = true
                
            }) { (finished: Bool) in
                
                self.zoomedOutImageView?.isHidden = false
                self.blackBackground?.removeFromSuperview()
                self.editCoverButton.removeFromSuperview()
                self.deleteCoverButton.removeFromSuperview()
                imageView.removeFromSuperview()
                
                completion()
            }
        }
    }
    
    private func addCoverPhotoPanGesture (imageView: UIImageView?) {
        
        if imageView != nil {
            
            panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:)))
            
            imageView?.addGestureRecognizer(panGesture!)
        }
    }
    
    @objc private func handlePan (sender: UIPanGestureRecognizer) {
        
        switch sender.state {
            
        case .began, .changed:
            
            moveWithPan(sender: sender)
            
        case .ended:
            
            if (zoomedInImageView?.frame.minY ?? 0 > (self.view.frame.height / 2)) {
                
                handleZoomOut()
            }
            
            else if (zoomedInImageView?.frame.maxY ?? 0 < (self.view.frame.height / 2)) {
                
                handleZoomOut()
            }
            
            else {
                
                returnToOrigin()
            }
            
        default:
            break
        }
    }
    
    private func moveWithPan (sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: self.view)
        
        if let imageView = zoomedInImageView {

            let translatedMinYCoord = imageView.frame.minY + translation.y
            let translatedMinXCoord = imageView.frame.minX + translation.x
            let translatedMaxYCoord = imageView.frame.maxY + translation.y
            
            imageView.frame = CGRect(x: translatedMinXCoord, y: translatedMinYCoord, width: imageView.frame.width, height: imageView.frame.height)
            
            if let backgroundView = blackBackground, let zoomedInMinYCoord =  zoomedInImageViewFrame?.minY, let zoomedInMaxYCoord = zoomedInImageViewFrame?.maxY {
                    
                if translatedMinYCoord > zoomedInMinYCoord {
                    
                    let originalMinYDistanceToBottom = view.frame.height - zoomedInMinYCoord
                    let adjustedMinYDistanceToBottom = abs((translatedMinYCoord - (view.frame.height - originalMinYDistanceToBottom)) - originalMinYDistanceToBottom) //tricky but it works
                    //let cornerRadiusPart = ((0.5 * (zoomedInImageViewFrame?.width ?? 0)) / originalMinYDistanceToBottom)
                    let alphaPart = (1 / originalMinYDistanceToBottom)
                    
                    //imageView.layer.cornerRadius = (originalMinYDistanceToBottom - adjustedMinYDistanceToBottom) * cornerRadiusPart
                    
                    backgroundView.backgroundColor = UIColor.black.withAlphaComponent(alphaPart * adjustedMinYDistanceToBottom)
                    editCoverButton.alpha = alphaPart * adjustedMinYDistanceToBottom
                    deleteCoverButton.alpha = alphaPart * adjustedMinYDistanceToBottom
                }
                
                else if translatedMinYCoord < zoomedInMinYCoord {
                    
                    //let cornerRadiusPart = (0.5 * (zoomedInImageViewFrame?.width ?? 0)) / zoomedInMaxYCoord
                    let alphaPart = (1 / zoomedInMaxYCoord)
                    
//                    let testVar = ((view.frame.height - maxYCoord) - (view.frame.height - zoomedInMaxYCoord))
//                    imageView.layer.cornerRadius = cornerRadiusPart * testVar
                    
                    backgroundView.backgroundColor = UIColor.black.withAlphaComponent(alphaPart * translatedMaxYCoord)
                    editCoverButton.alpha = alphaPart * translatedMaxYCoord
                    deleteCoverButton.alpha = alphaPart * translatedMaxYCoord
                }
            }
            
            sender.setTranslation(CGPoint.zero, in: self.view)
        }
    }
    
    private func returnToOrigin () {
        
        if let imageView = zoomedInImageView, let imageViewFrame = zoomedInImageViewFrame {
            
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                
                self.blackBackground?.backgroundColor = .black
                self.editCoverButton.alpha = 1
                self.deleteCoverButton.alpha = 1
                
                imageView.frame = imageViewFrame
            })
        }
    }
    
    private func vibrate () {
        
        let generator: UIImpactFeedbackGenerator?
        
        if #available(iOS 13.0, *) {

            generator = UIImpactFeedbackGenerator(style: .rigid)
        
        } else {
            
            generator = UIImpactFeedbackGenerator(style: .medium)
        }
        
        generator?.impactOccurred()
    }
    
    @objc private func dismissKeyboard () {
        
        view.endEditing(true)
    }
}

extension ConversationInfoViewController: ConvoNameEnteredProtocol {
    
    func convoNameEntered (name: String) {
        
        convoName = name
    }
}

extension ConversationInfoViewController: ConversateWithMemberProtcol {
    
    func conversateWithMember(_ member: Friend) {
        
        dismiss(animated: true) {
            
            self.moveToConversationWithMemberDelegate?.moveToConversationWithMember(member)
        }
    }
}

extension ConversationInfoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func takePhotoSelected () {
        
        let imagePicker = UIImagePickerController()
        imagePicker.navigationBar.configureNavBar()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func choosePhotoSelected () {
        
        let imagePicker = UIImagePickerController()
        imagePicker.navigationBar.configureNavBar()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[.editedImage] {
            
            selectedImageFromPicker = editedImage as? UIImage
        }
        
        else if let originalImage = info[.originalImage] {
            
            selectedImageFromPicker = originalImage as? UIImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            
            //selectedCoverPhoto = selectedImage
            
            SVProgressHUD.show()
            
            if let conversation = personalConversation {
                
                let coverPhotoID = UUID().uuidString
                
                firebaseMessaging.saveConversationCoverPhoto(conversationID: conversation.conversationID, coverPhotoID: coverPhotoID, coverPhoto: selectedImage) { (error) in
                    
                    if error != nil {
                        
                        SVProgressHUD.showError(withStatus: error?.localizedDescription)
                    }
                    
                    else {
                        
                        if let conversationIndex = self.firebaseMessaging.personalConversations.firstIndex(where: { $0.conversationID == conversation.conversationID }) {
                            
                            self.firebaseMessaging.personalConversations[conversationIndex].coverPhotoID = coverPhotoID
                            self.firebaseMessaging.personalConversations[conversationIndex].conversationCoverPhoto = selectedImage
                        }
                        
                        self.personalConversation?.coverPhotoID = coverPhotoID
                        self.personalConversation?.conversationCoverPhoto = selectedImage
                        self.messagingInfoTableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                        
                        self.dismiss(animated: true) {
                            
                            SVProgressHUD.dismiss()
                        }
                    }
                }
            }
            
            else if let conversation = collabConversation {
                
//                firebaseMessaging.saveConversationCoverPhoto(conversationID: conversation.conversationID, coverPhotoID: coverPhoto: selectedImage) { (error) in
//                    
//                    if error != nil {
//                        
//                        SVProgressHUD.showError(withStatus: error?.localizedDescription)
//                    }
//                    
//                    else {
//                        
//                        self.collabConversation?.conversationHasCoverPhoto = true
//                        self.collabConversation?.conversationCoverPhoto = selectedImage
//                        self.messagingInfoTableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
//                        
//                        self.dismiss(animated: true) {
//                            
//                            SVProgressHUD.dismiss()
//                        }
//                    }
//                }
            }
        }
        
        else {
            
            dismiss(animated: true) {
                
                SVProgressHUD.showError(withStatus: "Sorry, something went wrong selecting this photo")
            }
        }
    }
}
