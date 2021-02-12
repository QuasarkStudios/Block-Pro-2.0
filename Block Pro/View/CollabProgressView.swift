//
//  CollabProgressView.swift
//  Block Pro
//
//  Created by Nimat Azeez on 2/4/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit

class CollabProgressView: UIView {
    
    var collabProgressCircle: ProgressCircles?
    var completedProgressCircle: ProgressCircles?
    var inProgressProgressCircle: ProgressCircles?
    var lateProgressCircle: ProgressCircles?
    
    let progressStackView = UIStackView()
    
    let selectedProgressLabel = UILabel()
    
    var searchBar: SearchBar?
    
    let calendar = Calendar.current
    
    var collab: Collab? {
        didSet {
            
            setCollabContainerLabelText()
            
            animateCollabProgress()
            
            if selectedStatus == nil {
                
                setCollabSelectedProgressLabelText()
            }
        }
    }
    
    var blocks: [Block]? {
        didSet {
            
            animateCompletedProgress()
            animateInProgressProgress()
            animateLateProgress()
            
            if selectedStatus == .completed {
                
                setCompletedSelectedProgressLabelText()
            }
            
            else if selectedStatus == .inProgress {
                
                setInProgressSelectedProgressLabelText()
            }
            
            else if selectedStatus == .late {
                
                setLateSelectedProgressLabelText()
            }
            
            collabProgressDelegate?.filterBlocks(status: selectedStatus)
            
            searchBar?.alpha = blocks?.count ?? 0 > 0 ? 1 : 0
        }
    }
    
    var currentCollabProgressStrokeEnd: Double = 0.0025
    var currentCompletedProgressStrokeEnd: Double = 0.0025
    var currentInProgressProgressStrokeEnd: Double = 0.0025
    var currentLateProgressStrokeEnd: Double = 0.0025
    
    var selectedStatus: BlockStatus?
    var selectedProgressLabelFormatIsPercentage: Bool = true
    
    weak var collabProgressDelegate: CollabProgressProtocol?
    
    init (_ collabViewController: AnyObject?) {
        super.init(frame: .zero)

        self.clipsToBounds = true
        
        if let viewController = collabViewController as? CollabProgressProtocol {
            
            collabProgressDelegate = viewController
        }
        
        configureCollabProgressCircle()
        configureCompletedProgressCircle()
        configureInProgressProgressCircle()
        configureLateProgressCircle()
        
        configureProgressStackView()
        configureProgressContainers()
        
        configureSelectedProgressLabel()
        
        configureSearchBar()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Progress Circle Configuration
    
    private func configureCollabProgressCircle () {
        
        collabProgressCircle = ProgressCircles(radius: (UIScreen.main.bounds.width * 0.5) / 2, lineWidth: 10, strokeColor: UIColor(hexString: "222222")!.cgColor, strokeEnd: 0)
        configureProgressCircleConstraints(collabProgressCircle)
    }
    
    private func configureCompletedProgressCircle () {

        completedProgressCircle = ProgressCircles(radius: ((UIScreen.main.bounds.width * 0.5) / 2) * 0.8, lineWidth: 10, strokeColor: UIColor(hexString: "2ECC70", withAlpha: 0.80)!.cgColor, strokeEnd: 0)
        configureProgressCircleConstraints(completedProgressCircle)
    }
    
    private func configureInProgressProgressCircle () {
        
        inProgressProgressCircle = ProgressCircles(radius: ((UIScreen.main.bounds.width * 0.5) / 2) * 0.6, lineWidth: 10, strokeColor: UIColor(hexString: "5065A0", withAlpha: 0.75)!.cgColor, strokeEnd: 0)
        configureProgressCircleConstraints(inProgressProgressCircle)
    }
    
    private func configureLateProgressCircle () {
        
        lateProgressCircle = ProgressCircles(radius: ((UIScreen.main.bounds.width * 0.5) / 2) * 0.4, lineWidth: 10, strokeColor: UIColor(hexString: "E84D3C", withAlpha: 0.75)!.cgColor, strokeEnd: 0)
        configureProgressCircleConstraints(lateProgressCircle)
    }
    
    
    //MARK: - Progress Circle Constraints Configration
    
    private func configureProgressCircleConstraints (_ progressCircle: UIView?) {
        
        self.addSubview(progressCircle!)
        progressCircle?.translatesAutoresizingMaskIntoConstraints = false
        
        [
            
            //centerXAnchor is 20 points away left side of the contentView after factoring in the radius of the progressCircle
            progressCircle?.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: -(abs(20 - (UIScreen.main.bounds.width * 0.5) / 2))),
            progressCircle?.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -142),
            progressCircle?.widthAnchor.constraint(equalToConstant: (UIScreen.main.bounds.width * 0.5)),
            progressCircle?.heightAnchor.constraint(equalToConstant: (UIScreen.main.bounds.width * 0.5) + 12)
        
        ].forEach{( $0?.isActive = true )}
    }
    
    
    //MARK: - Configure Progress Stack View
    
    private func configureProgressStackView () {
        
        self.addSubview(progressStackView)
        progressStackView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            progressStackView.leadingAnchor.constraint(equalTo: collabProgressCircle!.trailingAnchor, constant: 22.5),
            progressStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            progressStackView.centerYAnchor.constraint(equalTo: collabProgressCircle!.centerYAnchor, constant: 0),
            progressStackView.heightAnchor.constraint(equalToConstant: 130)
        
        ].forEach({ $0.isActive = true })
        
        progressStackView.alignment = .center
        progressStackView.distribution = .fillEqually
        progressStackView.axis = .vertical
        progressStackView.spacing = 18
    }
    
    
    //MARK: - Progress Container Configuration
    
    private func configureProgressContainers () {
        
        var count = 0
        
        while count < 4 {
            
            let container = UIView()
            
            progressStackView.addArrangedSubview(container)
            container.translatesAutoresizingMaskIntoConstraints = false
            
            [
            
                container.leadingAnchor.constraint(equalTo: container.superview!.leadingAnchor, constant: 0),
                container.trailingAnchor.constraint(equalTo: container.superview!.trailingAnchor, constant: 0),
                container.heightAnchor.constraint(equalToConstant: 19)
            
            ].forEach({ $0.isActive = true })
            
            container.tag = Int(count)
            container.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(progressContainerTapped(sender:))))
            
            configureContainerStatusIndicator(container, count)
            configureContainerProgressLabel(container, count)
            
            count += 1
        }
    }
    
    
    //MARK: - Container Status Indicator Configuration
    
    private func configureContainerStatusIndicator(_ container: UIView, _ count: Int) {
        
        let statusIndicatorBubbleContainer = UIView()
        let statusIndicatorBubble = UIView()
        
        container.addSubview(statusIndicatorBubbleContainer)
        statusIndicatorBubbleContainer.translatesAutoresizingMaskIntoConstraints = false
        
        statusIndicatorBubbleContainer.addSubview(statusIndicatorBubble)
        statusIndicatorBubble.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            statusIndicatorBubbleContainer.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 0),
            statusIndicatorBubbleContainer.topAnchor.constraint(equalTo: container.topAnchor, constant: 0),
            statusIndicatorBubbleContainer.widthAnchor.constraint(equalToConstant: 19),
            statusIndicatorBubbleContainer.heightAnchor.constraint(equalToConstant: 19),
            
            statusIndicatorBubble.centerXAnchor.constraint(equalTo: statusIndicatorBubbleContainer.centerXAnchor),
            statusIndicatorBubble.centerYAnchor.constraint(equalTo: statusIndicatorBubbleContainer.centerYAnchor),
            statusIndicatorBubble.widthAnchor.constraint(equalToConstant: 11),
            statusIndicatorBubble.heightAnchor.constraint(equalToConstant: 11),
            
        ].forEach({ $0.isActive = true })
        
        statusIndicatorBubbleContainer.layer.borderWidth = 2
        statusIndicatorBubbleContainer.layer.cornerRadius = 9.5
        statusIndicatorBubbleContainer.layer.cornerCurve = .continuous
        statusIndicatorBubbleContainer.clipsToBounds = true
        
        statusIndicatorBubble.layer.cornerRadius = 11 * 0.5
        statusIndicatorBubble.layer.cornerCurve = .continuous
        statusIndicatorBubble.clipsToBounds = true
        
        if count == 0 {
            
            statusIndicatorBubbleContainer.layer.borderColor = UIColor(hexString: "222222")?.cgColor
            statusIndicatorBubble.backgroundColor = UIColor(hexString: "222222")
        }
        
        else if count == 1 {
            
            statusIndicatorBubbleContainer.layer.borderColor = UIColor(hexString: "2ECC70", withAlpha: 0.8)?.cgColor
            statusIndicatorBubble.backgroundColor = UIColor(hexString: "2ECC70")
        }
        
        else if count == 2 {
            
            statusIndicatorBubbleContainer.layer.borderColor = UIColor(hexString: "5065A0", withAlpha: 0.75)?.cgColor
            statusIndicatorBubble.backgroundColor = UIColor(hexString: "5065A0", withAlpha: 0.75)
        }
        
        else if count == 3 {
            
            statusIndicatorBubbleContainer.layer.borderColor = UIColor(hexString: "E84D3C", withAlpha: 0.75)?.cgColor
            statusIndicatorBubble.backgroundColor = UIColor(hexString: "E84D3C", withAlpha: 0.75)
        }
    }
    
    
    //MARK: - Container Progress Label Configuration
    
    private func configureContainerProgressLabel (_ container: UIView, _ count: Int) {
        
        let progressLabel = UILabel()
        
        container.addSubview(progressLabel)
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
            
            progressLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 29),
            progressLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -5),
            progressLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 0),
            progressLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: 0)
            
        ].forEach{( $0.isActive = true )}
        
        progressLabel.font = UIFont(name: "Poppins-SemiBold", size: 13)
        progressLabel.textAlignment = .left
        
        if count == 0 {
            
            progressLabel.text = collab?.name ?? "Collab"
            progressLabel.textColor = .black
        }
        
        else if count == 1 {
            
            progressLabel.text = "Completed"
            progressLabel.textColor = .placeholderText
            progressLabel.adjustsFontSizeToFitWidth = true
        }
        
        else if count == 2 {
            
            progressLabel.text = "In Progress"
            progressLabel.textColor = .placeholderText
            progressLabel.adjustsFontSizeToFitWidth = true
        }
        
        else if count == 3 {
            
            progressLabel.text = "Late"
            progressLabel.textColor = .placeholderText
            progressLabel.adjustsFontSizeToFitWidth = true
        }
    }
    
    
    //MARK: - Selected Progress Label Configuration
    
    private func configureSelectedProgressLabel () {
        
        self.addSubview(selectedProgressLabel)
        selectedProgressLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            selectedProgressLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -87),
            selectedProgressLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            selectedProgressLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            selectedProgressLabel.heightAnchor.constraint(equalToConstant: 25)
        
        ].forEach({ $0.isActive = true })
        
        selectedProgressLabel.isUserInteractionEnabled = true
        
        selectedProgressLabel.font = UIFont(name: "Poppins-SemiBold", size: 18)
        selectedProgressLabel.textAlignment = .center
        selectedProgressLabel.adjustsFontSizeToFitWidth = true
        
        selectedProgressLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectedProgressLabelTapped)))
    }
    
    
    //MARK: - Search Bar Configuration
    
    private func configureSearchBar () {
        
        if let viewController = collabProgressDelegate as? CollabViewController {
            
            searchBar = SearchBar(parentViewController: viewController, placeholderText: "Search by name or status")
            
            self.addSubview(searchBar!)
            searchBar?.translatesAutoresizingMaskIntoConstraints = false
            
            [
            
                searchBar!.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 25),
                searchBar!.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -25),
                searchBar!.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -25),
                searchBar!.heightAnchor.constraint(equalToConstant: 37)
            
            ].forEach({ $0.isActive = true })
        }
    }
    
    //MARK: - Set Collab Container Text
    //Used to set the text for the collab container in the progressStackView
    private func setCollabContainerLabelText () {
        
        for progressContainer in progressStackView.arrangedSubviews {
            
            if progressContainer.tag == 0 {
                
                for subview in progressContainer.subviews {
                    
                    if let label = subview as? UILabel {
                        
                        label.text = collab?.name ?? "Collab"
                        
                        break
                    }
                }
                
                break
            }
        }
    }
    

    //MARK: Collab Progress Circle Animation
    
    private func animateCollabProgress () {
        
        if let startTime = collab?.dates["startTime"], let deadline = collab?.dates["deadline"], let collabDuration = calendar.dateComponents([.second], from: startTime, to: deadline).second {
            
            let timeRemaining = calendar.dateComponents([.second], from: Date(), to: deadline).second
            
            let progressStrokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
            progressStrokeAnimation.fromValue = currentCollabProgressStrokeEnd
            progressStrokeAnimation.fillMode = CAMediaTimingFillMode.forwards
            progressStrokeAnimation.isRemovedOnCompletion = false
            
            //If the strokeEnd will be larger than 0.0025
            if Double(collabDuration - timeRemaining!) / Double(collabDuration) >= 0.0025 {
                
                //Ensures that the stroke can only animate to the value of 1
                if Double(collabDuration - timeRemaining!) / Double(collabDuration) >= 1 {
                    
                    progressStrokeAnimation.toValue = 1
                }
                
                else {
                    
                    progressStrokeAnimation.toValue = Double(collabDuration - timeRemaining!) / Double(collabDuration)
                }
                
                progressStrokeAnimation.duration = 1
            }
            
            //If the stroke would normally animate to a stroke less than 0.0025; likely 0
            else {
                
                progressStrokeAnimation.toValue = 0.0025
                progressStrokeAnimation.duration = currentCollabProgressStrokeEnd == 0.0025 ? 0 : 1
            }
            
            if let progressCircle = collabProgressCircle {
                
                progressCircle.shapeLayer.add(progressStrokeAnimation, forKey: nil)
            }
            
            currentCollabProgressStrokeEnd = Double(collabDuration - timeRemaining!) / Double(collabDuration) <= 1 ? Double(collabDuration - timeRemaining!) / Double(collabDuration) : 1
        }
    }
    
    
    //MARK: Completed Progress Circle Animation
    
    private func animateCompletedProgress () {
        
        let blockCount: Int = blocks?.count ?? 0
        var completedBlockCount: Int = 0
        
        for block in blocks ?? [] {
            
            if block.status == .completed {
                
                completedBlockCount += 1
            }
        }
        
        let progressStrokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
        progressStrokeAnimation.fromValue = currentCompletedProgressStrokeEnd
        progressStrokeAnimation.fillMode = CAMediaTimingFillMode.forwards
        progressStrokeAnimation.isRemovedOnCompletion = false
        
        //If the strokeEnd will be larger than 0
        if Double(completedBlockCount) / Double(blockCount) > 0 {
            
            progressStrokeAnimation.toValue = Double(completedBlockCount) / Double(blockCount)
            progressStrokeAnimation.duration = 1
        }
        
        //If the stroke would normally animate to a stroke less than 0
        else {
            
            progressStrokeAnimation.toValue = 0.0025
            progressStrokeAnimation.duration = currentCompletedProgressStrokeEnd == 0.0025 ? 0 : 1
        }
        
        if let progressCircle = completedProgressCircle {
            
            progressCircle.shapeLayer.add(progressStrokeAnimation, forKey: nil)
        }
        
        currentCompletedProgressStrokeEnd = Double(completedBlockCount) / Double(blockCount) > 0 ? Double(completedBlockCount) / Double(blockCount) : 0.0025
    }
    
    
    //MARK: In Progress Progress Circle Animation
    
    private func animateInProgressProgress () {
        
        let blockCount: Int = blocks?.count ?? 0
        var inProgressBlockCount: Int = 0
        
        for block in blocks ?? [] {
            
            if let status = block.status {
                
                if status == .inProgress {
                    
                    inProgressBlockCount += 1
                }
            }
            
            else if let starts = block.starts, let ends = block.ends {
                
                if Date().isBetween(startDate: starts, endDate: ends) {
                    
                    inProgressBlockCount += 1
                }
            }
        }
        
        let progressStrokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
        progressStrokeAnimation.fromValue = currentInProgressProgressStrokeEnd
        
        //If the strokeEnd will be larger than 0
        if Double(inProgressBlockCount) / Double(blockCount) > 0 {
            
            progressStrokeAnimation.toValue = Double(inProgressBlockCount) / Double(blockCount)
            progressStrokeAnimation.duration = 1
        }
        
        //If the stroke would normally animate to a stroke less than 0
        else {
            
            progressStrokeAnimation.toValue = 0.0025
            progressStrokeAnimation.duration = currentInProgressProgressStrokeEnd == 0.0025 ? 0 : 1
        }
        
        progressStrokeAnimation.fillMode = CAMediaTimingFillMode.forwards
        progressStrokeAnimation.isRemovedOnCompletion = false
        
        if let progressCircle = inProgressProgressCircle {
            
            progressCircle.shapeLayer.add(progressStrokeAnimation, forKey: nil)
        }
        
        currentInProgressProgressStrokeEnd = Double(inProgressBlockCount) / Double(blockCount) > 0 ? Double(inProgressBlockCount) / Double(blockCount) : 0.0025
    }
    
    
    //MARK: Late Progress Circle Animation
    
    private func animateLateProgress () {
        
        let blockCount: Int = blocks?.count ?? 0
        var lateProgressBlockCount: Int = 0
        
        for block in blocks ?? [] {
            
            if let status = block.status {
                
                if status == .late {
                    
                    lateProgressBlockCount += 1
                }
            }
            
            else if let ends = block.ends {
                
                if Date() > ends {
                    
                    lateProgressBlockCount += 1
                }
            }
        }
        
        let progressStrokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
        progressStrokeAnimation.fromValue = currentLateProgressStrokeEnd
        progressStrokeAnimation.fillMode = CAMediaTimingFillMode.forwards
        progressStrokeAnimation.isRemovedOnCompletion = false
        
        //If the strokeEnd will be larger than 0
        if Double(lateProgressBlockCount) / Double(blockCount) > 0 {
            
            progressStrokeAnimation.toValue = Double(lateProgressBlockCount) / Double(blockCount)
            progressStrokeAnimation.duration = 1
        }
        
        //If the stroke would normally animate to a stroke less than 0
        else {
            
            progressStrokeAnimation.toValue = 0.0025
            progressStrokeAnimation.duration = currentLateProgressStrokeEnd == 0.0025 ? 0 : 1
        }
        
        if let progressCircle = lateProgressCircle {
            
            progressCircle.shapeLayer.add(progressStrokeAnimation, forKey: nil)
        }
        
        currentLateProgressStrokeEnd = Double(lateProgressBlockCount) / Double(blockCount) > 0 ? Double(lateProgressBlockCount) / Double(blockCount) : 0.0025
    }
    
    
    //MARK: Set Collab Selected Progress Label Text
    
    func setCollabSelectedProgressLabelText () {
        
        //Check to see if the collabContainer is currently selected before attempting to change the selectedProgressLabel text
        if let progressContainer = progressStackView.arrangedSubviews.first {
            
            for subview in progressContainer.subviews {
                
                if let label = subview as? UILabel, label.textColor != .black {
                    
                    return
                }
            }
        }
        
        if let deadline = collab?.dates["deadline"] {
            
            if let years = calendar.dateComponents([.year], from: Date(), to: deadline).year, years != 0 {
                
                selectedProgressLabel.text = years > 0 ? "Over a year left" : "Over a year ago"
            }
            
            else if let months = calendar.dateComponents([.month], from: Date(), to: deadline).month, months != 0 {
                
                if months > 0 {
                    
                    selectedProgressLabel.text = months == 1 ? "1 month left" : "\(months) months left"
                }
                
                else {
                    
                    selectedProgressLabel.text = months == -1 ? "1 month ago" : "\(abs(months)) months ago"
                }
            }
            
            else if let days = calendar.dateComponents([.day], from: Date(), to: deadline).day, days != 0 {
                
                if days > 0 {
                    
                    selectedProgressLabel.text = days == 1 ? "1 day left" : "\(days) days left"
                }
                
                else {
                    
                    selectedProgressLabel.text = days == -1 ? "1 day ago" : "\(abs(days)) days ago"
                }
            }
            
            else if let hours = calendar.dateComponents([.hour], from: Date(), to: deadline).hour, hours != 0 {
                
                if hours > 0 {
                    
                    selectedProgressLabel.text = hours == 1 ? "1 hour left" : "\(hours) hours left"
                }
                
                else {
                    
                    selectedProgressLabel.text = hours == -1 ? "1 hour ago" : "\(abs(hours)) hours ago"
                }
            }
            
            else if let minutes = calendar.dateComponents([.minute], from: Date(), to: deadline).minute, minutes != 0 {
                
                if minutes > 0 {
                    
                    selectedProgressLabel.text = minutes == 1 ? "1 minute left" : "\(minutes) minutes left"
                }
                
                else {
                    
                    selectedProgressLabel.text = minutes == -1 ? "1 minute ago" : "\(abs(minutes)) minutes ago"
                }
            }
            
            else {
                
                selectedProgressLabel.text = "Now"
            }
        }
    }
    
    
    //MARK: Set Compeleted Selected Progress Label Text
    
    private func setCompletedSelectedProgressLabelText () {
        
        let blockCount: Int = blocks?.count ?? 0
        var completedBlockCount: Int = 0
        
        for block in blocks ?? [] {
            
            if block.status == .completed {
                
                completedBlockCount += 1
            }
        }
        
        if selectedProgressLabelFormatIsPercentage {
            
            if blockCount > 0 {
                
                let completedPercentage = round((Double(completedBlockCount) / Double(blockCount)) * 100)
                
                selectedProgressLabel.text = "\(Int(completedPercentage))% of blocks completed"
            }
            
            else {
                
                selectedProgressLabel.text = "0% of blocks completed"
            }
        }
        
        else {
            
            selectedProgressLabel.text = "\(completedBlockCount)/\(blockCount) of blocks completed"
        }
    }
    
    
    //MARK: Set In Progress Selected Progress Label Text
    
    private func setInProgressSelectedProgressLabelText () {
        
        let blockCount: Int = blocks?.count ?? 0
        var inProgressBlockCount: Int = 0
        
        for block in blocks ?? [] {
            
            if let status = block.status {
                
                if status == .inProgress {
                    
                    inProgressBlockCount += 1
                }
            }
            
            else if let starts = block.starts, let ends = block.ends {
                
                if Date().isBetween(startDate: starts, endDate: ends) {
                    
                    inProgressBlockCount += 1
                }
            }
        }
        
        if selectedProgressLabelFormatIsPercentage {
            
            if blockCount > 0 {
                
                let completedPercentage = round((Double(inProgressBlockCount) / Double(blockCount)) * 100)
                
                selectedProgressLabel.text = "\(Int(completedPercentage))% of blocks in progress"
            }
            
            else {
                
                selectedProgressLabel.text = "0% of blocks in progress"
            }
        }
        
        else {
            
            selectedProgressLabel.text = "\(inProgressBlockCount)/\(blockCount) of blocks in progress"
        }
    }
    
    
    //MARK: Set Late Selected Progress Label Text
    
    private func setLateSelectedProgressLabelText () {
        
        let blockCount: Int = blocks?.count ?? 0
        var lateProgressBlockCount: Int = 0
        
        for block in blocks ?? [] {
            
            if let status = block.status {
                
                if status == .late {
                    
                    lateProgressBlockCount += 1
                }
            }
            
            else if let ends = block.ends {
                
                if Date() > ends {
                    
                    lateProgressBlockCount += 1
                }
            }
        }
        
        if selectedProgressLabelFormatIsPercentage {
            
            if blockCount > 0 {
                
                let completedPercentage = round((Double(lateProgressBlockCount) / Double(blockCount)) * 100)
                
                selectedProgressLabel.text = "\(Int(completedPercentage))% of blocks late"
            }
            
            else {
                
                selectedProgressLabel.text = "0% of blocks late"
            }
        }
        
        else {
            
            selectedProgressLabel.text = "\(lateProgressBlockCount)/\(blockCount) of blocks late"
        }
    }
    
    
    //MARK: - Progress Container Tapped
    
    @objc private func progressContainerTapped (sender: UITapGestureRecognizer) {
        
        let vibrateMethods = VibrateMethods()
        vibrateMethods.warningVibration()
        
        UIView.transition(with: self, duration: 0.2, options: .transitionCrossDissolve) {
            
            for subview in self.progressStackView.arrangedSubviews {
                
                //If this is the view that was selected
                if subview.tag == sender.view!.tag {
                    
                    for view in subview.subviews {
                        
                        if let label = view as? UILabel {
                            
                            label.textColor = .black
                        }
                    }
                }
                
                //If this view wasn't selected
                else {
                    
                    for view in subview.subviews {
                        
                        if let label = view as? UILabel {
                            
                            label.textColor = .placeholderText
                        }
                    }
                }
            }
            
            if sender.view!.tag == 0 {
                
                self.selectedStatus = nil
                
                self.setCollabSelectedProgressLabelText()
                
                self.collabProgressDelegate?.filterBlocks(status: nil)
            }
            
            else if sender.view!.tag == 1 {
                
                self.selectedStatus = .completed
                
                self.setCompletedSelectedProgressLabelText()
                
                self.collabProgressDelegate?.filterBlocks(status: .completed)
            }
            
            else if sender.view!.tag == 2 {
                
                self.selectedStatus = .inProgress
                
                self.setInProgressSelectedProgressLabelText()
                
                self.collabProgressDelegate?.filterBlocks(status: .inProgress)
            }
            
            else {
                
                self.selectedStatus = .late
                
                self.setLateSelectedProgressLabelText()
                
                self.collabProgressDelegate?.filterBlocks(status: .late)
            }
        }
    }
    
    
    //MARK: - Selected Progress Label Tapped
    
    @objc private func selectedProgressLabelTapped () {
        
        for arrangedSubview in progressStackView.arrangedSubviews {
            
            for subview in arrangedSubview.subviews {
                
                if let label = subview as? UILabel {
                    
                    //If this label is "selected"
                    if label.textColor == .black {
                        
                        if arrangedSubview.tag != 0 {
                            
                            let vibrateMethods = VibrateMethods()
                            vibrateMethods.warningVibration()
                            
                            selectedProgressLabelFormatIsPercentage = !selectedProgressLabelFormatIsPercentage
                            
                            UIView.transition(with: selectedProgressLabel, duration: 0.2, options: .transitionCrossDissolve) {
                                
                                if arrangedSubview.tag == 1 {
                                    
                                    self.setCompletedSelectedProgressLabelText()
                                }
                                
                                else if arrangedSubview.tag == 2 {
                                    
                                    self.setInProgressSelectedProgressLabelText()
                                }
                                
                                else if arrangedSubview.tag == 3 {
                                    
                                    self.setLateSelectedProgressLabelText()
                                }
                            }
                        }
                        
                        break
                    }
                }
            }
        }
    }
}
