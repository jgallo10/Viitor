//
//  EditReminderViewController.swift
//  CS_Viitor
//
//  Created by Student Account  on 4/7/22.
//

import UIKit
import CoreData

class EditReminderViewController: UIViewController {
    
    @IBOutlet var alertView: UIView!
    @IBOutlet var nameEditText: UITextField!
    @IBOutlet var amountEditText: UITextField!
    
    var reminder: ReminderEntity = ReminderEntity()
    var index: Int = Int()
    var parentVC: MainViewController?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setup()
    }
    
    func setup(){
        alertView.layer.cornerRadius = 8.0
        nameEditText.placeholder = reminder.name
        amountEditText.placeholder = String(reminder.amount)
        nameEditText.becomeFirstResponder()
    }
    
    @IBAction func doneEditing(_ sender: Any) {
        let a = amountEditText.text!
        let b = Double(a) ?? -1
        if(nameEditText.text?.isEmpty == false && amountEditText.text?.isEmpty == false && b >= 0){
            
            self.dismiss(animated: false, completion: {
            })
            
            reminder.name = nameEditText.text
            reminder.amount = b
            
            do {
                try context.save()
            }
            catch {
                print(error)
            }
            parentVC?.tableView.reloadData()
        }
        else{
            let alert = UIAlertController(title: "Invalid Input", message: "Fields must not be empty. Make sure the amount is a number greater than or equal to 0", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
            self.present(alert, animated: true)
        }
    }
    
    @IBAction func cancelEditing(_ sender: Any) {
        self.dismiss(animated: false, completion: {
        })
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
