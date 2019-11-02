//
//  InfoViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 10/7/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var infoLabelTopAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var infoTextView: UITextView!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var exitButton: UIButton!
    
    var selectedInfo: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        exitButton.layer.cornerRadius = 0.5 * exitButton.bounds.size.width
        exitButton.clipsToBounds = true
        
        infoTextView.layer.cornerRadius = 0.065 * infoTextView.bounds.size.width
        infoTextView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] //Top left corner and top right corner respectively
        infoTextView.clipsToBounds = true
        
        infoLabelTopAnchor.constant = 0
        textViewHeightConstraint.constant = 0
        
        infoLabel.text = selectedInfo
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        infoLabelTopAnchor.constant = 5
        textViewHeightConstraint.constant = view.frame.height - 60
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
        
        setText()
    }


    func setText () {
        
        let standardText: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "HelveticaNeue", size: 17.5) as Any]
        let boldText = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 30)]
        let semiBoldText = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 19)]
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: "", attributes: boldText)
        
        var heading: NSAttributedString!
        var description: NSAttributedString!
        
        switch selectedInfo {
            
        case "Free Time Cards":
            
            description = NSAttributedString(string: "Do you ever find yourself with some unexpected free time throughout your day, and you don't know what you should do to occupy yourself? Your Free Time Cards are here to help. \n \n", attributes: standardText)
            attributedString.append(description)
            
            
            heading = NSAttributedString(string: "How To Use Them \n \n", attributes: boldText)
            attributedString.append(heading)
            
            
            description = NSAttributedString(string: "Step 1: ", attributes: semiBoldText)
            attributedString.append(description)

            
            description = NSAttributedString(string: "Think of some tasks you really need to get done, but you don't really know when you'll have the time to get around to completing them. Also, keep in mind how long you think it'll take you to finish them up once you get started. \n \n", attributes: standardText)
            attributedString.append(description)
            
            
            description = NSAttributedString(string: "Step 2: ", attributes: semiBoldText)
            attributedString.append(description)
            
            
            description = NSAttributedString(string: "Once you have a few tasks in mind, go to the Free Time tab, and open up the card that either matches or is close to matching your expected time length of those tasks. \n \n", attributes: standardText)
            attributedString.append(description)
            
            
            description = NSAttributedString(string: "Step 3: ", attributes: semiBoldText)
            attributedString.append(description)
            
            
            description = NSAttributedString(string: "You can now add those tasks and many more to the cards that matches their time lengths by simply tapping on the \"Plus\" icon in the upper right of your screen and entering in the name of the task. \n \n", attributes: standardText)
            attributedString.append(description)
            
            
            description = NSAttributedString(string: "Step 4: ", attributes: semiBoldText)
            attributedString.append(description)
            
            
            description = NSAttributedString(string: "Now the next time you have some unexpected free time, just check back to your Free Time Cards and see what tasks you've been meaning to get done. Once you've completed the task, you can mark in complete by simply tapping on it and delete it by swiping left on it. Or if you've enabled \"Auto Delete Completed Tasks\", the next time you leave the Free Time tab or Block Pro in general, all your tasks marked completed will be automatically deleted for you.", attributes: standardText)
            attributedString.append(description)
            
            
            infoTextView.attributedText = attributedString
            
        case "Pomodoro":
            
            description = NSAttributedString(string: "Ever heard of the Pomodoro Technique? Neither did I before I started making Block Pro. Turns out it's a great way to break down your work into manageable intervals. \n \n", attributes: standardText)
            attributedString.append(description)
            
        
            heading = NSAttributedString(string: "What is the Pomodoro Technique? \n \n", attributes: boldText)
            attributedString.append(heading)
            
            
            description = NSAttributedString(string: "The Pomodoro Technique is a time management method in which you break down whatever work you need to get done into 25 minute intervals followed by 5 minute breaks. After 4 intervals, or 4 \"Pomodoros\", you can take a longer break for about 30 minutes. These regularly scheduled breaks help remind you to take a breather while working on larger projects to avoid feeling burnt out earlier than you'd like. \n \n", attributes: standardText)
            attributedString.append(description)
            
            
            heading = NSAttributedString(string: "Pomodoro Technique in Block Pro \n \n", attributes: boldText)
            attributedString.append(heading)
            
            
            description = NSAttributedString(string: "In Block Pro, the Pomodoro technique works a little differently. You can set the length of your Pomodoro session to a length between 15 - 30 minutes. You can also change the amount of Pomodoro sessions you need to complete before your 30 minute break, to as little as 2 sessions or as many as 5 sessions. Once a session or break is over, you'll get notified by Block Pro to either take a break, or get started on your next \"Pomodoro\". ", attributes: standardText)
            attributedString.append(description)
            
            
            infoTextView.attributedText = attributedString
            
        case "Time Block":
            
            description = NSAttributedString(string: "Time Blocking is the process of organizing every moment of your day to ensure that you are able to complete the tasks that are most important to you. While this may seem a little intense, and likely to cause you more stress while planning out your day, it can actually have the opposite effect by helping you get more done so you can have more free time. \n \n", attributes: standardText)
            attributedString.append(description)
            

            heading = NSAttributedString(string: "Time Blocking in Block Pro \n \n", attributes: boldText)
            attributedString.append(heading)
            
            
            description = NSAttributedString(string: "Step 1: ", attributes: semiBoldText)
            attributedString.append(description)


            description = NSAttributedString(string: "To start Time Blocking, go to the Time Block tab and select the day that you'd like to Time Block out. You can do this by using the calendar that will present itself after you tap on the \"Months\" or \"Weeks\" button. Or if the day you'd like to Time Block out is the current day, you can just go ahead and start. \n \n", attributes: standardText)
            attributedString.append(description)
            

            description = NSAttributedString(string: "Step 2: ", attributes: semiBoldText)
            attributedString.append(description)
            
            
            description = NSAttributedString(string: "To add your first TimeBlock, simply tap on the \"Plus\" icon located on the Tab Bar. You can then enter the name of the TimeBlock, when you'd like it to start and end, and the category it fits into if it does fit into one. You can also set it to notify you 5 - 15 minutes before the Time Block starts. \n \n", attributes: standardText)
            attributedString.append(description)
            
            
            description = NSAttributedString(string: "Step 3: ", attributes: semiBoldText)
            attributedString.append(description)
            
            
            description = NSAttributedString(string: "You can now add that TimeBlock by tapping on the \"Plus\" icon located on the upper right of your screen. \n \n", attributes: standardText)
            attributedString.append(description)
            
            
            heading = NSAttributedString(string: "Tips \n \n ", attributes: boldText)
            attributedString.append(heading)
            
            
            description = NSAttributedString(string: "\u{2022} Try to always start of by Blocking off the times you'll spend either at work or in class. This'll give you a good idea of when you can fit in any other projects or tasks you'd like to get done that day. \n \n ", attributes: standardText)
            attributedString.append(description)
            
            
            description = NSAttributedString(string: "\u{2022} Always try to leave some time for yourself by Blocking off some personal time. \n \n ", attributes: standardText)
            attributedString.append(description)
            
            
            description = NSAttributedString(string: "\u{2022} If you have any goals you've been working on or you'd like to start working on, try Blocking off around 30 - 60 minutes a day for them. \n \n", attributes: standardText)
            attributedString.append(description)
            
            infoTextView.attributedText = attributedString
            
        case "Collab":
            
            description = NSAttributedString(string: "Basically Time Blocking... but with your friends! \n \n", attributes: standardText)
            attributedString.append(description)
            
            
            heading = NSAttributedString(string: "How To Collab \n \n", attributes: boldText)
            attributedString.append(heading)
            
            
            description = NSAttributedString(string: "Step 1: ", attributes: semiBoldText)
            attributedString.append(description)
            
            
            description = NSAttributedString(string: "To start Collaborating with your friends, start off by going to the Collab tab and registering for a Collab account. \n \n", attributes: standardText)
            attributedString.append(description)
            
            
            description = NSAttributedString(string: "Step 2: ", attributes: semiBoldText)
            attributedString.append(description)
            
            
            description = NSAttributedString(string: "After registering for an account, you should now be moved to the \"Upcoming Collabs\" View. You'll want to add some friends to Collab with, and you can that by navigating to the \"Add Friends\" View by first tapping on the \"Friends\" icon located on the upper left of your screen, and then tapping on the \"Add Friends\" icon located on the upper right of your screen. \n \n", attributes: standardText)
            attributedString.append(description)
            
            
            description = NSAttributedString(string: "Step 3: ", attributes: semiBoldText)
            attributedString.append(description)
            
            
            description = NSAttributedString(string: "You should now be on the \"Add Friends\" View. Here you can search for your friends by entering in their username, or you can accept or decline friend requests that are sent to you. \n \n", attributes: standardText)
            attributedString.append(description)
            
            
            description = NSAttributedString(string: "Step 4: ", attributes: semiBoldText)
            attributedString.append(description)
            
            
            description = NSAttributedString(string: "After sending some Friend Requests and hopefully getting accepted, or after accepting some Friend Requests sent to you, you can now start Collaborating. To do this, you can either go back to the \"Upcoming Collab\" View and tapping on the \"Plus\" icon located on the upper right corner of your screen, or you can go to the \"Friends\" View and tap on the friend you'd like to Collab with. After tapping on a friend, tap on the \"New Collab\" Button and set up a New Collab. \n \n", attributes: standardText)
            attributedString.append(description)
            
            
            description = NSAttributedString(string: "Step 5: ", attributes: semiBoldText)
            attributedString.append(description)
            
            
            description = NSAttributedString(string: "From here, it's just like Time Blocking! You can collaborate with your friends to plan out days, events, or projects together. \n \n", attributes: standardText)
            attributedString.append(description)
            
            
            description = NSAttributedString(string: "You can delete a Collab by opening the Collab that you'd like to delete and giving your phone a little shake", attributes: semiBoldText)
            attributedString.append(description)
            
            
            infoTextView.attributedText = attributedString
           
        case "Privacy Policy":
            print("ok")
            
        default:
            break
        }
    }
    
    
    @IBAction func exitButton(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
}
