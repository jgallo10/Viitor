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
    @IBOutlet weak var notesBox: UITextView!
    @IBOutlet weak var timeLabel: UILabel!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var prevVC: MainViewController?
    var reminders: [ReminderEntity] = []
    var changeReminder: ReminderEntity = ReminderEntity()
    var editBox = UITextField()
    var index: Int = 0
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateData(theReminders: reminders)
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ReminderDetailViewController.tapFunction))
        nameLabel.isUserInteractionEnabled = true
        nameLabel.addGestureRecognizer(tap)
        
        let amountTap = UITapGestureRecognizer(target: self, action: #selector(ReminderDetailViewController.amountFunction))
        amountLabel.isUserInteractionEnabled = true
        amountLabel.addGestureRecognizer(amountTap)
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateData(theReminders: reminders)
    }
    
    @objc func tapFunction(sender: UITapGestureRecognizer) {
        print("tap working")
        let alertController = UIAlertController(title: "Edit Medication", message: "Enter the name of the medication", preferredStyle: .alert)
        alertController.addTextField(){ (UITextField) in
            UITextField.placeholder = "Enter Medication"
        }
        
        let cancleAction = UIAlertAction(title: "Cancle", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Save", style: .default){ [self]_ in
            let inputName = alertController.textFields![0].text
            
            if (inputName?.isEmpty == false){
                self.changeReminder.name = inputName
                
                do {try context.save()}
                catch{print(error)}
            }
            else{
                invalidInput()
            }
        }
        
        alertController.addAction(cancleAction)
        alertController.addAction(saveAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func amountFunction(sender: UITapGestureRecognizer){
        print("amount tap works")
        let alertController = UIAlertController(title: "Edit Quantity", message: "Enter the amount given", preferredStyle: .alert)
        alertController.addTextField(){ (UITextField) in
            UITextField.placeholder = "Enter Amount"
        }
        
        let cancleAction = UIAlertAction(title: "Cancle", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Save", style: .default){ [self]_ in
            let inputAmount = alertController.textFields![0].text
            let numD = Double(inputAmount ?? "-1")
            
            if (inputAmount?.isEmpty == false && numD! > 0){
                self.changeReminder.amount = Double(inputAmount!)!
                
                do {try context.save()}
                catch{print(error)}
            }
            else{
                invalidInput()
            }
        }
        
        alertController.addAction(cancleAction)
        alertController.addAction(saveAction)
        
        present(alertController, animated: true, completion: nil)
        }
    
    func invalidInput(){
        let alert = UIAlertController(title: "Invalid Input", message: "Input is empty", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Got It", style: .cancel))
        self.present(alert, animated: true)
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


}
