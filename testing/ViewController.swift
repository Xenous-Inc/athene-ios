//
//  ViewController.swift
//  testing
//
//  Created by Vadim on 04/03/2019.
//  Copyright © 2019 Vadim Zaripov. All rights reserved.
//

import UIKit
import Firebase
import os

var ref: DatabaseReference!
var user_id = ""

var next_date: String = ""
var date_amounts = [0, 0, 0, 0, 0]

var archive : [String] = []

var user : User? = nil

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var edit_text: UITextField!
    @IBOutlet weak var text: UILabel!
    @IBOutlet weak var warn_text: UILabel!
    @IBOutlet weak var change_text: UIButton!
    @IBOutlet weak var submit_btn: UIButton!
    
    var english: String = "Test"
    var russian: String = "Тест"
    var state: String = ""
    
    var now_date: String = ""
    var week_date: String = ""
    var month_date: String = ""
    var three_month_date: String = ""
    var six_month_date: String = ""
    
    var archive_amount = 0
    
    let dateFormatter = DateFormatter()
    
    var amount: Int = 0
    var words: [[String]] = []
    
    var answered = false
    
    @IBAction func ChangeWord(_ sender: UIButton) {
        performSegue(withIdentifier: "move_to_change_word", sender: self)
    }
    
    @IBAction func Submit(_ sender: UIButton) {
        sender.isEnabled = false
        answered = true
        var to_move = next_date
        var to_move_state = "every_day"
        var trig = true
        var i = 0
        if (edit_text.text!) == english {
            warn_text.text = "Верно!"
            switch state{
            case "every_day":
                to_move = week_date
                i = 1
                to_move_state = "every_week"
            case "every_week":
                to_move = month_date
                i = 2
                to_move_state = "every_month"
            case "every_month":
                to_move = three_month_date
                i = 3
                to_move_state = "every_three_month"
            case "every_three_month":
                to_move = six_month_date
                i = 4
                to_move_state = "every_six_month"
            default:
                trig = false
            }
        }else{
            warn_text.text = "No, correct is \(english)"
            change_text.setTitle("Change word", for: .normal)
            change_text.isEnabled = true
        }
        if trig{
            MoveCard(state: to_move_state, english: english, russian: russian, date : to_move, amount_in_date : i)
        }else{
            MoveCardToArchive(english: english, russian: russian)
        }
    }
    @IBAction func Next(_ sender: UIButton) {
        warn_text.text = ""
        change_text.setTitle("", for: .normal)
        change_text.isEnabled = false
        if(!answered){
            MoveCard(state: "every_day", english: english, russian: russian, date: next_date, amount_in_date: 0)
        }
        if(amount < 0){
            text.text = "End of words"
            sender.isEnabled = false
            submit_btn.isEnabled = false
        }else{
            english = words[amount][0]
            russian = words[amount][1]
            state = words[amount][2]
            
            text.text = russian
            submit_btn.isEnabled = true
            
            answered = false
        }
        edit_text.text = ""
    }
    
    func MoveCard(state : String, english : String, russian : String, date : String, amount_in_date : Int){
        ref.child("words").child(now_date).child(String(amount)).removeValue()
        ref.child("words").child(date).child(String(date_amounts[amount_in_date])).child("English").setValue(english)
        ref.child("words").child(date).child(String(date_amounts[amount_in_date])).child("Russian").setValue(russian)
        ref.child("words").child(date).child(String(date_amounts[amount_in_date])).child("category").setValue(state)
        amount -= 1
        date_amounts[amount_in_date] += 1
    }
    
    func MoveCardToArchive(english : String, russian : String){
        ref.child("words").child(now_date).child(String(amount)).removeValue()
        ref.child("archive").child(String(archive_amount)).setValue("\(russian) - \(english)")
        amount -= 1
        archive_amount += 1
    }
    
    func SetDates(){
        now_date = Date().string(format: "yyyy-MM-dd")
        next_date = (Calendar.current.date(byAdding: .day, value: 1, to: Date())!).string(format: "yyyy-MM-dd")
        week_date = (Calendar.current.date(byAdding: .day, value: 7, to: Date())!).string(format: "yyyy-MM-dd")
        month_date = (Calendar.current.date(byAdding: .month, value: 1, to: Date())!).string(format: "yyyy-MM-dd")
        three_month_date = (Calendar.current.date(byAdding: .month, value: 3, to: Date())!).string(format: "yyyy-MM-dd")
        six_month_date = (Calendar.current.date(byAdding: .month, value: 6, to: Date())!).string(format: "yyyy-MM-dd")
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        
    }

    @IBAction func NewWord(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "make_new_word", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(UserDefaults.isFirstLaunch()){
            //Run tutorial
            //return
        }
        if(Auth.auth().currentUser == nil){
            os_log("Signing out...")
            DispatchQueue.main.async(){
                self.performSegue(withIdentifier: "signing_out", sender: self)
            }
            return
        }
        
        user_id = Auth.auth().currentUser!.uid
        
        archive = []
        self.edit_text.delegate = self
        SetDates()
        ref = Database.database().reference().child("users").child(user_id)
        ref.child("words").observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.amount = Int(snapshot.childSnapshot(forPath: self.now_date).childrenCount)
            date_amounts[0] = Int(snapshot.childSnapshot(forPath: next_date).childrenCount)
            date_amounts[1] = Int(snapshot.childSnapshot(forPath: self.week_date).childrenCount)
            date_amounts[2] = Int(snapshot.childSnapshot(forPath: self.month_date).childrenCount)
            date_amounts[3] = Int(snapshot.childSnapshot(forPath: self.three_month_date).childrenCount)
            date_amounts[4] = Int(snapshot.childSnapshot(forPath: self.six_month_date).childrenCount)
            
            var date: Date, count: Int
            let enumerator = snapshot.children
            var last_words :[[String]] = []
            while let snap = enumerator.nextObject() as? DataSnapshot{
                date = self.dateFormatter.date(from: snap.key)!
                count = Calendar.current.dateComponents([.day], from: date, to: Date()).day!
                if(count > 0){
                    let enumer = snap.children
                    while let ds = enumer.nextObject() as? DataSnapshot{
                        let eng = ds.childSnapshot(forPath: "English").value as? String ?? ""
                        let rus = ds.childSnapshot(forPath: "Russian").value as? String ?? ""
                        var category = ds.childSnapshot(forPath: "category").value as? String ?? ""
                        ref.child("words").child(self.now_date).child(String(self.amount)).child("English").setValue(eng)
                        ref.child("words").child(self.now_date).child(String(self.amount)).child("Russian").setValue(rus)
                        if(count >= 3 && (category == "every_week" || category == "every_month")){
                            category = "every_day"
                        }
                        ref.child("words").child(self.now_date).child(String(self.amount)).child("category").setValue(category)
                        last_words.append([eng, rus, category])
                        self.amount += 1
                    }
                    ref.child("words").child(snap.key).removeValue()
                }else if(count == 0){
                    let enumer = snap.children
                    os_log("Hello")
                    while let ds = enumer.nextObject() as? DataSnapshot{
                        let eng = ds.childSnapshot(forPath: "English").value as? String ?? ""
                        let rus = ds.childSnapshot(forPath: "Russian").value as? String ?? ""
                        let category = ds.childSnapshot(forPath: "category").value as? String ?? ""
                        self.words.append([eng, rus, category])
                    }
                }
            }
            self.amount -= 1
            if(self.amount >= 0){
                self.words.append(contentsOf : last_words)
                self.english = self.words[self.amount][0]
                self.russian = self.words[self.amount][1]
                self.state = self.words[self.amount][2]
                
                self.text.text = self.russian
            }else{
                self.edit_text.isEnabled = false
                self.text.text = "End of words"
            }
            self.change_text.isEnabled = false
        })
        
        ref.child("archive").observeSingleEvent(of: .value, with: {(snapshot) in
            self.archive_amount = Int(snapshot.childrenCount)
            let enumerator = snapshot.children
            while let snap = enumerator.nextObject() as? DataSnapshot{
                archive.append(snap.value as? String ?? "")
            }
            
        })
        
    }
    
    @IBAction func SignOut(_ sender: Any) {
        let alert = UIAlertController(title: "Signing out", message: "Do you really want to sign out?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Sign out", style: UIAlertAction.Style.default, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
            os_log("Signing out")
            do{
                try Auth.auth().signOut()
                self.performSegue(withIdentifier: "signing_out", sender: self)
            }catch _ as NSError{
                //Error
                os_log("error")
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func GoToArchive(_ sender: Any) {
        performSegue(withIdentifier: "go_to_archive", sender: self)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        edit_text.resignFirstResponder()
        return true
    }

}

extension Date {
    func string(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

extension UserDefaults{
    static func isFirstLaunch() -> Bool{
        let hasBeenLaunchedBeforeFlag = "hasBeenLaunchedBeforeFlag"
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: hasBeenLaunchedBeforeFlag)
        if (isFirstLaunch) {
            UserDefaults.standard.set(true, forKey: hasBeenLaunchedBeforeFlag)
            UserDefaults.standard.synchronize()
        }
        return isFirstLaunch
    }
}

