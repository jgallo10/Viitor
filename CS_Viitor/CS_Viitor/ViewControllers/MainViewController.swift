//
//  ViewController.swift
//  CS_Viitor
//
//  Created by Jason Gallo on 4/1/22.
//

import UIKit
import CoreData

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, DeleteRowInTableviewDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var reminders: [ReminderEntity] = []
    var index: Int = 0
    var counter: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ReminderEntity")
        do {
            reminders = try context.fetch(fetchRequest) as! [ReminderEntity]
            updateData(theReminders: reminders)
        } catch {
            print(error)
        }
        
        let longPressedGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gestureRecognizer:)))
        longPressedGesture.minimumPressDuration = 0.5
        longPressedGesture.delegate = self
        longPressedGesture.delaysTouchesBegan = true
        tableView.addGestureRecognizer(longPressedGesture)
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateData(theReminders: reminders)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderCell", for: indexPath) as! ReminderTableViewCell
        cell.reminderLabel.text = reminders[indexPath.row].name
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(reminders.count)
        return reminders.count
    }
    
    @IBAction func addReminder(_ sender: Any) {
        let newReminder = NSEntityDescription.insertNewObject(forEntityName: "ReminderEntity", into: context) as! ReminderEntity
        let nameAlert = UIAlertController(title: "Medication", message: "Please add name of Medication", preferredStyle: .alert)
        nameAlert.addTextField(){(UITextField) in
            UITextField.placeholder = "EX: Cannabis"
        }
                
        let cancleBtn = UIAlertAction(title: "Cancle", style: .cancel)
        let saveBtn = UIAlertAction(title: "Save", style: .default){ [self]_ in
            let newName = nameAlert.textFields![0].text
            
            if (newName?.isEmpty == false){
                newReminder.name = newName
                newReminder.startDate = nil
                newReminder.endDate = nil
                newReminder.amount = 0
                newReminder.notes = nil
                newReminder.time = nil
                newReminder.id = Double.random(in: 1.278945...4.239539)
                reminders.append(newReminder)
                     
                do {try context.save()}
                catch{print(error)}
                self.updateData(theReminders: reminders)
            }
            else{
                let alert = UIAlertController(title: "Invalid Input", message: "Input is empty", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                self.present(alert, animated: true)
            }
        }
        
        nameAlert.addAction(saveBtn)
        nameAlert.addAction(cancleBtn)
        present(nameAlert, animated: true, completion: nil)
     
        
    }
    
    @objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        if (gestureRecognizer.state != .began) {
                return
            }

        let p = gestureRecognizer.location(in: tableView)
        if let indexPath = tableView.indexPathForRow(at: p) {
            index = indexPath.row
            let alert = UIAlertController(title: reminders[indexPath.row].name, message: reminders[indexPath.row].startDate?.description, preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Edit", style: .default, handler: {_ in
                self.createCustomAlert(reminder: self.reminders[indexPath.row],index: indexPath.row)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    func deleteRow(atIndex index: Int) {
        reminders.remove(at: index)
//        tableView.deleteRows(at: [IndexPath(row: rowToDelete, section: 1)], with: .fade)
        }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        index = indexPath.row
        performSegue(withIdentifier: "ShowDetail", sender: self)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            do {
                UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ["id_\(String(reminders[indexPath.row].id))"])
                context.delete(reminders[indexPath.row])
                try context.save()
            } catch{
                print(error)
            }
            self.updateData(theReminders: reminders)
            reminders.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func createCustomAlert(reminder: ReminderEntity, index: Int)
    {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let alertVC = sb.instantiateViewController(identifier: "EditReminderViewController") as! EditReminderViewController
        alertVC.parentVC = self
        alertVC.reminder = reminder
        alertVC.index = index
        alertVC.modalPresentationStyle = .overCurrentContext
        self.present(alertVC, animated: false, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "ShowDetail"){
            let vc = segue.destination as! ReminderDetailViewController
            vc.delegate = self
            vc.reminders = reminders
            vc.index = index
        }
    }
    
    func updateData(theReminders: [ReminderEntity]){
        self.reminders = theReminders
        tableView.reloadData()
    }


}

