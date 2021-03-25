//
//  HomeViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 3/8/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

//    var blockVC: BlockViewController?
    
    let headerView = HomeHeaderView()
//    let profilePicture = ProfilePicture()
    let profilePictureButton = UIButton()
    
    lazy var progressView = iProgressView(self, 100, .circleStrokeSpin)
//    let welcomeLabel = UILabel()
    
    lazy var collabCollectionView = UICollectionView(frame: .zero, collectionViewLayout: CollabCollectionViewFlowLayout(self))
    
    lazy var tabBar = CustomTabBar.sharedInstance
    
    let calendarButton = UIButton(type: .system)
    
    let currentUser = CurrentUser.sharedInstance
    let firebaseCollab = FirebaseCollab.sharedInstance
    let firebaseBlock = FirebaseBlock.sharedInstance
    
    var collabs: [Collab]?
    var selectedCollab: Collab?
    
    var blocks: [Block]?
    
    let calendar = Calendar.current
    let formatter = DateFormatter()
    
    let minimumHeaderViewHeight: CGFloat = (keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 60 : 40) + 135//80
    let maximumHeaderViewHeight: CGFloat = (keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 60 : 40) + 428.5 //Extra 2.5 added to improve aesthetics
    
    var expandedIndexPath: IndexPath?
    
    var selectedDate: Date?
    
    var headerViewHeightConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.hidesBackButton = true
        
        configureHomeHeaderView()
//        configureProfilePictureButton()
        
        configureCollectionView(collabCollectionView)
        
        configureTabBar()
        configureCalendarButton()
        
        configureGestureRecognizors()
        
        firebaseCollab.retrieveCollabs { [weak self] (collabs, members, error) in
            
            if collabs != nil {
                
                if self?.collabs == nil {
                    
                    self?.collabs = collabs?.sorted(by: { $0.dates["deadline"]! > $1.dates["deadline"]! })
                    
                    self?.collabCollectionView.reloadData()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        
                        self?.expandCollabCell()
                    }
                }
                
                else {
                    
                    
                }
            }
        }
        
        firebaseBlock.retrievePersonalBlocks { [weak self] (error, blocks) in
            
            if error != nil {
                
                print(error?.localizedDescription as Any)
            }
            
            else {
                
                self?.blocks = blocks
                
                self?.headerView.blocks = blocks
                
                self?.navigationController?.viewControllers.forEach({ (viewController) in
                    
                    if let blockVC = viewController as? BlockViewController {
                        
                        blockVC.blocks = blocks
                    }
                })
                
//                self?.blockVC?.blocks = blocks
            }
        }
        
        if currentUser.userSignedIn {
            
            firebaseCollab.retrieveUsersFriends()
        }
        
//        print(currentUser.userID)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.configureNavBar(barBackgroundColor: .clear, barStyleColor: .default)
        
        tabBar.shouldHide = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        blockVC = nil
    }
    
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
    
    private func configureProfilePictureButton () {
        
        if keyWindow != nil {
            
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
    
    private func configureCollectionView (_ collectionView: UICollectionView) {
        
        self.view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            collectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0),
            collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
        
        collectionView.backgroundColor = .white
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.delaysContentTouches = false
        
        //content inset also important because if there are not enough cells to fill the collection view, the header will not be able to be expanded again upon
        //collection view drag... just a quick note
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 300, right: 0)
        
        collectionView.register(HomeCollabCollectionViewCell.self, forCellWithReuseIdentifier: "homeCollabCollectionViewCell")
    }
    
    private func configureTabBar () {
        
        tabBarController?.tabBar.isHidden = true
        
        tabBar.homeTabNavigationController = navigationController
        tabBar.tabBarController = tabBarController
        
        keyWindow?.addSubview(tabBar)
    }
    
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

//        addBlockButton.addTarget(self, action: #selector(addBlockButtonPressed), for: .touchUpInside)
    }
    
    private func configureGestureRecognizors () {
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:)))
//        panGesture.cancelsTouchesInView = false
        headerView.addGestureRecognizer(panGesture)
    }
    
    @objc private func handlePan (sender: UIPanGestureRecognizer) {
        
        switch sender.state {
        
        case .began, .changed:
            
            if collabCollectionView.indexPathsForVisibleItems.contains(where: { $0.row == 0 }) {
                
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
    
    private func moveWithPan (_ sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: self.view)
        
        if translation.y > 0 {
            
            if (headerViewHeightConstraint?.constant ?? 0) + translation.y < maximumHeaderViewHeight {
                
                headerViewHeightConstraint?.constant += translation.y
                
                animateHeaderViewAlpha()
            }
            
            else {
                
                headerViewHeightConstraint?.constant = maximumHeaderViewHeight
                
            }
        }
        
        else {
            
            if (headerViewHeightConstraint?.constant ?? 0) + translation.y > minimumHeaderViewHeight {
                
                headerViewHeightConstraint?.constant += translation.y
                
                animateHeaderViewAlpha()
            }
            
            else {
                
                headerViewHeightConstraint?.constant = minimumHeaderViewHeight
                
                headerView.calendarHeaderLabel.alpha = 0
                headerView.calendarView.alpha = 0
                headerView.scheduleCollectionView.alpha = 0
            }
        }
        
        sender.setTranslation(.zero, in: self.view)
    }
    
    private func animateHeaderViewAlpha () {
        
        let alphaPart = 1 / (maximumHeaderViewHeight - minimumHeaderViewHeight)

        headerView.calendarHeaderLabel.alpha = alphaPart * ((headerViewHeightConstraint?.constant ?? 0) - minimumHeaderViewHeight)
        headerView.calendarView.alpha = alphaPart * ((headerViewHeightConstraint?.constant ?? 0) - minimumHeaderViewHeight)
        headerView.scheduleCollectionView.alpha = alphaPart * ((headerViewHeightConstraint?.constant ?? 0) - minimumHeaderViewHeight)
    }
    
    private func expandHeaderView () {
        
        headerViewHeightConstraint?.constant = maximumHeaderViewHeight
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            
            self.view.layoutIfNeeded()
            
            self.headerView.calendarHeaderLabel.alpha = 1
            self.headerView.calendarView.alpha = 1
            self.headerView.scheduleCollectionView.alpha = 1
        }
    }
    
    private func shrinkHeaderView () {
        
        headerViewHeightConstraint?.constant = minimumHeaderViewHeight
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            
            self.view.layoutIfNeeded()
            
            self.headerView.calendarHeaderLabel.alpha = 0
            self.headerView.calendarView.alpha = 0
            self.headerView.scheduleCollectionView.alpha = 0
        }
    }
    
    func updateSelectedDate (date: Date) {
        
        let updatedDateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        selectedDate = calendar.date(from: updatedDateComponents)
        
        if let date = selectedDate {
            
            headerView.calendarView.scrollToDate(date)
            headerView.calendarView.selectDates([date])
            
            formatter.dateFormat = "yyyy MM dd"
            
            let differenceInDates = calendar.dateComponents([.day], from: formatter.date(from: "2010 01 01") ?? Date(), to: date).day
            headerView.scheduleCollectionView.scrollToItem(at: IndexPath(item: differenceInDates ?? 0, section: 0), at: .centeredHorizontally, animated: true)
        }
    }
    
    func moveToBlocksView (_ selectedDate: Date) {
        
        self.selectedDate = selectedDate
        
        performSegue(withIdentifier: "moveToPersonalBlocksView", sender: self)
        
//        blockVC = BlockViewController()
//        blockVC?.formatter = formatter
//        blockVC?.selectedDate = selectedDate
//        blockVC?.blocks = blocks
//
//        let backBarItem = UIBarButtonItem()
//        backBarItem.title = ""
//        self.navigationItem.backBarButtonItem = backBarItem
//
//        self.navigationController?.pushViewController(blockVC!, animated: true)
    }
    
    func moveToAddCollabView () {
        
        let configureCollabVC = ConfigureCollabViewController()
        configureCollabVC.title = "Create a Collab"
        configureCollabVC.configurationView = true
        
        configureCollabVC.configureBarButtonItems()
        
//        configureCollabVC.collabCreatedDelegate = self
        
        let configureCollabNavigationController = UINavigationController(rootViewController: configureCollabVC)
        configureCollabNavigationController.navigationBar.prefersLargeTitles = true
        
        self.present(configureCollabNavigationController, animated: true, completion: nil)
    }
    
    @objc private func profilePictureButtonPressed () {
        
        performSegue(withIdentifier: "moveToProfileView", sender: self)
    }
    
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
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return collabs?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "homeCollabCollectionViewCell", for: indexPath) as! HomeCollabCollectionViewCell

        cell.formatter = formatter

        cell.collab = collabs?[indexPath.row]
        
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
        
//        print(scrollView.contentOffset)
        
        if scrollView.contentOffset.y >= 0 {

            //If the homeHeaderView is larger than minimum allowable height, process to decrementing its height
            if (headerViewHeightConstraint?.constant ?? 140) - scrollView.contentOffset.y > minimumHeaderViewHeight {

                headerViewHeightConstraint?.constant -= scrollView.contentOffset.y
                scrollView.contentOffset.y = 0

                animateHeaderViewAlpha()
            }

            else {

                if headerViewHeightConstraint?.constant != minimumHeaderViewHeight {

                    headerViewHeightConstraint?.constant = minimumHeaderViewHeight

                    headerView.calendarHeaderLabel.alpha = 0
                    headerView.calendarView.alpha = 0
                    headerView.scheduleCollectionView.alpha = 0

                    shrinkCollabCell()
                }
            }
        }

        else {

            //Checking if tracking because this was causing the header view to expand again when the user was attempting to scroll up
            //enabling the flicking then going to recheck if this is neccasary
            if headerViewHeightConstraint?.constant ?? 0 < maximumHeaderViewHeight/*, !scrollView.isTracking*/ {

                if headerViewHeightConstraint?.constant != maximumHeaderViewHeight {

                    headerViewHeightConstraint?.constant = maximumHeaderViewHeight

                    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {

                        self.view.layoutIfNeeded()
                    }
                }
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        if headerViewHeightConstraint?.constant == minimumHeaderViewHeight {
            
            shrinkCollabCell()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if !decelerate {
            
            expandCollabCell()
        }
        
        if headerViewHeightConstraint?.constant ?? 0 < maximumHeaderViewHeight * 0.8 {
            
            shrinkHeaderView()
        }
        
        else {
            
            expandHeaderView()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        expandCollabCell()
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        
        for visibleCell in collabCollectionView.visibleCells {
            
            if let cell = visibleCell as?HomeCollabCollectionViewCell {
                
                cell.shrinkCell()
            }
        }
        
        return true
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        
        expandedIndexPath = nil
        
        expandCollabCell()
    }
    
    private func expandCollabCell () {
        
        let visibleIndexPaths = collabCollectionView.indexPathsForVisibleItems.sorted(by: { $0.row < $1.row })
        
//        print(visibleIndexPaths.first?.row)
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//
//            print(self.collabCollectionView.indexPathsForVisibleItems.sorted(by: { $0.row < $1.row }).first?.row, "\n")
//        }
        
        //Ensures that the cell to be expanded hasn't already been expanded by the CollectionViewFlowLayout class
        if let firstIndexPath = visibleIndexPaths.first, expandedIndexPath == nil {
            
            if let cell = collabCollectionView.cellForItem(at: firstIndexPath) as? HomeCollabCollectionViewCell {
                
                cell.expandCell()
            }
            
            expandedIndexPath = firstIndexPath
            
            collabCollectionView.performBatchUpdates {
                
                self.collabCollectionView.reloadData()
            }
        }
    }
    
    private func shrinkCollabCell () {
        
        collabCollectionView.visibleCells.forEach { (collabCell) in

            if let cell = collabCell as? HomeCollabCollectionViewCell {

                cell.shrinkCell()
            }
        }

        expandedIndexPath = nil

        collabCollectionView.performBatchUpdates {

            self.collabCollectionView.reloadData()
        }
    }
}

extension HomeViewController: HomeViewProtocol {
    
    func collabCreated (_ collabID: String) {
        
    }
}
