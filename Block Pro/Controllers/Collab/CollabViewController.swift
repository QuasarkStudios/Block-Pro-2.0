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
    var memberProfileVC: CollabMemberProfileViewController?
    
    lazy var collabHeaderView = CollabHeaderView(collab)
    lazy var collabHeaderViewHeightConstraint = collabHeaderView.constraints.first(where: { $0.firstAttribute == .height })
    
    lazy var collabNavigationView = CollabNavigationView(self, collabStartTime: collab?.dates["startTime"], collabDeadline: collab?.dates["deadline"])
    let presentCollabNavigationViewButton = UIButton(type: .system)
    
    lazy var collabCalendarView = CollabCalendarView(self, collabStartTime: collab?.dates["startTime"], collabDeadline: collab?.dates["deadline"])
    
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
    
    let formatter = DateFormatter()
    let calendar = Calendar.current
    
    var blocks: [Block]?
    var selectedBlock: Block?
    var hiddenBlocks: [Block] = []
    var filteredBlocks: [Block] = []
    
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

    var calendarPresented: Bool = false
    
    var imageViewBeingZoomed: Bool?
    var keyboardWasPresent: Bool?
    
    var tabBarWasHidden: Bool = false
    
    var searchBeingConducted: Bool = false
    var blocksFiltered: Bool = false
    
    var collabNavigationViewTopAnchor: NSLayoutConstraint?
    
//    var viewAppeared: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureGestureRecognizers()
        
        configureHeaderView()
        configureCollabHomeTableView()
        
        configureCalendarView()
        
        configurePresentCollabNavigationViewButton()
        configureCollabNavigationView()
        
//        configureCalendarView()
        
        configureAddBlockButton()
        configureSeeHiddenBlocksButton()
        
        configureMessagingView() //Call first
        configureProgressView()
        configureBlockView()
        
        retrieveBlocks()
        retrieveMessages()
        
        setUserActiveStatus()
        
        retrieveMemberProfilePics()
        
        messageInputAccesoryView.alpha = 0
        
//        print(collab?.collabID)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        configureNavBar()
        
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
    
    override func didReceiveMemoryWarning() {
        
        var count = 0
        
        while count < messages?.count ?? 0 {
            
            messages?[count].messagePhoto?["photo"] = nil
            
            count += 1
        }
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
                
                return 2//3
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
            
            if selectedTab == "Progress" {
                
                return blocksFiltered ? filteredBlocks.count : blocks?.count ?? 0
            }
            
            else if selectedTab == "Blocks" {
                
                //still needs testing
                if var startTime = collab?.dates["startTime"], var deadline = collab?.dates["deadline"] {

                    //Formatting the startTime and deadline so that the only the date and not the time is truly used
                    formatter.dateFormat = "yyyy MM dd"
                    startTime = formatter.date(from: formatter.string(from: startTime)) ?? Date()
                    deadline = formatter.date(from: formatter.string(from: deadline)) ?? Date()
                    
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
                
                return messagingMethods.numberOfRowsInSection(messages: messages)
            }
            
            else {
                
                return 1 //Will be used to during tab transitions
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
        if tableView == collabHomeTableView {
            
            if indexPath.section == 0 {
                
//                if indexPath.row == 0 {
//
//                    let cell = tableView.dequeueReusableCell(withIdentifier: "collabHomeSectionHeaderCell", for: indexPath) as! CollabHomeSectionHeaderCell
//                    cell.selectionStyle = .none
//
//                    cell.sectionNameLabel.text = "Members"
//
//                    return cell
//                }
                
                if indexPath.row == 0 {
                    
                    let cell = UITableViewCell()
                    cell.isUserInteractionEnabled = false
                    return cell
                }
                
                else {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "collabHomeMembersCell", for: indexPath) as! CollabHomeMembersCell
                    cell.selectionStyle = .none
                    
                    cell.collabMemberDelegate = self
                    
                    cell.collab = collab
                    cell.blocks = blocks
                    
                    return cell
                }
                
//                if indexPath.row == 0 {
//
//                    let cell = tableView.dequeueReusableCell(withIdentifier: "collabHomeMembersCell", for: indexPath) as! CollabHomeMembersCell2
//                    cell.selectionStyle = .none
//
//                    cell.collab = collab
//
//                    return cell
//                }
//
//                else if indexPath.row == 1 {
//
//                    let cell = UITableViewCell()
//                    cell.isUserInteractionEnabled = false
//                    return cell
//                }
//
//                else {
//
//                    let cell = tableView.dequeueReusableCell(withIdentifier: "collabHomeMembersCell", for: indexPath) as! CollabHomeMembersCell
//                    cell.selectionStyle = .none
//                    cell.collab = collab
//
//                    return cell
//                }
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
            
            if selectedTab == "Progress" {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "blockCell", for: indexPath) as! BlockCell
                cell.selectionStyle = .none
                
                cell.formatter = formatter
                cell.block = blocksFiltered ? filteredBlocks[indexPath.row] : blocks?[indexPath.row]
                
                return cell
            }
            
            else if selectedTab == "Blocks" {
                
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
                
                return messagingMethods.cellForRowAt(indexPath: indexPath, messages: messages, members: collab?.members)
            }
            
            else {
                
                //Will be used to during tab transitions
                let cell = UITableViewCell()
                cell.isUserInteractionEnabled = false
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView == collabHomeTableView {
            
            if indexPath.section == 0 {
                
                if indexPath.row == 0 {
                    
                    return 10
                }
                
                else {
                    
                    if collab?.members.count ?? 0 > 1 {
                        
                        return 185
                    }
                    
                    else {
                        
                        return 160
                    }
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
            
            if selectedTab == "Progress" {
                
                if blocksFiltered {
                    
                    if filteredBlocks[indexPath.row].members?.count ?? 0 > 0 {
                        
                        return 210
                    }
                    
                    else {
                        
                        return 175
                    }
                }
                
                else {
                    
                    if blocks?[indexPath.row].members?.count ?? 0 > 0 {
                        
                        return 210
                    }
                    
                    else {
                        
                        return 175
                    }
                }
                
                
            }
            
            else if selectedTab == "Blocks" {
                
                return 2210
            }
            
            else if selectedTab == "Messages" {
                
                return messagingMethods.heightForRowAt(indexPath: indexPath, messages: messages)
            }
            
            else {
                
                return 500 //Will be used to during tab transitions
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if tableView == collabHomeTableView && indexPath.section == (tableView.numberOfSections - 1) {
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                
                self.presentCollabNavigationViewButton.alpha = 0
                self.tabBar.alpha = 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if tableView == collabHomeTableView && indexPath.section == (tableView.numberOfSections - 1) {
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                
                self.presentCollabNavigationViewButton.alpha = 1
                self.tabBar.alpha = 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == collabNavigationView.collabTableView, selectedTab == "Progress" {
            
            if let cell = tableView.cellForRow(at: indexPath) as? BlockCell {
                
                if let block = blocks?.first(where: { $0.blockID == cell.block?.blockID }) {
                    
                    selectedBlock = block
                    
                    performSegue(withIdentifier: "moveToSelectedBlockView", sender: self)
                }
                
                else {
                    
                    SVProgressHUD.showError(withStatus: "Sorry, this block may have been deleted")
                }
            }
        }
    }
    
    var previousContentOffsetYCoord: CGFloat = 0
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == collabHomeTableView {
            
            if scrollView.contentOffset.y >= 0 {
                
                if ((collabHeaderViewHeightConstraint?.constant ?? 0) - scrollView.contentOffset.y) > topBarHeight {
                    
                    collabHeaderViewHeightConstraint?.constant -= scrollView.contentOffset.y
                    scrollView.contentOffset.y = 0
                    
                    let alphaPart = 1 / (collabHeaderView.configureViewHeight() - 70/*80*/ - topBarHeight)
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
                
                if (collabHeaderViewHeightConstraint?.constant ?? 0) < collabHeaderView.configureViewHeight() - 70/*80*/ {
                    
                    collabHeaderViewHeightConstraint?.constant = collabHeaderView.configureViewHeight() - 70//80
                    
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
            
            if selectedTab == "Progress" {
                
                if scrollView.contentOffset.y >= 0 {
                    
                    //If the progress view height minus the scrollView contentOffset is larger than 67, it's minimum allowable height
                    if (collabNavigationView.progressViewHeightConstraint?.constant ?? 67) - scrollView.contentOffset.y > 67 {
                        
                        collabNavigationView.progressViewHeightConstraint?.constant -= scrollView.contentOffset.y //Decrementing the height of the progressView
                        
                        collabNavigationView.tableViewTopAnchorWithStackView?.constant -= scrollView.contentOffset.y //Decrementing the topAnchor of the tableView
                        
                        scrollView.contentOffset.y = 0
                    }
                    
                    //If the progress view height minus the scrollView contentOffset is less than 67
                    else {
                        
                        //This height will only allow the searchBar to be shown
                        collabNavigationView.progressViewHeightConstraint?.constant = 67
                        
                        //If the collabNavigationView is expanded
                        if navigationItem.hidesBackButton {
                            
                            //Setting the top anchor based on if the iPhone has a notch -- an iPhone with a notch will cause the progressView to have a larger topAnchor
                            //Therefore the top anchor of the tableView will also have to be larger by 20 points to compensate
                            collabNavigationView.tableViewTopAnchorWithStackView?.constant = keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 92 : 72
                        }
                        
                        //The collabNavigationView isn't expanded
                        else {
                            
                            //Setting the topAnchor when only the searchBar of the collabProgress view is shown
                            collabNavigationView.tableViewTopAnchorWithStackView?.constant = 72
                        }
                    }
                }
                
                else {
                    
                    let maximumProgressViewHeight: CGFloat = ((UIScreen.main.bounds.width * 0.5) + 12 + 55) + 87
                    
                    //If the progressView height is less than the maximum allowable height for the progressView
                    if collabNavigationView.progressViewHeightConstraint?.constant ?? 87 < maximumProgressViewHeight {
                        
                        collabNavigationView.progressViewHeightConstraint?.constant = maximumProgressViewHeight
                        
                        //If the collabNavigationView is expanded
                        if navigationItem.hidesBackButton {
                            
                            //Setting the top anchor based on if the iPhone has a notch -- an iPhone with a notch will cause the progressView to have a larger topAnchor
                            //Therefore the top anchor of the tableView will also have to be larger by 20 points to compensate
                            collabNavigationView.tableViewTopAnchorWithStackView?.constant = maximumProgressViewHeight + (keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 20 : 0)
                        }
                        
                        //The collabNavigationView isn't expanded
                        else {
                            
                            //Setting to the value that won't cause the tableView constraints to break
                            collabNavigationView.tableViewTopAnchorWithStackView?.constant = collabNavigationView.maximumTableViewTopAnchorWithStackView
                        }
                        
                        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                            
                            self.collabNavigationView.layoutIfNeeded()
                        }
                    }
                }
            }
            
            else if selectedTab == "Blocks" {
                
                //If the tableView is scrolling down
                if previousContentOffsetYCoord < scrollView.contentOffset.y {
                    
                    if let firstVisibleCellIndexPath = collabNavigationView.collabTableView.indexPathsForVisibleRows?.first {
                        
                        //"isDragging" checks if the user is the one who caused the scrollView to scroll
                        if let startTime = collab?.dates["startTime"], let adjustedDate = calendar.date(byAdding: .day, value: firstVisibleCellIndexPath.row, to: startTime), !calendar.isDate(adjustedDate, inSameDayAs: collabNavigationView.calendarView.selectedDates.first ?? Date()), scrollView.isDragging {
                            
                            collabCalendarView.calendarView.selectDates([adjustedDate])
                            collabCalendarView.calendarView.scrollToDate(adjustedDate)
                            
                            collabNavigationView.calendarView.selectDates([adjustedDate])
                            collabNavigationView.calendarView.scrollToDate(adjustedDate)

                            let vibrateMethods = VibrateMethods()
                            vibrateMethods.warningVibration()
                        }
                    }
                }
                
                //If the tableView is scrolling up
                else {
                    
                    if let lastVisibleCellIndexPath = collabNavigationView.collabTableView.indexPathsForVisibleRows?.last {
                
                        //"isDragging" checks if the user is the one who caused the scrollView to scroll
                        if let startTime = collab?.dates["startTime"], let adjustedDate = calendar.date(byAdding: .day, value: lastVisibleCellIndexPath.row, to: startTime), !calendar.isDate(adjustedDate, inSameDayAs: collabNavigationView.calendarView.selectedDates.first ?? Date()), scrollView.isDragging {
                            
                            collabCalendarView.calendarView.selectDates([adjustedDate])
                            collabCalendarView.calendarView.scrollToDate(adjustedDate)
                            
                            collabNavigationView.calendarView.selectDates([adjustedDate])
                            collabNavigationView.calendarView.scrollToDate(adjustedDate)
                
                            let vibrateMethods = VibrateMethods()
                            vibrateMethods.warningVibration()
                        }
                    }
                }
                
                previousContentOffsetYCoord = scrollView.contentOffset.y
                
                determineHiddenBlocks(scrollView)
            }
        }
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        
        if let startTime = collab?.dates["startTime"] {
            
            collabCalendarView.calendarView.selectDates([startTime])
            collabCalendarView.calendarView.scrollToDate(startTime)
            
            collabNavigationView.calendarView.selectDates([startTime])
            collabNavigationView.calendarView.scrollToDate(startTime)
        }
        
        return true
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if scrollView == collabNavigationView.collabTableView {
            
            if selectedTab == "Progress" {
                
                let progressViewHeight: CGFloat = ((UIScreen.main.bounds.width * 0.5) + 12 + 55) + 87
                
                if (collabNavigationView.progressViewHeightConstraint?.constant ?? 0) < progressViewHeight * 0.7 && (collabNavigationView.progressViewHeightConstraint?.constant ?? 0) != 67 {
                    
                    //This height will only allow the searchBar to be shown
                    collabNavigationView.progressViewHeightConstraint?.constant = 67
                    
                    //If the collabNavigationView is expanded
                    if navigationItem.hidesBackButton {
                        
                        //Setting the top anchor based on if the iPhone has a notch -- an iPhone with a notch will cause the progressView to have a larger topAnchor
                        //Therefore the top anchor of the tableView will also have to be larger by 20 points to compensate
                        collabNavigationView.tableViewTopAnchorWithStackView?.constant = keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 92 : 72
                    }
                    
                    //The collabNavigationView isn't expanded
                    else {
                        
                        //Setting the topAnchor when only the searchBar of the collabProgress view is shown
                        collabNavigationView.tableViewTopAnchorWithStackView?.constant = 72
                    }
                    
                    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                        
                        self.view.layoutIfNeeded()
                    }

                }
                
                //Will handle the progress animation
                if blocks?.count ?? 0 == 0 {
                    
                    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                        
                        self.collabNavigationView.handleProgressAnimation()
                        
                        self.view.layoutIfNeeded()
                    }
                }
            }
            
            else if selectedTab == "Blocks" {
                
                //If the calendar isn't presented
                //If the calendar is presented and the "collabNavigationView" has a height that doesn't require the "addBlockButton" and "tabBar" to be hidden
                //If the calendar is presented and the view is expanded
                if !calendarPresented || (calendarPresented && (self.addBlockButton.frame.minY - 330 >= 200 || collabNavigationViewTopAnchor?.constant ?? 0 == 0)) {
                    
                    if velocity.y < 0 {
                        
                        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                            
                            self.addBlockButton.alpha = 1
                            self.tabBar.alpha = 1
                        }
                    }
                    
                    else if velocity.y > 0.5 {
                        
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
        
        //If the collabNavigationView is expanded or the calendar is present
        if navigationItem.hidesBackButton == true {

            //If the collabNavigationView is expanded
            if collabNavigationViewTopAnchor?.constant == 0 {

                self.navigationController?.navigationBar.configureNavBar(barBackgroundColor: .clear, barTintColor: .black, barStyleColor: .default)
            }

            else {

                self.navigationController?.navigationBar.configureNavBar(barBackgroundColor: .clear, barTintColor: .white, barStyleColor: .black)
            }
        }
        
        else {
            
            //If the view has a title evident that the collabHeaderView or collabCalendarView is hidden
            if self.title?.leniantValidationOfTextEntered() ?? false {
                
                self.navigationController?.navigationBar.configureNavBar(barBackgroundColor: .clear, barTintColor: .black, barStyleColor: .default)
            }
            
            else {
                
                self.navigationController?.navigationBar.configureNavBar(barBackgroundColor: .clear, barTintColor: .white, barStyleColor: .black)
            }
        }
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
        
//        collabHomeTableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        collabHomeTableView.separatorStyle = .none
        collabHomeTableView.showsVerticalScrollIndicator = false
        collabHomeTableView.delaysContentTouches = false
        
        collabHomeTableView.register(CollabHomeSectionHeaderCell.self, forCellReuseIdentifier: "collabHomeSectionHeaderCell")
//        collabHomeTableView.register(UINib(nibName: "CollabHomeMembersCell", bundle: nil), forCellReuseIdentifier: "collabHomeMembersCell")
        collabHomeTableView.register(CollabHomeMembersCell.self, forCellReuseIdentifier: "collabHomeMembersCell")
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
            collabNavigationView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
        
        collabNavigationViewTopAnchor = collabNavigationView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: collabHeaderView.configureViewHeight() - 80)
        collabNavigationViewTopAnchor?.isActive = true
        
        collabNavigationView.collabViewController = self
    }
    
    private func configureCalendarView () {

        self.view.addSubview(collabCalendarView)
        collabCalendarView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            collabCalendarView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            collabCalendarView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            collabCalendarView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            collabCalendarView.heightAnchor.constraint(equalToConstant: topBarHeight + 425)
        
        ].forEach({ $0.isActive = true })
        
        collabCalendarView.isHidden = true
    }
    
    //should probably move all these configuration funcs for the navigation view to the navigation class
    private func configureProgressView () {
        
        collabNavigationView.collabTableView.scrollsToTop = true
        
        collabNavigationView.collabTableView.register(BlockCell.self, forCellReuseIdentifier: "blockCell")
    }
    
    private func configureBlockView () {
        
        collabNavigationView.collabTableView.dataSource = self
        collabNavigationView.collabTableView.delegate = self
        
        collabNavigationView.collabTableView.separatorStyle = .none
        
        collabNavigationView.collabTableView.estimatedRowHeight = 0
        
        collabNavigationView.collabTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 20 : 0, right: 0)
        collabNavigationView.collabTableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 40 : 0, right: 0)
        
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

        let dismissKeyboardTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardTap))
        dismissKeyboardTapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(dismissKeyboardTapGesture)
        
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
            
//            if selectedTab == "Blocks" && collabNavigationView.originalTableViewContentOffset == nil {
//
//                //Setting the originalContentOffset so that the collabTableView will be animated back into the correct position once the panGesture has completed
//                collabNavigationView.originalTableViewContentOffset = collabNavigationView.collabTableView.contentOffset.y
//            }
            
            moveWithPan(sender: sender)
            
        case .ended:
            
            if !calendarPresented {
                
                if (collabNavigationView.frame.minY > (collabHeaderView.frame.height / 2)) && (collabNavigationView.frame.minY < (UIScreen.main.bounds.height / 2)) {
                    
                    returnToOrigin()
                }
                
                else if (collabNavigationView.frame.minY < (collabHeaderView.frame.height / 2)) {
                    
                    expandView()
                }
                
                else if (collabNavigationView.frame.minY > (UIScreen.main.bounds.height / 2)) {
                    
                    shrinkView()
                }
            }
            
            else {
                
                //If the minY of the collabNavigationView is less than half of it's preset anchor when the calendar is present
                if collabNavigationView.frame.minY < (topBarHeight + (collabCalendarView.calendarView.visibleDates().monthDates.first?.date.determineNumberOfWeeks() == 4 ? 330 : 376)) / 2 {
                    
                    expandView()
                }
                
                else {
                    
                    returnToOrigin()
                }
            }
            
        default:
            
            break
        }
    }
    
    private func moveWithPan (sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: view)
        
        let collabHeaderViewHeightConstraint = collabHeaderView.constraints.first(where: { $0.firstAttribute == .height })
        let collabNavigationViewBottomAnchor = self.view.constraints.first(where: { $0.firstItem as? CollabNavigationView != nil && $0.firstAttribute == .bottom })
        
        if !calendarPresented {
            
            if (collabNavigationView.frame.minY + translation.y) < (collabHeaderView.configureViewHeight() - 80) {
                
                //where you should do the nav view animation
                
                //Took this away because I couldn't find a reason to keep it; remove towards the completion of the view
                //ProgressView animation now requires some updates as a result and other areas also may require updates *updated*
//                if collabNavigationViewBottomAnchor?.constant == 0 {
//
//                    collabNavigationView.collabTableView.contentOffset.y = collabNavigationView.collabTableView.contentOffset.y + translation.y
//                }
//
//                else {
//
//                    collabNavigationView.collabTableView.contentOffset.y += abs(collabNavigationViewBottomAnchor?.constant ?? 0)
//                }
                
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
                
                if selectedTab == "Messages" {
                    
                    messageInputAccesoryView.alpha = 1 - (1 * collabNavViewDistanceFromBottom) // was commented out but i am reversing that and seeing what happens (Feb. 17)
                }
            }
        }
        
        //If the calendar is presented
        else {
            
            //If the navigationViewTopAnchor + the translation is less than 330/376, the preset anchor for when the calendar view is presented
            if ((collabNavigationViewTopAnchor?.constant ?? 0) + translation.y) < topBarHeight + (collabCalendarView.calendarView.visibleDates().monthDates.first?.date.determineNumberOfWeeks() == 4 ? 330 : 376) {
                
                collabNavigationViewTopAnchor?.constant += translation.y
                collabNavigationViewBottomAnchor?.constant = 0
            }
            
            else {
                
                collabNavigationViewTopAnchor?.constant = topBarHeight + (collabCalendarView.calendarView.visibleDates().monthDates.first?.date.determineNumberOfWeeks() == 4 ? 330 : 376)
                collabNavigationViewBottomAnchor?.constant = 0
            }
        }
        
        sender.setTranslation(CGPoint.zero, in: view)
    }
    
    @objc private func returnToOrigin (animateCollabHeaderView: Bool = true, scrollTableView: Bool = true) {
        
        collabNavigationView.panGestureView.isUserInteractionEnabled = true
        
        resetConstraintsForReturnToOrigin(animateCollabHeaderView)
        
        if selectedTab == "Progress" {
            
            if blocks?.count ?? 0 == 0 {
                
                //Should be fine being called from here instead of from the animation block
                collabNavigationView.handleProgressAnimation()
            }
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.65, initialSpringVelocity: 0, options: [.curveEaseInOut], animations: {

            self.view.layoutIfNeeded()
            
            self.collabHeaderView.alpha = 1
            
            self.collabHomeTableView.contentOffset.y = 0

            self.collabNavigationView.layer.cornerRadius = 27.5
            self.collabNavigationView.panGestureIndicator.alpha = 1
            self.collabNavigationView.buttonStackView.alpha = !self.calendarPresented ? 1 : 0
            self.collabNavigationView.messagesAnimationView.animationTitleLabel.alpha = 0
            
            self.seeHiddenBlocksButton.alpha = 0
            
            if !self.calendarPresented {
                
                self.tabBar.alpha = self.selectedTab != "Messages" ? 1 : 0
                self.addBlockButton.alpha = self.selectedTab == "Blocks" ? 1 : 0
            }
            
            else {
                
                //Will remove the "addBlockButton" and the "tabBar" if the collabNavigationView will be too small once the calendar is presented
                self.tabBar.alpha = (self.addBlockButton.frame.minY - 330 >= 200) ? 1 : 0
                self.addBlockButton.alpha = (self.addBlockButton.frame.minY - 330 >= 200) ? 1 : 0
            }
        })
        
        let collabNavigationViewBottomAnchor = self.view.constraints.first(where: { $0.firstItem as? CollabNavigationView != nil && $0.firstAttribute == .bottom })
        collabNavigationViewBottomAnchor?.constant = 0
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut) {
            
            self.view.layoutIfNeeded()
        }
        
        if selectedTab == "Blocks" {

            collabNavigationView.dismissCalendar()
        }
        
        if selectedTab == "Messages" && self.messages?.count ?? 0 > 0 && scrollTableView {
            
            self.collabNavigationView.collabTableView.scrollToRow(at: IndexPath(row: ((self.messages?.count ?? 0) * 2) - 1, section: 0), at: .top, animated: true)
        }
    }
    
    private func shrinkView () {
        
        self.resignFirstResponder()
        
        let collabHeaderViewHeightAnchor = collabHeaderView.constraints.first(where: { $0.firstAttribute == .height })
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
        
        viewExpanded() //Call here
        
        collabNavigationView.panGestureView.isUserInteractionEnabled = false
        
        let collabNavigationViewBottomAnchor = self.view.constraints.first(where: { $0.firstItem as? CollabNavigationView != nil && $0.firstAttribute == .bottom })
        
        collabNavigationViewTopAnchor?.constant = 0
        collabNavigationViewBottomAnchor?.constant = 0
        
        if selectedTab == "Messages" {
            
            collabNavigationView.tableViewTopAnchorWithStackView?.constant = ((topBarHeight - collabNavigationView.buttonStackView.frame.maxY) + 5)
            
            collabNavigationView.messagesAnimationViewCenterYAnchor?.constant = -35
        }
        
        else if selectedTab == "Progress" {
            
            collabNavigationView.progressViewTopAnchorWithStackView?.constant = keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 30 : 10
            
            let progressViewHeight: CGFloat = ((UIScreen.main.bounds.width * 0.5) + 12 + 55) + 87
            
            //Adjusts the topAnchor of the tableView when the progressView is completely present as the view is being expanded
            if (collabNavigationView.progressViewHeightConstraint?.constant ?? 0) == progressViewHeight {
                
                //Setting the top anchor based on if the iPhone has a notch -- an iPhone with a notch will cause the progressView to have a larger topAnchor
                //Therefore the top anchor of the tableView will also have to be larger by 20 points to compensate
                collabNavigationView.tableViewTopAnchorWithStackView?.constant = progressViewHeight + (keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 20 : 0)
            }
            
            if blocks?.count ?? 0 == 0 {
                
                //Should be fine being called from here instead of from the animation block
                collabNavigationView.handleProgressAnimation()
            }
        }
        
        title = selectedTab
        
//        viewExpanded()
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.curveEaseInOut], animations: {

            self.view.layoutIfNeeded()

            self.collabNavigationView.layer.cornerRadius = 0
            self.collabNavigationView.panGestureIndicator.alpha = 0
            self.collabNavigationView.buttonStackView.alpha = 0
            
            self.collabNavigationView.messagesAnimationView.animationTitleLabel.alpha = self.messages?.count ?? 0 == 0 ? 1 : 0
            
            if self.selectedTab == "Blocks" {
                
                self.addBlockButton.alpha = 1
                self.tabBar.alpha = 1
            }
        })

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {

            if self.selectedTab == "Blocks" {
                
                self.collabNavigationView.presentCalendar()
                
                self.determineHiddenBlocks(self.collabNavigationView.collabTableView)
            }
        }

    }
    
    internal func viewExpanded () {
        
        navigationController?.navigationBar.configureNavBar(barBackgroundColor: .clear, barTintColor: .black, barStyleColor: .default)
        navigationItem.hidesBackButton = true

        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.stop, target: self, action: #selector(cancelButtonPressed))
        cancelButton.style = .done
        navigationItem.leftBarButtonItem = cancelButton
        
        if selectedTab == "Messages" {
            
            let attachmentButton = UIBarButtonItem(image: UIImage(named: "attach"), style: .done, target: self, action: #selector(attachmentButtonPressed))
            navigationItem.setRightBarButton(attachmentButton, animated: true)
        }
        
        removeGestureRecognizers()
    }
    
    private func resetConstraintsForReturnToOrigin (_ animateCollabHeaderView: Bool) {
        
        let presentNavViewButtonBottomAnchor = self.view.constraints.first(where: { $0.firstItem?.tag == 1 && $0.firstAttribute == .bottom })
        let collabTableViewTopAnchor = collabNavigationView.constraints.first(where: { $0.firstItem as? UITableView != nil && $0.firstAttribute == .top })
        
        if animateCollabHeaderView {
            
            collabHeaderViewHeightConstraint?.constant = collabHeaderView.configureViewHeight()
        }
    
        if calendarPresented {
            
            collabNavigationViewTopAnchor?.constant = topBarHeight + (collabCalendarView.calendarView.visibleDates().monthDates.first?.date.determineNumberOfWeeks() == 4 ? 330 : 376)
        }
        
        else {
            
            collabNavigationViewTopAnchor?.constant = collabHeaderView.configureViewHeight() - 80
        }
        
        presentNavViewButtonBottomAnchor?.constant = 40
        
        if selectedTab == "Progress" {
            
            collabNavigationView.progressViewTopAnchorWithStackView?.constant = 10
            
            //Checks to see if the currentHeight of the progressView will cause the height of the tableView to be less than 0
            //Explanation for the math in this statement is in the collabNavigationView when initializing the computed property "maximumTableViewTopAnchorWithStackView"
            if (collabHeaderView.configureViewHeight() - 80) + (27.5 + 40) + (collabNavigationView.progressViewHeightConstraint?.constant ?? 0) + 10 > UIScreen.main.bounds.height {
                
                collabNavigationView.tableViewTopAnchorWithStackView?.constant = collabNavigationView.maximumTableViewTopAnchorWithStackView
            }
        }
        
        else if selectedTab == "Blocks" {
            
            collabTableViewTopAnchor?.constant = 10
        }
        
        else if selectedTab == "Messages" {
            
            collabTableViewTopAnchor?.constant = 10
            
            collabNavigationView.messagesAnimationViewCenterYAnchor?.constant = 0
        }
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
    
    func presentCalendar () {
        
        self.becomeFirstResponder() //Fixes bug that was causing the messageInputAccesoryView from being shown once the calendar was presented when the collabNavigationView was shrunken
        
        var delay: Double = 0
        
        calendarPresented = true
        
        collabCalendarView.blocks = blocks
        collabCalendarView.selectedDate = collabNavigationView.calendarView.selectedDates.first

        if selectedTab == "Progress" || selectedTab == "Messages" {
            
            //Calling this func will allow for the buttons to be animated to their correct color as well as allow for the tableView to be changed
            collabNavigationView.blocksButtonTouchUpInside()
            
            delay = 0.25 //Slight delay to improve animations
        }
        
        //Adjusting the position of the panGetsureView
        collabNavigationView.insertSubview(collabNavigationView.panGestureView, aboveSubview: collabNavigationView.collabTableView)
        
        //Reconfiguring constraints
        collabNavigationViewTopAnchor?.constant = topBarHeight + (collabNavigationView.calendarView.selectedDates.first?.determineNumberOfWeeks() == 4 ? 330 : 376)
        collabNavigationView.buttonStackView.constraints.forEach { (constraint) in

            if constraint.firstAttribute == .height {

                constraint.constant = 0
            }
        }
        
        //Animations
        UIView.animate(withDuration: 0.5, delay: delay, usingSpringWithDamping: 0.65, initialSpringVelocity: 0, options: [.curveEaseInOut], animations: {

            self.view.layoutIfNeeded()

            self.collabNavigationView.buttonStackView.alpha = 0
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {

            UIView.transition(from: self.collabHeaderView, to: self.collabCalendarView, duration: 0.35, options: [.transitionCrossDissolve, .showHideTransitionViews], completion: nil)

            self.navigationItem.hidesBackButton = true

            let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.stop, target: self, action: #selector(self.dismissCalendar))
            cancelButton.style = .done
            self.navigationItem.leftBarButtonItem = cancelButton
        }
        
        UIView.animate(withDuration: 0.35, delay: delay, options: .curveEaseInOut) {
            
            //Will remove the "addBlockButton" and the "tabBar" if the collabNavigationView will be too small once the calendar is presented
            self.addBlockButton.alpha = (self.addBlockButton.frame.minY - 330 >= 200) ? 1 : 0
            self.tabBar.alpha = (self.addBlockButton.frame.minY - 330 >= 200) ? 1 : 0
        }
    }
    
    @objc private func dismissCalendar () {
        
        calendarPresented = false
        
        navigationController?.navigationBar.configureNavBar(barBackgroundColor: .clear, barTintColor: .white, barStyleColor: .black)
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = nil
        navigationItem.hidesBackButton = false
        
        //Adjusting the position of the panGetsureView
        collabNavigationView.insertSubview(collabNavigationView.panGestureView, aboveSubview: collabNavigationView.panGestureIndicator)
        
//        collabNavigationView.originalTableViewContentOffset = collabNavigationView.collabTableView.contentOffset.y
//        returnToOrigin(scrollTableView: false)
        
        //Resetting constraints
        collabHeaderViewHeightConstraint?.constant = collabHeaderView.configureViewHeight()
        collabNavigationViewTopAnchor?.constant = collabHeaderView.configureViewHeight() - 80
        
        collabNavigationView.buttonStackView.constraints.forEach { (constraint) in

            if constraint.firstAttribute == .height {

                constraint.constant = 40
            }
        }

        //Animations
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.65, initialSpringVelocity: 0, options: [.curveEaseInOut], animations: {

            self.view.layoutIfNeeded()

            self.collabNavigationView.buttonStackView.alpha = 1
        })

        UIView.transition(from: collabCalendarView, to: collabHeaderView, duration: 0.35, options: [.transitionCrossDissolve, .showHideTransitionViews]) { (finished: Bool) in
            
            //Once transition is completed
            UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut) {

                self.addBlockButton.alpha = 1
                self.tabBar.alpha = 1
            }
        }
    }
    
    internal func determineHiddenBlocks (_ scrollView: UIScrollView) {
        
        //Ensures that the view is expanded
        if let indexPath = collabNavigationView.collabTableView.indexPathsForVisibleRows?.first, navigationItem.hidesBackButton, collabNavigationViewTopAnchor?.constant ?? 0 == 0 {
            
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
            
            let configureBlockVC: ConfigureBlockViewController = ConfigureBlockViewController()
            configureBlockVC.title = "Add a Block"
            
            configureBlockVC.collab = collab
            configureBlockVC.blockCreatedDelegate = self
            
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
    
    func moveToObjectiveView () {
        
        let collabObjectiveViewController = CollabObjectiveViewController()
        collabObjectiveViewController.objective = collab?.objective
        
        self.present(collabObjectiveViewController, animated: true, completion: nil)
    }
    
    //MARK: - Add Cover Photo Function
    
    func presentAddPhotoAlert (tracker: String, shrinkView: Bool) {
        
        if shrinkView {
            
            self.shrinkView()
        }
        
        alertTracker = tracker
        
        let addCoverPhotoAlert = UIAlertController (title: nil, message: nil, preferredStyle: .actionSheet)
        
        let takePhotoAction = UIAlertAction(title: "    Take a Cover Photo", style: .default) { (takePhotoAction) in
          
            self.takePhotoSelected()
        }
        
        let cameraImage = UIImage(named: "camera2")
        takePhotoAction.setValue(cameraImage, forKey: "image")
        takePhotoAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        
        let choosePhotoAction = UIAlertAction(title: "    Choose a Cover Photo", style: .default) { (choosePhotoAction) in
            
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
    
    private func dismissKeyboard () {
        
        messageInputAccesoryView.textViewContainer.messageTextView.resignFirstResponder()
    }
    
    @objc private func dismissKeyboardTap () {
        
        if selectedTab == "Messages", messages?.count ?? 0 == 0 {
            
            messageInputAccesoryView.textViewContainer.messageTextView.resignFirstResponder()
        }
    }
    
    @objc private func cancelButtonPressed () {
        
        navigationController?.navigationBar.configureNavBar(barBackgroundColor: .clear, barTintColor: .white, barStyleColor: .black)
        title = ""
        
        //Dismissing the expanded view
        if !calendarPresented {
            
            navigationItem.leftBarButtonItem = nil
            navigationItem.rightBarButtonItem = nil
            navigationItem.hidesBackButton = false
        }
        
        //Dismissing the expanded view to go back to the calendarPresented view
        else {
            
            let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.stop, target: self, action: #selector(dismissCalendar))
            cancelButton.style = .done
            navigationItem.leftBarButtonItem = cancelButton
        }
        
//        reconfigureGestureRecognizers()
        
        if selectedTab == "Progress" {
            
            collabNavigationView.collabProgressView.searchBar?.endEditing(true)
        }
        
        else if selectedTab == "Blocks" {
            
            //Setting the original contentOffset so that the collabTableView will be animated back to the correct position after the view has returned to it's origin
//            collabNavigationView.originalTableViewContentOffset = collabNavigationView.collabTableView.contentOffset.y
        }
        
        else if selectedTab == "Messages" {

            dismissKeyboard ()
            
            messageInputAccesoryView.size = messageInputAccesoryView.configureSize()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                
                if self.messages?.count ?? 0 > 0 {
                    
                    self.collabNavigationView.collabTableView.scrollToRow(at: IndexPath(row: ((self.messages?.count ?? 0) * 2) - 1, section: 0), at: .top, animated: true)
                }
            }
        }
        
        //Experimenting with calling this after the if statements above... was previously before those statements but was causing issues with the "Blocks" condition
        //Allows for the "originalTableViewContentOffset" to be set by the "Blocks" condition
        returnToOrigin(scrollTableView: false)
    }
    
    @objc private func dismissExpandedView () {
        
        if navigationItem.hidesBackButton == true {
            
            if calendarPresented {
                
                //If the "collabNavigationView" is expanded
                if collabNavigationViewTopAnchor?.constant == 0 {
                    
                    cancelButtonPressed()
                }
                
                else {
                    
                    dismissCalendar()
                }
            }
            
            else {
                
                cancelButtonPressed()
            }
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
        
        if selectedTab == "Progress" {
            
            if blocks?.count ?? 0 > 0 {
                
                collabNavigationView.collabTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
            
            return
        }
        
        collabNavigationView.collabTableView.scrollsToTop = true
        collabNavigationView.collabTableView.keyboardDismissMode = .onDrag
        
        collabNavigationView.collabProgressView.collab = collab
        collabNavigationView.collabProgressView.blocks = blocks
        collabNavigationView.presentProgressView()
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
            
            self.collabNavigationView.collabTableView.alpha = 0
            self.addBlockButton.alpha = 0
            self.messageInputAccesoryView.alpha = 0
            self.collabNavigationView.messagesAnimationView.alpha = 0
            
            //Passed in the "selectedTab" because it hasn't been set for this view yet to prevent the "scrollViewDidScroll" method
            //from interferring with the animations of the "collabProgressView"
            self.collabNavigationView.handleProgressAnimation(selectedTab: "Progress")
            
            self.view.layoutIfNeeded()
            
        }) { (finished: Bool) in
            
            self.collabNavigationView.messagesAnimationView.animationView.stop()
            
            //Prevents interference from the scrollViewDidScroll func
            //Stops the scrolling of the tableView
            self.collabNavigationView.collabTableView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            
            self.selectedTab = "Progress" //Should be set here to prevent interference from the "scrollViewDidScroll" method
            self.collabNavigationView.collabTableView.reloadData()
            
            self.collabNavigationView.collabTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 60 : 40, right: 0)
            self.collabNavigationView.collabTableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 60 : 40, right: 0)
            
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                
                self.collabNavigationView.collabTableView.alpha = 1
                self.tabBar.alpha = 1
            })
        }
    }
    
    func blocksButtonTouchUpInside () {
        
        if selectedTab == "Blocks" {
            
            //Helps with the animations
            UIView.transition(with: collabNavigationView.collabTableView, duration: 0.3, options: .transitionCrossDissolve) {

                self.scrollToCurrentDate()
                self.scrollToFirstBlock()
            }
            
            if var startTime = collab?.dates["startTime"] {
                
                //Formatting the startTime so that the only the date and not the time is truly used
                formatter.dateFormat = "yyyy MM dd"
                startTime = formatter.date(from: formatter.string(from: startTime)) ?? Date()
                
                if let date = calendar.date(byAdding: .day, value: collabNavigationView.collabTableView.indexPathsForVisibleRows?.last?.row ?? 0, to: startTime) {
                    
                    collabCalendarView.calendarView.selectDates([date])
                    collabCalendarView.calendarView.scrollToDate(date)
                    
                    collabNavigationView.calendarView.selectDates([date])
                    collabNavigationView.calendarView.scrollToDate(date)
                }
            }
            
            return
        }
        
        //If the tableView is scrolling, this will help configure a placeholder cell before the tableView gets reloaded
        selectedTab = ""
        
        collabNavigationView.collabTableView.scrollsToTop = true
        
        collabNavigationView.dismissProgressView()
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                     
            self.collabNavigationView.collabTableView.alpha = 0
            self.messageInputAccesoryView.alpha = 0
            self.collabNavigationView.messagesAnimationView.alpha = 0
            
            //Calling inside animation blocks allows for all animations to be performed seamlessly
            self.collabNavigationView.handleProgressAnimation()
            
            self.view.layoutIfNeeded()
            
        }) { (finished: Bool) in
            
            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            self.collabNavigationView.messagesAnimationView.animationView.stop()
            
            //Stops the scrolling of the tableView
            self.collabNavigationView.collabTableView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            
            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            //Setting here prevents the tableView from trying to use cells from a different tab for the blocks tab
            //averting a possible outOfBounds error (has not yet occured but this is precautionary because it was occuring when moving
            //to the messages tab)
            self.selectedTab = "Blocks"
            self.collabNavigationView.collabTableView.reloadData()
            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            
            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            if var startTime = self.collab?.dates["startTime"], let currentSelectedDate = self.collabNavigationView.calendarView.selectedDates.first {

                //Formatting the startTime so that the only the date and not the time is truly used
                self.formatter.dateFormat = "yyyy MM dd"
                startTime = self.formatter.date(from: self.formatter.string(from: startTime)) ?? Date()

                //Scrolling to the first block of the currently selected date
                self.scrollToFirstBlock(indexPathToScrollTo: IndexPath(row: self.calendar.dateComponents([.day], from: startTime, to: currentSelectedDate).day ?? 0, section: 0), animate: false)
            }
            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            
            self.collabNavigationView.collabTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 20 : 0, right: 0)
            self.collabNavigationView.collabTableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 40 : 0, right: 0)
            
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                
                self.collabNavigationView.collabTableView.alpha = 1
                
                //The present calendar func decides whether the "tabBar" and "addBlockButton" should be hidden or not
                if !self.calendarPresented {
                    
                    self.tabBar.alpha = 1
                    self.addBlockButton.alpha = 1
                }
            })
        }
    }
    
    func messagesButtonTouchUpInside () {
        
        if selectedTab == "Messages" {
            
            if messages?.count ?? 0 > 0 {
                
                //Scrolling to the last message
                collabNavigationView.collabTableView.scrollToRow(at: IndexPath(row: ((messages?.count ?? 0) * 2) - 1, section: 0), at: .top, animated: true)
            }
            
            return
        }
        
        var delay: Double = 0
        
        //If the selectedTab is "Progress", will cause a 0.3 second delay to allow for the progressView to be dismissed before moving to the messages view
        //Fixes bug that was causing a crash when animating tableView change
        if selectedTab == "Progress" {
            
            //Fixes bug that wouldn't allow for the progressView to be dismissed when it was shrunken to only show it's searchBar
            //The scrollViewDidScroll method would be called overridding the dismissal of the progressView
            selectedTab = ""
            
            delay = 0.3
            collabNavigationView.dismissProgressView()
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                
                //Calling inside animation blocks allows for all animations to be performed seamlessly
                self.collabNavigationView.handleProgressAnimation()
                
                self.view.layoutIfNeeded()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
    
            self.collabNavigationView.collabTableView.scrollsToTop = false
            self.collabNavigationView.collabTableView.keyboardDismissMode = .interactive
    
            if self.messages?.count ?? 0 == 0 {
                
                self.collabNavigationView.messagesAnimationView.animationView.play()
            }
            
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
    
                self.collabNavigationView.collabTableView.alpha = 0
                self.tabBar.alpha = 0
                self.addBlockButton.alpha = 0
                
            }) { (finished: Bool) in
    
                //Stops the tableView from scrolling to prevent the "messages" array in the messaging methods from going out of bounds
                //with a indexPath.row that was going to be used by either the "Progress" or "Block" tab
                self.collabNavigationView.collabTableView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
                
                //Setting here prevents the tableView from trying to use cells from a different tab for the messages tab
                //averting a outOfBounds error in the messagingMethods
                self.selectedTab = "Messages"
                self.collabNavigationView.collabTableView.reloadData()
    
                //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                //Borrowed from the inputAccesoryViewMethods class
                let messageViewHeight = (self.messageInputAccesoryView.textViewContainer.frame.height + abs(self.inputAccesoryViewMethods.setTextViewBottomAnchor())) + 5
                
                self.collabNavigationView.collabTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: messageViewHeight + 5, right: 0)
                self.collabNavigationView.collabTableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: messageViewHeight, right: 0)
                //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                
                if self.messages?.count ?? 0 > 0 {
    
                    //Scrolling to the last message
                    self.collabNavigationView.collabTableView.scrollToRow(at: IndexPath(row: ((self.messages?.count ?? 0) * 2) - 1, section: 0), at: .top, animated: false)
                }
    
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
    
                    self.messageInputAccesoryView.alpha = 1
    
                    self.collabNavigationView.collabTableView.alpha = 1
                    
                    self.collabNavigationView.messagesAnimationView.alpha = self.messages?.count ?? 0 == 0 ? 1 : 0
                })
            }
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
        
        //Ensures that the collabNavigationView is expanded
        if collabNavigationViewTopAnchor?.constant ?? 0 != 0 {
            
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
        
        var topAnchor: CGFloat
        
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

extension CollabViewController: CollabMemberProtocol {
    
    func moveToProfileView (_ member: Member, _ memberContainerView: UIView/*_ profilePicture: ProfilePicture?*/) {
        
        tabBar.shouldHide = true
        
        memberProfileVC = CollabMemberProfileViewController()
        memberProfileVC?.modalPresentationStyle = .overCurrentContext
        
        memberProfileVC?.collabViewController = self
        
        memberProfileVC?.member = member
        memberProfileVC?.memberActivity = collab?.memberActivity?[member.userID]
        memberProfileVC?.blocks = blocks
        memberProfileVC?.memberContainerView = memberContainerView
        
        self.present(memberProfileVC!, animated: false) {
            
            self.memberProfileVC?.performZoomPresentationAnimation()
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
