//
//  ReminderDetailViewController.swift
//  CS_Viitor
//
//  Created by Student Account  on 4/6/22.
//

import UIKit

class ReminderDetailViewController: UIViewController {
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var frequencyLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    var type = "nil"
    var frequency = 1000
    var time = Date.now
    var amount = 1000
    var index: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        typeLabel.text = type
        frequencyLabel.text = String(frequency)
        timeLabel.text = time.description
        amountLabel.text = String(amount)

        // Do any additional setup after loading the view.
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
