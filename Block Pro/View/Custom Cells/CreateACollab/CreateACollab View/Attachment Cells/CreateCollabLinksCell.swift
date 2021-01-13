//
//  CreateCollabLinksCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 12/10/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import FavIcon

protocol CreateCollabLinksCellProtocol: AnyObject {
    
    func attachLinkSelected ()
    
    func linkEntered (_ linkID: String, _ url: String)
    
    func linkIconSaved (_ linkID: String, _ icon: UIImage?)
    
    func linkRenamed (_ linkID: String, _ name: String)
    
    func linkDeleted (_ linkID: String)
}

class CreateCollabLinksCell: UITableViewCell {

    let linksLabel = UILabel()
    let linksCountLabel = UILabel()
    let linksContainer = UIView()
    
    let attachLinkButton = UIButton()
    let linkImage = UIImageView(image: UIImage(systemName: "link.circle"))
    let attachLinkLabel = UILabel()
    
    let linkCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    
    let linkPageControl = UIPageControl()
    
    var linkBeingRenamed: Bool = false
    var linkBeingEdited: Bool = false
    
    var keyboardPresent: Bool = false
    var originalContentOffsetOfTableView: CGFloat = 0
    
    var links: [Link]? {
        didSet {
            
            reconfigureCell()
        }
    }
    
    weak var createCollabLinksCellDelegate: CreateCollabLinksCellProtocol?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "createCollabLinksCell")
        
        configureLinksLabel()
        configureLinksCountLabel()
        configureLinksContainer()
        configureCollectionView()
        configureAttachButton()
        
        configureNotificationObservors()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    
    //MARK: - Configure Links Label
    
    private func configureLinksLabel () {
        
        self.contentView.addSubview(linksLabel)
        linksLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            linksLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            linksLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            linksLabel.widthAnchor.constraint(equalToConstant: 125),
            linksLabel.heightAnchor.constraint(equalToConstant: 20)
        
        ].forEach({ $0.isActive = true })
        
        linksLabel.text = "Links"
        linksLabel.textColor = .black
        linksLabel.textAlignment = .left
        linksLabel.font = UIFont(name: "Poppins-SemiBold", size: 15)
    }
    
    
    //MARK: - Configure Links Count Label
    
    private func configureLinksCountLabel () {
        
        self.contentView.addSubview(linksCountLabel)
        linksCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            linksCountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            linksCountLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            linksCountLabel.widthAnchor.constraint(equalToConstant: 75),
            linksCountLabel.heightAnchor.constraint(equalToConstant: 20)
        
        ].forEach({ $0.isActive = true })
        
        linksCountLabel.alpha = 0
        linksCountLabel.text = "0/6"
        linksCountLabel.textColor = .black
        linksCountLabel.textAlignment = .right
        linksCountLabel.font = UIFont(name: "Poppins-SemiBold", size: 15)
    }
    
    
    //MARK: - Configure Links Container
    
    private func configureLinksContainer () {
        
        self.contentView.addSubview(linksContainer)
        linksContainer.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            linksContainer.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
            linksContainer.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20),
            linksContainer.topAnchor.constraint(equalTo: linksLabel.bottomAnchor, constant: 10),
            linksContainer.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0),
        
        ].forEach({ $0.isActive = true })
        
        linksContainer.backgroundColor = .white
        
        linksContainer.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
        linksContainer.layer.borderWidth = 1

        linksContainer.layer.cornerRadius = 10
        linksContainer.layer.cornerCurve = .continuous
        linksContainer.clipsToBounds = true
    }

    //MARK: - Configure Attach Button
    
    private func configureAttachButton () {
        
        linksContainer.addSubview(attachLinkButton)
        attachLinkButton.addSubview(linkImage)
        attachLinkButton.addSubview(attachLinkLabel)
        
        attachLinkButton.translatesAutoresizingMaskIntoConstraints = false
        linkImage.translatesAutoresizingMaskIntoConstraints = false
        attachLinkLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [

            attachLinkButton.leadingAnchor.constraint(equalTo: linksContainer.leadingAnchor, constant: 0),
            attachLinkButton.trailingAnchor.constraint(equalTo: linksContainer.trailingAnchor, constant: 0),
            attachLinkButton.topAnchor.constraint(equalTo: linksContainer.topAnchor, constant: 0),
            attachLinkButton.heightAnchor.constraint(equalToConstant: 55),
            
            linkImage.leadingAnchor.constraint(equalTo: attachLinkButton.leadingAnchor, constant: 20),
            linkImage.centerYAnchor.constraint(equalTo: attachLinkButton.centerYAnchor),
            linkImage.widthAnchor.constraint(equalToConstant: 25),
            linkImage.heightAnchor.constraint(equalToConstant: 25),

            attachLinkLabel.leadingAnchor.constraint(equalTo: attachLinkButton.leadingAnchor, constant: 10),
            attachLinkLabel.trailingAnchor.constraint(equalTo: attachLinkButton.trailingAnchor, constant: -10),
            attachLinkLabel.centerYAnchor.constraint(equalTo: attachLinkButton.centerYAnchor),
            attachLinkLabel.heightAnchor.constraint(equalToConstant: 25)

        ].forEach({ $0.isActive = true })
        
        attachLinkButton.backgroundColor = .clear
        attachLinkButton.addTarget(self, action: #selector(attachButtonPressed), for: .touchUpInside)
        
        linkImage.tintColor = .black
        linkImage.isUserInteractionEnabled = false
        
        attachLinkLabel.text = "Attach Links"
        attachLinkLabel.textColor = .black
        attachLinkLabel.textAlignment = .center
        attachLinkLabel.font = UIFont(name: "Poppins-SemiBold", size: 14)
        attachLinkLabel.isUserInteractionEnabled = false
    }
    
    
    //MARK: - Configure Collection View
    
    private func configureCollectionView () {
        
        linksContainer.addSubview(linkCollectionView)
        linkCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            linkCollectionView.topAnchor.constraint(equalTo: linksContainer.topAnchor, constant: 10),
            linkCollectionView.leadingAnchor.constraint(equalTo: linksContainer.leadingAnchor, constant: 0),
            linkCollectionView.trailingAnchor.constraint(equalTo: linksContainer.trailingAnchor, constant: 0),
            linkCollectionView.heightAnchor.constraint(equalToConstant: links?.count ?? 0 > 0 ? 80 : 0)
        
        ].forEach({ $0.isActive = true })
        
        linkCollectionView.dataSource = self
        linkCollectionView.delegate = self
        
        linkCollectionView.backgroundColor = .white
        
        linkCollectionView.showsHorizontalScrollIndicator = false
        linkCollectionView.isPagingEnabled = true
        linkCollectionView.delaysContentTouches = false
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 40, height: 80) //Width is the entire width of the linkContainer
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.scrollDirection = .horizontal
        
        linkCollectionView.collectionViewLayout = layout
        
        linkCollectionView.register(CreateCollabLinkCollectionViewCell.self, forCellWithReuseIdentifier: "createCollabLinkCollectionViewCell")
    }
    
    
    //MARK: - Configure Link Page Control
    
    private func configureLinkPageControl () {
        
        if links?.count ?? 0 > 2 {
            
            if linkPageControl.superview == nil {
                
                linksContainer.addSubview(linkPageControl)
            }
            
            linkPageControl.translatesAutoresizingMaskIntoConstraints = false
            
            [
            
                linkPageControl.topAnchor.constraint(equalTo: linkCollectionView.bottomAnchor, constant: 7.5),
                linkPageControl.centerXAnchor.constraint(equalTo: linksContainer.centerXAnchor),
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
            linkPageControl.currentPage = links?.count != 0 && links != nil ? links!.count - 1 : 0
            
            linkPageControl.addTarget(self, action: #selector(pageSelected), for: .valueChanged)
        }
        
        else {
            
            linkPageControl.removeFromSuperview()
        }
    }
    
    
    //MARK: - Reconfiguration Functions
    
    private func reconfigureCell () {
        
        if links?.count ?? 0 == 0 {
            
            configureNoLinksCell()
        }
        
        else if links?.count ?? 0 < 6 {
            
            configurePartialLinksCell()
        }
        
        else if links?.count ?? 0 == 6 {
            
            configureFullLinksCell()
        }
    }
    
    private func configureNoLinksCell () {
        
        linkCollectionView.alpha = 0
        
        linkPageControl.removeFromSuperview()
        
        //Resetting the constraints of the attachLinkButton
        linksContainer.constraints.forEach { (constraint) in
            
            if constraint.firstAttribute == .leading && constraint.firstItem as? UIButton != nil {
                
                constraint.constant = 0
            }
            
            else if constraint.firstAttribute == .trailing && constraint.firstItem as? UIButton != nil {
                
                constraint.constant = 0
            }
            
            else if constraint.firstAttribute == .top && constraint.firstItem as? UIButton != nil {
                
                constraint.constant = 0
            }
        }
        
        attachLinkButton.constraints.forEach { (constraint) in
            
            if constraint.firstAttribute == .height {
                
                constraint.constant = 55
            }
        }
        ////////////////////////////////////////////////////////////////////////
        
        self.attachLinkButton.backgroundColor = .clear
        
        UIView.transition(with: linksContainer, duration: 0.3, options: .transitionCrossDissolve) {
            
            self.linksCountLabel.alpha = 0

            self.attachLinkButton.alpha = 1
            
            self.linkImage.tintColor = .black
            self.linkImage.isUserInteractionEnabled = false

            self.attachLinkLabel.text = "Attach Links"
            self.attachLinkLabel.textColor = .black
            self.attachLinkLabel.textAlignment = .center
            self.attachLinkLabel.font = UIFont(name: "Poppins-SemiBold", size: 14)
            self.attachLinkLabel.isUserInteractionEnabled = false
        }
    }
    
    private func configurePartialLinksCell () {
        
        linksCountLabel.text = "\(links?.count ?? 0)/6"
        
        configureLinkPageControl()
        
        //Resetting the constraints of the attachLinkButton
        linksContainer.constraints.forEach { (constraint) in
            
            if constraint.firstAttribute == .leading && constraint.firstItem as? UIButton != nil {
                
                constraint.constant = 32.5
            }
            
            else if constraint.firstAttribute == .trailing && constraint.firstItem as? UIButton != nil {
                
                constraint.constant = -32.5
            }
            
            else if constraint.firstAttribute == .top && constraint.firstItem as? UIButton != nil {
                
                if links?.count ?? 0 < 3 {
                    
                    constraint.constant = 80 + 10 + 12.5
                }
                
                else {
                    
                    //The height of a linkCell i.e. 80; + the top anchor of the collection view i.e. 10; + the top anchor of the attach button i.e. 12.5; + the space needed for the segment indicator i.e. 27.5
                    constraint.constant = 80 + 10 + 12.5 + 27.5
                }
            }
        }
        
        attachLinkButton.constraints.forEach { (constraint) in
            
            if constraint.firstAttribute == .height {
                
                constraint.constant = 40
            }
        }
        
        attachLinkButton.backgroundColor = UIColor(hexString: "222222")
        attachLinkButton.layer.cornerRadius = 20
        attachLinkButton.clipsToBounds = true
        attachLinkButton.addTarget(self, action: #selector(attachButtonPressed), for: .touchUpInside)
        
        linkImage.tintColor = .white
        linkImage.isUserInteractionEnabled = false
        
        attachLinkLabel.text = "Attach"
        attachLinkLabel.textColor = .white
        attachLinkLabel.textAlignment = .center
        attachLinkLabel.font = UIFont(name: "Poppins-SemiBold", size: 14)
        attachLinkLabel.isUserInteractionEnabled = false
        
        //Resetting the height of the linkCollectionView
        linkCollectionView.constraints.forEach { (constraint) in
            
            if constraint.firstAttribute == .height {
                
                constraint.constant = 80
            }
        }
        
        linkCollectionView.reloadData()
        linkCollectionView.scrollToItem(at: IndexPath(item: linkCollectionView.numberOfItems(inSection: 0) - 1, section: 0), at: .centeredHorizontally, animated: false)
        
        UIView.transition(with: linksContainer, duration: 0.3, options: .transitionCrossDissolve) {
            
            self.linksCountLabel.alpha = 1
            self.linkCollectionView.alpha = 1
            self.attachLinkButton.alpha = 1
        }
    }
    
    private func configureFullLinksCell () {
        
        UIView.transition(with: linksContainer, duration: 0.3, options: .transitionCrossDissolve) {
            
            self.linksCountLabel.text = "6/6"
            
            self.linkCollectionView.reloadData()
            
            self.attachLinkButton.alpha = 0
        }
    }
    
    
    //MARK: - Configure Notification Observors
    
    private func configureNotificationObservors () {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardBeingPresented), name: UIApplication.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardBeingDismissed), name: UIApplication.keyboardWillHideNotification, object: nil)
    }
    
    
    //MARK: - Present Edit Link Alert
    
    private func presentEditLinkAlert (textField: UITextField) {
        
        let editLinkAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let renameLinkAction = UIAlertAction(title: "    Rename Link", style: .default) { (renameAction) in
            
            self.linkBeingRenamed = true
            
            textField.setCustomPlaceholder(text: "Enter name", alignment: .center)
            
            textField.becomeFirstResponder()
        }
        
        let renameImage = UIImage(systemName: "rectangle.and.pencil.and.ellipsis")
        renameLinkAction.setValue(renameImage, forKey: "image")
        renameLinkAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        
        let editLinkAction = UIAlertAction(title: "     Edit Link", style: .default) { (editLink) in
            
            self.linkBeingEdited = true
            
            textField.becomeFirstResponder()
        }
        
        let editImage = UIImage(systemName: "link")
        editLinkAction.setValue(editImage, forKey: "image")
        editLinkAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        editLinkAlert.addAction(renameLinkAction)
        editLinkAlert.addAction(editLinkAction)
        editLinkAlert.addAction(cancelAction)
        
        if let viewController = createCollabLinksCellDelegate as? CreateCollabViewController {
            
            viewController.present(editLinkAlert, animated: true) //Has to be presented by a viewController
        }
    }
    
    
    //MARK: - Retrieve Fav Icon
    
    func retrieveFavIcon (urlString: String?, completion: @escaping ((_ image: UIImage?) -> Void)) {
        
        var url: String = ""
        
        //Attempts to ensure that all URL's entered are formatted correctly, and attempts reformat them if they aren't
        if urlString?.localizedCaseInsensitiveContains("https:") ?? false {
            
            url = urlString!
        }
        
        else {
            
            url = "https://" + urlString!
        }
        
        do {
                
            try FavIcon.downloadPreferred(url, completion: { (result) in
                
                if case let .success(image) = result {
                    
                    //Prevents images that will be too blurry from being used
                    if image.size.width >= 30 || image.size.height >= 30 {
                        
                        completion(image)
                    }
                    
                    else {
                        
                        completion(nil)
                    }
                }
                
                //If the download failed
                else {
                    
                    completion(nil)
                }
            })
            
        } catch {
            
            completion(nil)
        }
    }
    
    //MARK: - Keyboard Being Presented
    
    @objc private func keyboardBeingPresented (notification: NSNotification) {
        
        if !keyboardPresent {
            
            var textFieldSelected: Bool = false
            
            //Ensures that a linkView's textField in a linkCollectionViewCell's is the textField that called the keyboard
            for visibleCell in linkCollectionView.visibleCells {
                    
                if let cell = visibleCell as? CreateCollabLinkCollectionViewCell {
                    
                    if cell.leftTextField.isFirstResponder || cell.rightTextField.isFirstResponder {
                        
                        textFieldSelected = true
                        break
                    }
                }
            }
            
            if textFieldSelected {
                
                keyboardPresent = true
                
                if let viewController = createCollabLinksCellDelegate as? CreateCollabViewController, let tableView = viewController.details_attachmentsTableView {
                    
                    let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
                    let keyboardHeight = keyboardFrame.cgRectValue.height
                    
                    //y-coord for the createCollabLinkCell in the CreateCollabViewController
                    let createLinkCellMinY = tableView.rectForRow(at: IndexPath(row: 6, section: 0)).minY
                    
                    //Distance from the top of the createCollabLinkCell to the top of the link collection view cell, i.e. 40; + the itemSize, i.e. 80; - (half the height of the linkTextField + the bottomAnchor of the linkTextField), i.e. 10.5
                    let textFieldCenter: CGFloat = 40 + 80 - 10.5
                    
                    //y-coord of the details_attachments table view in regards to the keyWindow
                    let tableViewMinY = viewController.view.convert(tableView.frame, to: keyWindow).minY
                    
                    let keyboardMinY = UIScreen.main.bounds.height - keyboardHeight
                    
                    let middleOfTableViewAndKeyboard = tableViewMinY.distance(to: keyboardMinY) / 2
                    
                    originalContentOffsetOfTableView = tableView.contentOffset.y
                    
                    UIView.animate(withDuration: 0.3) {
                        
                        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
                        tableView.contentOffset.y = (createLinkCellMinY + textFieldCenter - middleOfTableViewAndKeyboard)
                    }
                }
            }
        }
    }
    
    
    //MARK: - Keyboard Being Dismissed
    
    @objc private func keyboardBeingDismissed (notification: NSNotification) {
        
        if keyboardPresent {
            
            keyboardPresent = false
            
            if let viewController = createCollabLinksCellDelegate as? CreateCollabViewController, let tableView = viewController.details_attachmentsTableView {
                
                UIView.animate(withDuration: 0.3) {
                    
                    tableView.contentOffset.y = self.originalContentOffsetOfTableView
                }
                
                viewController.updateTableViewContentInset()
            }
        }
    }
    
    //MARK: - Attach Button Pressed
    
    @objc func attachButtonPressed () {
        
        createCollabLinksCellDelegate?.attachLinkSelected()
    }
    
    
    //MARK: - Page Selected
    
    @objc private func pageSelected () {
    
        linkCollectionView.scrollToItem(at: IndexPath(item: linkPageControl.currentPage, section: 0), at: .centeredHorizontally, animated: true)
    }
}


//MARK: - Collection View Extension

extension CreateCollabLinksCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
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
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "createCollabLinkCollectionViewCell", for: indexPath) as! CreateCollabLinkCollectionViewCell
        
        cell.createCollabLinksCellDelegate = createCollabLinksCellDelegate
        
        cell.leftTextField.delegate = self
        cell.rightTextField.delegate = self
        
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


//MARK: - UITextFieldDelegate Extension

extension CreateCollabLinksCell: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if let linkCollectionViewCell = linkCollectionView.visibleCells.first as? CreateCollabLinkCollectionViewCell {
            
            let leftTextFieldEditing: Bool = textField == linkCollectionViewCell.leftTextField //If the leftTextBeganEditing
            
            //Each var below either belongs to the left or right link view, depending on which textField is editing
            let linkName = leftTextFieldEditing ? linkCollectionViewCell.leftLink?.name : linkCollectionViewCell.rightLink?.name
            
            let cancelButton = leftTextFieldEditing ? linkCollectionViewCell.leftCancelButton : linkCollectionViewCell.rightCancelButton
            
            let imageViewContainer = leftTextFieldEditing ? linkCollectionViewCell.leftImageViewContainer : linkCollectionViewCell.rightImageViewContainer
            
            //If text has already been entered into the textField
            if textField.text?.leniantValidationOfTextEntered() ?? false {
                
                //If the alert hasn't been presented/an alert action hasn't been pressed
                if !linkBeingRenamed && !linkBeingEdited {
                    
                    presentEditLinkAlert(textField: textField)
                    
                    textField.endEditing(true) //Stop the keyboard from presenting itself
                }
                
                //If the user want's to rename the link
                else if linkBeingRenamed {
                    
                    //If the link has already been renamed
                    if linkName?.leniantValidationOfTextEntered() ?? false {
                        
                        textField.text = linkName
                    }
                    
                    else {
                        
                        textField.text = ""
                    }
                    
                    //Stops the user from deleting links or opening url's while the keyboard is present
                    cancelButton.isUserInteractionEnabled = false
                    imageViewContainer.isUserInteractionEnabled = false
                }
                
                
                //If the user wants to enter a link/edit a link
                else {
                    
                    linkBeingEdited = true
                    
                    //Stops the user from deleting links or opening url's while the keyboard is present
                    cancelButton.isUserInteractionEnabled = false
                    imageViewContainer.isUserInteractionEnabled = false
                }
            }
            
            //If the textField hasn't had text entered yet
            else {
                
                linkBeingEdited = true
                
                //Stops the user from deleting links or opening url's while the keyboard is present
                cancelButton.isUserInteractionEnabled = false
                imageViewContainer.isUserInteractionEnabled = false
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if let linkCollectionViewCell = linkCollectionView.visibleCells.first as? CreateCollabLinkCollectionViewCell {
            
            let leftTextFieldEndedEditing: Bool = textField == linkCollectionViewCell.leftTextField //If the leftTextEndedEditing
            
            //Each var below either belongs to the left or right link view, depending on which textField ended editing
            let linkID = leftTextFieldEndedEditing ? linkCollectionViewCell.leftLink!.linkID! : linkCollectionViewCell.rightLink!.linkID!
            
            let cancelButton = leftTextFieldEndedEditing ? linkCollectionViewCell.leftCancelButton : linkCollectionViewCell.rightCancelButton
            
            let imageViewContainer = leftTextFieldEndedEditing ? linkCollectionViewCell.leftImageViewContainer : linkCollectionViewCell.rightImageViewContainer
            
            //If a link was being renamed
            if linkBeingRenamed {
                
                createCollabLinksCellDelegate?.linkRenamed(linkID, textField.text!)
                
                if let linkIndex = links?.firstIndex(where: { $0.linkID == linkID }) {
                    
                    links?[linkIndex].name = textField.text!
                    
                    //If no name was entered/the name was deleted
                    if !(textField.text?.leniantValidationOfTextEntered() ?? false) {
                        
                        textField.setCustomPlaceholder(text: "Enter link", alignment: .center)
                        textField.text = links?[linkIndex].url
                    }
                }
            }
            
            //If a link was being entered/edited
            else if linkBeingEdited {
                
                createCollabLinksCellDelegate?.linkEntered(linkID, textField.text!)
                
                if let linkIndex = links?.firstIndex(where: { $0.linkID == linkID }) {
                    
                    links?[linkIndex].url = textField.text!
                    
                    if links?[linkIndex].url?.leniantValidationOfTextEntered() ?? false {
                        
                        retrieveFavIcon(urlString: links?[linkIndex].url!) { [weak self] (icon) in

                            if leftTextFieldEndedEditing {

                                linkCollectionViewCell.leftImage = icon
                            }

                            else {

                                linkCollectionViewCell.rightImage = icon
                            }
                            
                            //Caching the icon
                            self?.links?[linkIndex].icon = icon
                            self?.createCollabLinksCellDelegate?.linkIconSaved(linkID, icon)
                        }
                    }
                    
                    //If a url wasn't entered/a url was deleted
                    else {
                        
                        //Deleting the icon
                        if leftTextFieldEndedEditing {
                            
                            linkCollectionViewCell.leftImage = nil
                        }
                        
                        else {
                            
                            linkCollectionViewCell.rightImage = nil
                        }
                        
                        links?[linkIndex].icon = nil
                        createCollabLinksCellDelegate?.linkIconSaved(linkID, nil)
                    }
                }
            }
            
            linkBeingRenamed = false
            linkBeingEdited = false
            
            //Reallows the user from deleting links or opening url's after the keyboard has been dismissed
            cancelButton.isUserInteractionEnabled = true
            imageViewContainer.isUserInteractionEnabled = true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.endEditing(true)
        return true
    }
}
