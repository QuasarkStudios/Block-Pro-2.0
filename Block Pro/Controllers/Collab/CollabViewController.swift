//
//  CollabViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/24/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import SVProgressHUD

class CollabViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var hiddenBlockVC: HiddenBlocksViewController?
    
    lazy var collabHeaderView = CollabHeaderView(collab)
    lazy var collabHeaderViewHeightConstraint = collabHeaderView.constraints.first(where: { $0.firstAttribute == .height })
    
    lazy var collabNavigationView = CollabNavigationView(collabStartTime: collab?.dates["startTime"], collabDeadline: collab?.dates["deadline"])
    let presentCollabNavigationViewButton = UIButton(type: .system)
    
    var editCollabBarButton: UIBarButtonItem?
    
    let collabHomeTableView = UITableView()
    
    lazy var editCoverButton: UIButton = configureEditButton()
    lazy var deleteCoverButton: UIButton = configureDeleteButton()
    
    let addBlockButton = UIButton(type: .system)
    let seeHiddenBlocksButton = UIButton(type: .system)
    
    lazy var tabBar = CustomTabBar.sharedInstance
    
    var copiedAnimationView: CopiedAnimationView?
    
    let messageInputAccesoryView = InputAccesoryView(textViewPlaceholderText: "Send a message", showsAddButton: true)
    var inputAccesoryViewMethods: InputAccesoryViewMethods!
    
    let currentUser = CurrentUser.sharedInstance
    
    let firebaseCollab = FirebaseCollab.sharedInstance
    let firebaseStorage = FirebaseStorage()
    let firebaseBlock = FirebaseBlock.sharedInstance
    let firebaseMessaging = FirebaseMessaging.sharedInstance
    var collab: Collab?
    
//    let formatter = DateFormatter()
    let calendar = Calendar.current
    
    var blocks: [Block]?
    var selectedBlock: Block?
    var hiddenBlocks: [Block] = []
    
    var messagingMethods: MessagingMethods!
    var messages: [Message]?
    
    var selectedTab: String = "Blocks"
    var alertTracker: String = ""
    
    var keyboardHeight: CGFloat?
    
    var messageTextViewText: String = ""
    var selectedPhoto: UIImage?
    
    var gestureViewPanGesture: UIPanGestureRecognizer?
    var stackViewPanGesture: UIPanGestureRecognizer?
    var dismissExpandedViewGesture: UISwipeGestureRecognizer?
    
    var zoomingMethods: ZoomingImageViewMethods?

    var imageViewBeingZoomed: Bool?
    var keyboardWasPresent: Bool?
    
    var tabBarWasHidden: Bool = false
    
//    var viewAppeared: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavBar()
        configureGestureRecognizers()
        
        configureHeaderView()
        configureCollabHomeTableView()
        
        configurePresentCollabNavigationViewButton()
        configureCollabNavigationView()
        
        configureAddBlockButton()
        configureSeeHiddenBlocksButton()
        
        configureProgressView()
        configureBlockView()
        configureMessagingView()
        
        retrieveBlocks()
        retrieveMessages()
        
        setUserActiveStatus()
        
        retrieveMemberProfilePics()
        
        messageInputAccesoryView.alpha = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        retrieveMessageDraft()
        
        tabBar.shouldHide = tabBarWasHidden
        
        //Initializing here allows the animationView to be removed and readded multiple times
        copiedAnimationView = CopiedAnimationView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
//        viewAppeared = true
        
        hiddenBlockVC = nil
        
        addObservors()
        
        self.becomeFirstResponder()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        tabBarWasHidden = tabBar.alpha == 0
        
        removeObservors()
        
        #warning("find a better plack to remove these listeners")
//        firebaseBlock.collabBlocksListener?.remove(); #warning("will stop blocks from being recieved im pretty sure")
//        firebaseCollab.messageListener?.remove();
        
        setUserInactiveStatus()
        
        saveMessageDraft()
        
        copiedAnimationView?.removeCopiedAnimation(remove: true)
    }
    
    override var inputAccessoryView: UIView? {
        return messageInputAccesoryView
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if tableView == collabHomeTableView {
            
            return 6
        }
        
        else {
            
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == collabHomeTableView {
            
            if section == 0 {
                
                return 3
            }
            
            else if section == 1 {
                
                return 4
            }
            
            else if section == 2 {
                
                return 3
            }
            
            else if section == 3 {
                
                return 3
            }
            
            else if section == 4 {
                
                return 3
            }
            
            else {
                
                return 1
            }
        }
        
        else {
            
            if selectedTab == "Blocks" {
                
                //still needs testing
                if let startTime = collab?.dates["startTime"], let deadline = collab?.dates["deadline"] {
                    
                    if let days = calendar.dateComponents([.day], from: startTime, to: deadline).day, days != 0 {
                        
                        return days + 1
                    }
                    
                    else {
                        
                        //this can only be tested once create a collab view is reconfigured giving users the ability to set a collab to start and end on the same day
                        return 1
                    }
                }
                
                else {
                    
                    return 1
                }
            }
            
            else if selectedTab == "Messages" {
                
                if tableView == collabNavigationView.collabTableView {

                    return messagingMethods.numberOfRowsInSection(messages: messages)
                }
                
                return messagingMethods.numberOfRowsInSection(messages: messages)
            }
            
            else {
                
                return 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
        if tableView == collabHomeTableView {
            
            if indexPath.section == 0 {
                
                if indexPath.row == 0 {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "collabHomeSectionHeaderCell", for: indexPath) as! CollabHomeSectionHeaderCell
                    cell.selectionStyle = .none
                    
                    cell.sectionNameLabel.text = "Members"
                    
                    return cell
                }
                
                else if indexPath.row == 1 {
                    
                    let cell = UITableViewCell()
                    cell.isUserInteractionEnabled = false
                    return cell
                }
                
                else {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "collabHomeMembersCell", for: indexPath) as! CollabHomeMembersCell
                    cell.selectionStyle = .none
                    cell.collab = collab
                    
                    return cell
                }
            }
            
            else if indexPath.section == 1 {
                
                if indexPath.row == 0 {
                    
                    let cell = UITableViewCell()
                    cell.isUserInteractionEnabled = false
                    return cell
                }
                
                else if indexPath.row == 1 {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "collabHomeSectionHeaderCell", for: indexPath) as! CollabHomeSectionHeaderCell
                    cell.selectionStyle = .none
                    
                    cell.sectionNameLabel.text = "Locations"
                    return cell
                }
                
                else if indexPath.row == 2 {
                    
                    let cell = UITableViewCell()
                    cell.isUserInteractionEnabled = false
                    return cell
                }
                
                else {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "collabHomeLocationsCell", for: indexPath) as! CollabHomeLocationsCell
                    cell.selectionStyle = .none
                    
                    cell.locations = collab?.locations
                    
                    cell.locationSelectedDelegate = self
                    
                    return cell
                }
            }
            
            else if indexPath.section == 2 {
                
                if indexPath.row == 0 {
                    
                    let cell = UITableViewCell()
                    cell.isUserInteractionEnabled = false
                    return cell
                }
                
                else if indexPath.row == 1 {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "collabHomeSectionHeaderCell", for: indexPath) as! CollabHomeSectionHeaderCell
                    cell.selectionStyle = .none
                    
                    cell.sectionNameLabel.text = "Photos"
                    return cell
                }
                
                else {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "collabHomePhotosCell", for: indexPath) as! CollabHomePhotosCell
                    cell.selectionStyle = .none
                    
                    cell.collab = collab

                    cell.cachePhotoDelegate = self
                    cell.zoomInDelegate = self
                    cell.presentCopiedAnimationDelegate = self
                    
                    return cell
                }
            }
            
            else if indexPath.section == 3 {
                
                if indexPath.row == 0 {
                    
                    let cell = UITableViewCell()
                    cell.isUserInteractionEnabled = false
                    return cell
                }
                
                else if indexPath.row == 1 {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "collabHomeSectionHeaderCell", for: indexPath) as! CollabHomeSectionHeaderCell
                    cell.selectionStyle = .none
                    
                    cell.sectionNameLabel.text = "Voice Memos"
                    return cell
                }
                
                else {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "collabHomeVoiceMemosCell", for: indexPath) as! CollabHomeVoiceMemosCell
                    cell.selectionStyle = .none
                    
                    cell.collab = collab
                    
                    return cell
                }
            }
            
            else if indexPath.section == 4 {
                
                if indexPath.row == 0 {
                    
                    let cell = UITableViewCell()
                    cell.isUserInteractionEnabled = false
                    return cell
                }
                
                else if indexPath.row == 1 {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "collabHomeSectionHeaderCell", for: indexPath) as! CollabHomeSectionHeaderCell
                    cell.selectionStyle = .none
                    
                    cell.sectionNameLabel.text = "Links"
                    return cell
                }
                
                else {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "collabHomeLinksCell", for: indexPath) as! CollabHomeLinksCell
                    cell.selectionStyle = .none
                    
                    cell.links = collab?.links//?.sorted(by: { ($0.name ?? $0.url)! < ($1.name ?? $1.url)! })
                    
                    cell.cacheIconDelegate = self
                    
                    return cell
                }
            }
            
            else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "leaveCollabCell", for: indexPath) as! LeaveCollabCell
                cell.selectionStyle = .none
                return cell
            }
        }
        
        else {
            
            if selectedTab == "Blocks" {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "blocksTableViewCell", for: indexPath) as! BlocksTableViewCell
                cell.selectionStyle = .none
                
                cell.collab = collab
                cell.blockSelectedDelegate = self
                
                if let startTime = collab?.dates["startTime"], let dateForCell = calendar.date(byAdding: .day, value: indexPath.row, to: startTime) {
                    
                    cell.blocks = blocks?.filter({ calendar.isDate($0.starts!, inSameDayAs: dateForCell) }).sorted(by: { $0.starts! < $1.starts! })
                }
                
                return cell
            }
            
            else if selectedTab == "Messages" {
                
                if tableView == collabNavigationView.collabTableView {
                    
                    return messagingMethods.cellForRowAt(indexPath: indexPath, messages: messages, members: collab?.members)
                }
            }
            
            else if selectedTab == "Progress" {
                
                if tableView == collabNavigationView.collabTableView {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "collabProgressCell", for: indexPath) as! CollabProgressCell
                    cell.selectionStyle = .none
                    
                    cell.collab = collab
                    cell.blocks = blocks
                    
                    return cell
                }
            }
            
            return messagingMethods.cellForRowAt(indexPath: indexPath, messages: messages, members: collab?.members)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView == collabHomeTableView {
            
            if indexPath.section == 0 {
                
                if indexPath.row == 0 {
                    
                    return 20
                }
                
                else if indexPath.row == 1 {
                    
                    return 10
                }
                
                else if indexPath.row == 2 {
                    
                    return 170//200
                }
                
                else {
                    
                    return 200
                }
            }
            
            else if indexPath.section == 1 {
                
                if indexPath.row == 0 {
                    
                    return 20
                }
                
                else if indexPath.row == 1 {
                    
                    return 20
                }
                
                else if indexPath.row == 2 {
                    
                    return 10
                }
                
                else {
                    
                    if collab?.locations?.count ?? 0 == 0 {
                        
//                        let itemSize = (UIScreen.main.bounds.width - (40 + 10 + 20)) / 3
                        return itemSize + 20 + 20 //This is borrowed from the collabPhotos cell to allow both cells to look the same
                    }
                    
                    else if collab?.locations?.count == 1 {
                        
                        return 200
                    }
                    
                    else {
                        
                        return 232.5
                    }
                }
            }
            
            else if indexPath.section == 2 {
                
                if indexPath.row == 0 {
                    
                    return 2.5
                }
                
                else if indexPath.row == 1 {
                    
                    return 25
                }
                
                else {
                    
//                    let itemSize = (UIScreen.main.bounds.width - (40 + 10 + 20)) / 3
                    
                    if collab?.photoIDs.count ?? 0 <= 3 {
                        
                        return itemSize + 20 + 20// The item size plus the top and bottom edge insets, i.e. 20 and the top and bottom anchors i.e. 20
                    }
                    
                    else {
                        
                        return (itemSize * 2) + 20 + 20 + 5 //The height of the two rows of items that'll be displayed plus the edge insets, i.e. 20, the top and bottom anchors i.e. 20, and the line spacing i.e. 5
                    }
                }
            }
            
            else if indexPath.section == 3 {
                
                if indexPath.row == 0 {
                    
                    return 2.5
                }
                
                else if indexPath.row == 1 {
                    
                    return 25
                }
                
                else {
                    
                    return itemSize + 42
                }
            }
            
            else if indexPath.section == 4 {
                
                if indexPath.row == 0 {
                    
                    return 2.5
                }
                
                else if indexPath.row == 1 {
                    
                    return 25
                }
                
                else {
                    
                    if collab?.links?.count ?? 0 == 0 {
                        
                        return itemSize + 42
                    }
                    
                    else if collab?.links?.count ?? 0 < 3 {
                        
                        return 120
                    }
                    
                    else {
                        
                        return 147.5
                    }
                }
            }
            
            else {
                
                return 80
            }
        }
        
        else {
            
            if selectedTab == "Blocks" {
                
                return 2210
            }
            
            else if selectedTab == "Messages" {
                
                if tableView == collabNavigationView.collabTableView {
                    
                    return messagingMethods.heightForRowAt(indexPath: indexPath, messages: messages)
                }
            }
            
            else if selectedTab == "Progress" {
                
                //radius of the largest progress circle plus it's track layer width plus the progress label height and a roughly 25 point top buffer
                return (UIScreen.main.bounds.width * 0.5) + 12 + 55
            }
            
            return messagingMethods.heightForRowAt(indexPath: indexPath, messages: messages)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if tableView == collabHomeTableView && indexPath.section == (tableView.numberOfSections - 1) {
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                
//                self.collabHomeTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//                self.collabHomeTableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                
                self.presentCollabNavigationViewButton.alpha = 0
                self.tabBar.alpha = 0
            }
        }
        
        else {
            
//            if selectedTab == "Blocks" {
//
//                if viewAppeared {
//
//                    if let lastVisibleCellIndexPath = tableView.indexPathsForVisibleRows?.last {
//
//                        if let startTime = collab?.dates["startTime"], let adjustedDate = calendar.date(byAdding: .day, value: lastVisibleCellIndexPath.row, to: startTime) {
//
//                            collabNavigationView.calendarView.scrollToDate(adjustedDate)
//                            collabNavigationView.calendarView.selectDates([adjustedDate])
//                        }
//                    }
//                }
//            }
        }
        
//        let tableViewExpandedHeight = self.view.frame.height - topBarHeight
//
//        if tableView.contentSize.height > tableViewExpandedHeight {
//
//            if indexPath.section == 3 {
//
//                print("check")
//
//                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
//
//                    self.collabHomeTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//                    self.collabHomeTableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//
//                    self.presentCollabNavigationViewButton.alpha = 0
//                    self.tabBar.alpha = 0
//                }
//            }
//
//            else {
//
//
//            }
//        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if tableView == collabHomeTableView && indexPath.section == (tableView.numberOfSections - 1) {
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                
                self.presentCollabNavigationViewButton.alpha = 1
                self.tabBar.alpha = 1
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == collabHomeTableView {
            
            if scrollView.contentOffset.y >= 0 {
                
                if ((collabHeaderViewHeightConstraint?.constant ?? 0) - scrollView.contentOffset.y) > topBarHeight {
                    
                    collabHeaderViewHeightConstraint?.constant -= scrollView.contentOffset.y
                    scrollView.contentOffset.y = 0
                    
                    let alphaPart = 1 / (collabHeaderView.configureViewHeight() - 80 - topBarHeight)
                    collabHeaderView.alpha = alphaPart * (collabHeaderViewHeightConstraint!.constant - topBarHeight)
                }
                
                else {
                    
                    collabHeaderViewHeightConstraint?.constant = topBarHeight
                    collabHeaderView.alpha = 0
                    
                    self.title = collab?.name
                    navigationController?.navigationBar.configureNavBar(barBackgroundColor: .clear, barTintColor: .black, barStyleColor: .default)
                }
            }
            
            else {
                
                self.title = nil
                navigationController?.navigationBar.configureNavBar(barBackgroundColor: .clear, barTintColor: .white, barStyleColor: .black)
                
                if (collabHeaderViewHeightConstraint?.constant ?? 0) < collabHeaderView.configureViewHeight() - 80 {
                    
                    collabHeaderViewHeightConstraint?.constant = collabHeaderView.configureViewHeight() - 80
                    
                    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {

                        self.view.layoutIfNeeded()
                    })
                }

                else {
                    
//                    collabHeaderViewHeightConstraint?.constant = (collabHeaderView.configureViewHeight() - 80) + abs(scrollView.contentOffset.y)
                }
            }
        }
        
        else {
            
            if selectedTab == "Blocks" {
                
                //22 is the top contentInset of the collabTableView; this will be required to be updated if that ever changes
                if scrollView.contentOffset.y == 22 {
                    
                    if let startTime = collab?.dates["startTime"] {
                        
                        collabNavigationView.calendarView.scrollToDate(startTime)
                        collabNavigationView.calendarView.selectDates([startTime])
                    }
                }
                
                determineHiddenBlocks(scrollView)
            }
        }
    }
    
    internal func determineHiddenBlocks (_ scrollView: UIScrollView) {
        
        //Ensures that the view is expanded
        if let indexPath = collabNavigationView.collabTableView.indexPathsForVisibleRows?.first, navigationItem.hidesBackButton {
            
            //The range of y-Coords that is used to determine which hidden blocks can be presented
            let range = scrollView.contentOffset.y - CGFloat(2210 * indexPath.row) ... scrollView.contentOffset.y - CGFloat(2210 * indexPath.row) + scrollView.frame.height
            
            if let cell = collabNavigationView.collabTableView.cellForRow(at: indexPath) as? BlocksTableViewCell {
                
                hiddenBlocks = []
                
                for hiddenBlock in cell.hiddenBlocks {
                    
                    let blockStartHour = calendar.dateComponents([.hour], from: hiddenBlock.starts!).hour!
                    let blockStartMinute = calendar.dateComponents([.minute], from: hiddenBlock.starts!).minute!
                    let yCoord = CGFloat((Double(blockStartHour) * 90) + (Double(blockStartMinute) * 1.5)) + 50
                    
                    //If the hidden block's y-Coord is within the range meaning that it would be visible to the user if it wasn't hidden
                    if range.contains(yCoord) {
                        
                        hiddenBlocks.append(hiddenBlock)
                    }
                }
                
                //If the hiddenBlocksVC is currently in the navigation stack/presented to the user, this will update the hiddenBlocks in that view
                if let viewController = hiddenBlockVC {
                    
                    viewController.hiddenBlocks = hiddenBlocks
                }
                
                //Animating the hiddenBlocksButton based on the number of hiddenBlocks available
                if hiddenBlocks.count > 0 {
                    
                    UIView.animate(withDuration: 0.3) {
                        
                        self.seeHiddenBlocksButton.alpha = 1
                    }
                }
                
                else {
                    
                    UIView.animate(withDuration: 0.3) {
                        
                        self.seeHiddenBlocksButton.alpha = 0
                    }
                }
            }
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if scrollView == collabNavigationView.collabTableView {
            
            if selectedTab == "Blocks" {
                
                if velocity.y < 0 {
                    
                    if let firstVisibleCellIndexPath = collabNavigationView.collabTableView.indexPathsForVisibleRows?.first {
                        
                        if let startTime = collab?.dates["startTime"], let adjustedDate = calendar.date(byAdding: .day, value: firstVisibleCellIndexPath.row, to: startTime), adjustedDate != collabNavigationView.calendarView.selectedDates.first ?? Date() {

                            collabNavigationView.calendarView.scrollToDate(adjustedDate)
                            collabNavigationView.calendarView.selectDates([adjustedDate])
                            
                            let vibrateMethods = VibrateMethods()
                            vibrateMethods.warningVibration()
                        }
                    }
                    
                    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                        
                        self.addBlockButton.alpha = 1
                        self.tabBar.alpha = 1
                    }
                }
                
                else {
                    
                    if let lastVisibleCellIndexPath = collabNavigationView.collabTableView.indexPathsForVisibleRows?.last {
                        
                        if let startTime = collab?.dates["startTime"], let adjustedDate = calendar.date(byAdding: .day, value: lastVisibleCellIndexPath.row, to: startTime), adjustedDate != collabNavigationView.calendarView.selectedDates.first ?? Date() {
                            
                            collabNavigationView.calendarView.scrollToDate(adjustedDate)
                            collabNavigationView.calendarView.selectDates([adjustedDate])
                            
                            let vibrateMethods = VibrateMethods()
                            vibrateMethods.warningVibration()
                        }
                    }
                    
                    if velocity.y > 0.5 {
                        
                        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                            
                            self.addBlockButton.alpha = 0
                            self.tabBar.alpha = 0
                        }
                    }
                }
            }
        }
    }
    
    private func configureNavBar () {
        
        self.navigationController?.navigationBar.configureNavBar(barBackgroundColor: .clear, barTintColor: .white, barStyleColor: .black)
        
        editCollabBarButton = UIBarButtonItem(title: "Edit", style: .done, target: self, action: #selector(editCollabButtonPressed))
    }
    
    private func configureHeaderView () {
        
        self.view.addSubview(collabHeaderView)
        collabHeaderView.collabViewController = self
    }
    
    private func configureCollabHomeTableView () {
        
        self.view.addSubview(collabHomeTableView)
        collabHomeTableView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            collabHomeTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            collabHomeTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            collabHomeTableView.topAnchor.constraint(equalTo: collabHeaderView.bottomAnchor, constant: 5),
            collabHomeTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
        
        collabHomeTableView.dataSource = self
        collabHomeTableView.delegate = self
        
//        collabHomeTableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 200, right: 0)
        collabHomeTableView.separatorStyle = .none
        collabHomeTableView.showsVerticalScrollIndicator = false
        collabHomeTableView.delaysContentTouches = false
        
        collabHomeTableView.register(CollabHomeSectionHeaderCell.self, forCellReuseIdentifier: "collabHomeSectionHeaderCell")
        collabHomeTableView.register(UINib(nibName: "CollabHomeMembersCell", bundle: nil), forCellReuseIdentifier: "collabHomeMembersCell")
        collabHomeTableView.register(UINib(nibName: "CollabHomeLocationsCell", bundle: nil), forCellReuseIdentifier: "collabHomeLocationsCell")
        collabHomeTableView.register(UINib(nibName: "CollabHomePhotosCell", bundle: nil), forCellReuseIdentifier: "collabHomePhotosCell")
        collabHomeTableView.register(CollabHomeVoiceMemosCell.self, forCellReuseIdentifier: "collabHomeVoiceMemosCell")
        collabHomeTableView.register(CollabHomeLinksCell.self, forCellReuseIdentifier: "collabHomeLinksCell")
        collabHomeTableView.register(UINib(nibName: "LeaveCollabCell", bundle: nil), forCellReuseIdentifier: "leaveCollabCell")
    }
    
    private func configureCollabNavigationView () {
        
        self.view.addSubview(collabNavigationView)
        collabNavigationView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            collabNavigationView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            collabNavigationView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
//            collabNavigationView.topAnchor.constraint(equalTo: collabHeaderView.bottomAnchor, constant: /*-50*/-80),
            collabNavigationView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: collabHeaderView.configureViewHeight() - 80),
            collabNavigationView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
        
//        collabNavigationView.collabStartTime = collab?.dates["startTime"]
//        collabNavigationView.collabDeadline = collab?.dates["deadline"]
        
        collabNavigationView.collabViewController = self
    }
    
    //should probably move all these configuration funcs for the navigation view to the navigation class
    private func configureProgressView () {
        
        collabNavigationView.collabTableView.register(CollabProgressCell.self, forCellReuseIdentifier: "collabProgressCell")
    }
    
    private func configureBlockView () {
        
        collabNavigationView.collabTableView.dataSource = self
        collabNavigationView.collabTableView.delegate = self
        
        collabNavigationView.collabTableView.separatorStyle = .none
        
        collabNavigationView.collabTableView.estimatedRowHeight = 0
        
        collabNavigationView.collabTableView.scrollsToTop = true
        
        collabNavigationView.collabTableView.register(BlocksTableViewCell.self, forCellReuseIdentifier: "blocksTableViewCell")
    }
    
    private func configureMessagingView () {
        
        messageInputAccesoryView.parentViewController = self
//        messageInputAccesoryView.isHidden = true
        
        messagingMethods = MessagingMethods(parentViewController: self, tableView: collabNavigationView.collabTableView, collabID: collab?.collabID ?? "")
        messagingMethods.configureTableView()
        
        inputAccesoryViewMethods = InputAccesoryViewMethods(accesoryView: messageInputAccesoryView, textViewPlaceholderText: "Send a message", tableView: collabNavigationView.collabTableView)
    }
    
    private func configurePresentCollabNavigationViewButton () {
        
        self.view.addSubview(presentCollabNavigationViewButton)
        presentCollabNavigationViewButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
            
            presentCollabNavigationViewButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            presentCollabNavigationViewButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -(self.view.frame.height - tabBar.frame.minY) - 15),
            presentCollabNavigationViewButton.widthAnchor.constraint(equalToConstant: 37.5),
            presentCollabNavigationViewButton.heightAnchor.constraint(equalToConstant: 37.5)
        
        ].forEach({ $0.isActive = true })
        
        presentCollabNavigationViewButton.tag = 1
        
        presentCollabNavigationViewButton.tintColor = UIColor(hexString: "222222")
        presentCollabNavigationViewButton.setImage(UIImage(systemName: "chevron.up.circle.fill"), for: .normal)
        presentCollabNavigationViewButton.contentVerticalAlignment = .fill
        presentCollabNavigationViewButton.contentHorizontalAlignment = .fill
        
        presentCollabNavigationViewButton.addTarget(self, action: #selector(presentNavViewButtonPressed), for: .touchUpInside)
        
        let buttonBackgroundView = UIView(frame: CGRect(x: 5, y: 5, width: 27.5, height: 27.5))
        buttonBackgroundView.backgroundColor = .white
        buttonBackgroundView.isUserInteractionEnabled = false
        
        buttonBackgroundView.layer.cornerRadius = 27.5 * 0.5
        buttonBackgroundView.clipsToBounds = true
        
        presentCollabNavigationViewButton.addSubview(buttonBackgroundView)
        presentCollabNavigationViewButton.bringSubviewToFront(presentCollabNavigationViewButton.imageView!)
    }
    
    private func configureEditButton () -> UIButton {
        
        let button = UIButton(type: .system)
        
        button.frame = CGRect(x: 15, y: 50, width: 75, height: 35)
        
        button.setTitle("Edit", for: .normal)
        button.titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 16)
        button.contentHorizontalAlignment = .center
        button.tintColor = .white
        button.alpha = 0
        button.addTarget(self, action: #selector(editCoverButtonPressed), for: .touchUpInside)
        
        return button
    }
    
    private func configureDeleteButton () -> UIButton {
        
        let button = UIButton(type: .system)
        
        let xCoord = self.view.frame.width - (75 + 20)
        button.frame = CGRect(x: xCoord, y: 50, width: 75, height: 35)
        
        button.setTitle("Delete", for: .normal)
        button.titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 16)
        button.contentHorizontalAlignment = .center
        button.tintColor = .systemRed
        button.alpha = 0
        button.addTarget(self, action: #selector(deleteCoverButtonPressed), for: .touchUpInside)
        
        return button
    }
    
    private func configureAddBlockButton () {
        
        view.addSubview(addBlockButton)
        addBlockButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
            
            addBlockButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -29),
            addBlockButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -(self.view.frame.height - tabBar.frame.minY) - 25),
            addBlockButton.widthAnchor.constraint(equalToConstant: 60),
            addBlockButton.heightAnchor.constraint(equalToConstant: 60)
            
        ].forEach( { $0.isActive = true } )
        
        addBlockButton.backgroundColor = UIColor(hexString: "222222")
        addBlockButton.setImage(UIImage(named: "plus 2"), for: .normal)
        addBlockButton.tintColor = .white
        
        addBlockButton.layer.cornerRadius = 30

        addBlockButton.addTarget(self, action: #selector(addBlockButtonPressed), for: .touchUpInside)
    }
    
    private func configureSeeHiddenBlocksButton () {
        
        self.view.addSubview(seeHiddenBlocksButton)
        seeHiddenBlocksButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            seeHiddenBlocksButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -12.5),
            seeHiddenBlocksButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 0),
            seeHiddenBlocksButton.widthAnchor.constraint(equalToConstant: 35),
            seeHiddenBlocksButton.heightAnchor.constraint(equalToConstant: 35)
            
        ].forEach({ $0.isActive = true })
        
        seeHiddenBlocksButton.alpha = 0
        
        seeHiddenBlocksButton.tintColor = UIColor(hexString: "222222")
        seeHiddenBlocksButton.setImage(UIImage(systemName: "chevron.right.circle.fill"), for: .normal)
        seeHiddenBlocksButton.contentVerticalAlignment = .fill
        seeHiddenBlocksButton.contentHorizontalAlignment = .fill
        
        seeHiddenBlocksButton.addTarget(self, action: #selector(seeHiddenBlocksButtonPressed), for: .touchUpInside)
        
        let buttonBackgroundView = UIView(frame: CGRect(x: 5, y: 5, width: 25, height: 25))
        buttonBackgroundView.backgroundColor = .white
        buttonBackgroundView.isUserInteractionEnabled = false
        
        buttonBackgroundView.layer.cornerRadius = 25 * 0.5
        buttonBackgroundView.clipsToBounds = true
        
        seeHiddenBlocksButton.addSubview(buttonBackgroundView)
        seeHiddenBlocksButton.bringSubviewToFront(seeHiddenBlocksButton.imageView!)
    }
    
    
    internal func addObservors () {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardBeingPresented), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardBeingDismissed), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(setUserActiveStatus), name: UIApplication.didBecomeActiveNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(setUserInactiveStatus), name: UIApplication.willResignActiveNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(saveMessageDraft), name: UIApplication.willTerminateNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(sendMessage), name: .userDidSendMessage, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(addAttachment), name: .userDidAddMessageAttachment, object: nil)
    }
    
    private func removeObservors () {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    private func configureGestureRecognizers () {

        dismissExpandedViewGesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissExpandedView))
        dismissExpandedViewGesture?.delegate = self
        dismissExpandedViewGesture?.cancelsTouchesInView = true
        dismissExpandedViewGesture?.direction = .right
        view.addGestureRecognizer(dismissExpandedViewGesture!)
        
        gestureViewPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:)))
        //panGestureView.addGestureRecognizer(gestureViewPanGesture!)
        collabNavigationView.panGestureView.addGestureRecognizer(gestureViewPanGesture!)
        
        stackViewPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:)))
//        buttonStackView.addGestureRecognizer(stackViewPanGesture!)
        collabNavigationView.buttonStackView.addGestureRecognizer(stackViewPanGesture!)
    }
        
    private func reconfigureGestureRecognizers () {
        
//        panGestureView.addGestureRecognizer(gestureViewPanGesture!)
//        buttonStackView.addGestureRecognizer(stackViewPanGesture!)
    }
    
    private func removeGestureRecognizers () {
        
        if let gestureViewGesture = gestureViewPanGesture, let stackViewGesture = stackViewPanGesture {
            
//            panGestureView.removeGestureRecognizer(gestureViewGesture)
//            buttonStackView.removeGestureRecognizer(stackViewGesture)
        }
    }
    
    //May not be neccasary because profile pics may already be obtained from the home view; leaving it here for now tho. Mainly because there may be cases where the user hasnt allowed for all the pics to be loaded yet, and its not the time for me to be setting up observors 
    private func retrieveMemberProfilePics () {

        if let members = collab?.members {
            
            var count = 0
            
            for member in members {
                
                if let memberIndex = firebaseCollab.friends.firstIndex(where: {$0.userID == member.userID}) {

                    collab?.members[count].profilePictureImage = firebaseCollab.friends[memberIndex].profilePictureImage
                }
                
                else {
                    
                    let memberIndex = count
                    
                    firebaseStorage.retrieveUserProfilePicFromStorage(userID: member.userID) { (profilePic, userID) in
                        
                        self.collab?.members[memberIndex].profilePictureImage = profilePic
                        
                        
                    }
                }
                
                count += 1
            }
        }
        
        else {
            
            print("something went wrong")
        }
    }
    

    
    @objc private func handlePan (sender: UIPanGestureRecognizer) {
        
        switch sender.state {
            
        case .began, .changed:
            
            if collabNavigationView.originalTableViewContentOffset == nil {
                
                //Setting the originalContentOffset so that the collabTableView will be animated back into the correct position once the panGesture has completed
                collabNavigationView.originalTableViewContentOffset = collabNavigationView.collabTableView.contentOffset.y
            }
            
            moveWithPan(sender: sender)
            
        case .ended:
            
            if (collabNavigationView.frame.minY > (collabHeaderView.frame.height / 2)) && (collabNavigationView.frame.minY < (UIScreen.main.bounds.height / 2)) {
                
                returnToOrigin()
            }
            
            else if (collabNavigationView.frame.minY < (collabHeaderView.frame.height / 2)) {
                
                expandView()
            }
            
            else if (collabNavigationView.frame.minY > (UIScreen.main.bounds.height / 2)) {
                
                shrinkView()
            }

        default:
            
            break
        }
    }
    
    private func moveWithPan (sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: view)
        
        let collabHeaderViewHeightConstraint = collabHeaderView.constraints.first(where: { $0.firstAttribute == .height })
        let collabNavigationViewTopAnchor = self.view.constraints.first(where: { $0.firstItem as? CollabNavigationView != nil && $0.firstAttribute == .top })
        let collabNavigationViewBottomAnchor = self.view.constraints.first(where: { $0.firstItem as? CollabNavigationView != nil && $0.firstAttribute == .bottom })
        
        if (collabNavigationView.frame.minY + translation.y) < (collabHeaderView.configureViewHeight() - 80) {
            
            //where you should do the nav view animation
            
            if collabNavigationViewBottomAnchor?.constant == 0 {
                
                collabNavigationView.collabTableView.contentOffset.y = collabNavigationView.collabTableView.contentOffset.y + translation.y
            }
            
            else {
                
                collabNavigationView.collabTableView.contentOffset.y += abs(collabNavigationViewBottomAnchor?.constant ?? 0)
            }
            
            collabNavigationViewTopAnchor?.constant += translation.y
            collabNavigationViewBottomAnchor?.constant = 0
            
//            the alpha animation stuff
            let collabNavigationViewMinY = collabNavigationView.frame.minY - 44 > 0 ? collabNavigationView.frame.minY - 44 : 0
            let adjustedAlpha: CGFloat = ((1 / (collabHeaderView.configureViewHeight() - 80)) * collabNavigationViewMinY)
            collabNavigationView.panGestureIndicator.alpha = adjustedAlpha > 0 ? adjustedAlpha : 0
            collabNavigationView.buttonStackView.alpha = adjustedAlpha > 0 ? adjustedAlpha : 0
        }
        
        else {
            
            //where you should do the header view animation
            
            collabNavigationViewTopAnchor?.constant += translation.y
            collabNavigationViewBottomAnchor?.constant = collabNavigationView.frame.minY - (collabHeaderView.configureViewHeight() - 80)
        
            let collabNavViewOriginMinY = collabHeaderView.configureViewHeight() - 80
            let collabNavViewDistanceFromBottom = (collabNavigationViewTopAnchor!.constant - collabNavViewOriginMinY) / (self.view.frame.height - collabNavViewOriginMinY)
            
            collabHeaderViewHeightConstraint?.constant = collabHeaderView.configureViewHeight() - (70 * collabNavViewDistanceFromBottom)
            
//            messageInputAccesoryView.alpha = 1 - (1 * collabNavViewDistanceFromBottom)
        }
        
        sender.setTranslation(CGPoint.zero, in: view)
    }
    
    @objc private func returnToOrigin (animateCollabHeaderView: Bool = true, scrollTableView: Bool = true) {
        
//        self.navigationItem.rightBarButtonItem = nil
        
        let collabNavigationViewTopAnchor = self.view.constraints.first(where: { $0.firstItem as? CollabNavigationView != nil && $0.firstAttribute == .top })
        let collabNavigationViewBottomAnchor = self.view.constraints.first(where: { $0.firstItem as? CollabNavigationView != nil && $0.firstAttribute == .bottom })
        let presentNavViewButtonBottomAnchor = self.view.constraints.first(where: { $0.firstItem?.tag == 1 && $0.firstAttribute == .bottom })
        let collabTableViewTopAnchor = collabNavigationView.constraints.first(where: { $0.firstItem as? UITableView != nil && $0.firstAttribute == .top })
        
        if animateCollabHeaderView {
            
            collabHeaderViewHeightConstraint?.constant = collabHeaderView.configureViewHeight()
        }
    
        collabNavigationViewTopAnchor?.constant = collabHeaderView.configureViewHeight() - 80
//        collabNavigationViewBottomAnchor?.constant = 0
        presentNavViewButtonBottomAnchor?.constant = 40
        collabTableViewTopAnchor?.constant = 10
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.65, initialSpringVelocity: 0, options: [.curveEaseInOut], animations: {

            self.view.layoutIfNeeded()
            
            self.collabHeaderView.alpha = 1
            
            self.collabHomeTableView.contentOffset.y = 0

            self.collabNavigationView.layer.cornerRadius = 27.5
            self.collabNavigationView.panGestureIndicator.alpha = 1
            self.collabNavigationView.buttonStackView.alpha = 1
            
            self.tabBar.alpha = self.selectedTab != "Messages" ? 1 : 0
            self.addBlockButton.alpha = self.selectedTab == "Blocks" ? 1 : 0
            self.seeHiddenBlocksButton.alpha = 0
        })
        
        collabNavigationViewBottomAnchor?.constant = 0
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut) {
            
            self.view.layoutIfNeeded()
        }

        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//
//            if self.selectedTab == "Blocks" {
//
//                self.collabNavigationView.dismissCalendar()
//            }
//        }
        
        if selectedTab == "Blocks" {

            collabNavigationView.dismissCalendar()
        }
        
        if selectedTab == "Messages" && self.messages?.count ?? 0 > 0 && scrollTableView {
            
            self.collabNavigationView.collabTableView.scrollToRow(at: IndexPath(row: ((self.messages?.count ?? 0) * 2) - 1, section: 0), at: .top, animated: true)
        }
    }
    
    private func shrinkView () {
        
        self.resignFirstResponder()
        
//        self.navigationItem.rightBarButtonItem = editCollabBarButton
        
        let collabHeaderViewHeightAnchor = collabHeaderView.constraints.first(where: { $0.firstAttribute == .height })
        let collabNavigationViewTopAnchor = self.view.constraints.first(where: { $0.firstItem as? CollabNavigationView != nil && $0.firstAttribute == .top })
        let collabNavigationViewBottomAnchor = self.view.constraints.first(where: { $0.firstItem as? CollabNavigationView != nil && $0.firstAttribute == .bottom })
        let presentNavViewButtonBottomAnchor = self.view.constraints.first(where: { $0.firstItem?.tag == 1 && $0.firstAttribute == .bottom })
        
        collabHeaderViewHeightAnchor?.constant = collabHeaderView.configureViewHeight() - 70
        collabNavigationViewTopAnchor?.constant = self.view.frame.height
        collabNavigationViewBottomAnchor?.constant = self.view.frame.height
        presentNavViewButtonBottomAnchor?.constant = -(self.view.frame.height - tabBar.frame.minY) - 15
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            
            self.view.layoutIfNeeded()
            
            self.tabBar.alpha = 1
            self.presentCollabNavigationViewButton.alpha = 1
            self.addBlockButton.alpha = 0
            self.seeHiddenBlocksButton.alpha = 0
            self.messageInputAccesoryView.alpha = 0
        }
    }
    
    internal func expandView () {
 
        let collabNavigationViewTopAnchor = self.view.constraints.first(where: { $0.firstItem as? CollabNavigationView != nil && $0.firstAttribute == .top })
        let collabNavigationViewBottomAnchor = self.view.constraints.first(where: { $0.firstItem as? CollabNavigationView != nil && $0.firstAttribute == .bottom })
        
        collabNavigationViewTopAnchor?.constant = 0
        collabNavigationViewBottomAnchor?.constant = 0
        
        if selectedTab == "Progress" || selectedTab == "Messages" {
            
            collabNavigationView.tableViewTopAnchorWithStackView?.constant = ((topBarHeight - collabNavigationView.buttonStackView.frame.maxY) + 5)//30
        }
        
        title = selectedTab
        
        viewExpanded()
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.curveEaseInOut], animations: {

            self.view.layoutIfNeeded()

            self.collabNavigationView.layer.cornerRadius = 0
            self.collabNavigationView.panGestureIndicator.alpha = 0
            self.collabNavigationView.buttonStackView.alpha = 0
        })

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {

            if self.selectedTab == "Blocks" {

                self.collabNavigationView.presentCalendar()
            }
        }

    }
    
    internal func viewExpanded () {
        
        navigationController?.navigationBar.configureNavBar(barBackgroundColor: .clear, barTintColor: .black, barStyleColor: .default)
        navigationItem.hidesBackButton = true

        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.stop, target: self, action: #selector(cancelButtonPressed))
        cancelButton.style = .done
        navigationItem.leftBarButtonItem = cancelButton
        
        if selectedTab == "Blocks" {
            
            let attachmentButton = UIBarButtonItem(image: UIImage(named: "info"), style: .done, target: self, action: #selector(infoButtonPressed))
            navigationItem.setRightBarButton(attachmentButton, animated: true)
        }
        
        else if selectedTab == "Messages" {
            
            let attachmentButton = UIBarButtonItem(image: UIImage(named: "attach"), style: .done, target: self, action: #selector(attachmentButtonPressed))
            navigationItem.setRightBarButton(attachmentButton, animated: true)
        }
        
        removeGestureRecognizers()
    }
    
    //MARK: - User Activity Functions
    
    #warning("yo this is a quick reminder that this works a little weird in this view; basically it'll always cause the messages in the messagehomeview to appear read even if the user hasn't moved to the messages tab in this view yet... sumn to look at and decide whether or not to fix in da future")
    @objc private func setUserActiveStatus () {
        
        if let collabID = collab?.collabID {
            
            //Probably move this func to firebaseCollab as well as firebaseMessaging; little weird using firebaseMessaging this weird imo
            firebaseMessaging.setActivityStatus(collabID: collabID, "now")
        }
    }
    
    @objc private func setUserInactiveStatus () {
          
        //if !infoViewBeingPresented {
            
        if let collabID = collab?.collabID {
                
                //Probably move this func to firebaseCollab as well as firebaseMessaging; little weird using firebaseMessaging this weird imo
                firebaseMessaging.setActivityStatus(collabID: collabID, Date())
            }
        //}
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveToSendPhotoView" {
            
            let sendPhotoVC = segue.destination as! SendPhotoMessageViewController
            sendPhotoVC.collabConversationID = collab?.collabID
            sendPhotoVC.reconfigureCollabViewDelegate = self
            sendPhotoVC.selectedPhoto = selectedPhoto
            
            removeObservors()
        }
        
        else if segue.identifier == "moveToAttachmentsView" {
            
            let attachmentsView = segue.destination as! CollabMessagesAttachmentsView
            attachmentsView.collabID = collab?.collabID
            attachmentsView.photoMessages = firebaseMessaging.filterPhotoMessages(messages: messages).sorted(by: { $0.timestamp > $1.timestamp })
        }
        
        else if segue.identifier == "moveToLocationsView" {
            
            let locationVC = segue.destination as! LocationsViewController
            locationVC.locations = collab?.locations
            
            if let cell = collabHomeTableView.cellForRow(at: IndexPath(row: 3, section: 1)) as? CollabHomeLocationsCell {
                
                locationVC.selectedLocationIndex = cell.selectedLocationIndex
            }
        }
        
        else if segue.identifier == "moveToConfigureBlockView" {
            
//            if let navController = segue.destination as? UINavigationController {
//                
//                let configureBlockVC = navController.viewControllers.first as! ConfigureBlockViewController
//                configureBlockVC.collab = collab
//            }
            
            let configureBlockVC: ConfigureBlockViewController = ConfigureBlockViewController()
            configureBlockVC.title = "Add a Block"
            
            configureBlockVC.collab = collab
            
            //This will set the block date to be the current selected date
            if let selectedDate = collabNavigationView.calendarView.selectedDates.first, !calendar.isDate(selectedDate, inSameDayAs: Date()) {
                
                configureBlockVC.block.starts = selectedDate
                configureBlockVC.block.ends = selectedDate.adjustTime(roundDown: false)
            }
            
            let configureBlockNavigationController = UINavigationController(rootViewController: configureBlockVC)
            configureBlockNavigationController.navigationBar.prefersLargeTitles = true
            
            self.present(configureBlockNavigationController, animated: true, completion: nil)
        }
        
        else if segue.identifier == "moveToSelectedBlockView" {
            
            if let navController = segue.destination as? UINavigationController {
                
                let selectedBlockVC = navController.viewControllers.first as! SelectedBlockViewController
                selectedBlockVC.collab = collab
                selectedBlockVC.block = selectedBlock
            }
        }
    }
    //MARK: - Add Cover Photo Function
    
    func presentAddPhotoAlert (tracker: String, shrinkView: Bool) {
        
        if shrinkView {
            
            self.shrinkView()
        }
        
        alertTracker = tracker
        
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
    
    
    private func prepViewForImageViewZooming () {
        
        imageViewBeingZoomed = true
        
        if messageInputAccesoryView.textViewContainer.messageTextView.isFirstResponder {
            
            keyboardWasPresent = true
        }
        
        else {
            
            keyboardWasPresent = false
        }
        
        self.messageInputAccesoryView.textViewContainer.messageTextView.resignFirstResponder()
        self.resignFirstResponder()
    }
    
    @objc private func dismissKeyboard () {
        
        messageInputAccesoryView.textViewContainer.messageTextView.resignFirstResponder()
    }
    
    @objc private func cancelButtonPressed () {
        
        navigationController?.navigationBar.configureNavBar(barBackgroundColor: .clear, barTintColor: .white, barStyleColor: .black)
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = nil
        navigationItem.hidesBackButton = false

        title = ""
        
        reconfigureGestureRecognizers()
        
        //Setting the original contentOffset so that the collabTableView will be animated back to the correct position after the view has returned to it's origin
        collabNavigationView.originalTableViewContentOffset = collabNavigationView.collabTableView.contentOffset.y
        
        returnToOrigin(scrollTableView: false)
        
        if selectedTab == "Messages" {

            dismissKeyboard ()
            
            messageInputAccesoryView.size = messageInputAccesoryView.configureSize()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                
                if self.messages?.count ?? 0 > 0 {
                    
                    self.collabNavigationView.collabTableView.scrollToRow(at: IndexPath(row: ((self.messages?.count ?? 0) * 2) - 1, section: 0), at: .top, animated: true)
                }
            }
        }
    }
    
    @objc private func dismissExpandedView () {

        if navigationItem.hidesBackButton == true /*&& tabBar.shouldHide == true */{
            
            cancelButtonPressed()
        }
    }
    
    @objc private func editCollabButtonPressed () {
        
        print("edit")
    }
    
    @objc private func infoButtonPressed () {
        
    }
    
    @objc private func attachmentButtonPressed () {
        
        performSegue(withIdentifier: "moveToAttachmentsView", sender: self)
    }
    
    
    
    @objc func editCoverButtonPressed () {
        
        zoomingMethods?.handleZoomOutOnImageView()
        
        presentAddPhotoAlert(tracker: "coverAlert", shrinkView: false)
    }
    
    @objc func deleteCoverButtonPressed () {
        
        SVProgressHUD.show()
        
        firebaseCollab.deleteCollabCoverPhoto(collabID: collab!.collabID) { [weak self] (error) in
            
            if error != nil {
                
                SVProgressHUD.showError(withStatus: error?.localizedDescription)
            }
            
            else {
                
                SVProgressHUD.dismiss()
                
                self?.collab?.coverPhotoID = nil
                self?.collab?.coverPhoto = nil
                self?.collabHeaderView.setCoverPhoto(self?.collab)
                
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut) {
                    
                    self?.zoomingMethods?.blackBackground?.backgroundColor = .clear
                    self?.zoomingMethods?.optionalButtons.forEach({ $0?.alpha = 0 })
                    self?.zoomingMethods?.zoomedInImageView?.alpha = 0
                    
                } completion: { (finished: Bool) in
                    
                    self?.zoomingMethods?.blackBackground?.removeFromSuperview()
                    self?.zoomingMethods?.optionalButtons.forEach({ $0?.removeFromSuperview() })
                    self?.zoomingMethods?.zoomedInImageView?.removeFromSuperview()
                }
            }
        }
    }


    
    func progressButtonTouchUpInside () {
        
        selectedTab = "Progress"
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
            
            self.collabNavigationView.collabTableView.alpha = 0
            self.addBlockButton.alpha = 0
            self.messageInputAccesoryView.alpha = 0
            
        }) { (finished: Bool) in
            
            self.collabNavigationView.collabTableView.reloadData()
            
//            self.collabNavigationView.collabTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                
                self.collabNavigationView.collabTableView.alpha = 1
                self.collabNavigationView.collabTableView.contentInset = UIEdgeInsets(top: 22, left: 0, bottom: 0, right: 0)
                self.tabBar.alpha = 1
            })
        }
    }
    
    func blocksButtonTouchUpInside () {
        
        selectedTab = "Blocks"
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                     
            self.collabNavigationView.collabTableView.alpha = 0
            self.messageInputAccesoryView.alpha = 0
            
        }) { (finished: Bool) in
            
            self.collabNavigationView.collabTableView.reloadData()
            
            self.scrollToCurrentDate()
            self.scrollToFirstBlock()
            
//            self.collabNavigationView.collabTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                
                self.collabNavigationView.collabTableView.alpha = 1
                self.tabBar.alpha = 1
                self.addBlockButton.alpha = 1
            })
        }
    }
    
    func messagesButtonTouchUpInside () {
        
        selectedTab = "Messages"
        
//        configureMessagingView()
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
            
            self.collabNavigationView.collabTableView.alpha = 0
            self.tabBar.alpha = 0
            self.addBlockButton.alpha = 0
            //self.tabBar.shouldHide = true

        }) { (finished: Bool) in
            
            self.collabNavigationView.collabTableView.reloadData()
            
            if self.messages?.count ?? 0 > 0 {
                
                self.collabNavigationView.collabTableView.scrollToRow(at: IndexPath(row: ((self.messages?.count ?? 0) * 2) - 1, section: 0), at: .top, animated: false)
            }
            
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {

//                self.messageInputAccesoryView.isHidden = false
                self.messageInputAccesoryView.alpha = 1
                
                self.collabNavigationView.collabTableView.alpha = 1
            })
        }
    }
    
    @objc private func presentNavViewButtonPressed () {
        
        returnToOrigin(animateCollabHeaderView: false)
        
        self.becomeFirstResponder()
        
        self.title = nil
        navigationController?.navigationBar.configureNavBar(barBackgroundColor: .clear, barTintColor: .white, barStyleColor: .black)
        
        self.collabHeaderViewHeightConstraint?.constant = collabHeaderView.configureViewHeight()
        
        UIView.animate(withDuration: 0.275, delay: 0, options: .curveEaseInOut) {
            
            self.view.layoutIfNeeded()
            
            self.collabHeaderView.alpha = 1
            
            self.collabHomeTableView.contentOffset.y = 0
        }
        
        if selectedTab == "Messages" {
            
            messageInputAccesoryView.alpha = 1
        }
    }
    
    @objc private func addBlockButtonPressed () {
        
        if navigationItem.hidesBackButton == false {
            
            expandView()
        }
        
        performSegue(withIdentifier: "moveToConfigureBlockView", sender: self)
    }
    
    @objc private func seeHiddenBlocksButtonPressed () {
        
        hiddenBlockVC = HiddenBlocksViewController()
        hiddenBlockVC?.hiddenBlocks = hiddenBlocks
        hiddenBlockVC?.blockSelectedDelegate = self
        
        let backBarButtonItem = UIBarButtonItem()
        backBarButtonItem.title = ""
        self.navigationItem.backBarButtonItem = backBarButtonItem
        
        self.navigationController?.pushViewController(hiddenBlockVC!, animated: true)
    }
}

extension CollabViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {

//        if gestureRecognizer == tabBar.dismissActiveTabBarSwipeGesture && otherGestureRecognizer == dismissExpandedViewGesture {
//
//            return true
//        }
//
//        else if gestureRecognizer == dismissExpandedViewGesture && otherGestureRecognizer == tabBar.dismissActiveTabBarSwipeGesture {
//
//            return true
//        }

        return false
    }
}

extension CollabViewController: BlockSelectedProtocol {
    
    func blockSelected (_ block: Block) {
        
        selectedBlock = block
        
        performSegue(withIdentifier: "moveToSelectedBlockView", sender: self)
    }
}

extension CollabViewController: CachePhotoProtocol {
    
    internal func cacheMessagePhoto(messageID: String, photo: UIImage?) {
        
        if let messageIndex = messages?.firstIndex(where: { $0.messageID == messageID }) {
            
            messages?[messageIndex].messagePhoto?["photo"] = photo
        }
    }
    
    func cacheCollabPhoto(photoID: String, photo: UIImage?) {
        
        collab?.photos[photoID] = photo
    }
    
    func cacheBlockPhoto(photoID: String, photo: UIImage?) {}
}

extension CollabViewController: PresentCopiedAnimationProtocol {
    
    func presentCopiedAnimation() {
        
        var collabNavigationViewTopAnchor: NSLayoutConstraint?
        var topAnchor: CGFloat
        
        self.view.constraints.forEach { (constraint) in
            
            if constraint.firstItem as? CollabNavigationView != nil && constraint.firstAttribute == .top {
                
                collabNavigationViewTopAnchor = constraint
            }
        }
        
        //The view hasn't been expanded
        if collabNavigationViewTopAnchor?.constant != 0 {
            
            let statusBarHeight = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
            topAnchor = statusBarHeight + 10
        }
        
        else {
            let navBarHeight = navigationController?.navigationBar.frame.maxY ?? 0
            topAnchor = navBarHeight + 10
        }
        
        copiedAnimationView?.presentCopiedAnimation(topAnchor: topAnchor)
    }
}

extension CollabViewController: ZoomInProtocol {
    
    func zoomInOnPhotoImageView(photoImageView: UIImageView) {
        
        prepViewForImageViewZooming() 
        
        zoomingMethods = ZoomingImageViewMethods(on: photoImageView, cornerRadius: 10, completion: { [weak self] in
        
            self?.becomeFirstResponder()
            
            if self?.keyboardWasPresent ?? false {
                
                self?.messageInputAccesoryView.textViewContainer.messageTextView.becomeFirstResponder()
            }
            
            self?.imageViewBeingZoomed = false
        })
        
        zoomingMethods?.performZoom()
    }
}

extension CollabViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func takePhotoSelected () {

        let imagePicker = UIImagePickerController()
        imagePicker.navigationBar.configureNavBar()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false

        self.present(imagePicker, animated: true, completion: nil)
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

            dismiss(animated: true, completion: nil)

            if alertTracker == "coverAlert" {

                collabHeaderView.configureCoverPhoto()
                
                let coverPhotoID = UUID().uuidString
                
                firebaseCollab.saveCollabCoverPhoto(collabID: collab!.collabID, coverPhotoID: coverPhotoID, coverPhoto: selectedImage) { [weak self] (error) in
                    
                    if error != nil {
                        
                        SVProgressHUD.showError(withStatus: error?.localizedDescription)
                    }
                    
                    else {
                        
                        self?.collab?.coverPhotoID = coverPhotoID
                        self?.collab?.coverPhoto = selectedImage
                        self?.collabHeaderView.setCoverPhoto(self?.collab)
                    }
                }
            }
            
            else if alertTracker == "attachmentAlert" {
                
                selectedPhoto = selectedImage
                
                performSegue(withIdentifier: "moveToSendPhotoView", sender: self)
            }
        }

        else {

            dismiss(animated: true) {

                SVProgressHUD.showError(withStatus: "Sorry, something went wrong selecting this photo")
            }
        }
    }
}

extension CollabViewController: LocationSelectedProtocol {
    
    func locationSelected(_ location: Location?) {
        
        let locationsVC: LocationsViewController = LocationsViewController()
        locationsVC.locations = collab?.locations
    
        if let cell = collabHomeTableView.cellForRow(at: IndexPath(row: 3, section: 1)) as? CollabHomeLocationsCell {
            
            locationsVC.selectedLocationIndex = cell.selectedLocationIndex
        }
        
        //Creating the navigation controller for the LocationsViewController
        let locationsNavigationController = UINavigationController(rootViewController: locationsVC)
        
        self.present(locationsNavigationController, animated: true, completion: nil)
        
//        performSegue(withIdentifier: "moveToLocationsView", sender: self)
    }
}

extension CollabViewController: CacheIconProtocol {
    
    func cacheIcon (linkID: String, icon: UIImage?) {
        
        if let linkIndex = collab?.links?.firstIndex(where: { $0.linkID == linkID }) {
            
            collab?.links?[linkIndex].icon = icon != nil ? icon : UIImage(named: "link")
            
            if let cell = collabHomeTableView.cellForRow(at: IndexPath(row: 2, section: 4)) as? CollabHomeLinksCell {
                
                cell.links = collab?.links
            }
        }
    }
}
