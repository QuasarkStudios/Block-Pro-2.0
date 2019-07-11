//
//  SelectedFriendViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 7/8/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit

protocol CollabSelected {
    
    func performSegue ()
    
}

class SelectedFriendViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var upcoming_historyTableView: UITableView!
    
    @IBOutlet weak var friendView: UIView!
    
    @IBOutlet weak var newCollabButton: UIButton!
    @IBOutlet weak var upcomingButton: UIButton!
    @IBOutlet weak var historyButton: UIButton!
    @IBOutlet weak var deleteFriendButton: UIButton!
    
    @IBOutlet weak var dismissTableViewIndicator: UIButton!
    @IBOutlet weak var dismissTableViewButton: UIButton!
    @IBOutlet weak var exitButton: UIButton!
    
    var collabSelectedDelegate: CollabSelected?
    
    var timer: Timer?
    
    var animateButtonTracker: Bool = true
    var animateDown: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()

        upcoming_historyTableView.delegate = self
        upcoming_historyTableView.dataSource = self
        upcoming_historyTableView.register(UINib(nibName: "UpcomingCollabTableCell", bundle: nil), forCellReuseIdentifier: "UpcomingCollabCell")
        
        upcoming_historyTableView.frame = CGRect(x: 0, y: 550, width: 306, height: 370)
        
        friendView.layer.cornerRadius = 0.1 * friendView.bounds.size.width
        friendView.clipsToBounds = true
        
        newCollabButton.layer.cornerRadius = 0.068 * newCollabButton.bounds.size.width
        newCollabButton.clipsToBounds = true
        
        upcomingButton.layer.cornerRadius = 0.068 * upcomingButton.bounds.size.width
        upcomingButton.clipsToBounds = true
        
        historyButton.layer.cornerRadius = 0.068 * historyButton.bounds.size.width
        historyButton.clipsToBounds = true
        
        deleteFriendButton.layer.cornerRadius = 0.068 * deleteFriendButton.bounds.size.width
        deleteFriendButton.clipsToBounds = true
        
        dismissTableViewIndicator.frame.origin.y = 525
        dismissTableViewButton.isEnabled = false
        
        exitButton.layer.cornerRadius = 0.5 * exitButton.bounds.size.width
        exitButton.clipsToBounds = true
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UpcomingCollabCell", for: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        animateButtonTracker = false
        timer?.invalidate()
        
        dismiss(animated: true) {
            
            self.collabSelectedDelegate?.performSegue()
        }
        
    }
    
    @objc func animateDismissButton (timer: Timer) {

        print("check")
        if animateButtonTracker == true {
            
            if animateDown == true {
                
                UIView.animate(withDuration: 2, animations: {

                    self.dismissTableViewIndicator.frame = CGRect(x: 133, y: 100, width: 40, height: 30)
                    //self.dismissTableViewButton.frame.origin.y = 100
                    
                }) { (finished: Bool) in
                    
                    self.animateDown = false
                }
            }
            
            else if animateDown == false {
                
                
                UIView.animate(withDuration: 2, animations: {
                    
                    self.dismissTableViewIndicator.frame = CGRect(x: 103, y: 80, width: 100, height: 35)
                    //self.dismissTableViewButton.frame.origin.y = 80
                    
                }) { (finished: Bool) in
                    self.animateDown = true
                }
            }
        }
        print(animateDown)

    }

    
    
    @IBAction func upcomingButton(_ sender: Any) {
        
        animateButtonTracker = true
        
        let date = Date()
        timer = Timer(fireAt: date, interval: 3, target: self, selector: #selector(self.animateDismissButton), userInfo: nil, repeats: true)
        
        dismissTableViewButton.isEnabled = true
        
        UIView.animate(withDuration: 0.2, animations: {
            
            self.newCollabButton.frame.origin.x = -300
            self.upcomingButton.frame.origin.x = 415
            self.historyButton.frame.origin.x = -300
            self.deleteFriendButton.frame.origin.x = 415
            
        }) { (finished: Bool) in
            UIView.animate(withDuration: 0.2, animations: {
                
                self.dismissTableViewIndicator.frame.origin.y = 80
                self.upcoming_historyTableView.frame = CGRect(x: 0, y: 130, width: 306, height: 370)
                
            }, completion: { (finished: Bool) in
                RunLoop.main.add(self.timer!, forMode: .common)
                
            })
            
        }
        
    }
    
    @IBAction func historyButton(_ sender: Any) {
        
        animateButtonTracker = true
        
        let date = Date()
        timer = Timer(fireAt: date, interval: 3, target: self, selector: #selector(self.animateDismissButton), userInfo: nil, repeats: true)
        
        dismissTableViewButton.isEnabled = true
        
        UIView.animate(withDuration: 0.2, animations: {
            
            self.newCollabButton.frame.origin.x = -300
            self.upcomingButton.frame.origin.x = 415
            self.historyButton.frame.origin.x = -300
            self.deleteFriendButton.frame.origin.x = 415
            
        }) { (finished: Bool) in
            UIView.animate(withDuration: 0.2, animations: {
                
                self.dismissTableViewIndicator.frame.origin.y = 80
                self.upcoming_historyTableView.frame = CGRect(x: 0, y: 130, width: 306, height: 370)
                
            }, completion: { (finished: Bool) in
                RunLoop.main.add(self.timer!, forMode: .common)
                
            })
            
        }
    }
    
    @IBAction func dismissTableViewButton(_ sender: Any) {
        
        animateButtonTracker = false
        animateDown = true
        timer?.invalidate()
        
        UIView.animate(withDuration: 0.2, animations: {
            
            self.dismissTableViewIndicator.frame = CGRect(x: 103, y: 525, width: 100, height: 35)
            self.upcoming_historyTableView.frame = CGRect(x: 0, y: 550, width: 306, height: 370)
            
        }) { (finished: Bool) in
            
            UIView.animate(withDuration: 0.2, animations: {
                self.newCollabButton.frame.origin.x = 23
                self.upcomingButton.frame.origin.x = 23
                self.historyButton.frame.origin.x = 23
                self.deleteFriendButton.frame.origin.x = 23
            })
        }
        
    }
    
    
    @IBAction func exitButton(_ sender: Any) {
        
        animateButtonTracker = false
        timer?.invalidate()
        
        dismiss(animated: true, completion: nil)
    }
    
}


