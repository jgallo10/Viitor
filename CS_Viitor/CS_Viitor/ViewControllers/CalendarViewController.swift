//
//  CalendarViewController.swift
//  CS_Viitor
//
//  Created by user217486 on 4/12/22.
//

import FSCalendar
import UIKit
import CoreData
import UserNotifications

class CalendarViewController: UIViewController, FSCalendarDelegate {
    
    @IBOutlet var calendar: FSCalendar!
    @IBOutlet var timePicker: UIDatePicker!
    @IBOutlet var switchStatus: UISwitch!
    var firstDate: Date?
    var lastDate: Date?
    var datesRange: [Date]?
    let calendarComponent = Calendar.current
    var startDateComponents = DateComponents()
    let endDateComponents = DateComponents()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var reminders: [ReminderEntity] = []
    var index: Int = 0


    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.delegate = self
        calendar.allowsMultipleSelection = true

        // Do any additional setup after loading the view.
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        // nothing selected:
        if firstDate == nil {
            firstDate = date
            datesRange = [firstDate!]

            print("datesRange contains: \(datesRange!)")

            return
        }

        // only first date is selected:
        if firstDate != nil && lastDate == nil {
            // handle the case of if the last date is less than the first date:
            if date <= firstDate! {
                calendar.deselect(firstDate!)
                firstDate = date
                datesRange = [firstDate!]

                print("datesRange contains: \(datesRange!)")

                return
            }

            let range = datesRange(from: firstDate!, to: date)
            lastDate = range.last

            for d in range {
                calendar.select(d)
            }

            datesRange = range

            print("datesRange contains: \(datesRange!)")

            return
        }

        // both are selected:
        if firstDate != nil && lastDate != nil {
            for d in calendar.selectedDates {
                calendar.deselect(d)
            }

            lastDate = nil
            firstDate = nil

            datesRange = []

            print("datesRange contains: \(datesRange!)")
        }
    }

    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        // both are selected:

        // NOTE: the is a REDUANDENT CODE:
        if firstDate != nil && lastDate != nil {
            for d in calendar.selectedDates {
                calendar.deselect(d)
            }

            lastDate = nil
            firstDate = nil

            datesRange = []
            print("datesRange contains: \(datesRange!)")
        }
    }
    
    func datesRange(from: Date, to: Date) -> [Date] {
        // in case of the "from" date is more than "to" date,
        // it should returns an empty array:
        if from > to { return [Date]() }

        var tempDate = from
        var array = [tempDate]

        while tempDate < to {
            tempDate = Calendar.current.date(byAdding: .day, value: 1, to: tempDate)!
            array.append(tempDate)
        }

        return array
    }

    @IBAction func doneEditing(_ sender: Any) {
        if firstDate != nil{
            
            formatDate()
            scheduleNotification()
            
            do {
                try context.save()
            }
            catch {
                print(error)
            }
        }else if switchStatus.isOn == true{
            formatDate()
            scheduleNotification()
            
            do {
                try context.save()
            }
            catch {
                print(error)
            }
        }
        _ = navigationController?.popViewController(animated: true)
    }
    
    func scheduleNotification(){
        formatDateComponents()
        
        let content = UNMutableNotificationContent()
        content.title = reminders[index].name!
        content.sound = .defaultCritical
        content.body = "\(reminders[index].name ?? "Default") Reminder"
        content.badge = NSNumber(value: 3)
        print(content.body)
        
        if switchStatus.isOn == false {
            var i = 0
            let range = datesRange(from: firstDate!, to: lastDate ?? firstDate!)

            for d in range {
                let trigger = UNCalendarNotificationTrigger(dateMatching: startDateComponents, repeats: false)
                
                let request = UNNotificationRequest(identifier: "id_\(String(reminders[index].id))_\(String(i))", content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
                    if error != nil {
                        print("something went wrong with normal notification")
                    }
                })
                
                startDateComponents.day! += 1
                i += 1
                
                
            }
        } else if switchStatus.isOn == true {
            let trigger = UNCalendarNotificationTrigger(dateMatching: startDateComponents, repeats: true)
            
            let request = UNNotificationRequest(identifier: "id_\(String(reminders[index].id))", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
                if error != nil {
                    print("something went wrong with repeating notification")
                }
            })
        }
    }
    
    func formatDate(){
        reminders[index].startDate = firstDate ?? calendar.today
        reminders[index].endDate = lastDate ?? nil
        
        if switchStatus.isOn == true {
            reminders[index].endDate = nil
        }
        
        let formatter1 = DateFormatter()
        formatter1.timeStyle = .none
        
        let formatter2 = DateFormatter()
        formatter2.dateStyle = .none
        
        let formatter = DateFormatter()
        
        formatter1.dateFormat = "yyyy/MM/dd"
        formatter1.timeZone = TimeZone(abbreviation: "CST")
        formatter2.dateFormat = "hh:mm a Z"
        formatter2.timeZone = TimeZone(abbreviation: "CST")
        formatter.dateFormat = "yyyy/MM/dd hh:mm a Z"
        formatter.timeZone = TimeZone(abbreviation: "CST")
        
        let startDateString: String = "\(formatter1.string(from: reminders[index].startDate!)) \(formatter2.string(from: timePicker.date))"
        if reminders[index].endDate != nil {
            let endDateString: String = "\(formatter1.string(from: reminders[index].endDate!)) \(formatter2.string(from: timePicker.date))"
            reminders[index].endDate = formatter.date(from: endDateString)
        }
        
        reminders[index].startDate = formatter.date(from: startDateString)
        
        reminders[index].time = formatter.date(from: startDateString)
        
    }
    
    func formatDateComponents(){
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd hh:mm a Z"
        formatter.timeZone = TimeZone(abbreviation: "CST")
        
        var startString = formatter.string(for: reminders[index].startDate)
        var begin = (startString?.index(startString!.startIndex, offsetBy: 0))!
        var end = (startString?.index(startString!.startIndex, offsetBy: 4))!
        var range = begin..<end
        let year = Int(String(startString![range]))
        
        begin = (startString?.index(startString!.startIndex, offsetBy: 5))!
        end = (startString?.index(startString!.startIndex, offsetBy: 7))!
        range = begin..<end
        let month = Int(String(startString![range]))
        
        begin = (startString?.index(startString!.startIndex, offsetBy: 8))!
        end = (startString?.index(startString!.startIndex, offsetBy: 10))!
        range = begin..<end
        let day = Int(String(startString![range]))
        
        begin = (startString?.index(startString!.startIndex, offsetBy: 11))!
        end = (startString?.index(startString!.startIndex, offsetBy: 13))!
        range = begin..<end
        let hour = Int(String(startString![range]))
        
        begin = (startString?.index(startString!.startIndex, offsetBy: 14))!
        end = (startString?.index(startString!.startIndex, offsetBy: 16))!
        range = begin..<end
        let minute = Int(String(startString![range]))
        
        startDateComponents = DateComponents(calendar: calendarComponent, timeZone: TimeZone(abbreviation: "CST"), year: year, month: month, day: day, hour: hour, minute: minute)
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
