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

    var edit_text: UITextField!
    var text: UITextField!
    var submit_btn: UIButton!
    var forgot_btn: UIButton!
    
    var now_date: String = ""
    var week_date: String = ""
    var month_date: String = ""
    var three_month_date: String = ""
    var six_month_date: String = ""
    
    var archive_amount = 0
    
    let dateFormatter = DateFormatter()
    
    var answered = false
    
    
    func ChangeWord(_ sender: UIButton) {
        performSegue(withIdentifier: "move_to_change_word", sender: self)
    }
    
    @objc func next_btn_pressed(_ sender: Any){
        if(answered){
            Next(sender)
        }else{
            Submit()
        }
    }
    
    var deadline = DispatchTime.now()
    func Submit() {
        answered = true
        var to_move = next_date
        var trig = true
        var new_lvl = words[current].level + 1
        deadline = .now()
        if (edit_text.text!) == words[current].english {
            (view.viewWithTag(101) as? UIImageView)?.tintColor = UIColor.init(rgb: green_clr)
            edit_text.textColor = UIColor.init(rgb: green_clr)
            deadline = .now() + 0.7
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
            animateIncorrectAnswer()
            //warn_text.text = "No, correct is \(words[current].english)"
            //change_text.setTitle("Change word", for: .normal)
            //change_text.isEnabled = true
        }
        if trig{
            UpdateCard(ind: words[current].db_index, date: to_move, level: new_lvl)
        }else{
            MoveCardToArchive(ind: words[current].db_index)
        }
        current += 1
    }
    
    func animateIncorrectAnswer(){
        let oldValue = submit_btn.layer.cornerRadius
        let new_height = 2*submit_btn.bounds.height
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.4)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeInEaseOut))
        
        UIView.animate(withDuration: 0.4, animations: {
            self.submit_btn.bounds = CGRect(x: 0, y: 0, width: 2*self.submit_btn.bounds.height, height: new_height)
            self.submit_btn.center = CGPoint(x: self.view.frame.width / 2, y: 0.9*self.view.frame.height - self.submit_btn.bounds.height / 2)
            let img = self.view.viewWithTag(101)!
            img.center = self.submit_btn.center
            img.bounds = CGRect(x: 0, y: 0, width: 0.5*self.submit_btn.bounds.width, height: img.bounds.height)
            let d = self.view.viewWithTag(102) as! UILabel
            d.center = CGPoint(x: self.view.center.x, y: self.submit_btn.frame.maxY + d.bounds.height)
            d.text = main_page_next_text
            for i in self.view.subviews{
                if([201, 202].contains(i.tag)){
                    i.alpha = 0.8
                }else if(i.tag >= 200){
                    i.alpha = 1
                    if([205, 206].contains(i.tag)){i.isUserInteractionEnabled = true}
                }else if([0, 103].contains(i.tag)){
                    i.alpha = 0
                    i.isUserInteractionEnabled = false
                }
            }
        })
               
        let cornerAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.cornerRadius))
        cornerAnimation.fromValue = oldValue
        cornerAnimation.toValue = new_height / 2
        submit_btn.layer.cornerRadius = new_height / 2
        submit_btn.layer.add(cornerAnimation, forKey: #keyPath(CALayer.cornerRadius))

        CATransaction.commit()
    }
    
    @objc func Next(_ sender: Any) {
        //warn_text.text = ""
        //change_text.setTitle("", for: .normal)
        //change_text.isEnabled = false
        if(!answered){
            UpdateCard(ind: words[current].db_index, date: next_date, level: 0)
            current += 1
        }
        if(current >= words.count){
            text.text = "End of words"
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
        resetTint()
    }
    
    func MoveCardToArchive(ind: Int){
        ref.child("words").child(String(ind)).child("level").setValue(-1)
        resetTint()
    }
    
    @objc func resetTint(){
        DispatchQueue.main.asyncAfter(deadline: deadline, execute: {
            (self.view.viewWithTag(101) as? UIImageView)?.tintColor = UIColor.white
            self.edit_text.textColor = UIColor.white
            self.Next(self)
        })
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gb = GraphicBuilder(width: view.frame.size.width, height: view.frame.size.height)
        view = gb.buildMainView()
        edit_text = view.viewWithTag(2) as? UITextField
        text = view.viewWithTag(1) as? UITextField
        submit_btn = view.viewWithTag(100) as? UIButton
        submit_btn.addTarget(self, action: #selector(next_btn_pressed(_:)), for: .touchUpInside)
        forgot_btn = view.viewWithTag(103) as? UIButton
        forgot_btn.addTarget(self, action: #selector(Next(_:)), for: .touchUpInside)
        
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
        })
    }
    
    func SignOut(_ sender: Any) {
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
    
    func GoToArchive(_ sender: Any) {
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
