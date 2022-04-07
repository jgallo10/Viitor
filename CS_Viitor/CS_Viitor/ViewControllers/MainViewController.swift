//
//  ViewController.swift
//  CS_Viitor
//
//  Created by Jason Gallo on 4/1/22.
//

import UIKit
import CoreData

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var reminders: [ReminderEntity] = []
    var index: Int = 0
    
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderCell", for: indexPath) as! ReminderTableViewCell
        cell.reminderLabel.text = reminders[indexPath.row].type
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminders.count
    }
    
    @IBAction func addReminder(_ sender: Any) {
        let newReminder = NSEntityDescription.insertNewObject(forEntityName: "ReminderEntity", into: context) as! ReminderEntity
        
        var timeComponents = DateComponents()
        timeComponents.year = 2022
        timeComponents.month = 1
        timeComponents.day = 1
        timeComponents.timeZone = TimeZone(abbreviation: "CST")
        timeComponents.hour = 0
        timeComponents.minute = 0
        let timeCalendar = Calendar(identifier: .gregorian)
        
        newReminder.type = "Medication \(reminders.count + 1)"
        newReminder.time = timeCalendar.date(from: timeComponents)
        newReminder.amount = 0
        newReminder.frequency = 0
        reminders.append(newReminder)
        do {
            try context.save()
        }
        catch{
            print(error)
        }
        self.updateData(theReminders: reminders)
    }
    
    @objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        if (gestureRecognizer.state != .began) {
                return
            }

        let p = gestureRecognizer.location(in: tableView)
        if let indexPath = tableView.indexPathForRow(at: p) {
            index = indexPath.row
            let alert = UIAlertController(title: reminders[indexPath.row].type, message: reminders[indexPath.row].time?.description, preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Edit", style: .default, handler: {_ in
                self.createCustomAlert(reminder: self.reminders[indexPath.row],index: indexPath.row)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        index = indexPath.row
        performSegue(withIdentifier: "ShowDetail", sender: self)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            do {
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
            vc.frequency = Int(reminders[index].frequency)
            vc.amount = Int(reminders[index].amount)
            vc.time = reminders[index].time!
            vc.type = reminders[index].type ?? "type was nil"
        }
    }
    
    func updateData(theReminders: [ReminderEntity]){
        self.reminders = theReminders
        tableView.reloadData()
    }


}

