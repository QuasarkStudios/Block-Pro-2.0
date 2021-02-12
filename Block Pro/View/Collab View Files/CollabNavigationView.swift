//
//  CollabNavigationView.swift
//  Block Pro
//
//  Created by Nimat Azeez on 9/29/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CollabNavigationView: UIView {
    
    let panGestureView = UIView()
    let panGestureIndicator = UIView()
    
    let buttonStackView = UIStackView()
    
    let progressButton = UIButton(type: .system)
    let blocksButton = UIButton(type: .system)
    let messagesButton = UIButton(type: .system)
    
    let calendarContainer = UIView()
    let calendarHeaderLabel = UILabel()
    let calendarView = JTAppleCalendarView()
    
    lazy var collabProgressView = CollabProgressView(collabViewController)
    var progressViewTopAnchorWithStackView: NSLayoutConstraint?
    var progressViewHeightConstraint: NSLayoutConstraint?
    
    let collabTableView = UITableView()
    var tableViewTopAnchorWithStackView: NSLayoutConstraint?
    var tableViewTopAnchorWithCalendar: NSLayoutConstraint?
    
    lazy var progressAnimationView = ProgressAnimationView()
    var progressAnimationViewTopAnchor: NSLayoutConstraint?
    var progressAnimationViewHeightConstraint: NSLayoutConstraint?
    
    var collabStartTime: Date?
    var collabDeadline: Date?
    
    let formatter = DateFormatter()
    
    var originalTableViewContentOffset: CGFloat?
    
    let progressViewHeight: CGFloat = ((UIScreen.main.bounds.width * 0.5) + 12 + 55) + 87
    
    var animationViewShrunkenHeight: CGFloat = 0
    var animationViewExpandedHeight: CGFloat = 0
    
    //Only used when collabProgressView is present
    var maximumTableViewTopAnchorWithStackView: CGFloat {
        
        if let viewController = collabViewController as? CollabViewController {
            
            //Top anchor of the collabNavigationView + the top anchor and height of the panGestureIndicator + the height of buttonStackView + the progressViewHeight and it's topAnchor
            if (viewController.collabHeaderView.configureViewHeight() - 80) + (27.5 + 40) + progressViewHeight + 10 > UIScreen.main.bounds.height {
                
                //Means that the height of the tableView will be less than zero if the topAnchor is set to the height of the progressViewHeight
                return UIScreen.main.bounds.height - (viewController.collabHeaderView.configureViewHeight() - 80) - (27.5 + 40)
            }
            
            else {
                
                //Height of the progressView + it's topAnchor
                return progressViewHeight + 10
            }
        }
        
        else {
            
            return 0
        }
    }
    
    weak var collabViewController: AnyObject?
    
    init (_ collabViewController: AnyObject, collabStartTime: Date?, collabDeadline: Date?) {
        super.init(frame: .zero)
        
        self.collabStartTime = collabStartTime
        self.collabDeadline = collabDeadline
        
        self.collabViewController = collabViewController
        
        configureView()
        configurePanGestureView()
        configureButtonStackView()
        configureButtons()
        configureCalendarContainer()
        configureCalendarHeader()
        configureCalendarView()
        configureCollabProgressView()
        configureTableView()
        configureProgressAnimationView() //Call here
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Configure View
    
    private func configureView () {
        
        self.backgroundColor = .white
    
        self.layer.cornerRadius = 27.5
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    
    //MARK: - Configure Pan Gesture View
    
    private func configurePanGestureView () {
        
        self.addSubview(panGestureIndicator) //Add this as a subview first
        self.addSubview(panGestureView)
        
        panGestureIndicator.translatesAutoresizingMaskIntoConstraints = false
        panGestureView.translatesAutoresizingMaskIntoConstraints = false
        
        [

            panGestureIndicator.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            panGestureIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            panGestureIndicator.widthAnchor.constraint(equalToConstant: 50),
            panGestureIndicator.heightAnchor.constraint(equalToConstant: 7.5),
            
            panGestureView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            panGestureView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            panGestureView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            panGestureView.heightAnchor.constraint(equalToConstant: 80)

        ].forEach{( $0.isActive = true )}
        
        panGestureIndicator.backgroundColor = UIColor(hexString: "222222")
        panGestureIndicator.layer.cornerRadius = 4
        panGestureIndicator.layer.cornerCurve = .continuous
        panGestureIndicator.clipsToBounds = true
    }
    
    
    //MARK: - Configure Button Stack View
    
    private func configureButtonStackView () {
        
        self.addSubview(buttonStackView)
        
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            buttonStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            buttonStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            buttonStackView.topAnchor.constraint(equalTo: panGestureIndicator.bottomAnchor, constant: 10),
            buttonStackView.heightAnchor.constraint(equalToConstant: 40)
        
        ].forEach({ $0.isActive = true })
        
        buttonStackView.alignment = .fill
        buttonStackView.distribution = .fillEqually
        
        buttonStackView.addArrangedSubview(progressButton)
        buttonStackView.addArrangedSubview(blocksButton)
        buttonStackView.addArrangedSubview(messagesButton)
    }
    
    
    //MARK: - Configure Buttons
    
    private func configureButtons () {
        
        progressButton.setTitle("Progress", for: .normal)
        progressButton.setTitleColor(UIColor.lightGray, for: .normal)
        progressButton.titleLabel?.font = UIFont(name: "Poppins-Medium", size: 15)
        progressButton.addTarget(self, action: #selector(progressButtonTouchUpInside), for: .touchUpInside)
        
        blocksButton.setTitle("Blocks", for: .normal)
        blocksButton.setTitleColor(UIColor.black, for: .normal)
        blocksButton.titleLabel?.font = UIFont(name: "Poppins-Medium", size: 15)
        blocksButton.addTarget(self, action: #selector(blocksButtonTouchUpInside), for: .touchUpInside)
        
        messagesButton.setTitle("Messages", for: .normal)
        messagesButton.setTitleColor(UIColor.lightGray, for: .normal)
        messagesButton.titleLabel?.font = UIFont(name: "Poppins-Medium", size: 15)
        messagesButton.addTarget(self, action: #selector(messagesButtonTouchUpInside), for: .touchUpInside)
    }
    
    
    //MARK: - Configure Table View
    
    private func configureTableView() {
        
        self.addSubview(collabTableView)
        collabTableView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            collabTableView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            collabTableView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            collabTableView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
        
        tableViewTopAnchorWithStackView = collabTableView.topAnchor.constraint(equalTo: buttonStackView.bottomAnchor, constant: 10)
        tableViewTopAnchorWithStackView?.isActive = true
        
        tableViewTopAnchorWithCalendar = collabTableView.topAnchor.constraint(equalTo: calendarContainer.bottomAnchor, constant: 5)
        tableViewTopAnchorWithCalendar?.isActive = false
        
        collabTableView.keyboardDismissMode = .interactive
        
        collabTableView.delaysContentTouches = false
        
        collabTableView.register(UITableViewCell.self, forCellReuseIdentifier: "seperatorCell")
    }
    
    //MARK: - Configure Calendar Container
    
    private func configureCalendarContainer () {
        
        self.addSubview(calendarContainer)
        calendarContainer.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            calendarContainer.topAnchor.constraint(equalTo: self.topAnchor, constant: topBarHeight + 10),
            calendarContainer.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            calendarContainer.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            calendarContainer.heightAnchor.constraint(equalToConstant: 0) //Height will be set later
        
        ].forEach({ $0.isActive = true })
        
        calendarContainer.clipsToBounds = true //Prevents the calendar from being seen during view transitions
    }
    
    
    //MARK: - Configure Calendar Header
    
    private func configureCalendarHeader () {
        
        calendarContainer.addSubview(calendarHeaderLabel)
        calendarHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            calendarHeaderLabel.leadingAnchor.constraint(equalTo: calendarContainer.leadingAnchor, constant: 18),
            calendarHeaderLabel.trailingAnchor.constraint(equalTo: calendarContainer.trailingAnchor, constant: 0),
            calendarHeaderLabel.topAnchor.constraint(equalTo: calendarContainer.topAnchor, constant: 0),
            calendarHeaderLabel.heightAnchor.constraint(equalToConstant: 30)
            
        ].forEach({ $0.isActive = true })
        
        calendarHeaderLabel.font = UIFont(name: "Poppins-SemiBold", size: 18)
        calendarHeaderLabel.textColor = .black
        calendarHeaderLabel.textAlignment = .left
    }
    
    
    //MARK: - Configure Calendar View
    
    private func configureCalendarView () {
        
        calendarContainer.addSubview(calendarView)
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            calendarView.topAnchor.constraint(equalTo: calendarHeaderLabel.bottomAnchor, constant: 5),
            calendarView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0),
            calendarView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - UIScreen.main.bounds.width.truncatingRemainder(dividingBy: 7)),
            calendarView.heightAnchor.constraint(equalToConstant: 55)
        
        ].forEach({ $0.isActive = true })
        
        calendarView.calendarDataSource = self
        calendarView.calendarDelegate = self
        
        calendarView.scrollingMode = .stopAtEachSection
        calendarView.scrollDirection = .horizontal
        calendarView.showsVerticalScrollIndicator = false
        calendarView.showsHorizontalScrollIndicator = false
        
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        
        calendarView.allowsMultipleSelection = false
        calendarView.isRangeSelectionUsed = false
        
        calendarView.backgroundColor = .white
        
        calendarView.register(UINib(nibName: "DateCell", bundle: nil), forCellWithReuseIdentifier: "dateCell")
        
        //Removes white lines for the cells that appear
        calendarView.cellSize = (UIScreen.main.bounds.width - UIScreen.main.bounds.width.truncatingRemainder(dividingBy: 7)) / 7
        
        formatter.dateFormat = "MMMM"
        
        if let startTime = collabStartTime, Date() < startTime {

            calendarHeaderLabel.text = formatter.string(from: startTime)
            
            calendarView.scrollToDate(startTime, animateScroll: false)
            calendarView.selectDates([startTime])
        }

        else if let deadline = collabDeadline, Date() > deadline {

            calendarHeaderLabel.text = formatter.string(from: deadline)

            calendarView.scrollToDate(deadline, animateScroll: false)
            calendarView.selectDates([deadline])
        }

        else {

            calendarHeaderLabel.text = formatter.string(from: Date())
            
            calendarView.scrollToDate(Date(), animateScroll: false)
            calendarView.selectDates([Date()])
        }
    }
    
    
    //MARK: - Configure Progress View
    
    private func configureCollabProgressView () {
        
        self.addSubview(collabProgressView)
        collabProgressView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            collabProgressView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            collabProgressView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            
        ].forEach({ $0.isActive = true })
        
        progressViewTopAnchorWithStackView = collabProgressView.topAnchor.constraint(equalTo: buttonStackView.bottomAnchor, constant:  10)
        progressViewTopAnchorWithStackView?.isActive = true
        
        progressViewHeightConstraint = collabProgressView.heightAnchor.constraint(equalToConstant: 0)
        progressViewHeightConstraint?.isActive = true
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:)))
        collabProgressView.addGestureRecognizer(panGesture)
    }
    
    
    //MARK: - Configure Progress Animation View
    
    private func configureProgressAnimationView () {
        
        let tabBar = CustomTabBar.sharedInstance
        
        //The height of the buttonStackView factoring in the top and bottom anchors (67.5) + the topAnchor of the tableView
        animationViewExpandedHeight = ((27.5 + 40) + ((keyWindow?.safeAreaInsets.bottom ?? 0) > 0 ? 92 : 72)).distance(to: tabBar.frame.minY)
        
        if let viewController = collabViewController as? CollabViewController {
            
            //Min-Y of the collabNavigationView + the height of the buttonStackView factoring in the top and bottom anchors (67.5)
            animationViewShrunkenHeight = ((viewController.collabHeaderView.configureViewHeight() - 80) + (27.5 + 40)).distance(to: tabBar.frame.minY)
        }
        
        //iPhone SE
        if UIScreen.main.bounds.width == 320 && UIScreen.main.bounds.height == 568 {
            
            progressAnimationView.shrunkenHeight = animationViewShrunkenHeight * 0.9
            progressAnimationView.expandedHeight = animationViewExpandedHeight
        }
        
        else {
            
            progressAnimationView.shrunkenHeight = animationViewShrunkenHeight * 0.75
            progressAnimationView.expandedHeight = animationViewExpandedHeight
        }
        
        self.addSubview(progressAnimationView)
        progressAnimationView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            progressAnimationView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            progressAnimationView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
        
        ].forEach({ $0.isActive = true })
        
        //Height of the progressView when only the searchBar is showing plus 10
        progressAnimationViewTopAnchor = progressAnimationView.topAnchor.constraint(equalTo: collabProgressView.bottomAnchor, constant: -77)
        progressAnimationViewTopAnchor?.isActive = true
        
        progressAnimationViewHeightConstraint = progressAnimationView.heightAnchor.constraint(equalToConstant: animationViewShrunkenHeight)
        progressAnimationViewHeightConstraint?.isActive = true
        
        progressAnimationView.clipsToBounds = true
        progressAnimationView.isUserInteractionEnabled = false
    }
    
    
    //MARK: - Pan Gesture Functions
    
    @objc private func handlePan (sender: UIPanGestureRecognizer) {
        
        switch sender.state {
        
        case .began, .changed:
            
            //Ensures that the tableView hasn't been scrolled before allowing the panGesture
            if collabTableView.contentOffset.y == 0 {
                
                moveWithPan(sender)
            }
          
        case .ended:
            
            if (progressViewHeightConstraint?.constant ?? 0) < progressViewHeight / 2 {
                
                shrinkView()
            }
            
            else {
                
                returnToOrigin()
            }
            
        default:
            
            break
        }
    }
    
    private func moveWithPan (_ sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: self)
        
        if translation.y > 0 {
            
            //The progressView's maximum height hasn't been reached
            if (progressViewHeightConstraint?.constant ?? 87) + translation.y < progressViewHeight {
                
                progressViewHeightConstraint?.constant += translation.y
                
                //If the collabNavigationView is expanded, i.e. the topAnchor of the tableView can be adjusted as neccasary
                if let viewController = collabViewController as? CollabViewController, viewController.navigationItem.hidesBackButton {
                    
                    tableViewTopAnchorWithStackView?.constant += translation.y
                }
                
                else {
                    
                    //If the topAnchor of the tableView + the translation will be less than the maximum allowable topAnchor of the tableView
                    if (tableViewTopAnchorWithStackView?.constant ?? 0) + translation.y < maximumTableViewTopAnchorWithStackView {
                        
                        tableViewTopAnchorWithStackView?.constant += translation.y
                    }
                    
                    else {
                        
                        tableViewTopAnchorWithStackView?.constant = maximumTableViewTopAnchorWithStackView
                    }
                }
            }
            
            //The progressView's maximum height has been reached
            else {
                
                progressViewHeightConstraint?.constant = progressViewHeight
                
                //If the collabNavigationView is expanded, i.e. the topAnchor of the tableView can be adjusted as neccasary
                if let viewController = collabViewController as? CollabViewController, viewController.navigationItem.hidesBackButton {
                    
                    //Setting the top anchor based on if the iPhone has a notch -- an iPhone with a notch will cause the progressView to have a larger topAnchor
                    //Therefore the top anchor of the tableView will also have to be larger by 20 points to compensate
                    tableViewTopAnchorWithStackView?.constant = progressViewHeight + (keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 20 : 0)
                }
                
                else {
                    
                    tableViewTopAnchorWithStackView?.constant = maximumTableViewTopAnchorWithStackView
                }
            }
        }
        
        else {
            
            //If the height of the progressView after being subtracted by the tranlation will be greater than 0
            if (progressViewHeightConstraint?.constant ?? 87) + translation.y > 0 {
                
                progressViewHeightConstraint?.constant += translation.y
                
                tableViewTopAnchorWithStackView?.constant += translation.y
            }
            
            else {
                
                progressViewHeightConstraint?.constant = 0
                
                //If the collabNavigationView is expanded
                if let viewController = collabViewController as? CollabViewController, viewController.navigationItem.hidesBackButton {
                    
                    //Will be animated to it's proper value when "returnToOrigin" is called
                    tableViewTopAnchorWithStackView?.constant = keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 30 : 0
                }
                
                else {
                    
                    //Will be animated to it's proper value when "returnToOrigin" is called
                    tableViewTopAnchorWithStackView?.constant = 0
                }
            }
        }
        
        sender.setTranslation(CGPoint.zero, in: self)
    }
    
    private func shrinkView () {
        
        progressViewHeightConstraint?.constant = 67 //Will only allow the searchBar to be shown
        
        //If the collabNavigationView is expanded
        if let viewController = collabViewController as? CollabViewController, viewController.navigationItem.hidesBackButton {
            
            //Setting the top anchor based on if the iPhone has a notch -- an iPhone with a notch will cause the progressView to have a larger topAnchor
            //Therefore the top anchor of the tableView will also have to be larger by 20 points to compensate
            tableViewTopAnchorWithStackView?.constant = keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 92 : 72
        }
        
        else {
            
            tableViewTopAnchorWithStackView?.constant = 72
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            
            self.handleProgressAnimation()
            
            self.layoutIfNeeded()
        }
    }
    
    private func returnToOrigin () {
        
        progressViewHeightConstraint?.constant = progressViewHeight //Maximum height of the progressView
        
        //If the collabNavigationView is expanded
        if let viewController = collabViewController as? CollabViewController, viewController.navigationItem.hidesBackButton {
            
            //Setting the top anchor based on if the iPhone has a notch -- an iPhone with a notch will cause the progressView to have a larger topAnchor
            //Therefore the top anchor of the tableView will also have to be larger by 20 points to compensate
            tableViewTopAnchorWithStackView?.constant = progressViewHeight + (keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 20 : 0)
        }
        
        else {
            
            tableViewTopAnchorWithStackView?.constant = maximumTableViewTopAnchorWithStackView
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            
            self.handleProgressAnimation()
            
            self.layoutIfNeeded()
        }
    }
    
    
    //MARK: - Present Progress Container
    
    func presentProgressView () {
        
        progressViewHeightConstraint?.constant = progressViewHeight
        
        tableViewTopAnchorWithStackView?.constant = maximumTableViewTopAnchorWithStackView
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            
            self.layoutIfNeeded()
        }
    }
    
    
    //MARK: - Dismiss Progress Container
    
    func dismissProgressView (animate: Bool = true) {
        
        progressViewHeightConstraint?.constant = 0
        
        tableViewTopAnchorWithStackView?.constant = 10

        UIView.animate(withDuration: animate ? 0.3 : 0, delay: 0, options: .curveEaseInOut) {

            self.layoutIfNeeded()
        }
    }
    
    
    //MARK: - Handle Progress Animation
    
    func handleProgressAnimation (selectedTab: String = "") {
        
        if let viewController = self.collabViewController as? CollabViewController {

            //If the "selectedTab" that was passed in is equal to Progress or the viewControllers "selectedTab" is equal to Progress and there are no blocks
            if (selectedTab == "Progress" || viewController.selectedTab == "Progress") && viewController.blocks?.count ?? 0 == 0 {

                self.progressAnimationView.animationView.alpha = 1

                //If the animation isn't already playing
                if !self.progressAnimationView.animationView.isAnimationPlaying {

                    self.progressAnimationView.animationView.play()
                }

                //If the view is expanded
                if viewController.navigationItem.hidesBackButton && (self.progressViewHeightConstraint?.constant ?? 0) <= 67 {

                    self.progressAnimationViewHeightConstraint?.constant = self.animationViewExpandedHeight
                    self.progressAnimationView.animationViewCenterYAnchor?.constant = -35 //Random value that was the most visually appealing
                    self.progressAnimationView.animationTitleLabel.alpha = 1
                }

                //If the view isn't expanded
                else {

                    self.progressAnimationViewHeightConstraint?.constant = self.animationViewShrunkenHeight
                    self.progressAnimationView.animationViewCenterYAnchor?.constant = 0
                    self.progressAnimationView.animationTitleLabel.alpha = 0
                }
            }

            //Dismissing the animation
            else {

                self.progressAnimationView.animationView.stop()

                self.progressAnimationView.animationView.alpha = 0
                self.progressAnimationView.animationTitleLabel.alpha = 0
            }
        }
    }
    

    //MARK: - Present Calendar
    
    func presentCalendar () {
        
        calendarContainer.constraints.forEach { (constraint) in
            
            if constraint.firstAttribute == .height {
                
                constraint.constant = 90
            }
        }
        
        self.tableViewTopAnchorWithStackView?.isActive = false
        
        self.tableViewTopAnchorWithCalendar?.constant = 10
        self.tableViewTopAnchorWithCalendar?.isActive = true
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            
            self.layoutIfNeeded()
            
            self.collabTableView.contentInset = UIEdgeInsets(top: -22, left: 0, bottom: keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 20 : 0, right: 0)
            self.collabTableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 30 : 0, right: 0)
            
            //Setting the contentOffset of the tableView back to what it was before the view was expanded
            if let contentOffset =  self.originalTableViewContentOffset {
                
                self.collabTableView.contentOffset.y = contentOffset
            }
        }
    }
    
    
    //MARK: - Dismiss Calendar
    
    func dismissCalendar () {
        
        calendarContainer.constraints.forEach { (constraint) in
            
            if constraint.firstAttribute == .height {
                
                constraint.constant = 0
            }
        }
        
        self.tableViewTopAnchorWithCalendar?.isActive = false
        self.tableViewTopAnchorWithStackView?.isActive = true
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            
            self.layoutIfNeeded()
            
            self.collabTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 20 : 0, right: 0)
            self.collabTableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 30 : 0, right: 0)
            
            //Setting the contentOffset of the tableView back to what it was before the view was shrunk
            if let contentOffset =  self.originalTableViewContentOffset {
                
                self.collabTableView.contentOffset.y = contentOffset
            }
            
        } completion: { (finished: Bool) in
            
            //Setting this to nil will allow the panGesture to reset the originalContentOffset next time the view is panned
            self.originalTableViewContentOffset = nil
        }
    }
    
    
    //MARK: - Progress Button Action
    
    @objc private func progressButtonTouchUpInside () {
        
        if let viewController = collabViewController as? CollabViewController {
            
            viewController.progressButtonTouchUpInside()
            
            UIView.transition(with: buttonStackView, duration: 0.15, options: .transitionCrossDissolve, animations: {
                
                self.progressButton.setTitleColor(.black, for: .normal)
                self.blocksButton.setTitleColor(.lightGray, for: .normal)
                self.messagesButton.setTitleColor(.lightGray, for: .normal)
            })
        }
    }
    
    
    //MARK: - Blocks Button Action
    
    @objc private func blocksButtonTouchUpInside () {
        
        if let viewController = collabViewController as? CollabViewController {
            
            viewController.blocksButtonTouchUpInside()
            
            UIView.transition(with: buttonStackView, duration: 0.15, options: .transitionCrossDissolve, animations: {
                
                self.progressButton.setTitleColor(.lightGray, for: .normal)
                self.blocksButton.setTitleColor(.black, for: .normal)
                self.messagesButton.setTitleColor(.lightGray, for: .normal)
            })
        }
    }
    
    
    //MARK: - Messages Button Action
    
    @objc private func messagesButtonTouchUpInside () {
        
        if let viewController = collabViewController as? CollabViewController {
            
            viewController.messagesButtonTouchUpInside()
            
            UIView.transition(with: buttonStackView, duration: 0.15, options: .transitionCrossDissolve, animations: {
                
                self.progressButton.setTitleColor(.lightGray, for: .normal)
                self.blocksButton.setTitleColor(.lightGray, for: .normal)
                self.messagesButton.setTitleColor(.black, for: .normal)
            })
        }
    }
}

//MARK: - JTAppleCalendar Extension
extension CollabNavigationView: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
    
        formatter.dateFormat = "yyyy MM dd"
        
        let startTimeDayOfWeek = Calendar.current.dateComponents([.weekday], from: collabStartTime ?? Date()).weekday
        
        return ConfigurationParameters(startDate: collabStartTime ?? Date(), endDate: collabDeadline ?? formatter.date(from: "2050 01 01")!, numberOfRows: 1, calendar: Calendar(identifier: .gregorian), generateInDates: .forFirstMonthOnly, generateOutDates: .off, firstDayOfWeek: DaysOfWeek(rawValue: startTimeDayOfWeek ?? 1) ?? .sunday, hasStrictBoundaries: false)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "dateCell", for: indexPath) as! DateCell
        self.calendar(calendar, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        
        configureCell(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, shouldSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool {
        
        //If the selected date is between the startTime and the deadline
        if let startTime = collabStartTime, let deadline = collabDeadline, date.isBetween(startDate: startTime, endDate: deadline) {

            return true
        }

        else {

            if let startTime = collabStartTime {
                
                formatter.dateFormat = "yyyy MM dd"
                
                //If the selected date is greater than or equal to the startTime
                if formatter.date(from: formatter.string(from: date)) ?? Date() >= formatter.date(from: formatter.string(from: startTime)) ?? Date() {
                    
                    if let deadline = collabDeadline {
                        
                        //If the selected date is less than or equal to the deadline
                        if formatter.date(from: formatter.string(from: date)) ?? Date() <= formatter.date(from: formatter.string(from: deadline)) ?? Date() {
                            
                            return true
                        }
                        
                        //If the selected date is greater than the deadline
                        else {
                            
                            let vibrateMethods = VibrateMethods()
                            vibrateMethods.warningVibration()
                            
                            calendar.selectDates([deadline])
                            
                            return false
                        }
                    }
                    
                    //If there is no deadline and the selected date is greater than the start time
                    else {
                        
                        return true
                    }
                }
                
                //If the selected date is less than the start time
                else {
                    
                    let vibrateMethods = VibrateMethods()
                    vibrateMethods.warningVibration()
                    
                    calendar.selectDates([startTime])
                    
                    return false
                }
            }
            
            //If for some reason the start time is nil
            else {
                
                let vibrateMethods = VibrateMethods()
                vibrateMethods.warningVibration()
                
                return false
            }
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        
        configureCell(view: cell, cellState: cellState)
        
        if cellState.selectionType != .programatic {
            
            if let startTime = collabStartTime, let row = Calendar.current.dateComponents([.day], from: startTime, to: date).day {
                
                if let viewController = collabViewController as? CollabViewController {
                    
                    viewController.scrollToFirstBlock(indexPathToScrollTo: IndexPath(row: row, section: 0))
                }
            }
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        
        configureCell(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        
        //Sets the headerLabel text
        let segmentInfo = visibleDates.monthDates.first
    
        if let visibleDate = segmentInfo?.date {
            
            formatter.dateFormat = "MMMM"
            calendarHeaderLabel.text = formatter.string(from: visibleDate)
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        
        //If the user scrolled to a date before the start time
        if let startTime = collabStartTime, visibleDates.monthDates.first?.date ?? Date() < startTime {
            
            calendar.scrollToDate(startTime)
        }
        
        //If the user scrolled to a date after the deadline
        else if let deadline = collabDeadline, visibleDates.monthDates.first?.date ?? Date() > deadline {
            
            calendar.scrollToDate(deadline)
        }
    }
    
    
    //MARK: - Configure Calendar Cell
    
    func configureCell(view: JTAppleCell?, cellState: CellState) {
        
        guard let cell = view as? DateCell else { return }
        
            cell.dateLabel.text = cellState.text
            cell.rangeSelectionView.isHidden = true
        
            handleCellSelected(cell: cell, cellState: cellState)
    }
    
    
    //MARK: - Handle Cell Selected
    
    func handleCellSelected (cell: DateCell, cellState: CellState) {
        
        cell.singleSelectionView.isHidden = cellState.isSelected ? false : true
        
        cell.dateLabel.textColor = cellState.isSelected ? .white : UIColor(hexString: "222222")
        cell.dateLabel.font = UIFont(name: "Poppins-SemiBold", size: 19)
        
        cell.singleSelectionView.layer.cornerRadius = 0.5 * cell.singleSelectionView.frame.width
    }
}
