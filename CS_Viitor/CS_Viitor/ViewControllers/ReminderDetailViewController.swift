//
//  ReminderDetailViewController.swift
//  CS_Viitor
//
//  Created by Student Account  on 4/6/22.
//

import UIKit
import CoreData

class ReminderDetailViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var notesBox: UITextView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var amountView: UIView!
    @IBOutlet weak var startDateView: UIView!
    @IBOutlet weak var endDateView: UIView!
    @IBOutlet weak var timeView: UIView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var prevVC: MainViewController?
    var reminders: [ReminderEntity] = []
    var editBox = UITextField()
    var index: Int = 0
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateData(theReminders: reminders)
        notesBox.returnKeyType = .done
        notesBox.delegate = self
        
        
        let nameTap = UITapGestureRecognizer(target: self, action: #selector(ReminderDetailViewController.tapFunction))
        nameLabel.isUserInteractionEnabled = true
        nameLabel.addGestureRecognizer(nameTap)
        
        let amountTap = UITapGestureRecognizer(target: self, action: #selector(ReminderDetailViewController.amountFunction))
        amountView.isUserInteractionEnabled = true
        amountView.addGestureRecognizer(amountTap)
        
        let startDateTap = UITapGestureRecognizer(target: self, action: #selector(ReminderDetailViewController.dateTimeFunction))
        startDateView.isUserInteractionEnabled = true
        startDateView.addGestureRecognizer(startDateTap)
        
        let endDateTap = UITapGestureRecognizer(target: self, action: #selector(ReminderDetailViewController.dateTimeFunction))
        endDateView.isUserInteractionEnabled = true
        endDateView.addGestureRecognizer(endDateTap)
        
        let TimeTap = UITapGestureRecognizer(target: self, action: #selector(ReminderDetailViewController.dateTimeFunction))
        timeView.isUserInteractionEnabled = true
        timeView.addGestureRecognizer(TimeTap)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateData(theReminders: reminders)
    }
    
    @IBAction func dateTimeBtn(_ sender: Any) {
        performSegue(withIdentifier: "ShowCalendar", sender: self)
    }
    
    @objc func dateTimeFunction(sender: UITapGestureRecognizer){
        print("Changing date and time")
        performSegue(withIdentifier: "ShowCalendar", sender: self)
    }
    
    @IBAction func deleteBtn(_ sender: Any) {
        do {
            context.delete(reminders[index])
            try context.save()
        }
        catch{print(error)
        }
        
        //delete the row in MainViewController here
        _ = navigationController?.popViewController(animated: true)
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
                reminders[index].name = inputName
                
                do {try context.save()}
                catch{print(error)}
                updateData(theReminders: reminders)
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
                reminders[index].amount = Double(inputAmount!)!
                
                do {try context.save()}
                catch{print(error)}
                updateData(theReminders: reminders)
            }
            else{
                invalidInput()
            }
        }
        
        alertController.addAction(cancleAction)
        alertController.addAction(saveAction)
        
        present(alertController, animated: true, completion: nil)
        }
    
//    func saveGo(){
//        reminders[index].notes = notesBox.text
//        do{ try context.save()}
//        catch{print(error)}
//        performSegue(withIdentifier: "ShowCalendar", sender: self)
//    }
    
    func invalidInput(){
        let alert = UIAlertController(title: "Invalid Input", message: "Input is empty", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Got It", style: .cancel))
        self.present(alert, animated: true)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.white{
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "/n" {
            textView.resignFirstResponder()
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView){
            if textView.text == ""{
                textView.text = "Add Notes Here"
                textView.textColor = UIColor.white
            }else{
                reminders[index].notes = textView.text
                do{ try context.save()}
                catch{print(error)}
                updateData(theReminders: reminders)
            }
        }
    
    func updateData(theReminders: [ReminderEntity]){
        do {
            try context.save()
        }
        catch {
            print(error)
        }
        
        let dateForm = DateFormatter()
        let timeForm = DateFormatter()
        dateForm.dateFormat = "yyyy/MM/dd"// hh:mm a Z"
        timeForm.dateFormat = "hh:mm a z"
        timeForm.timeZone = TimeZone(abbreviation: "CST")
        
        nameLabel.text = reminders[index].name
        amountLabel.text = String(reminders[index].amount)
        
        if reminders[index].startDate == nil {
            startDateLabel.text = "N/A"
        } else {
            startDateLabel.text = dateForm.string(for: reminders[index].startDate)
        }
        if reminders[index].endDate == nil {
            endDateLabel.text = "N/A"
        } else {
            endDateLabel.text = dateForm.string(for: reminders[index].endDate)
        }
        if reminders[index].time == nil{
            timeLabel.text = "N/A"
        }else {
            timeLabel.text = timeForm.string(from: reminders[index].time!)
        }
        if reminders[index].notes != nil {
            notesBox.text = reminders[index].notes
        }
        else {
            notesBox.text = "Add Notes Here"
            notesBox.textColor = UIColor.white
            
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
