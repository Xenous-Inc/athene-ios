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

var now_date: String = ""
var week_date: String = ""
var month_date: String = ""
var three_month_date: String = ""
var six_month_date: String = ""

class ViewController: UIViewController, UITextFieldDelegate {

    var edit_text: UITextField!
    var text: UITextField!
    var submit_btn: UIButton!
    var forgot_btn: UIButton!
    
    var archive_amount = 0
    
    let dateFormatter = DateFormatter()
    
    var answering = true
    
    var submit_btn_old_frame = CGRect()
    
    var frame: CGRect? = nil
    
    init(frame: CGRect)   {
        print("init nibName style")
        super.init(nibName: nil, bundle: nil)
        self.frame = frame
    }

    // note slightly new syntax for 2017
    required init?(coder aDecoder: NSCoder) {
        print("init coder style")
        super.init(coder: aDecoder)
        
    }
    
    //Navigation
    
    @objc func next_btn_pressed(_ sender: UIButton){
        if(text.text! == end_of_words_text || text.text! == no_words_for_today){return}
        submit_btn.isEnabled = false
        forgot_btn.isEnabled = false
        if(answering){
            Submit(sender: sender.tag)
        }else{
            Next()
        }
    }
    
    var deadline = DispatchTime.now()
    func Submit(sender: Int) {
        guard let eng = edit_text.text?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        deadline = .now()
        if (sender == submit_btn.tag) && (eng == words[current].english.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)) {
            (view.viewWithTag(101) as? UIImageView)?.tintColor = UIColor.init(rgb: green_clr)
            edit_text.textColor = UIColor.init(rgb: green_clr)
            deadline = .now() + 0.9
            switch words[current].level{
            case 0:
                UpdateCard(ind: words[current].db_index, date: week_date, level: words[current].level + 1)
            case 1:
                UpdateCard(ind: words[current].db_index, date: month_date, level: words[current].level + 1)
            case 2:
                UpdateCard(ind: words[current].db_index, date: three_month_date, level: words[current].level + 1)
            case 3:
                UpdateCard(ind: words[current].db_index, date: six_month_date, level: words[current].level + 1)
            default:
                MoveCardToArchive(ind: words[current].db_index)
            }
            resetTint()
        }else{
            answering = false
            UpdateCard(ind: words[current].db_index, date: next_date, level: 0)
            animateIncorrectAnswer(ans: edit_text.text!, correct: words[current].english, status: sender)
        }
        current += 1
    }
    
    @objc func Next() {
        if(answering == false){
            answering = true
            animateNextWord()
        }
        if(current >= words.count){
            text.text = end_of_words_text
            submit_btn.isEnabled = false
            forgot_btn.isEnabled = false
        }else{
            text.text = words[current].russian
            submit_btn.isEnabled = true
            forgot_btn.isEnabled = true
        }
        edit_text.text = ""
    }
    
    //Graphics
    
    func animateIncorrectAnswer(ans: String, correct: String, status: Int){
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
            if(status == self.submit_btn.tag){
                self.text.text = ans
                self.text.textColor = UIColor.magenta
            }
            self.edit_text.text = correct
            self.edit_text.textColor = UIColor.init(rgb: green_clr)
            self.edit_text.isUserInteractionEnabled = false
        }, completion: {(finished: Bool) in
            self.submit_btn.isEnabled = true
        })
        
        let cornerAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.cornerRadius))
        cornerAnimation.fromValue = oldValue
        cornerAnimation.toValue = new_height / 2
        submit_btn.layer.cornerRadius = new_height / 2
        submit_btn.layer.add(cornerAnimation, forKey: #keyPath(CALayer.cornerRadius))

        CATransaction.commit()
    }
    
    func animateNextWord(){
        let oldValue = submit_btn.layer.cornerRadius
        let new_height = submit_btn.bounds.height / 2
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.4)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeInEaseOut))
        
        UIView.animate(withDuration: 0.4, animations: {
            self.submit_btn.frame = self.submit_btn_old_frame
            let img = self.view.viewWithTag(101)!
            img.center = self.submit_btn.center
            img.bounds = CGRect(x: 0, y: 0, width: 0.33*self.submit_btn.bounds.width, height: img.bounds.height)
            let d = self.view.viewWithTag(102) as! UILabel
            d.center = CGPoint(x: self.view.center.x, y: self.submit_btn.frame.maxY + d.bounds.height)
            d.text = main_page_describtion_check
            for i in self.view.subviews{
                if(i.tag >= 200){
                    i.alpha = 0
                    i.isUserInteractionEnabled = false
                }else if([0, 103].contains(i.tag)){
                    i.alpha = 1
                    if(i.tag == 103){i.isUserInteractionEnabled = true}
                }
            }
            self.text.textColor = UIColor.white
            self.edit_text.text = ""
            self.edit_text.textColor = UIColor.white
            self.edit_text.isUserInteractionEnabled = true
        })
               
        let cornerAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.cornerRadius))
        cornerAnimation.fromValue = oldValue
        cornerAnimation.toValue = new_height / 2
        submit_btn.layer.cornerRadius = new_height / 2
        submit_btn.layer.add(cornerAnimation, forKey: #keyPath(CALayer.cornerRadius))

        CATransaction.commit()
    }
    
    @objc func resetTint(){
        DispatchQueue.main.asyncAfter(deadline: deadline, execute: {
            (self.view.viewWithTag(101) as? UIImageView)?.tintColor = UIColor.white
            self.edit_text.textColor = UIColor.white
            self.Next()
        })
    }
    
    //Database
    
    func UpdateCard(ind: Int, date: String, level: Int){
        ref.child("words").child(String(ind)).child("date").setValue(date)
        ref.child("words").child(String(ind)).child("level").setValue(level)
    }
    
    func MoveCardToArchive(ind: Int){
        ref.child("words").child(String(ind)).child("level").setValue(-1)
    }
    
    @objc func Delete(_ sender: Any) {
        let alert = UIAlertController(title: delete_alert_question, message: delete_alert_warning, preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: delete_alert_delete, style: UIAlertAction.Style.default, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
            current -= 1
            let ind = words[current].db_index
            number_of_words -= 1
            ref.child("words").observeSingleEvent(of: .value, with: { (snap) in
                let last = snap.childrenCount - 1
                ref.child("words").child(String(ind)).child("English").setValue(snap.childSnapshot(forPath: String(last)).childSnapshot(forPath: "English").value)
                ref.child("words").child(String(ind)).child("Russian").setValue(snap.childSnapshot(forPath: String(last)).childSnapshot(forPath: "Russian").value)
                ref.child("words").child(String(ind)).child("date").setValue(snap.childSnapshot(forPath: String(last)).childSnapshot(forPath: "date").value)
                ref.child("words").child(String(ind)).child("level").setValue(snap.childSnapshot(forPath: String(last)).childSnapshot(forPath: "level").value)
                ref.child("words").child(String(ind)).child("category").setValue(snap.childSnapshot(forPath: String(last)).childSnapshot(forPath: "category").value)
                
                for i in words{
                    if(i.db_index == last){
                        i.db_index = ind
                        break
                    }
                }
                
                words.remove(at: current)
                
                ref.child("words").child(String(last)).removeValue()
                
                self.Next()
            })
        }))
        
        alert.addAction(UIAlertAction(title: delete_alert_cancel, style: UIAlertAction.Style.default, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(frame != nil){
            view.frame = frame!
        }
        let gb = GraphicBuilder(width: view.frame.size.width, height: view.frame.size.height)
        view = gb.buildMainView()
        edit_text = view.viewWithTag(2) as? UITextField
        text = view.viewWithTag(1) as? UITextField
        submit_btn = view.viewWithTag(100) as? UIButton
        submit_btn_old_frame = submit_btn.frame
        submit_btn.addTarget(self, action: #selector(next_btn_pressed(_:)), for: .touchUpInside)
        forgot_btn = view.viewWithTag(103) as? UIButton
        forgot_btn.addTarget(self, action: #selector(next_btn_pressed(_:)), for: .touchUpInside)
        
        (view.viewWithTag(206) as! UIButton).addTarget(self, action: #selector(Delete(_:)), for: .touchUpInside)
        (view.viewWithTag(205) as! UIButton).addTarget(self, action: #selector(ChangeWord(_:)), for: .touchUpInside)
        
        self.edit_text.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("View will appear reached")
        checkWordsUpdate()
    }
    
    func checkWordsUpdate(){
        if(current < words.count){
            self.text.text = words[current].russian
            self.submit_btn.isEnabled = true
            self.forgot_btn.isEnabled = true
        }else{
            self.text.text = no_words_for_today
            submit_btn.isEnabled = false
            forgot_btn.isEnabled = false
        }
    }
    
    @objc func ChangeWord(_ sender: UIButton) {
        main_vc.performSegue(withIdentifier: "create_word_segue", sender: main_vc)
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
