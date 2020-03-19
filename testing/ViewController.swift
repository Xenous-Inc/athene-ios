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
var number_of_words = 0

var archive : [Word] = []

var current: Int = 0;
var words: [Word] = []

var user : User? = nil

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var edit_text: UITextField!
    @IBOutlet weak var text: UILabel!
    @IBOutlet weak var warn_text: UILabel!
    @IBOutlet weak var change_text: UIButton!
    @IBOutlet weak var submit_btn: UIButton!
    
    var now_date: String = ""
    var week_date: String = ""
    var month_date: String = ""
    var three_month_date: String = ""
    var six_month_date: String = ""
    
    var archive_amount = 0
    
    let dateFormatter = DateFormatter()
    
    var answered = false
    
    @IBAction func ChangeWord(_ sender: UIButton) {
        performSegue(withIdentifier: "move_to_change_word", sender: self)
    }
    
    @IBAction func Submit(_ sender: UIButton) {
        sender.isEnabled = false
        answered = true
        var to_move = next_date
        var trig = true
        var new_lvl = words[current].level + 1
        if (edit_text.text!) == words[current].english {
            warn_text.text = "Верно!"
            switch words[current].level{
            case 0:
                to_move = week_date
            case 1:
                to_move = month_date
            case 2:
                to_move = three_month_date
            case 3:
                to_move = six_month_date
            default:
                trig = false
            }
        }else{
            new_lvl = 0
            warn_text.text = "No, correct is \(words[current].english)"
            change_text.setTitle("Change word", for: .normal)
            change_text.isEnabled = true
        }
        if trig{
            UpdateCard(ind: words[current].db_index, date: to_move, level: new_lvl)
        }else{
            MoveCardToArchive(ind: words[current].db_index)
        }
        current += 1
    }
    
    @IBAction func Next(_ sender: UIButton) {
        warn_text.text = ""
        change_text.setTitle("", for: .normal)
        change_text.isEnabled = false
        if(!answered){
            UpdateCard(ind: words[current].db_index, date: next_date, level: 0)
            current += 1
        }
        if(current >= words.count){
            text.text = "End of words"
            sender.isEnabled = false
            submit_btn.isEnabled = false
        }else{
            text.text = words[current].russian
            submit_btn.isEnabled = true
            
            answered = false
        }
        edit_text.text = ""
    }
    
    func UpdateCard(ind: Int, date: String, level: Int){
        ref.child("words").child(String(ind)).child("date").setValue(date)
        ref.child("words").child(String(ind)).child("level").setValue(level)
    }
    
    func MoveCardToArchive(ind: Int){
        ref.child("words").child(String(ind)).child("level").setValue(-1)
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
        words = []
        current = 0
        self.edit_text.delegate = self
        number_of_words = 0
        SetDates()
        ref = Database.database().reference().child("users").child(user_id)
        ref.child("words").observeSingleEvent(of: .value, with: { (snapshot) in
            
            number_of_words = Int(snapshot.childrenCount)
            var date: Date, count: Int, trig: Bool = false
            let enumerator = snapshot.children
            var last_words :[Word] = []
            while let snap = enumerator.nextObject() as? DataSnapshot{
                date = self.dateFormatter.date(from: snap.childSnapshot(forPath: "date").value as? String ?? "")!
                let n_date = self.dateFormatter.date(from: self.now_date)!
                count = Calendar.current.dateComponents([.day], from: date, to: n_date).day!
                let eng = snap.childSnapshot(forPath: "English").value as? String ?? ""
                let rus = snap.childSnapshot(forPath: "Russian").value as? String ?? ""
                let category = snap.childSnapshot(forPath: "category").value as? String ?? ""
                var level = snap.childSnapshot(forPath: "category").value as? Int ?? 0
                if(level == -1){
                    archive.append(Word(eng: eng, rus: rus, ct: category, lvl: -1, ind: Int(snap.key)!))
                }else if(count > 0){
                    trig = true
                    ref.child("words").child(snap.key).child("date").setValue(self.now_date)
                    if(count >= 3 && (level == 1 || level == 2)){
                        level = 0
                    }
                    ref.child("words").child(snap.key).child("level").setValue(level)
                    last_words.append(Word(eng: eng, rus: rus, ct: category, lvl: level, ind: Int(snap.key)!))
                }else if(count == 0){
                    os_log("Hello")
                    trig = true
                    words.append(Word(eng: eng, rus: rus, ct: category, lvl: level, ind: Int(snap.key)!))
                }
            }
            if(trig){
                words.append(contentsOf : last_words)
                
                self.text.text = words[current].russian
            }else{
                self.edit_text.isEnabled = false
                self.text.text = "End of words"
            }
            self.change_text.isEnabled = false
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

