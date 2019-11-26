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
    
    @IBOutlet weak var dismissCardView: UIView!
    @IBOutlet weak var dismissViewTopAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var fiveMinContainer: UIView!
    @IBOutlet weak var fiveMinView: UIView!
    @IBOutlet weak var fiveMinTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var fiveMinBottomAnchor: NSLayoutConstraint!
    @IBOutlet weak var fiveLabelTopAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var tenMinContainer: UIView!
    @IBOutlet weak var tenMinView: UIView!
    @IBOutlet weak var tenMinTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var tenMinBottomAnchor: NSLayoutConstraint!
    @IBOutlet weak var tenLabelTopAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var fifteenMinContainer: UIView!
    @IBOutlet weak var fifteenMinView: UIView!
    @IBOutlet weak var fifteenMinTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var fifteenMinBottomAnchor: NSLayoutConstraint!
    @IBOutlet weak var fifteenLabelTopAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var thirtyMinContainer: UIView!
    @IBOutlet weak var thirtyMinView: UIView!
    @IBOutlet weak var thirtyMinTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var thirtyMinBottomAnchor: NSLayoutConstraint!
    @IBOutlet weak var thirtyLabelTopAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var fourty_fiveMinContainer: UIView!
    @IBOutlet weak var fourty_fiveMinView: UIView!
    @IBOutlet weak var fourty_fiveMinTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var fourty_fiveMinBottomAnchor: NSLayoutConstraint!
    @IBOutlet weak var fourty_fiveLabelTopAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var oneHourContainer: UIView!
    @IBOutlet weak var oneHourView: UIView!
    @IBOutlet weak var oneHourTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var oneHourBottomAnchor: NSLayoutConstraint!
    @IBOutlet weak var oneHourLabelTopAnchor: NSLayoutConstraint!
    
    let realm = try! Realm()
    let defaults = UserDefaults.standard
    
    var allCards: Results<Card>?
    var selectedTaskLength: Card?
    var tasks: Results<Task>?
    
    //Used to access a specific Card container from Realm
    let taskLengths: [String] = ["5 Minute", "10 Minute", "15 Minute", "30 Minute", "45 Minute", "1 Hour"]
    var selectedTask: String = ""
    
    //Pre-defining the tasks tuple structure
    typealias taskTuple = (taskID: String, taskName: String, dateCreated: Date, done: Bool)
    var functionTuple: taskTuple = (taskID: "", taskName: "", dateCreated: Date(), done: false)
    var taskArray: [taskTuple] = []
    
    var cards: [[String : Any]] = [] //Array containing the UIView, top anchor, bottom anchor, and animation status of each card
    var tappedCard: UIView!
    var tappedCardTopAnchor: NSLayoutConstraint!
    var tappedCardBottomAnchor: NSLayoutConstraint!
    var tappedCardLabelTopAnchor: NSLayoutConstraint!
    
    var dismissViewIndicator = UIView()
    
    let tasksTableView = UITableView()
    
    var pan: UIPanGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Watches for when this view will resign its active state
        NotificationCenter.default.addObserver(self, selector: #selector(autoDeleteCompletedTasks), name: UIApplication.willResignActiveNotification, object: nil)
        
        //Adding gradient layer to the view
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.frame = view.frame
        gradientLayer.colors = [UIColor(hexString: "#e9e4f0")?.cgColor as Any, UIColor(hexString: "#d3cce3")?.cgColor as Any]
        gradientLayer.locations = [0.0, 0.66]
        
        view.layer.addSublayer(gradientLayer)
        view.bringSubviewToFront(visualEffectView)
        
        dismissCardView.backgroundColor = .clear
        
        configureContainers()
        
        //setupTableView()
    }
    

    override func viewDidAppear(_ animated: Bool) {
        
       setupTableView()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        autoDeleteCompletedTasks()
    }
    
    
    //MARK: - Configure Containers Function
    
    func configureContainers () {
        
        //5 Minute Card
        view.bringSubviewToFront(fiveMinContainer)
        
        fiveMinContainer.backgroundColor = fiveMinContainer.backgroundColor?.darken(byPercentage: 0.1)
        
        fiveMinContainer.layer.cornerRadius = 0.08 * fiveMinContainer.bounds.size.width
        fiveMinContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        fiveMinContainer.clipsToBounds = true
        
        fiveMinView.layer.cornerRadius = 0.075 * fiveMinView.bounds.size.width
        fiveMinView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        fiveMinView.clipsToBounds = true
        
        //10 Minute Card
        view.bringSubviewToFront(tenMinContainer)
        
        tenMinContainer.backgroundColor = tenMinContainer.backgroundColor?.darken(byPercentage: 0.1)
        
        tenMinContainer.layer.cornerRadius = 0.08 * tenMinContainer.bounds.size.width
        tenMinContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        tenMinContainer.clipsToBounds = true
        
        tenMinView.layer.cornerRadius = 0.075 * fiveMinView.bounds.size.width
        tenMinView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        tenMinView.clipsToBounds = true
        
        //15 Minute Card
        view.bringSubviewToFront(fifteenMinContainer)
        
        fifteenMinContainer.backgroundColor = fifteenMinContainer.backgroundColor?.darken(byPercentage: 0.1)
        
        fifteenMinContainer.layer.cornerRadius = 0.08 * tenMinContainer.bounds.size.width
        fifteenMinContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        fifteenMinContainer.clipsToBounds = true
        
        
        fifteenMinView.layer.cornerRadius = 0.075 * fiveMinView.bounds.size.width
        fifteenMinView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        fifteenMinView.clipsToBounds = true
        
        //30 Minute Card
        view.bringSubviewToFront(thirtyMinContainer)
        
        thirtyMinContainer.backgroundColor = thirtyMinContainer.backgroundColor?.darken(byPercentage: 0.1)
        
        thirtyMinContainer.layer.cornerRadius = 0.08 * thirtyMinContainer.bounds.size.width
        thirtyMinContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        thirtyMinContainer.clipsToBounds = true

        
        thirtyMinView.layer.cornerRadius = 0.075 * fiveMinView.bounds.size.width
        thirtyMinView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        thirtyMinView.clipsToBounds = true
        
        //45 Minute Card
        view.bringSubviewToFront(fourty_fiveMinContainer)
        
        fourty_fiveMinContainer.backgroundColor = fourty_fiveMinContainer.backgroundColor?.darken(byPercentage: 0.1)
        
        fourty_fiveMinContainer.layer.cornerRadius = 0.08 * fourty_fiveMinContainer.bounds.size.width
        fourty_fiveMinContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        fourty_fiveMinContainer.clipsToBounds = true
        
        
        fourty_fiveMinView.layer.cornerRadius = 0.075 * fourty_fiveMinView.bounds.size.width
        fourty_fiveMinView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        fourty_fiveMinView.clipsToBounds = true
        
        //1 Hour Card
        view.bringSubviewToFront(oneHourContainer)
        
        oneHourContainer.backgroundColor = oneHourContainer.backgroundColor?.darken(byPercentage: 0.1)
        
        oneHourContainer.layer.cornerRadius = 0.08 * oneHourContainer.bounds.size.width
        oneHourContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        oneHourContainer.clipsToBounds = true
        
        
        oneHourView.layer.cornerRadius = 0.075 * oneHourView.bounds.size.width
        oneHourView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        oneHourView.clipsToBounds = true
        
        //Adding the UIView, top anchor, bottom anchor, and animation status of each card to the "cards" array
        cards.append(["card" : fiveMinContainer!, "cardTopAnchor" : fiveMinTopAnchor!, "cardBottomAnchor" : fiveMinBottomAnchor!, "labelTopAnchor" : fiveLabelTopAnchor!, "cardAnimated" : false])
        cards.append(["card" : tenMinContainer!, "cardTopAnchor" : tenMinTopAnchor!, "cardBottomAnchor" : tenMinBottomAnchor!, "labelTopAnchor" : tenLabelTopAnchor!, "cardAnimated" : false])
        cards.append(["card" : fifteenMinContainer!, "cardTopAnchor" : fifteenMinTopAnchor!, "cardBottomAnchor" : fifteenMinBottomAnchor!, "labelTopAnchor" : fifteenLabelTopAnchor!, "cardAnimated" : false])
        cards.append(["card" : thirtyMinContainer!, "cardTopAnchor" : thirtyMinTopAnchor!, "cardBottomAnchor" : thirtyMinBottomAnchor!, "labelTopAnchor" : thirtyLabelTopAnchor!, "cardAnimated" : false])
        cards.append(["card" : fourty_fiveMinContainer!, "cardTopAnchor" : fourty_fiveMinTopAnchor!, "cardBottomAnchor" : fourty_fiveMinBottomAnchor!, "labelTopAnchor" : fourty_fiveLabelTopAnchor!, "cardAnimated" : false])
        cards.append(["card" : oneHourContainer!, "cardTopAnchor" : oneHourTopAnchor!, "cardBottomAnchor" : oneHourBottomAnchor!, "labelTopAnchor" : oneHourLabelTopAnchor!, "cardAnimated" : false])
    }
    
    
    //MARK: - Setup TableView Function
    
    func setupTableView () {
        
        tasksTableView.frame = CGRect(x: 1, y: 60, width: fiveMinContainer.frame.width - 2, height: fiveMinContainer.frame.height - 60)
        tasksTableView.backgroundColor = .white
        tasksTableView.delegate = self
        tasksTableView.dataSource = self
        
        tasksTableView.register(SwipeTableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    
    //MARK: - Load Tasks Function
    
    func loadTasks (_ taskLength: String) {
        
        allCards = realm.objects(Card.self).filter("taskLength = %@", taskLength) //Getting the Card container that matches the selected "taskLength" if one exists
        
        //If a card matching that selected "taskLength" was found/exists
        if allCards?.count ?? 0 != 0 {
            
            selectedTaskLength = allCards![0]
            
            //If there are tasks within that card container
            if selectedTaskLength?.tasks.count != 0 {
                
                tasks = selectedTaskLength?.tasks.sorted(byKeyPath: "dateCreated")
                taskArray = organizeTasks(functionTuple)
            }
            
            else {
                
                taskArray.removeAll()
            }
        }
        
        //If a card matching that selected "taskLength" was not found / does not exist
        else {
            
            //Creating a new card container for the selected "taskLength"
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
    
    
    //MARK: - Organize Tasks Function
    
    func organizeTasks (_ taskTuple: taskTuple) -> [(taskTuple)] {
        
        var taskTuple = taskTuple
        var returnTaskArray: [taskTuple] = []
        
        //Adding the tasks pulled from Realm to the "returnTaskArray"
        for task in tasks! {
            
            taskTuple.taskID = task.taskID
            taskTuple.taskName = task.name
            taskTuple.dateCreated = task.dateCreated!
            taskTuple.done = task.done
            
            returnTaskArray.append(taskTuple)
        }
        
        returnTaskArray = returnTaskArray.sorted(by: {$0.dateCreated > $1.dateCreated}) //Sorting the "returnTaskArray" by the date each task was created
        
        var count: Int = 0

        //Adding all the tasks that have been completed to the bottom of the array
        for task in returnTaskArray {
            
            if task.done == true {
                
                let completedTask = returnTaskArray.remove(at: count)
                returnTaskArray.append(completedTask)
            }
            
            else {
                count += 1
            }
            
        }
        
        return returnTaskArray
    }
    
    
    //MARK: - Save Tasks Function
    
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
    
    
    //MARK: - Delete Tasks Function
    
    func deleteTask (_ selectedTask: Int) {
        
        guard let deletedTask = realm.object(ofType: Task.self, forPrimaryKey: taskArray[selectedTask - 1].taskID) else { return }
    
        do {
            try realm.write {
                realm.delete(deletedTask)
            }
        } catch {
            print("Error deleting task \(error)")
        }
    }
    
    
    //MARK: - Auto Delete Tasks Function
    
    @objc func autoDeleteCompletedTasks () {
        
        //If the user has enabled auto deleting tasks
        if defaults.value(forKey: "autoDeleteTasks") as? Bool ?? false == true {
            
            for length in taskLengths {
                
                allCards = realm.objects(Card.self).filter("taskLength = %@", length)
                
                //If a card exists for the current "taskLength"
                if allCards?.count ?? 0 != 0 {
                    
                    selectedTaskLength = allCards![0]
                    tasks = selectedTaskLength?.tasks.sorted(byKeyPath: "name")
                    
                    //For loop that checks each "task" done property and deletes the task if it is true
                    for task in tasks! {
                        
                        if task.done == true {
                            
                            guard let deletedTask = realm.object(ofType: Task.self, forPrimaryKey: task.taskID) else { return }
                            
                                do {
                                    try realm.write {
                                        realm.delete(deletedTask)
                                    }
                                } catch {
                                    print("Error deleting task \(error)")
                                }
                        }
                    }
                }
            }
        }
        
        taskArray.removeAll()
        loadTasks(selectedTask)
        tasksTableView.reloadData()
    }
    
    
    //MARK: - Animate Cards Function
    
    func animateCards (_ tappedCard: UIView, _ animateDown: Bool) {
        
        var count: Int = 0
        
        //Animates the selected card up and the rest of the cards down
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
                
                UIView.animate(withDuration: 0.2, animations: {
                    
                    self.view.layoutIfNeeded()
                    
                }) { (finished: Bool) in
                    
                    self.tappedCardLabelTopAnchor.constant = 7.5
                    
                    UIView.animate(withDuration: 0.2) {
                        
                        self.dismissViewIndicator.center = CGPoint(x: self.tappedCard.center.x - 15, y: 15)
                        self.view.layoutIfNeeded()
                    }
                }
                
                count += 1
            }
        }
        
        //Animates all the cards to their original position
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
            
            tasksTableView.removeFromSuperview()
            dismissViewIndicator.removeFromSuperview()
            tappedCardLabelTopAnchor.constant = 0
        }
    }
    
    
    //MARK: - Add Dismiss Indicator Function
    
    func addIndicator () {
        
        dismissViewIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 7.5)
        dismissViewIndicator.center = CGPoint(x: tappedCard.center.x - 15, y: -10)
        
        dismissViewIndicator.layer.cornerRadius = 0.075 * 50
        dismissViewIndicator.clipsToBounds = true
        
        dismissViewIndicator.backgroundColor = UIColor(hexString: "f2f2f2")?.darken(byPercentage: 0.05)
        
        tappedCard.addSubview(dismissViewIndicator)
    }
    
    //MARK: - Pan Gesture Functions
    
    func addPanGesture (view: UIView) {
        
        view.addGestureRecognizer(pan)
    }
    
    @objc func handlePan (sender: UIPanGestureRecognizer) {
        
        let dismissView = sender.view!
        
        switch sender.state {
            
        case .began, .changed:
            
            moveViewWithPan (sender: sender)
        
        case .ended:
            
            if tappedCardTopAnchor.constant >= view.frame.height / 2.5 {
                
                self.dismissView(dismissView, tappedCard)
            }
            
            else {
                
                returnViewToOrigin()
            }
            
        default:
            break
        }
    }
    
    
    func moveViewWithPan (sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: view)
        
        if tappedCardTopAnchor.constant + translation.y > 75 {
            
            tappedCardTopAnchor.constant += translation.y
            tappedCardBottomAnchor.constant -= translation.y
            sender.setTranslation(CGPoint.zero, in: view)
        }
        
        else {
            tappedCardTopAnchor.constant = 75
            tappedCardBottomAnchor.constant = 0
        }
    }
    
    
    func returnViewToOrigin () {
        
        tappedCardTopAnchor.constant = 75
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    
    func dismissView (_ dismissView: UIView, _ tappedCard: UIView) {
        
        tappedCardTopAnchor.constant = 750
        tappedCardBottomAnchor.constant = -750
        
        UIView.animate(withDuration: 0.15, animations: {
            
            self.view.layoutIfNeeded()
            
        }) { (finished: Bool) in
            
            self.animateCards(tappedCard, false)
            self.removePanGesture(view: dismissView)
            self.view.sendSubviewToBack(dismissView)
        }
        
        addTaskButton.isEnabled = false
        taskArray.removeAll()
    }
    
    
    func removePanGesture (view: UIView) {
        
        view.removeGestureRecognizer(pan)
    }
    
    
    //MARK: - Add Task Button
    
    @IBAction func addTask(_ sender: Any) {

        var textField = UITextField()
        
        let addTaskAlert = UIAlertController(title: "Add A \(selectedTask) Task", message: nil, preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let taskNameArray = Array(textField.text ?? "")
            var taskNameEntered: Bool = false
            
            //For loop that checks to see if "textField" isn't empty
            for char in taskNameArray {
                
                if char != " " {
                    taskNameEntered = true
                    break
                }
            }
            
            if taskNameEntered == true {
                
                self.saveTasks(textField.text!)
                self.loadTasks(self.selectedTask)
                self.tasksTableView.reloadData()
            }
            
            else {
                ProgressHUD.showError("Please enter a name for the task")
            }

        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        //Adding a textField to the "addTaskAlert"
        addTaskAlert.addTextField { (field) in
            
            textField = field
            textField.placeholder = "Enter Task Name Here"
            
        }
        addTaskAlert.addAction(addAction)
        addTaskAlert.addAction(cancelAction)
        
        present(addTaskAlert, animated: true, completion: nil)
    }
    
   
    //MARK: - Card Buttons
    
    @IBAction func cardButtons(_ sender: UIButton) {
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        tappedCard = cards[sender.tag]["card"] as? UIView
        tappedCardTopAnchor = cards[sender.tag]["cardTopAnchor"] as? NSLayoutConstraint
        tappedCardBottomAnchor = cards[sender.tag]["cardBottomAnchor"] as? NSLayoutConstraint
        tappedCardLabelTopAnchor = cards[sender.tag]["labelTopAnchor"] as? NSLayoutConstraint
        
        selectedTask = taskLengths[sender.tag]
        
        loadTasks(selectedTask)
        tasksTableView.reloadData()

        animateCards(tappedCard, true)
        addIndicator()
        
        pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:)))
        addPanGesture(view: dismissCardView)
        view.bringSubviewToFront(dismissCardView)
        
        addTaskButton.isEnabled = true
    }
}


//MARK: - Extension for the UITableViewDelegate, UITableViewDataSource and SwipeTableViewCellDelegate

extension FreeTimeViewController: UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate {

    
    //MARK: - TableView DataSource Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        view.tintColor = UIColor(hexString: "F2F2F2")
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return "Tasks"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return taskArray.count + 1 //Must always add one more row than neccasary to allow for the "SwipeCellKit" methods to work properly
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if taskArray.count > 0 {
            
            if indexPath.row == 0 {

                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
                return cell
            }
            
            else {
              
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
                
                cell.delegate = self
            
                cell.textLabel?.text = taskArray[indexPath.row - 1].taskName
                cell.textLabel?.textColor = .black
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.adjustsFontSizeToFitWidth = true
                
                //Ternary operator ==>
                // value = condition ? valueIfTrue : valueIfFalse
                cell.accessoryType = taskArray[indexPath.row - 1].done ? .checkmark : .none
                
                cell.isUserInteractionEnabled = true
                
                return cell
            }
        }
        
        else {
           
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
            
            cell.textLabel?.text = "No Tasks Saved"
            cell.textLabel?.textColor = UIColor.lightGray
            
            cell.accessoryType = .none
            
            cell.isUserInteractionEnabled = false
            
            return cell
        }
    }
    
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
            if taskArray.count > 0 {
    
                if indexPath.row == 0 {
    
                    return 0.0
                }
    
                else {
    
                    let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)]
                    let size = CGSize(width: tasksTableView.frame.size.width, height: 1000)
                    let estimatedFrame = NSString(string: taskArray[indexPath.row - 1].taskName).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes as [NSAttributedString.Key : Any], context: nil)
                    
                    if estimatedFrame.height < 50 {
                        
                        return 50
                    }
                    
                    else {
                        
                        return estimatedFrame.height + 20
                    }
                }
            }
    
            else {
    
                return 55.0
            }
        }

    
    //MARK: - TableView Delegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let tappedTask = Task()
        
        tappedTask.taskID = taskArray[indexPath.row - 1].taskID
        tappedTask.name = taskArray[indexPath.row - 1].taskName
        tappedTask.dateCreated = taskArray[indexPath.row - 1].dateCreated
        tappedTask.done = !taskArray[indexPath.row - 1].done
        
        do {
            try self.realm.write {
                realm.add(tappedTask, update: .modified)
            }
        } catch {
            print("Error updating task \(error)")
        }
        
        loadTasks(selectedTask)
        tasksTableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    
    //MARK: SwipeCell Delegate Methods
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            
            self.deleteTask(indexPath.row)
            self.taskArray.remove(at: indexPath.row - 1)
        }

        return [deleteAction]
        
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        
        var options = SwipeTableOptions()
        options.expansionStyle = .destructive
        return options
    }
}
