//
//  HomeViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 1/29/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import iProgressHUD

class HomeViewController2: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var profilePicContainer: UIView!
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var profilePicBlurView: UIView!
    @IBOutlet weak var profileButton: UIButton!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var monthLabel: UILabel!
    
    @IBOutlet weak var homeTableView: UITableView!
    
    let currentUser = CurrentUser.sharedInstance
    
    var collab_personalButton = UIButton(type: .system)
    
    var viewTracker: String = ""
    
    var viewInitiallyLoaded: Bool = false
    
    let formatter = DateFormatter()
    
    var weekSectionArray: [[Date]]?
    
    var tableViewAutoScrolled: Bool = false
    
    var visibleCell: IndexPath?
    
    var currentDate: Date = Date()
    
    var selectedDate: Date?
    
    let firebaseCollab = FirebaseCollab.sharedInstance
    
    var selectedCollab: Collab?
    
    lazy var tabBar = CustomTabBar.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewTracker = "personal"
        
        configureMonthButton()
        
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
        
//        animateEntryToView()
        
        print("check")
        
        homeTableView.delegate = self
        homeTableView.dataSource = self
        
        homeTableView.showsVerticalScrollIndicator = false
        homeTableView.separatorStyle = .none
        //homeTableView.rowHeight = 430
        
        homeTableView.isPagingEnabled = true
        
        homeTableView.register(UINib(nibName: "HomeTableViewCell", bundle: nil), forCellReuseIdentifier: "homeCell")
        
        homeTableView.register(UINib(nibName: "HomeCollabTableViewCell", bundle: nil), forCellReuseIdentifier: "homeCollabTableViewCell")
        
        configureCalendar(currentDate)
        
        profileButton.addTarget(self, action: #selector(profileButtonPressed), for: .touchUpInside)
        
//        tabBarController?.tabBar.barTintColor = .white
//        //tabBarController?.tabBar.shadowImage = UIImage()
//        tabBarController?.tabBar.isTranslucent = false
//        tabBarController?.tabBar.clipsToBounds = true
        
        //tabBarController?.delegate = self
        
        if currentUser.userSignedIn {
            
            userNameLabel.text = "Hey \(currentUser.firstName)"
            
            let firebaseCollab = FirebaseCollab.sharedInstance
            
            firebaseCollab.retrieveUsersFriends()
        }
        
        else {
            
            formatter.dateFormat = "MMMM"
            userNameLabel.text =  "Here's your \(formatter.string(from: currentDate)) calendar"
            userNameLabel.adjustsFontSizeToFitWidth = true
        }
        
        if /*currentUser.profilePictureURL != nil && */currentUser.profilePictureImage == nil {
            
            setProfilePicture()
            
            retrieveCollabs()
        }
        
        configureTabBar()
        
//        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
//        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//
//            UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
//
//                print(requests)
//            }
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        configureNavBar()
        
        tabBar.shouldHide = false
        
//        configureTabBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
//        tabBar.previousNavigationController = navigationController
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if viewInitiallyLoaded == false {
            
            scrollToCurrentWeek()
            viewInitiallyLoaded = true
        }
        
//        configureTabBar()
        
//        if tabBar.previousNavigationController == navigationController && tabBar.popped != true {
//
//            configureTabBar()
//        }
//
//        else if tabBar.popped == true {
//
//            tabBar.popped = false
//        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        //tabBar.shouldHide = true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
         
        if viewTracker == "personal" {
           
            return weekSectionArray?.count ?? 0
        }
        
        else {
            
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if viewTracker == "personal" {
            
            return 1
        }
        
        else {

            return firebaseCollab.collabs.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
        if viewTracker == "personal" {
            
            return homeTableView.frame.height
        }
        
        else {
            
            return 300
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if viewTracker == "personal" {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "homeCell", for: indexPath) as! HomeTableViewCell
            cell.selectionStyle = .none
            
            cell.personalCollectionContent = weekSectionArray?[indexPath.section]
            
            cell.homeViewController = self
            
            return cell
        }
        
        else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "homeCollabTableViewCell", for: indexPath) as! HomeCollabTableViewCell
            cell.selectionStyle = .none
            
            cell.collab = firebaseCollab.collabs[indexPath.row]
            cell.collabSelectedDelegate = self
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        //Checks to see if the cell matching the current date is going to be displayed; done after the tableView is autoScrolled
        if tableViewAutoScrolled == true {
            
            scrollToCurrentDay(tableView, cell, indexPath)
        }
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        
        return false
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        
    }

    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        if visibleCell ?? nil != nil {
            
            if let cell = homeTableView.cellForRow(at: visibleCell!) as? HomeTableViewCell {
                
                cell.shrinkPersonalCell()
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if decelerate == false {
            
            scrollToMostVisibleCell()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        scrollToMostVisibleCell()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
        scrollToMostVisibleCell()
    }

    
    private func animateEntryToView () {
        
        let animationView = UIView(frame: view.frame)
        animationView.backgroundColor = UIColor(hexString: "262626")
        
        view.addSubview(animationView)
        
        UIView.animate(withDuration: 0.25, animations: {
            
            animationView.backgroundColor = .clear
            
            self.navigationController?.navigationBar.isHidden = false
            self.tabBarController?.tabBar.isHidden = false
            
        }) { (finished: Bool) in
            
            animationView.removeFromSuperview()
        }
    }
    
    private func configureNavBar () {
        
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
//        self.navigationController?.navigationBar.shadowImage = UIImage()
//        //self.navigationController?.navigationBar.isTranslucent = true
//        self.navigationController?.view.backgroundColor = .clear
        
        self.navigationController?.navigationBar.configureNavBar(barBackgroundColor: .clear, barTintColor: .black)
        
        let profileButton: UIButton = UIButton(type: .system)
        profileButton.frame = CGRect(x: 0, y: 0, width: 79, height: 50)
        //profileButton.backgroundColor = UIColor.blue.withAlphaComponent(0.4)
        profileButton.addTarget(self, action: #selector(profileButtonPressed), for: .touchUpInside)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileButton)
        
        let newCollabButton: UIButton = UIButton(type: .system)
        newCollabButton.setImage(UIImage(named: "genius"), for: .normal)
        newCollabButton.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        newCollabButton.addTarget(self, action: #selector(createCollab), for: .touchUpInside)
        
        collab_personalButton.frame = CGRect(x: 0, y: 0, width: 65, height: 25)
        collab_personalButton.backgroundColor = UIColor(hexString: "ECECEC", withAlpha: 0.70)
        collab_personalButton.addTarget(self, action: #selector(updateView), for: .touchUpInside)
        
        collab_personalButton.layer.cornerRadius = 14
        collab_personalButton.clipsToBounds = true
        
        collab_personalButton.setTitle("Collab", for: .normal)
        collab_personalButton.titleLabel?.font = UIFont(name: "Poppins-Regular", size: 13)
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: newCollabButton), UIBarButtonItem(customView: collab_personalButton)]
        
        profilePicContainer.layer.shadowRadius = 2.5
        profilePicContainer.layer.shadowColor = UIColor(hexString: "39434A")?.cgColor
        profilePicContainer.layer.shadowOffset = CGSize(width: 0, height: 0)
        profilePicContainer.layer.shadowOpacity = 0.75
        
        profilePicContainer.layer.borderWidth = 1
        profilePicContainer.layer.borderColor = UIColor(hexString: "F4F4F4", withAlpha: 0.05)?.cgColor
        
        profilePicContainer.layer.cornerRadius = 0.5 * profilePicContainer.bounds.width
        profilePicContainer.layer.masksToBounds = false
        profilePicContainer.clipsToBounds = false
        
        profilePicImageView.layer.cornerRadius = 0.5 * profilePicImageView.bounds.width
        profilePicImageView.layer.masksToBounds = false
        profilePicImageView.clipsToBounds = true
        
        profilePicBlurView.layer.cornerRadius = 0.5 * profilePicImageView.bounds.width
        profilePicBlurView.clipsToBounds = true
        profilePicBlurView.alpha = 0
    }
    
    func configureTabBar () {

        tabBarController?.tabBar.isHidden = true
//        tabBarController?.delegate = tabBar
//        
//        tabBar.shouldHide = false
//        tabBar.tabBarController = tabBarController
//        tabBar.currentNavigationController = self.navigationController
//        
//        tabBar.animateEntryToView()
//        tabBar.workItem?.cancel()
        
//        tabBarController?.delegate = self
        tabBar.homeTabNavigationController = navigationController
        tabBar.tabBarController = tabBarController
        
        keyWindow?.addSubview(tabBar)
    }
    
    private func setProfilePicture () {
        
        let firebaseStorage = FirebaseStorage()
        
        animateProfilePic(true)
        
        firebaseStorage.retrieveUserProfilePicFromStorage(userID: currentUser.userID) { (profilePic, nil) in

            self.animateProfilePic(false)

            UIView.transition(with: self.profilePicContainer, duration: 0.3, options: .curveLinear, animations: {

                self.profilePicImageView.image = self.currentUser.profilePictureImage

            }, completion: nil)
        }
        
//        firebaseStorage.retrieveCurrentUsersProfilePicFromStorage(profilePicURL: currentUser.profilePictureURL!) {
//
//            self.animateProfilePic(false)
//
//            UIView.transition(with: self.profilePicContainer, duration: 0.3, options: .curveLinear, animations: {
//
//                self.profilePicImageView.image = self.currentUser.profilePictureImage
//
//            }, completion: nil)
//        }
    }
    
    private func animateProfilePic (_ animate: Bool) {
        
        if animate {
            
            profilePicBlurView.alpha = 0.3
            
            let iProgress = iProgressHUD()
            iProgress.isShowModal = false
            iProgress.isShowCaption = false
            iProgress.isTouchDismiss = false
            iProgress.boxColor = .clear
            
            iProgress.indicatorSize = 100
            
            iProgress.attachProgress(toView: profilePicContainer)
            
            profilePicContainer.updateIndicator(style: .circleStrokeSpin)
            
            profilePicContainer.showProgress()
        }
        
        else {
            
            profilePicContainer.dismissProgress()
            
            UIView.animate(withDuration: 0.15) {
                
                self.profilePicBlurView.alpha = 0
            }
        }
    }
    
    private func configureMonthButton () {
        
        let monthButton: UIButton = UIButton()
        monthButton.backgroundColor = .white
        
        monthButton.addTarget(self, action: #selector(monthButtonPressed), for: .touchUpInside)
        
        view.addSubview(monthButton)
        
        monthButton.translatesAutoresizingMaskIntoConstraints = false
        
        monthButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15).isActive = true
        monthButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -110).isActive = true
        monthButton.widthAnchor.constraint(equalToConstant: 67.5).isActive = true
        monthButton.heightAnchor.constraint(equalToConstant: 67.5).isActive = true

        monthButton.layer.cornerRadius = 0.5 * monthButton.bounds.size.width

        monthButton.layer.shadowRadius = 2.5
        monthButton.layer.shadowColor = UIColor(hexString: "39434A")?.cgColor
        monthButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        monthButton.layer.shadowOpacity = 0.35

        monthButton.layer.cornerRadius = 0.5 * 67.5
        monthButton.layer.masksToBounds = false
        monthButton.clipsToBounds = false

        monthButton.layer.borderWidth = 1
        monthButton.layer.borderColor = UIColor(hexString: "F2F2F2")?.cgColor

        let monthImage = UIImageView(image: UIImage(named: "database"))
        monthImage.contentMode = .scaleToFill

        view.addSubview(monthImage)

        monthImage.translatesAutoresizingMaskIntoConstraints = false

        monthImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25).isActive = true
        monthImage.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -120).isActive = true
        monthImage.widthAnchor.constraint(equalToConstant: 45).isActive = true
        monthImage.heightAnchor.constraint(equalToConstant: 45).isActive = true
    }
    
    private func configureCalendar (_ date: Date) {
        
        weekSectionArray?.removeAll()
        weekSectionArray = [[]]
        
        formatter.dateFormat = "M/d"
        
        let calendar = Calendar.current
        
        let interval = calendar.dateInterval(of: .month, for: date)
        
        let days = calendar.dateComponents([.day], from: interval!.start, to: interval!.end).day!
        
        let startOfMonth = interval!.start
        
        var loopCount: Int = 0
        var weekCount: Int = 0
        
        while loopCount < days {
            
            let currentDate: Date = calendar.date(byAdding: .day, value: loopCount, to: startOfMonth)!
            
            weekSectionArray?[weekCount].append(currentDate)
            
            if (calendar.component(.weekday, from: currentDate) == 7) && (loopCount + 1 != days) {
                
                weekCount += 1
                weekSectionArray?.append([])
            }
            
            loopCount += 1
        }
        
        formatter.dateFormat = "MMMM"
        monthLabel.text = formatter.string(from: date)
    }
    
    private func scrollToCurrentWeek () {
        
        //homeTableView.isUserInteractionEnabled = false
        
        let currentDate: Date = Date()
        formatter.dateFormat = "MMMM d yyyy"
        
        var sectionToScrollTo: Int?
         
        var count: Int = 0
        
        if weekSectionArray?.count ?? 0 > 0 {
            
            for dates in weekSectionArray! {
                
                for date in dates {

                    if formatter.string(from: date) == formatter.string(from: currentDate) {

                        sectionToScrollTo = count

                        break
                    }
                }
                
                if sectionToScrollTo != nil {
                    
                    break
                }
                
                count += 1
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                
                let indexPath: IndexPath = IndexPath(row: 0, section: sectionToScrollTo ?? 0)
                self.visibleCell = IndexPath(row: 0, section: indexPath.section)
                
                if indexPath.section == 0 {
                    
                    let cell = self.homeTableView.cellForRow(at: self.visibleCell!)
                    
                    self.scrollToCurrentDay(self.homeTableView, cell!, self.visibleCell!)
                }
                
                else {
                    
                    self.homeTableView.scrollToRow(at: indexPath, at: .top, animated: true)
                    
                    self.tableViewAutoScrolled = true
                }
            }
        }
    }
    
    private func scrollToCurrentDay (_ tableView: UITableView, _ cell: UITableViewCell, _ indexPath: IndexPath) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {

            let confirmedVisibleCell: Int?

//            //If the user is not on the last section of the homeTableView
//            if indexPath.section != self.weekSectionArray.count - 1 {
//
//                confirmedVisibleCell = 1
//                //print("check1")
//            }
//
//            else {
//
//                confirmedVisibleCell = 2
//                //print("check2")
//            }
            
            confirmedVisibleCell = 0

            if tableView.cellForRow(at: indexPath) == tableView.visibleCells[confirmedVisibleCell ?? 1] {

                //print("check12")

                let currentDate: Date = Date()
                self.formatter.dateFormat = "MMMM d yyyy"

                if let homeCell = cell as? HomeTableViewCell {

                    //print("check2")

                    var indexToScrollTo: Int = 0
                    var count: Int = 0

                    for date in homeCell.personalCollectionContent {

                        if self.formatter.string(from: date) == self.formatter.string(from: currentDate) {

                            indexToScrollTo = count
                            break
                        }

                        count += 1
                    }

                    let indexPath: IndexPath = IndexPath(row: indexToScrollTo, section: 0)
                    homeCell.personalCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                    homeCell.visibleItem = indexPath

                    homeCell.growPersonalCell(delay: 0.5)

                    self.homeTableView.isUserInteractionEnabled = true
                    self.tableViewAutoScrolled = false
                }
            }
        }
    }
    
    private func scrollToMostVisibleCell () {
        
        if viewTracker == "personal" {
            
            let visibleRows: [IndexPath] = homeTableView.indexPathsForVisibleRows!
            let topHalfRect: CGRect = CGRect(x: 0, y: navigationItem.accessibilityFrame.height, width: view.frame.width, height: (view.center.y - navigationItem.accessibilityFrame.height))
            var topHalfCells: [IndexPath] = []

            var count = 0

            for cell in homeTableView.visibleCells {

                let cellFrame: CGRect = CGRect(x: cell.frame.minX, y: cell.frame.minY - homeTableView.contentOffset.y, width: cell.frame.width, height: cell.frame.height)

                if cellFrame.intersects(topHalfRect) {

                    topHalfCells.append(visibleRows[count])
                }

                count += 1
            }

            let indexPath: IndexPath = IndexPath(row: 0, section: topHalfCells[0][0])
            homeTableView.scrollToRow(at: indexPath, at: .top, animated: true)

            visibleCell = IndexPath(row: 0, section: indexPath.section)

            let cell = homeTableView.cellForRow(at: visibleCell!) as! HomeTableViewCell

            cell.assignVisibleCell {
                cell.growPersonalCell()
            }
        }
    }
    
    private func retrieveCollabs () {
        
//        firebaseCollab.retrieveCollabs()
    }
    
    func moveToTimeBlockView (selectedDate: Date) {
        
        self.selectedDate = selectedDate
        
        performSegue(withIdentifier: "moveToTimeBlockView", sender: self)
    }
    
    @objc private func profileButtonPressed () {
        
        performSegue(withIdentifier: "moveToProfilePopover", sender: self)
    }
    
    @objc private func updateView () {
        
        if viewTracker == "personal" {
            
            viewTracker = "collab"
            homeTableView.isPagingEnabled = false
            collab_personalButton.setTitle("Personal", for: .normal)
            collab_personalButton.titleLabel?.font = UIFont(name: "Poppins-Regular", size: 12)
        }
        
        else {
            
            viewTracker = "personal"
            homeTableView.isPagingEnabled = true
            collab_personalButton.setTitle("Collab", for: .normal)
            collab_personalButton.titleLabel?.font = UIFont(name: "Poppins-Regular", size: 13)
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            
            self.homeTableView.alpha = 0
            
        }) { (finished: Bool) in
            
            self.homeTableView.reloadData()
            
            if self.firebaseCollab.collabs.count > 0 {
                
                self.homeTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                
                self.homeTableView.alpha = 1
            })
        }
    }
    
    @objc private func createCollab () {
        
//        performSegue(withIdentifier: "moveToCreateACollabView", sender: self)
        
        let configureCollabVC = ConfigureCollabViewController()
        configureCollabVC.title = "Create a Collab"
        configureCollabVC.configurationView = true
        
        configureCollabVC.configureBarButtonItems()
        
//        configureCollabVC.collabCreatedDelegate = self
        
        let configureCollabNavigationController = UINavigationController(rootViewController: configureCollabVC)
        configureCollabNavigationController.navigationBar.prefersLargeTitles = true
        
        self.present(configureCollabNavigationController, animated: true, completion: nil)
    }
    
    @objc private func monthButtonPressed () {
        
        print("move to calendar view")
    }
    
    @IBAction func previousMonth(_ sender: Any) {
        
        let calendar = Calendar.current
        currentDate = calendar.date(byAdding: .month, value: -1, to: currentDate)!
        
        configureCalendar(currentDate)
        
        formatter.dateFormat = "MMMM"
        userNameLabel.text =  "Here's your \(formatter.string(from: currentDate)) calendar"
        userNameLabel.adjustsFontSizeToFitWidth = true
        
        if visibleCell ?? nil != nil {
            
            if let cell = homeTableView.cellForRow(at: visibleCell!) as? HomeTableViewCell {
            
                cell.shrinkPersonalCell()
            }
        }
        
        homeTableView.reloadData()
        homeTableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
    }
    
    @IBAction func nextMonth(_ sender: Any) {
        
        let calendar = Calendar.current
        currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate)!
        
        configureCalendar(currentDate)
        
        formatter.dateFormat = "MMMM"
        userNameLabel.text = "Here's your \(formatter.string(from: currentDate)) calendar"
        userNameLabel.adjustsFontSizeToFitWidth = true
        
        if visibleCell ?? nil != nil {
            
            if let cell = homeTableView.cellForRow(at: visibleCell!) as? HomeTableViewCell {
                
                cell.shrinkPersonalCell()
            }
        }
        
        homeTableView.reloadData()
        homeTableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let item: UIBarButtonItem = UIBarButtonItem()
        item.title = ""
        navigationItem.backBarButtonItem = item
        
        if segue.identifier == "moveToTimeBlockView" {
            
//            let timeBlockVC = segue.destination as! TimeBlockViewController2
//            timeBlockVC.currentDate = selectedDate!
        }
        
        else if segue.identifier == "moveToProfilePopover" {
            
            let sidebarVC = segue.destination as! ProfileSidebarViewController
            sidebarVC.moveToProfileDelegate = self
            
        }
        
        else if segue.identifier == "moveToProfileView" {
            
            let profileVC = segue.destination as! ProfileViewController
            profileVC.profileViewDelegate = self
        }
        
        else if segue.identifier == "moveToCreateACollabView" {
    
            if let navController = segue.destination as? UINavigationController {
                
//                let createCollabVC = navController.viewControllers.first as! CreateCollabViewController
//                createCollabVC.collabCreatedDelegate = self
            }
        }
        
        else if segue.identifier == "moveToCollabView" {
            
            let collabVC = segue.destination as! CollabViewController
            collabVC.collab = selectedCollab
        }
    }
}

//extension HomeViewController2: CollabCreatedProtocol {
//
//    func collabCreated (_ collab: Collab) {
//
//        print("check")
//    }
//}

extension HomeViewController2: MoveToProfile {
    
    func moveToProfileView () {
        
        dismiss(animated: false) {
            
            self.performSegue(withIdentifier: "moveToProfileView", sender: self)
        }
    }
}

extension HomeViewController2: ProfileView {
    
    func profilePicChanged (_ image: UIImage) {
        
        profilePicImageView.image = image
    }
}

//extension HomeViewController2: CollabCreated {
//
//    func reloadData() {
//
//        retrieveCollabs()
//
//        viewTracker = "personal"
//
//        updateView()
//    }
//
//}

extension HomeViewController2: CollabSelected {
    
    func performSegueToCollab(collab: Collab) {
        
        selectedCollab = collab
        
        performSegue(withIdentifier: "moveToCollabView", sender: self)
    }
}
