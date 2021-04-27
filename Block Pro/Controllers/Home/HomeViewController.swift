//
//  HomeViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 3/8/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit
import Lottie
import SVProgressHUD

class HomeViewController: UIViewController {
    
    let headerView = HomeHeaderView()
    let profilePictureButton = UIButton()
    
    lazy var collabCollectionView = UICollectionView(frame: .zero, collectionViewLayout: CollabCollectionViewFlowLayout(self))
    let calendarTableView = UITableView()
    
    let animationView = AnimationView(name: "home-animation")
    let animationTitleLabel = UILabel()
    
    let calendarButton = UIButton(type: .system)
    
    lazy var tabBar = CustomTabBar.sharedInstance
    
    let currentUser = CurrentUser.sharedInstance
    let firebaseAuth = FirebaseAuthentication()
    let firebaseCollab = FirebaseCollab.sharedInstance
    let firebaseBlock = FirebaseBlock.sharedInstance
    
    var loadingAnimationTimer: Timer?
    var loadingCount: Int = 1
    
    var allCollabs: [Collab]?
    var acceptedCollabsForSelectedDate: [Collab]?
    var deadlinesForCollabs: [Date] = []
    
    var selectedCollab: Collab?
    
    var blocks: [Block]?
    
    let calendar = Calendar.current
    let formatter = DateFormatter()
    
    let minimumHeaderViewHeight: CGFloat = (keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 60 : 40) + 135
    let minimumHeaderViewHeightWithCalendar: CGFloat = (keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 60 : 40) + 85
    let maximumHeaderViewHeight: CGFloat = (keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 60 : 40) + 428.5 //Extra 2.5 added to improve aesthetics
    
    var expandedIndexPath: IndexPath?
    
    var yCoordForExpandedCell: CGFloat? {
        didSet {
            
            expandCollabCell()
        }
    }
    
    var selectedDate: Date? {
        didSet {
            
            //The first retrieval of the collabs has been completed
            if allCollabs != nil {
                
                filterAcceptedCollabsForSelectedDate()
                
                UIView.transition(with: collabCollectionView, duration: 0.3, options: .transitionCrossDissolve) {
                    
                    self.collabCollectionView.reloadData()
                }
            }
            
            //Updates the selectedDate for the calendar in the headerView and the calendars in the calendarTableView
            updateCalendarsWithNewSelectedDate()
        }
    }
    
    var calendarPresent: Bool = false
    var headerViewWasExpanded: Bool = false
    
    var headerViewHeightConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.hidesBackButton = true
        
        configureHomeHeaderView()
        configureProfilePictureButton()
        
        configureCollectionView(collabCollectionView)
        configureTableView(calendarTableView)
        
        configureTabBar()
        configureCalendarButton()
        
        configureAnimationView()
        configureAnimationTitleLabel()
        configureAnimationTimer()
        
        configureGestureRecognizors()
        
        retrieveCollabs()
        
        retrieveBlocks()
        
        firebaseCollab.retrieveUsersFriends()
        
        NotificationCenter.default.addObserver(self, selector: #selector(determineNotifications), name: .didUpdateFriends, object: nil)
        
//        print(currentUser.userID)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.configureNavBar(barBackgroundColor: .clear, barStyleColor: .default)
        
        profilePictureButton.isUserInteractionEnabled = true
        
        //Checking to see if the splash screen is still present on the screen
        if keyWindow?.subviews.first(where: { $0 as? UIImageView != nil && $0.tag == 2 }) == nil {
            
            tabBar.shouldHide = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Should only still be nil when this view is being presented from the LogInViewController
        if !(tabBar.shouldHide ?? false) {
            
            tabBar.shouldHide = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        profilePictureButton.isUserInteractionEnabled = false
    }
    
    
    //MARK: - Configure Home Header View
    
    private func configureHomeHeaderView () {
        
        self.view.addSubview(headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            headerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            headerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            headerView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
        
        ].forEach({ $0.isActive = true })
        
        headerViewHeightConstraint = headerView.heightAnchor.constraint(equalToConstant: maximumHeaderViewHeight)
        headerViewHeightConstraint?.isActive = true
        
        headerView.homeViewController = self
    }
    
    
    //MARK: - Configure Profile Picture Button
    
    private func configureProfilePictureButton () {
        
        if keyWindow != nil {
            
            //Added to the keyWindow so it will be above the navigationBar
            keyWindow?.addSubview(profilePictureButton)
            profilePictureButton.translatesAutoresizingMaskIntoConstraints = false
            
            [
            
                profilePictureButton.topAnchor.constraint(equalTo: keyWindow!.topAnchor, constant: keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 60 : 40),
                profilePictureButton.leadingAnchor.constraint(equalTo: keyWindow!.leadingAnchor, constant: 25),
                profilePictureButton.widthAnchor.constraint(equalToConstant: 60),
                profilePictureButton.heightAnchor.constraint(equalToConstant: 60)
                
            ].forEach({ $0.isActive = true })
            
            profilePictureButton.addTarget(self, action: #selector(profilePictureButtonPressed), for: .touchUpInside)
        }
    }
    
    
    //MARK: - Configure CollectionView
    
    private func configureCollectionView (_ collectionView: UICollectionView) {
        
        self.view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            collectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0),
            collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
        
        collectionView.backgroundColor = .clear
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.delaysContentTouches = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.bounces = false
        
        //This bottom inset seems to work for all screens
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: self.view.frame.height - minimumHeaderViewHeight, right: 0)
        
        collectionView.register(HomeCollabCollectionViewCell.self, forCellWithReuseIdentifier: "homeCollabCollectionViewCell")
    }
    
    
    //MARK: - Configure TableView
    
    private func configureTableView (_ tableView: UITableView) {
        
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
        
        tableView.isHidden = true
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.estimatedRowHeight = 0
        
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        
        tableView.register(HomeCalendarCell.self, forCellReuseIdentifier: "homeCalendarCell")
    }
    
    
    //MARK: - Configure Tab Bar
    
    private func configureTabBar () {
        
        tabBarController?.tabBar.isHidden = true
        
        tabBar.homeTabNavigationController = navigationController
        tabBar.tabBarController = tabBarController
        
        keyWindow?.addSubview(tabBar)
    }
    
    
    //MARK: - Configure Calendar Button
    
    private func configureCalendarButton () {
        
        self.view.addSubview(calendarButton)
        calendarButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
            
            calendarButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -29),
            calendarButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -(self.view.frame.height - tabBar.frame.minY) - 25),
            calendarButton.widthAnchor.constraint(equalToConstant: 60),
            calendarButton.heightAnchor.constraint(equalToConstant: 60)
            
        ].forEach( { $0.isActive = true } )
        
        calendarButton.backgroundColor = UIColor(hexString: "222222")
        calendarButton.setImage(UIImage(systemName: "calendar"), for: .normal)
        calendarButton.tintColor = .white
        
        calendarButton.contentHorizontalAlignment = .fill
        calendarButton.contentVerticalAlignment = .fill
        
        calendarButton.imageView?.contentMode = .scaleAspectFit
        calendarButton.imageEdgeInsets = UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14)
        
        calendarButton.layer.cornerRadius = 30
        
        calendarButton.layer.shadowColor = UIColor(hexString: "39434A")?.cgColor
        calendarButton.layer.shadowRadius = 2
        calendarButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        calendarButton.layer.shadowOpacity = 0.65

        calendarButton.addTarget(self, action: #selector(calendarButtonPressed), for: .touchUpInside)
    }
    
    
    //MARK: - Configure Animation View
    
    private func configureAnimationView () {
        
        self.view.insertSubview(animationView, belowSubview: collabCollectionView)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            animationView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? -30 : -10),
            animationView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
            animationView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width),
            animationView.heightAnchor.constraint(equalToConstant: ((tabBar.frame.minY - 85) - minimumHeaderViewHeight) * 0.8)
            //Height is 80% of the distance between the bottom of
            //headerView and top of the calendarButton without accounting
            //for it being offset by either 10 or 30 points by the topAnchor
        
        ].forEach({ $0.isActive = true })
        
        animationView.isUserInteractionEnabled = false
        
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .loop
        animationView.backgroundBehavior = .pauseAndRestore
        
        animationView.play()
    }
    
    
    //MARK: - Configure Animation Title
    
    private func configureAnimationTitleLabel () {
        
        //Distance between the bottom of the animationView and the top of the calendar button
        //Adding either 10 or 30 accounts for the fact that the animationView is offset by either 10 or 30 points
        let proposedHeightOfLabel = (((tabBar.frame.minY - 85) - minimumHeaderViewHeight) * 0.2) + (keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 30 : 10)
        
        self.view.insertSubview(animationTitleLabel, belowSubview: collabCollectionView)
        animationTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            animationTitleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            animationTitleLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            animationTitleLabel.topAnchor.constraint(equalTo: animationView.bottomAnchor, constant: 0),
            animationTitleLabel.heightAnchor.constraint(equalToConstant: proposedHeightOfLabel > 70 ? proposedHeightOfLabel : 70)
        
        ].forEach({ $0.isActive = true })
        
        animationTitleLabel.isUserInteractionEnabled = false
        
        animationTitleLabel.font = UIFont(name: "Poppins-SemiBold", size: 25)
        animationTitleLabel.numberOfLines = 0
        animationTitleLabel.textAlignment = .center
        animationTitleLabel.text = "No Collabs\nYet"
    }
    
    
    //MARK: - Configure Animation Timer
    
    private func configureAnimationTimer () {
        
        loadingAnimationTimer = Timer(fireAt: Date(), interval: 0.7, target: self, selector: #selector(updateLoadingAnimation), userInfo: nil, repeats: true)
    
        guard let timer = loadingAnimationTimer else { return }
        
            RunLoop.main.add(timer, forMode: .common)
    }
    
    
    //MARK: - Configure Gesture Recognizors
    
    private func configureGestureRecognizors () {
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:)))
        headerView.addGestureRecognizer(panGesture)
        
        let downSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(collectionViewSwipedDown))
        downSwipeGesture.delegate = self
        downSwipeGesture.direction = .down
        collabCollectionView.addGestureRecognizer(downSwipeGesture)
    }
    
    
    //MARK: - Retrieve Collabs
    
    private func retrieveCollabs () {
        
        firebaseCollab.retrieveCollabs { [weak self] (retrivedCollabs, error) in
            
            if let collabs = retrivedCollabs {
                
                //Signifying the this is the first retrieval attempt of the collabs
                if self?.allCollabs == nil {
                    
                    self?.allCollabs = collabs
                    
                    self?.filterAcceptedCollabsForSelectedDate()
                    
                    UIView.transition(with: self!.collabCollectionView, duration: 0.3, options: .transitionCrossDissolve) {
                        
                        self?.collabCollectionView.reloadData()
                    }
                    
                    //Delaying sligtly allows the collectionView time to reload and the collabCell to expand
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        
                        self?.yCoordForExpandedCell = 0
                        self?.expandCollabCell()
                    }
                }
                
                else {
                    
                    self?.collabsUpdated(collabs)
                }
                
                self?.loadingAnimationTimer?.invalidate()
                
                //Determines the deadlines for all accepted collabs and reloads the calendars with the new deadlines
                self?.determineDeadlinesForCollabs(collabs)
                
                //Determinines which collabRequests are new and in turn should be presented as a notification
                self?.determineNotifications()
            }
        }
    }
    
    
    //MARK: - Retrieve Blocks
    
    private func retrieveBlocks () {
        
        firebaseBlock.retrievePersonalBlocks { [weak self] (error, blocks) in
            
            if error != nil {
                
                print(error?.localizedDescription as Any)
            }
            
            else {
                
                self?.blocks = blocks
                
                self?.headerView.blocks = blocks
                
                //If the personal blocks view controller is present, this will update the blocks in that view
                self?.navigationController?.viewControllers.forEach({ (viewController) in
                    
                    if let blockVC = viewController as? BlockViewController {
                        
                        blockVC.blocks = blocks
                    }
                })
            }
        }
    }
    
    
    //MARK: - Update Loading Animation
    
    @objc private func updateLoadingAnimation () {
        
        if loadingCount == 0 {
            
            animationTitleLabel.text = "Loading."
            loadingCount += 1
        }
        
        else if loadingCount == 1 {
            
            animationTitleLabel.text = "Loading.."
            loadingCount += 1
        }
        
        else if loadingCount == 2 {
            
            animationTitleLabel.text = "Loading..."
            loadingCount = 0
        }
    }
    
    
    //MARK: - Update Selected Date
    
    func updateSelectedDate (date: Date) {
        
        let updatedDateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        selectedDate = calendar.date(from: updatedDateComponents)
    }
    
    
    //MARK: - Filter Accepted Collabs for Selected Date
    
    private func filterAcceptedCollabsForSelectedDate () {
        
        acceptedCollabsForSelectedDate = []
        
        for collab in allCollabs ?? [] {
            
            //If the user has accepted this collab
            if collab.accepted?[currentUser.userID] == true {
                
                if let date = selectedDate, let startTime = collab.dates["startTime"], let deadline = collab.dates["deadline"] {
                    
                    //If this selectedDate is between the startTime and deadline of this collab
                    if date.isBetween(startDate: startTime, endDate: deadline) {
                        
                        acceptedCollabsForSelectedDate?.append(collab)
                    }
                    
                    //If the selected date is equal to the startTime or deadline
                    else if calendar.isDate(date, inSameDayAs: startTime) || calendar.isDate(date, inSameDayAs: deadline) {
                        
                        acceptedCollabsForSelectedDate?.append(collab)
                    }
                }
            }
        }
        
        //Sorting the collabs by their deadline
        acceptedCollabsForSelectedDate?.sort(by: { $0.dates["deadline"] ?? Date() < $1.dates["deadline"] ?? Date() })
        
        //Will present the animationView if there are no collabs for the selected date
        presentAnimationView()
    }
    

    //MARK: - Update Calendars with New Selected Date
    
    private func updateCalendarsWithNewSelectedDate () {
        
        //If the selectedDate in the headerView isn't equal to the new selectedDate
        //Signifies that the new selectedDate was not selected in the calendar for the headerView
        if let date = selectedDate, date != headerView.selectedDate {
            
            headerView.selectedDate = date
            
            headerView.calendarView.selectDates([date])
            headerView.calendarView.scrollToDate(date)
            
            headerView.scrollToScheduleCellForDate()
        }
        
        //Each calendar cell in the calendarTableView
        for visibleCell in calendarTableView.visibleCells {

            if let cell = visibleCell as? HomeCalendarCell {

                //If the selectedDate in the calendarCell is not equal to the new selectedDate
                //Signifies that the new selectedDate was not selected in the calendar for this cell
                if let date = selectedDate, date != cell.selectedDate {
                    
                    cell.selectedDate = date
                    
                    cell.calendarView.deselect(dates: cell.calendarView.selectedDates)
                    
                    cell.calendarView.selectDates([date])
                }
            }
        }
    }
    
    
    //MARK: - Determine Deadlines for Collabs
    
    private func determineDeadlinesForCollabs (_ collabs: [Collab]) {
        
        var deadlines: [Date] = []
        
        collabs.forEach { (collab) in
            
            if collab.accepted?[currentUser.userID] == true, let deadline = collab.dates["deadline"] {
                
                deadlines.append(deadline)
            }
        }
        
        deadlinesForCollabs = deadlines
        
        //Will also reload the calendar in the headerView
        headerView.deadlinesForCollabs = deadlines
        
        //Will also reload the calendar in each visibleCell
        calendarTableView.visibleCells.forEach({ if let cell = $0 as? HomeCalendarCell { cell.deadlinesForCollabs = deadlines } })
    }
    
    
    //MARK: - Determine Notifications
    
    @objc private func determineNotifications () {
        
        var newFriendRequestsCount: Int = 0
        var newCollabRequestsCount: Int = 0
        
        for friend in firebaseCollab.friends {
            
            //If this friendRequest has not been viewed yet and the request was not sent by the currentUser
            if friend.accepted == nil, friend.requestSentBy != currentUser.userID {
                
                newFriendRequestsCount += 1
            }
        }
        
        for collab in allCollabs ?? [] {
            
            //If this collabRequest has not been viewed yet
            if collab.accepted?[currentUser.userID] as? Bool == nil {

                newCollabRequestsCount += 1
            }
        }
        
        tabBar.setNotificationIndicator(notificationCount: newFriendRequestsCount + newCollabRequestsCount)
    }
    
    
    //MARK: - Collabs Updated
    
    private func collabsUpdated (_ retrievedCollabs: [Collab]) {
        
        //The collabs that have just been retrieved from Firebase
        var retrievedAcceptedCollabIDs: [String] = []
        retrievedCollabs.forEach({ if $0.accepted?[currentUser.userID] == true { retrievedAcceptedCollabIDs.append($0.collabID) } })
        
        //The collabs that have been previously cached in the allCollabs array
        var cachedAcceptedCollabIDs: [String] = []
        allCollabs?.forEach({ if $0.accepted?[currentUser.userID] == true { cachedAcceptedCollabIDs.append($0.collabID) } })
        
        allCollabs = retrievedCollabs
        filterAcceptedCollabsForSelectedDate()
        
        //Checks if the amount of accepted collabs have changed or if any accepted collabs have been swapped in/out
        if retrievedAcceptedCollabIDs.count != cachedAcceptedCollabIDs.count || !(retrievedAcceptedCollabIDs.allSatisfy({ cachedAcceptedCollabIDs.contains($0) })) {
            
            UIView.transition(with: collabCollectionView, duration: 0.3, options: .transitionCrossDissolve) {
                
                self.collabCollectionView.reloadData()
            }
        }
        
        else {
            
            var indexPathsToReload: [IndexPath] = []
            
            for indexPath in collabCollectionView.indexPathsForVisibleItems {
                
                if let cell = collabCollectionView.cellForItem(at: indexPath) as? HomeCollabCollectionViewCell, let cachedCollab = cell.collab, let updatedCollab = allCollabs?.first(where: { $0.collabID == cachedCollab.collabID }) {
                    
                    //If the coverPhoto has been updated
                    if cachedCollab.coverPhotoID != updatedCollab.coverPhotoID {
                        
                        indexPathsToReload.append(indexPath)
                    }
                    
                    //If the name has been updated
                    else if cachedCollab.name != updatedCollab.name {
                        
                        indexPathsToReload.append(indexPath)
                    }
                    
                    //If either the startTime of the deadline has been updated
                    else if cachedCollab.dates["startTime"] != updatedCollab.dates["startTime"] || cachedCollab.dates["deadline"] != updatedCollab.dates["deadline"] {
                        
                        indexPathsToReload.append(indexPath)
                    }
                    
                    //If the members have been updated
                    else if cachedCollab.currentMembersIDs.count != updatedCollab.currentMembersIDs.count || !(updatedCollab.currentMembersIDs.allSatisfy({ cachedCollab.currentMembersIDs.contains($0) })) {
                        
                        indexPathsToReload.append(indexPath)
                    }
                }
            }
            
            if indexPathsToReload.count > 0 {
                
                //Stops the collectionView from animating the reloading of the items
                UIView.performWithoutAnimation {
                    
                    self.collabCollectionView.reloadItems(at: indexPathsToReload)
                }
            }
        }
    }
    
    
    //MARK: - Present Animation View
    
    private func presentAnimationView () {
        
        if acceptedCollabsForSelectedDate?.count ?? 0 == 0 && !calendarPresent {
            
            animationTitleLabel.text = "No Collabs\nYet"
            
            if animationView.alpha != 1 {
                
                animationView.play()
                
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                    
                    self.animationView.alpha = 1
                    self.animationTitleLabel.alpha = 1
                }
            }
        }
        
        else {
            
            if animationView.alpha != 0 {
                
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                    
                    self.animationView.alpha = 0
                    self.animationTitleLabel.alpha = 0
                    
                } completion: { (finished: Bool) in
                    
                    self.animationView.stop()
                    self.animationTitleLabel.text = "No Collabs\nYet"
                }
            }
        }
    }
    
    
    //MARK: - Handle Pan
    
    @objc private func handlePan (sender: UIPanGestureRecognizer) {
        
        if !calendarPresent {
            
            switch sender.state {
            
            case .began, .changed:
                
                //Ensures that the first collabCell is visible before allowing the panGesture to work
                //Only the case if the collectionView is populated with cells, otherwise always allow the panGesture to work
                if collabCollectionView.indexPathsForVisibleItems.contains(where: { $0.row == 0 }) || collabCollectionView.numberOfItems(inSection: 0) == 0 {
                    
                    moveWithPan(sender)
                }

            case .ended:
                
                if headerViewHeightConstraint?.constant ?? 0 < maximumHeaderViewHeight * 0.8 {
                    
                    shrinkHeaderView()
                }
                
                else {
                    
                    expandHeaderView()
                }
                
            default:
                
                break
            }
        }
    }
    
    
    //MARK: - Move with Pan
    
    private func moveWithPan (_ sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: self.view)
        
        //The user is dragging down
        if translation.y > 0 {
            
            if (headerViewHeightConstraint?.constant ?? 0) + translation.y < maximumHeaderViewHeight {
                
                headerViewHeightConstraint?.constant += translation.y
                
                animateHeaderViewAlpha()
                animateAnimationTitleLabelAlpha()
            }
            
            else {
                
                headerViewHeightConstraint?.constant = maximumHeaderViewHeight
            }
        }
        
        //The user is dragging up
        else {
            
            if (headerViewHeightConstraint?.constant ?? 0) + translation.y > minimumHeaderViewHeight {
                
                headerViewHeightConstraint?.constant += translation.y
                
                animateHeaderViewAlpha()
                animateAnimationTitleLabelAlpha()
            }
            
            else {
                
                headerViewHeightConstraint?.constant = minimumHeaderViewHeight
                
                headerView.calendarHeaderLabel.alpha = 0
                headerView.calendarView.alpha = 0
                headerView.scheduleCollectionView.alpha = 0
                
                animationTitleLabel.alpha = acceptedCollabsForSelectedDate?.count ?? 0 == 0 ? 1 : 0
            }
        }
        
        sender.setTranslation(.zero, in: self.view)
    }
    
    
    //MARK: - CollectionView Swiped Down
    
    @objc private func collectionViewSwipedDown () {
        
        //Will expand the headerView when the collectionView is swiped down
        //Required because scrollViewDidEndDragging will only expand the headerView upon a drag down when there is more than one cell in the collectionView
        if collabCollectionView.contentOffset.y == 0 && headerViewHeightConstraint?.constant != maximumHeaderViewHeight {
            
            expandHeaderView()
        }
    }
    
    
    //MARK: - Animate Header View Alpha
    
    private func animateHeaderViewAlpha () {
        
        let alphaPart = 1 / (maximumHeaderViewHeight - minimumHeaderViewHeight)

        headerView.calendarHeaderLabel.alpha = alphaPart * ((headerViewHeightConstraint?.constant ?? 0) - minimumHeaderViewHeight)
        headerView.calendarView.alpha = alphaPart * ((headerViewHeightConstraint?.constant ?? 0) - minimumHeaderViewHeight)
        headerView.personalLabel.alpha = alphaPart * ((headerViewHeightConstraint?.constant ?? 0) - minimumHeaderViewHeight)
        headerView.scheduleCollectionView.alpha = alphaPart * ((headerViewHeightConstraint?.constant ?? 0) - minimumHeaderViewHeight)
    }
    
    
    //MARK: - Animate Animation Title Label Alpha
    
    private func animateAnimationTitleLabelAlpha () {
        
        if acceptedCollabsForSelectedDate?.count ?? 0 == 0 {
            
            let alphaPart = 1 / (maximumHeaderViewHeight - minimumHeaderViewHeight)
            
            animationTitleLabel.alpha = 1 - (alphaPart * ((headerViewHeightConstraint?.constant ?? 0) - minimumHeaderViewHeight))
        }
        
        else {
            
            animationTitleLabel.alpha = 0
        }
    }
    
    
    //MARK: - Expand Header View
    
    private func expandHeaderView () {
        
        headerViewHeightConstraint?.constant = maximumHeaderViewHeight
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            
            self.view.layoutIfNeeded()
            
            self.headerView.calendarHeaderLabel.alpha = 1
            self.headerView.calendarView.alpha = 1
            self.headerView.personalLabel.alpha = 1
            self.headerView.scheduleCollectionView.alpha = 1
            self.headerView.collabContainer.alpha = 1
            
            self.animationTitleLabel.alpha = 0
            
        } completion: { (finished: Bool) in
            
            self.collabCollectionView.showsVerticalScrollIndicator = false
            
            self.headerView.collabContainer.backgroundColor = .white
        }
    }
    
    
    //MARK: - Shrink Header View
    
    private func shrinkHeaderView () {
        
        headerViewHeightConstraint?.constant = !calendarPresent ? minimumHeaderViewHeight : minimumHeaderViewHeightWithCalendar
        
        if calendarPresent {
            
            headerView.collabContainer.backgroundColor = .clear
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            
            self.view.layoutIfNeeded()
            
            self.headerView.calendarHeaderLabel.alpha = 0
            self.headerView.calendarView.alpha = 0
            self.headerView.personalLabel.alpha = 0
            self.headerView.scheduleCollectionView.alpha = 0
            self.headerView.collabContainer.alpha = self.calendarPresent ? 0 : 1
            
            self.animationTitleLabel.alpha = self.acceptedCollabsForSelectedDate?.count ?? 0 == 0 ? 1 : 0
            
        } completion: { (finished: Bool) in
            
            self.collabCollectionView.showsVerticalScrollIndicator = !self.calendarPresent
            
            self.headerView.collabContainer.backgroundColor = self.calendarPresent ? .clear : .white
        }
    }
    
    
    //MARK: - Expand Collab Cell
    
    private func expandCollabCell (recursionCount: Int = 0) {
        
        var cellFound: Bool = false
        
        //Ensures that yCoord has been assigned and that not cell is currently expanded
        if let yCoord = yCoordForExpandedCell, expandedIndexPath == nil {
            
            for indexPath in collabCollectionView.indexPathsForVisibleItems {
                
                if let cell = collabCollectionView.cellForItem(at: indexPath) as? HomeCollabCollectionViewCell {
                    
                    //Finds the cell with a minY that matches the assigned yCoord
                    if cell.frame.minY == yCoord {
                        
                        cell.expandCell()
                        
                        expandedIndexPath = indexPath
                        
                        collabCollectionView.performBatchUpdates {
                            
                            self.collabCollectionView.reloadData()
                        }
                        
                        cellFound = true
                        break
                    }
                }
            }
            
            //If a cell was not found, this function will will try again up to 2 more times
            //Fixes issue where a cell may not have been expanded when the user was scrolling back up
            if !cellFound, recursionCount < 3 {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {

                    self.expandCollabCell(recursionCount: recursionCount + 1)
                }
            }
        }
    }
    
    
    //MARK: - Shrink Collab Cell
    
    private func shrinkCollabCell () {
        
        collabCollectionView.visibleCells.forEach { (collabCell) in

            if let cell = collabCell as? HomeCollabCollectionViewCell {

                cell.shrinkCell()
            }
        }
        
        expandedIndexPath = nil
        yCoordForExpandedCell = nil
        
        collabCollectionView.performBatchUpdates {

            self.collabCollectionView.reloadData()
        }
    }
    
    
    //MARK: - Move to Home Sidebar View
    
    private func moveToHomeSidebarView () {
        
        let homeSidebarVC = HomeSidebarViewController()
        homeSidebarVC.modalPresentationStyle = .overFullScreen
        
        homeSidebarVC.sidebarDelegate = self
        
        self.present(homeSidebarVC, animated: false, completion: nil)
    }
    
    
    //MARK: - Move to Blocks View
    
    func moveToBlocksView (_ selectedDate: Date) {
        
        performSegue(withIdentifier: "moveToPersonalBlocksView", sender: self)
    }
    
    
    //MARK: - Move to Add Collab View
    
    func moveToAddCollabView () {
        
        let configureCollabVC = ConfigureCollabViewController()
        configureCollabVC.title = "Create a Collab"
        configureCollabVC.configurationView = true
        
        configureCollabVC.configureBarButtonItems()
        
        configureCollabVC.collabCreatedDelegate = self
        
        let configureCollabNavigationController = UINavigationController(rootViewController: configureCollabVC)
        configureCollabNavigationController.navigationBar.prefersLargeTitles = true
        
        self.present(configureCollabNavigationController, animated: true, completion: nil)
    }
    
    
    //MARK: - Prepare for Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveToCollabView" {
            
            let collabVC = segue.destination as! CollabViewController
            collabVC.collab = selectedCollab
            
            let backButtonItem = UIBarButtonItem()
            backButtonItem.title = ""
            self.navigationItem.backBarButtonItem = backButtonItem
        }
        
        else if segue.identifier == "moveToPersonalBlocksView" {
            
            let blocksVC = segue.destination as! BlockViewController
            blocksVC.formatter = formatter
            blocksVC.selectedDate = selectedDate
            blocksVC.blocks = blocks
            
            let backBarItem = UIBarButtonItem()
            backBarItem.title = ""
            self.navigationItem.backBarButtonItem = backBarItem
        }
    }
    
    
    //MARK: - Profile Picture Button Pressed
    
    @objc private func profilePictureButtonPressed () {
        
        //Double check to ensure the HomeViewController is present
        if self.navigationController?.visibleViewController == self {
            
            moveToHomeSidebarView()
        }
    }
    
    
    //MARK: - Calendar Button Pressed
    
    @objc func calendarButtonPressed () {
        
        calendarPresent = !calendarPresent
        
        //Handling the calendarButton animation
        ///////////////////////////////////////////////////////////////////////
        let inset: CGFloat = calendarPresent ? 17 : 14
        
        calendarButton.setImage(calendarPresent ? UIImage(named: "plus 2") : UIImage(systemName: "calendar"), for: .normal)
        
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut) {
            
            self.calendarButton.imageEdgeInsets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
            
            self.calendarButton.transform = CGAffineTransform(rotationAngle: self.calendarPresent ? CGFloat.pi / 4 : 0)
        }
        ///////////////////////////////////////////////////////////////////////
        
        
        //Scrolling to the cell that cooresponds to the month of the selectedDate
        ///////////////////////////////////////////////////////////////////////
        if calendarPresent {

            formatter.dateFormat = "yyyy MM dd"

            if let startDate = self.formatter.date(from: "2010 01 01"), let date = selectedDate {

                //Returns the difference between the start of the calendars (1/1/10) and the selectedDate in months
                if let row = calendar.dateComponents([.month], from: startDate, to: date).month {
                    
                    calendarTableView.scrollToRow(at: IndexPath(row: row * 2, section: 0), at: .top, animated: false)
                }
            }
        }
        ///////////////////////////////////////////////////////////////////////
        
        
        //Animating the change from the collabCollectionView to the calendarTableView
        ///////////////////////////////////////////////////////////////////////
        UIView.transition(from: calendarPresent ? collabCollectionView : calendarTableView, to: calendarPresent ? calendarTableView : collabCollectionView, duration: 0.3, options: [.transitionCrossDissolve, .showHideTransitionViews])
        ///////////////////////////////////////////////////////////////////////
        
        
        //Shrinking or expanding the headerView
        ///////////////////////////////////////////////////////////////////////
        if calendarPresent {
            
            //Tracks whether or not the headerView was expanded
            headerViewWasExpanded = headerViewHeightConstraint?.constant == maximumHeaderViewHeight
            
            shrinkHeaderView()
        }
        
        else {
            
            if headerViewWasExpanded {
                
                expandHeaderView()
            }
            
            else {
                
                shrinkHeaderView()
            }
        }
        ///////////////////////////////////////////////////////////////////////
        
        //Handling the visibility of the animationView
        presentAnimationView()
    }
}


//MARK: - Gesture Recognizor Delegate

extension HomeViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}


//MARK: - CollectionView DataSource and Delegate Extension

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return acceptedCollabsForSelectedDate?.count ?? 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "homeCollabCollectionViewCell", for: indexPath) as! HomeCollabCollectionViewCell

        cell.formatter = formatter
    
        cell.collab = acceptedCollabsForSelectedDate?[indexPath.row]
        
        //If this current cell should be expanded
        if expandedIndexPath == indexPath {

            cell.expandCell(animate: false)
        }

        else {

            cell.shrinkCell(animate: false)
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return expandedIndexPath == indexPath ? CGSize(width: UIScreen.main.bounds.width, height: 190) : CGSize(width: UIScreen.main.bounds.width, height: 100)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let cell = collectionView.cellForItem(at: indexPath) as? HomeCollabCollectionViewCell {
            
            if let selectedCollab = firebaseCollab.collabs.first(where: { $0.collabID == cell.collab?.collabID }) {
                
                self.selectedCollab = selectedCollab

                performSegue(withIdentifier: "moveToCollabView", sender: self)
            }
        }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y >= 0, scrollView == collabCollectionView {
            
            //If the homeHeaderView is larger than minimum allowable height, proceed to decrementing its height
            if (headerViewHeightConstraint?.constant ?? 140) - scrollView.contentOffset.y > minimumHeaderViewHeight {

                headerViewHeightConstraint?.constant -= scrollView.contentOffset.y
                scrollView.contentOffset.y = 0

                animateHeaderViewAlpha()
                animateAnimationTitleLabelAlpha()
            }

            else {

                //If the headerView has yet to be shrunken to its minimum allowable height
                if headerViewHeightConstraint?.constant != minimumHeaderViewHeight {

                    headerViewHeightConstraint?.constant = minimumHeaderViewHeight

                    headerView.calendarHeaderLabel.alpha = 0
                    headerView.calendarView.alpha = 0
                    headerView.personalLabel.alpha = 0
                    headerView.scheduleCollectionView.alpha = 0
                    
                    animationTitleLabel.alpha = acceptedCollabsForSelectedDate?.count ?? 0 == 0 ? 1 : 0
                    
                    shrinkCollabCell()
                }
                
                //Ensures the user is responsible for the scrollView scrolling
                else if scrollView.isDragging {
                    
                    if headerViewHeightConstraint?.constant == minimumHeaderViewHeight, scrollView.contentOffset.y > 0 {
                        
                        //Check to see if the last cell is visible
                        if let lastIndexPath = collabCollectionView.indexPathsForVisibleItems.first(where: { $0.row == collabCollectionView.numberOfItems(inSection: 0) - 1}), let lastCollabCell = collabCollectionView.cellForItem(at: lastIndexPath) {
                            
                            //If the user is attempting to scroll past the last cell
                            if scrollView.contentOffset.y > lastCollabCell.frame.minY {
                                
                                scrollView.contentOffset.y = collabCollectionView.visibleCells.last?.frame.minY ?? 0
                            }
                            
                            //scrollViewWillBeginDragging doesn't have the ability to shrink the first cell, so it has to be done here
                            else if expandedIndexPath?.row == 0 {
                                
                                shrinkCollabCell()
                            }
                        }
                        
                        //scrollViewWillBeginDragging doesn't have the ability to shrink the first cell, so it has to be done here
                        else if expandedIndexPath?.row == 0 {
                            
                            shrinkCollabCell()
                        }
                    }
                }
            }
        }
    }
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        //If the headerView is shrunken, and the first cell isn't the one currently expanded
        if self.headerViewHeightConstraint?.constant == self.minimumHeaderViewHeight && expandedIndexPath?.row != 0 && scrollView == collabCollectionView {
            
            self.shrinkCollabCell()
        }
    }
    
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if scrollView == collabCollectionView {
            
            //If the user is scrolling up
            if velocity.y >= 0 {
                
                if headerViewHeightConstraint?.constant ?? 0 < maximumHeaderViewHeight * 0.8 {
                    
                    shrinkHeaderView()
                }
                
                else {
                    
                    expandHeaderView()
                }
            }
            
            //If the user is scrolling down
            else {
                
                if scrollView.contentOffset.y == 0 && collabCollectionView.numberOfItems(inSection: 0) > 1 {
                    
                    expandHeaderView()
                }
            }
        }
        
        else if scrollView == calendarTableView {
            
            //If the user is scrolling up
            if velocity.y < 0 {

                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {

                    self.tabBar.alpha = 1
                    self.calendarButton.alpha = 1
                })
            }

            //If the user is scrolling down
            else if velocity.y > 0.5 {

                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {

                    self.tabBar.alpha = 0
                    self.calendarButton.alpha = 0
                })
            }
        }
    }
    
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        
        if scrollView == collabCollectionView {
            
            shrinkCollabCell()
        }
        
        return true
    }
    
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        
        if scrollView == collabCollectionView {
            
            yCoordForExpandedCell = 0
            expandedIndexPath = nil
            
            expandCollabCell()
        }
    }
}


//MARK: - TableView DataSource and Delegate Extension

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        formatter.dateFormat = "yyyy MM dd"
        
        return ((calendar.dateComponents([.month], from: formatter.date(from: "2010 01 01") ?? Date(), to: formatter.date(from: "2050 02 01") ?? Date()).month ??
            0) * 2)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row % 2 == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "homeCalendarCell", for: indexPath) as! HomeCalendarCell
            cell.selectionStyle = .none
            
            formatter.dateFormat = "yyyy MM dd"
            
            if let dateForCell = calendar.date(byAdding: .month, value: indexPath.row / 2, to: formatter.date(from: "2010 01 01") ?? Date()) {
                
                cell.formatter = formatter
                cell.dateForCell = dateForCell
                cell.selectedDate = selectedDate ?? Date()
                cell.deadlinesForCollabs = deadlinesForCollabs
                
                cell.homeViewController = self
            }
            
            return cell
        }
        
        else {
            
            let cell = UITableViewCell()
            cell.isUserInteractionEnabled = false
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row % 2 == 0 {
            
            formatter.dateFormat = "yyyy MM dd"
            
            let dateForCell = calendar.date(byAdding: .month, value: indexPath.row / 2, to: formatter.date(from: "2010 01 01") ?? Date()) ?? Date()
            let numberOfWeeks = dateForCell.determineNumberOfWeeks() + 1 //Adding 1 gives the true numberOfWeeks
            
            //81 is the height of the cell without factoring in the calendar
            //47 is the height of each dateCell
            return CGFloat(81 + (numberOfWeeks * 47))
        }
        
        else {
            
            let dateForPreviousCalendarCell = calendar.date(byAdding: .month, value: ((indexPath.row - 1) / 2), to: formatter.date(from: "2010 01 01") ?? Date()) ?? Date()
            
            if let lastDayOfTheMonth = calendar.dateComponents([.weekday], from: dateForPreviousCalendarCell.endOfMonth).weekday {

                //If the last day of the month is either Sunday or Monday
                if lastDayOfTheMonth < 3 {
                    
                    return 32.5
                }
                
                else {

                    return 50
                }
            }

            else {

                return 50
            }
        }
    }
}


//MARK: - Collab Created Protocol

extension HomeViewController: CollabCreatedProtocol {
    
    func collabCreated (_ collabID: String) {
        
        if let collab = allCollabs?.first(where: { $0.collabID == collabID }) {
            
            selectedCollab = collab
            
            performSegue(withIdentifier: "moveToCollabView", sender: self)
        }
    }
}


//MARK: - Sidebar Protocol

extension HomeViewController: SidebarProtocol {
    
    func moveToProfileView () {
        
        performSegue(withIdentifier: "moveToProfileView", sender: self)
    }
    
    func moveToFriendsView() {
        
        print("friends view")
    }
    
    func moveToPrivacyView () {
        
        print("move to privacy view")
    }
    
    func userSignedOut() {
        
        SVProgressHUD.show()
        
        firebaseAuth.logOutUser { (error) in

            if error != nil {

                SVProgressHUD.showError(withStatus: error?.localizedDescription)
            }

            else {

                self.tabBar.shouldHide = true
                
                self.navigationController?.popToRootViewController(animated: true)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    
                    SVProgressHUD.showSuccess(withStatus: "You've been signed out")
                }
            }
        }
    }
}
