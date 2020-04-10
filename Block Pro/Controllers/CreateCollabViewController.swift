//
//  CreateCollabViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/9/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class CreateCollabViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIAdaptivePresentationControllerDelegate {

    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var segmentContainer: UIView!
    @IBOutlet weak var segmentBackground: UIView!
    @IBOutlet weak var selectedSegmentIndicator: UIView!
    @IBOutlet weak var segmentIndicatorLeadingAnchor: NSLayoutConstraint!
    @IBOutlet weak var segmentIndicatorWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var detailsButton: UIButton!
    @IBOutlet weak var detailsButtonWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var attachmentsButton: UIButton!
    @IBOutlet weak var attachmentButtonWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var details_attachmentsTableView: UITableView!
    
    var viewIntiallyLoaded: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavBar()
        
        configureTableView()
        
        addTapGesture()
        
        if #available(iOS 13.0, *) {
            isModalInPresentation = true
            presentationController?.delegate = self
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !viewIntiallyLoaded {
            
            configureSegmentedControl()
            viewIntiallyLoaded = true
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 9
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "collabNameCell", for: indexPath) as! CollabNameCell
            return cell
        }
        
        else if indexPath.row == 2 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "collabObjectiveCell", for: indexPath) as! CollabObjectiveCell
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.row {
            
        case 0:
            
            return 70
            
        case 2:
            
            return 110
            
        case 4:
            
            return 80
            
        case 6, 8:
            
            return 65
            
        default:
            
            return 25
            
        }
    }
    
    private func configureNavBar () {
        
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        navBar.backgroundColor = .clear
    }
    
    private func configureSegmentedControl () {
        
        segmentContainer.layer.cornerRadius = 10
        segmentContainer.clipsToBounds = true
        
        segmentBackground.layer.cornerRadius = 10
        segmentBackground.clipsToBounds = true
        
        segmentIndicatorWidthConstraint.constant = segmentContainer.frame.width / 2
        selectedSegmentIndicator.layer.cornerRadius = 10
        selectedSegmentIndicator.clipsToBounds = true
        
        detailsButtonWidthConstraint.constant = segmentContainer.frame.width / 2
        detailsButton.layer.cornerRadius = 10
        detailsButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        detailsButton.clipsToBounds = true
        
        attachmentButtonWidthConstraint.constant = segmentContainer.frame.width / 2
        attachmentsButton.layer.cornerRadius = 10
        attachmentsButton.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        attachmentsButton.clipsToBounds = true
    }
    
    private func configureTableView () {
        
        details_attachmentsTableView.dataSource = self
        details_attachmentsTableView.delegate = self
        
        details_attachmentsTableView.separatorStyle = .none
        details_attachmentsTableView.showsHorizontalScrollIndicator = false
        
        details_attachmentsTableView.register(UINib(nibName: "CollabNameCell", bundle: nil), forCellReuseIdentifier: "collabNameCell")
        
        details_attachmentsTableView.register(UINib(nibName: "CollabObjectiveCell", bundle: nil), forCellReuseIdentifier: "collabObjectiveCell")
    }
    
    private func addTapGesture () {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard () {
        
        view.endEditing(true)
    }
    
    @IBAction func exitButton(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func doneButton(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func detailsButtonPressed(_ sender: Any) {
        
        segmentIndicatorLeadingAnchor.constant = 0
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            
            self.view.layoutIfNeeded()
            
            self.attachmentsButton.setTitleColor(.black, for: .normal)
            self.detailsButton.setTitleColor(.white, for: .normal)
            
        }) { (finished: Bool) in
            
            
        }
    }
    
    
    @IBAction func attachmentsButtonPressed(_ sender: Any) {
        
        segmentIndicatorLeadingAnchor.constant = segmentContainer.frame.width / 2
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            
            self.view.layoutIfNeeded()
            
            self.attachmentsButton.setTitleColor(.white, for: .normal)
            self.detailsButton.setTitleColor(.black, for: .normal)
            
        }) { (finished: Bool) in
            
        }
    }
    
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        
//        let dismissAlert = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
//        dismissAlert.changeTitleFont(text: "Cancel Collab Creation")
//
//        let continueAction = UIAlertAction(title: "Keep Creating", style: .default) { (continueAction) in
//
//            dismissAlert.dismiss(animated: true, completion: nil)
//        }
//
//        continueAction.setValue(UIColor.flatBlue(), forKey: "titleTextColor")
//        
//        let cancelAction = UIAlertAction(title: "Stop Creating", style: .destructive) { (cancelAction) in
//
//            self.dismiss(animated: true, completion: nil)
//        }
//
//        dismissAlert.addAction(continueAction)
//        dismissAlert.addAction(cancelAction)
//
//        present(dismissAlert, animated: true, completion: nil)
    }
}

extension UIAlertController {
    
    func changeTitleFont (text: String) {
        
        let continueText = text
        var mutableString = NSMutableAttributedString()
        mutableString = NSMutableAttributedString(string: continueText, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15)])
        mutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: continueText.count))

        setValue(mutableString, forKey: "attributedTitle")
    }
}


