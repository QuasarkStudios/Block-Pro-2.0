//
//  FreeTimeViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 10/20/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit

class FreeTimeViewController: UIViewController {

    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    @IBOutlet weak var addTaskButton: UIBarButtonItem!
    
    @IBOutlet weak var fiveMinContainer: UIView!
    @IBOutlet weak var fiveMinView: UIView!
    @IBOutlet weak var fiveMinTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var fiveMinBottomAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var tenMinContainer: UIView!
    @IBOutlet weak var tenMinView: UIView!
    @IBOutlet weak var tenMinTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var tenMinBottomAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var fifteenMinContainer: UIView!
    @IBOutlet weak var fifteenMinView: UIView!
    @IBOutlet weak var fifteenMinTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var fifteenMinBottomAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var thirtyMinContainer: UIView!
    @IBOutlet weak var thirtyMinView: UIView!
    @IBOutlet weak var thirtyMinTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var thirtyMinBottomAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var fourty_fiveMinContainer: UIView!
    @IBOutlet weak var fourty_fiveMinView: UIView!
    @IBOutlet weak var fourty_fiveMinTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var fourty_fiveMinBottomAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var oneHourContainer: UIView!
    @IBOutlet weak var oneHourView: UIView!
    @IBOutlet weak var oneHourTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var oneHourBottomAnchor: NSLayoutConstraint!
    
    let tasksTableView = UITableView()
    
    let realm = try! Realm()
    
    var allCards: Results<Card>?
    var selectedTaskLength: Card?
    var tasks: Results<Task>?
    
    var taskArray: [taskTuple] = []
    
    let taskLengths: [String] = ["5 mins", "10 mins", "15 mins", "30 mins", "45 mins", "1 hour"]
    var selectedTask: String = ""
    
    var cards: [[String : Any]] = []
    
    var gradientLayer: CAGradientLayer!
    
    typealias taskTuple = (taskID: String, taskName: String, dateCreated: Date, done: Bool)
    var functionTuple: taskTuple = (taskID: "", taskName: "", dateCreated: Date(), done: false)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.frame
        gradientLayer.colors = [UIColor(hexString: "#d3cce3")?.cgColor as Any, UIColor(hexString: "#e9e4f0")?.cgColor as Any]
//        gradientLayer.colors = [ UIColor(hexString: "#e65245")?.cgColor as Any, UIColor(hexString: "#e43a15")?.cgColor as Any]
        gradientLayer.locations = [0.0, 0.33, 0.66]

        view.layer.addSublayer(gradientLayer)
        view.bringSubviewToFront(visualEffectView)
        
        addTaskButton.isEnabled = false
        
        configureContainers()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
       setupTableView()
    }
    

    func configureContainers () {
        
        view.bringSubviewToFront(fiveMinContainer)
        
        fiveMinContainer.backgroundColor = fiveMinContainer.backgroundColor?.darken(byPercentage: 0.1)
        
        fiveMinContainer.layer.cornerRadius = 0.08 * fiveMinContainer.bounds.size.width
        fiveMinContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        fiveMinContainer.clipsToBounds = true
        
        fiveMinView.layer.cornerRadius = 0.075 * fiveMinView.bounds.size.width
        fiveMinView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        fiveMinView.clipsToBounds = true
        
        view.bringSubviewToFront(tenMinContainer)
        
        tenMinContainer.backgroundColor = tenMinContainer.backgroundColor?.darken(byPercentage: 0.1)
        
        tenMinContainer.layer.cornerRadius = 0.08 * tenMinContainer.bounds.size.width
        tenMinContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        tenMinContainer.clipsToBounds = true
        
        tenMinView.layer.cornerRadius = 0.075 * fiveMinView.bounds.size.width
        tenMinView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        tenMinView.clipsToBounds = true
        
        view.bringSubviewToFront(fifteenMinContainer)
        
        fifteenMinContainer.backgroundColor = fifteenMinContainer.backgroundColor?.darken(byPercentage: 0.1)
        
        fifteenMinContainer.layer.cornerRadius = 0.08 * tenMinContainer.bounds.size.width
        fifteenMinContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        fifteenMinContainer.clipsToBounds = true
        
        
        fifteenMinView.layer.cornerRadius = 0.075 * fiveMinView.bounds.size.width
        fifteenMinView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        fifteenMinView.clipsToBounds = true
        
        view.bringSubviewToFront(thirtyMinContainer)
        
        thirtyMinContainer.backgroundColor = thirtyMinContainer.backgroundColor?.darken(byPercentage: 0.1)
        
        thirtyMinContainer.layer.cornerRadius = 0.08 * thirtyMinContainer.bounds.size.width
        thirtyMinContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        thirtyMinContainer.clipsToBounds = true

        
        thirtyMinView.layer.cornerRadius = 0.075 * fiveMinView.bounds.size.width
        thirtyMinView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        thirtyMinView.clipsToBounds = true
        
        view.bringSubviewToFront(fourty_fiveMinContainer)
        
        fourty_fiveMinContainer.backgroundColor = fourty_fiveMinContainer.backgroundColor?.darken(byPercentage: 0.1)
        
        fourty_fiveMinContainer.layer.cornerRadius = 0.08 * fourty_fiveMinContainer.bounds.size.width
        fourty_fiveMinContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        fourty_fiveMinContainer.clipsToBounds = true
        
        
        fourty_fiveMinView.layer.cornerRadius = 0.075 * fourty_fiveMinView.bounds.size.width
        fourty_fiveMinView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        fourty_fiveMinView.clipsToBounds = true
        
        view.bringSubviewToFront(oneHourContainer)
        
        oneHourContainer.backgroundColor = oneHourContainer.backgroundColor?.darken(byPercentage: 0.1)
        
        oneHourContainer.layer.cornerRadius = 0.08 * oneHourContainer.bounds.size.width
        oneHourContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        oneHourContainer.clipsToBounds = true
        
        
        oneHourView.layer.cornerRadius = 0.075 * oneHourView.bounds.size.width
        oneHourView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        oneHourView.clipsToBounds = true
        
        cards.append(["card" : fiveMinContainer!, "cardTopAnchor" : fiveMinTopAnchor!, "cardBottomAnchor" : fiveMinBottomAnchor!, "cardAnimated" : false])
        
        cards.append(["card" : tenMinContainer!, "cardTopAnchor" : tenMinTopAnchor!, "cardBottomAnchor" : tenMinBottomAnchor!, "cardAnimated" : false])
        
        cards.append(["card" : fifteenMinContainer!, "cardTopAnchor" : fifteenMinTopAnchor!, "cardBottomAnchor" : fifteenMinBottomAnchor!, "cardAnimated" : false])
        
        cards.append(["card" : thirtyMinContainer!, "cardTopAnchor" : thirtyMinTopAnchor!, "cardBottomAnchor" : thirtyMinBottomAnchor!, "cardAnimated" : false])
        
        cards.append(["card" : fourty_fiveMinContainer!, "cardTopAnchor" : fourty_fiveMinTopAnchor!, "cardBottomAnchor" : fourty_fiveMinBottomAnchor!, "cardAnimated" : false])
        
        cards.append(["card" : oneHourContainer!, "cardTopAnchor" : oneHourTopAnchor!, "cardBottomAnchor" : oneHourBottomAnchor!, "cardAnimated" : false])
        
    }
    
    func setupTableView () {
        
        tasksTableView.frame = CGRect(x: 1, y: 60, width: fiveMinContainer.frame.width - 2, height: fiveMinContainer.frame.height)
        tasksTableView.backgroundColor = .white
        tasksTableView.delegate = self
        tasksTableView.dataSource = self
        
        tasksTableView.rowHeight = 50
        
        tasksTableView.register(SwipeTableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    func loadTasks (_ taskLength: String) {
        
        allCards = realm.objects(Card.self).filter("taskLength = %@", taskLength)
        
        if allCards?.count ?? 0 != 0 {
            
            selectedTaskLength = allCards![0]
            
            if selectedTaskLength?.tasks.count != 0 {
                
                tasks = selectedTaskLength?.tasks.sorted(byKeyPath: "dateCreated")
                taskArray = organizeTasks(functionTuple)
                print(Date(), taskArray)
            }
        }
        
        else {
            
            let newTaskLength = Card()
            newTaskLength.taskLength = taskLength
            
            do {
                
                try realm.write {
                    
                    realm.add(newTaskLength)
                }
            } catch {
                print("Error creating a new task \(error)")
            }
            
            loadTasks(taskLength)
        }
        
    }
    
    func organizeTasks (_ taskTuple: taskTuple) -> [(taskTuple)] {
        
        var taskTuple = taskTuple
        var returnTaskArray: [taskTuple] = []
        
        for task in tasks! {
            
            taskTuple.taskID = task.taskID
            taskTuple.taskName = task.name
            taskTuple.dateCreated = task.dateCreated!
            taskTuple.done = task.done
            
            returnTaskArray.append(taskTuple)
        }
        
        returnTaskArray = returnTaskArray.sorted(by: {$0.dateCreated > $1.dateCreated})
        
        var count: Int = 0
        
        while count < returnTaskArray.count {
            
            if returnTaskArray[count].done == true {
                
                let completedTask = returnTaskArray.remove(at: count)
                returnTaskArray.append(completedTask)
            }
            
            count += 1
        }
        
        return returnTaskArray
    }
    
    func saveTasks (_ name: String) {
        
        let newTask = Task()
        
        newTask.name = name
        newTask.dateCreated = Date()
        
        do {
            try realm.write {
                selectedTaskLength?.tasks.append(newTask)
            }
        } catch {
            print("Error creating a new task \(error)")
        }
    }
    
    func deleteTask (_ selectedTask: Int) {
        
        guard let deletedTask = realm.object(ofType: Task.self, forPrimaryKey: taskArray[selectedTask].taskID) else { return }
    
        do {
            try realm.write {
                realm.delete(deletedTask)
            }
        } catch {
            print("Error deleting task \(error)")
        }
        
        loadTasks(self.selectedTask)
        tasksTableView.reloadData()
        
    }
    
    @IBAction func addTask(_ sender: Any) {
        
        var textField = UITextField()
        
        let addTaskAlert = UIAlertController(title: "Add A 5 Minute Task", message: nil, preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            
            self.saveTasks(textField.text!)
            self.loadTasks(self.selectedTask)
            self.tasksTableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        addTaskAlert.addTextField { (field) in
            
            textField = field
            textField.placeholder = "Enter Task Name Here"
            
        }
        addTaskAlert.addAction(addAction)
        addTaskAlert.addAction(cancelAction)
        
        present(addTaskAlert, animated: true, completion: nil)
    }
    
    
    @IBAction func cardButtons(_ sender: UIButton) {
        
        let tappedCard: UIView = cards[sender.tag]["card"] as! UIView
        let cardAnimated: Bool = cards[sender.tag]["cardAnimated"] as! Bool
        
        selectedTask = taskLengths[sender.tag]
        
        if cardAnimated == false {
            
            animateCards(tappedCard, true)
            
            addTaskButton.isEnabled = true
        }
        
        else {
            
            animateCards(tappedCard, false)
            
            addTaskButton.isEnabled = false
        }
        
        if cardAnimated == false {
            
            loadTasks(selectedTask)
            tasksTableView.reloadData()
        }
        
        else {
            
            taskArray.removeAll()
        }
        
    }
    
    
    func animateCards (_ tappedCard: UIView, _ animateDown: Bool) {
        
        var count: Int = 0
        
        if animateDown == true {
            
            while count < 6 {
                
                let card = cards[count]["card"] as! UIView
                let cardTopAnchor = cards[count]["cardTopAnchor"] as! NSLayoutConstraint
                let cardBottomAnchor = cards[count]["cardBottomAnchor"] as! NSLayoutConstraint
                
                if tappedCard == card {
                    
                    cardTopAnchor.constant = 75
                    cardBottomAnchor.constant = 0
                    
                    card.addSubview(tasksTableView)
                    
                    cards[count]["cardAnimated"] = true
                }
                
                else {
                    
                    cardTopAnchor.constant = 750
                    cardBottomAnchor.constant = -750
                }
                
                UIView.animate(withDuration: 0.2) {
                    self.view.layoutIfNeeded()
                }
                
                count += 1
            }
        }
        
        else {
            
            while count < 6 {
                
                let cardTopAnchor = cards[count]["cardTopAnchor"] as! NSLayoutConstraint
                let cardBottomAnchor = cards[count]["cardBottomAnchor"] as! NSLayoutConstraint
                
                switch count {
                    
                case 0:
                    
                    cardTopAnchor.constant = 75
                
                case 1:
                    
                    cardTopAnchor.constant = 130
                    
                case 2:
                    
                    cardTopAnchor.constant = 185
            
                case 3:
                    
                    cardTopAnchor.constant = 240
                    
                case 4:
                    
                    cardTopAnchor.constant = 295
                    
                default:
                    
                    cardTopAnchor.constant = 350
                }
                
                cardBottomAnchor.constant = 0
                
                UIView.animate(withDuration: 0.2) {
                    
                    self.view.layoutIfNeeded()
                }
                
                cards[count]["cardAnimated"] = false
                
                count += 1
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                self.tasksTableView.removeFromSuperview()
            }
        }
    }
    
}

extension FreeTimeViewController: UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        view.tintColor = UIColor(hexString: "F2F2F2")//?.darken(byPercentage: 0.025)
        //let header = view as! UITableViewHeaderFooterView
        //header.textLabel?.textColor = UIColor.white
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return "Tasks"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if taskArray.count > 0 {
            
            return taskArray.count
        }
        
        else {
            
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if taskArray.count > 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
            cell.delegate = self
            
            cell.textLabel?.text = taskArray[indexPath.row].taskName
            
            //Ternary operator ==>
            // value = condition ? valueIfTrue : valueIfFalse
            cell.accessoryType = taskArray[indexPath.row].done ? .checkmark : .none
            
            return cell
        }
        
        else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = "No Tasks Saved"
            cell.isUserInteractionEnabled = false
            
            return cell
        }
        

    }
    
    
    //MARK: SwipeCell Delegate Methods
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            
            self.deleteTask(indexPath.row)
//            self.loadTasks(self.selectedTask)
//            self.tasksTableView.reloadData()
        }

        return [deleteAction]
        
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        
        var options = SwipeTableOptions()
        options.expansionStyle = .destructive
        return options
    }
}
