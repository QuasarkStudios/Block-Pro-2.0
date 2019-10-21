//
//  FreeTimeViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 10/20/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit
//import RealmSwift
//import SwipeCellKit

class FreeTimeViewController: UIViewController {

    @IBOutlet weak var fiveMinContainer: UIView!
    @IBOutlet weak var fiveMinTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var fiveMinView: UIView!
    
    @IBOutlet weak var tenMinContainer: UIView!
    @IBOutlet weak var tenMinTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var tenMinView: UIView!
    
    @IBOutlet weak var fifteenMinContainer: UIView!
    @IBOutlet weak var fifteenMinTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var fifteenMinView: UIView!
    
    @IBOutlet weak var thirtyMinContainer: UIView!
    @IBOutlet weak var thirtyMinTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var thirtyMinView: UIView!
    
    @IBOutlet weak var fourty_fiveMinContainer: UIView!
    @IBOutlet weak var fourty_fiveMinTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var fourty_fiveMinView: UIView!
    
    @IBOutlet weak var oneHourContainer: UIView!
    @IBOutlet weak var oneHourTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var oneHourView: UIView!
    
    var tasksTableView = UITableView()
    
    var gradientLayer: CAGradientLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        gradientLayer = CAGradientLayer()
//        gradientLayer.frame = view.frame
//        gradientLayer.colors = [UIColor(hexString: "#d3cce3")?.cgColor as Any, UIColor(hexString: "#e9e4f0")?.cgColor as Any]
//        gradientLayer.locations = [0.0, 0.33, 0.66]
//
//        view.layer.addSublayer(gradientLayer)
        
        configureContainers()
    }
    

    func configureContainers () {
        
        view.bringSubviewToFront(fiveMinContainer)
        
        fiveMinContainer.backgroundColor = fiveMinContainer.backgroundColor?.darken(byPercentage: 0.05)
        
        fiveMinContainer.layer.cornerRadius = 0.08 * fiveMinContainer.bounds.size.width
        fiveMinContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        fiveMinContainer.clipsToBounds = true
        
        fiveMinView.layer.cornerRadius = 0.075 * fiveMinView.bounds.size.width
        fiveMinView.clipsToBounds = true
        
        view.bringSubviewToFront(tenMinContainer)
        
        tenMinContainer.backgroundColor = tenMinContainer.backgroundColor?.darken(byPercentage: 0.05)
        
        tenMinContainer.layer.cornerRadius = 0.08 * tenMinContainer.bounds.size.width
        tenMinContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        tenMinContainer.clipsToBounds = true
        
        tenMinView.layer.cornerRadius = 0.075 * fiveMinView.bounds.size.width
        tenMinView.clipsToBounds = true
        
        view.bringSubviewToFront(fifteenMinContainer)
        
        fifteenMinContainer.backgroundColor = fifteenMinContainer.backgroundColor?.darken(byPercentage: 0.05)
        
        fifteenMinContainer.layer.cornerRadius = 0.08 * tenMinContainer.bounds.size.width
        fifteenMinContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        fifteenMinContainer.clipsToBounds = true
        
        fifteenMinView.layer.cornerRadius = 0.075 * fiveMinView.bounds.size.width
        fifteenMinView.clipsToBounds = true
        
        view.bringSubviewToFront(thirtyMinContainer)
        
        thirtyMinContainer.backgroundColor = thirtyMinContainer.backgroundColor?.darken(byPercentage: 0.05)
        
        thirtyMinContainer.layer.cornerRadius = 0.08 * thirtyMinContainer.bounds.size.width
        thirtyMinContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        thirtyMinContainer.clipsToBounds = true
        
        thirtyMinView.layer.cornerRadius = 0.075 * fiveMinView.bounds.size.width
        thirtyMinView.clipsToBounds = true
        
        view.bringSubviewToFront(fourty_fiveMinContainer)
        
        fourty_fiveMinContainer.backgroundColor = fourty_fiveMinContainer.backgroundColor?.darken(byPercentage: 0.05)
        
        fourty_fiveMinContainer.layer.cornerRadius = 0.08 * fourty_fiveMinContainer.bounds.size.width
        fourty_fiveMinContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        fourty_fiveMinContainer.clipsToBounds = true
        
        fourty_fiveMinView.layer.cornerRadius = 0.075 * fourty_fiveMinView.bounds.size.width
        fourty_fiveMinView.clipsToBounds = true
        
        view.bringSubviewToFront(oneHourContainer)
        
        oneHourContainer.backgroundColor = oneHourContainer.backgroundColor?.darken(byPercentage: 0.05)
        
        oneHourContainer.layer.cornerRadius = 0.08 * oneHourContainer.bounds.size.width
        oneHourContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        oneHourContainer.clipsToBounds = true
        
        oneHourView.layer.cornerRadius = 0.075 * oneHourView.bounds.size.width
        oneHourView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        oneHourView.clipsToBounds = true
        
    }
    
    func setupTableView () {
        
        tasksTableView.frame = fiveMinView.frame
        tasksTableView.backgroundColor = .blue
        fiveMinView.addSubview(tasksTableView)
    }
    
    @IBAction func minuteButton(_ sender: UIButton) {
        
        if sender.tag == 0 {
            
            fiveMinPressed()
        }
        
        else if sender.tag == 1 {
            
            tenMinPressed()
        }
        
        else if sender.tag == 2 {
            
            fifteenMinPressed()
        }
    }
    
    
    func fiveMinPressed () {
        
        tenMinTopAnchor.constant = 700
        fifteenMinTopAnchor.constant = 700
        thirtyMinTopAnchor.constant = 700
        fourty_fiveMinTopAnchor.constant = 700
        oneHourTopAnchor.constant = 700
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    func tenMinPressed () {
        
        fiveMinTopAnchor.constant = -300
        fifteenMinTopAnchor.constant = 700
        thirtyMinTopAnchor.constant = 700
        fourty_fiveMinTopAnchor.constant = 700
        oneHourTopAnchor.constant = 700
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func fifteenMinPressed () {
        
        fiveMinTopAnchor.constant = -300
        tenMinTopAnchor.constant = -300
        thirtyMinTopAnchor.constant = 700
        fourty_fiveMinTopAnchor.constant = 700
        oneHourTopAnchor.constant = 700
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
    }
    
}
