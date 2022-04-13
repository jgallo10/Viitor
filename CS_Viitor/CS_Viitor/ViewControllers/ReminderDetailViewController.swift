//
//  ReminderDetailViewController.swift
//  CS_Viitor
//
//  Created by Student Account  on 4/6/22.
//

import UIKit
import CoreData

class ReminderDetailViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var prevVC: MainViewController?

    var reminders: [ReminderEntity] = []
    var index: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateData(theReminders: reminders)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateData(theReminders: reminders)
    }
    
    func updateData(theReminders: [ReminderEntity]){
        do {
            try context.save()
        }
        catch {
            print(error)
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd hh:mm a Z"
        formatter.timeZone = TimeZone(abbreviation: "CST")
        
        nameLabel.text = reminders[index].name
        amountLabel.text = String(reminders[index].amount)
        
        if reminders[index].startDate == nil {
            startDateLabel.text = "Date Not Set"
        } else {
            startDateLabel.text = formatter.string(for: reminders[index].startDate)
        }
        if reminders[index].endDate == nil {
            endDateLabel.text = "N/A"
        } else {
            endDateLabel.text = formatter.string(for: reminders[index].endDate)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "ShowCalendar"){
            let vc = segue.destination as! CalendarViewController
            vc.reminders = reminders
            vc.index = index
            
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
