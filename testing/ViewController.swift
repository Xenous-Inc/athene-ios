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

var next_date: Date = Date()
var number_of_words = 0

var archive : [Word] = []

var words: [Word] = []

var user : User? = nil

var now_date: Date = Date()
var week_date: Date = Date()
var month_date: Date = Date()
var three_month_date: Date = Date()
var six_month_date: Date = Date()

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

    required init?(coder aDecoder: NSCoder) {
        print("init coder style")
        super.init(coder: aDecoder)
        
    }
    
    //Navigation
    
    @objc func next_btn_pressed(_ sender: UIButton){
        if(words.count == 0){return}
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
        if (sender == submit_btn.tag && (edit_text.text == "" || edit_text.text == " ")){
            messageAlert(vc: self, message: message_no_word, text_error: alert_no_word_description)
            submit_btn.isEnabled = true
            forgot_btn.isEnabled = true
            return
        }
        guard let eng = edit_text.text?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        deadline = .now()
        if (sender == submit_btn.tag) && (eng == words[0].english.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)) {
            (view.viewWithTag(101) as? UIImageView)?.tintColor = UIColor.init(rgb: green_clr)
            edit_text.textColor = UIColor.init(rgb: green_clr)
            deadline = .now() + 0.9
            switch words[0].level{
            case 0:
                UpdateCard(ind: words[0].db_index, date: week_date, level: words[0].level + 1)
            case 1:
                UpdateCard(ind: words[0].db_index, date: month_date, level: words[0].level + 1)
            case 2:
                UpdateCard(ind: words[0].db_index, date: three_month_date, level: words[0].level + 1)
            case 3:
                UpdateCard(ind: words[0].db_index, date: six_month_date, level: words[0].level + 1)
            default:
                MoveCardToArchive(ind: words[0].db_index)
            }
            resetTint()
        }else{
            answering = false
            UpdateCard(ind: words[0].db_index, date: next_date, level: 0)
            animateIncorrectAnswer(ans: edit_text.text!, correct: words[0].english, status: sender)
        }
    }
    
    @objc func Next() {
        words.remove(at: 0)
        if(answering == false){
            answering = true
            animateNextWord()
        }
        if(words.count == 0){
            contentView.removeFromSuperview()
            view.addSubview(endOfWordsView)
            endOfWordsView.text = end_of_words_text
            main_vc.cheerView.start()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                main_vc.cheerView.stop()
            }
        }else{
            text.text = words[0].russian
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
            for i in self.contentView.subviews{
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
            for i in self.contentView.subviews{
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
    
    func UpdateCard(ind: Int, date: Date, level: Int){
        ref.child("words").child(String(ind)).child("date").setValue(date.toDatabaseFormat())
        ref.child("words").child(String(ind)).child("level").setValue(level)
    }
    
    func MoveCardToArchive(ind: Int){
        ref.child("words").child(String(ind)).child("level").setValue(-1)
    }
    
    @objc func Delete(_ sender: Any) {
        let alert = UIAlertController(title: delete_alert_question, message: delete_alert_warning, preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: delete_alert_delete, style: UIAlertAction.Style.default, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
            let ind = words[0].db_index
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
                
                ref.child("words").child(String(last)).removeValue()
                
                self.Next()
            })
        }))
        
        alert.addAction(UIAlertAction(title: delete_alert_cancel, style: UIAlertAction.Style.default, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    var contentView = MainView(frame: CGRect.init(x: 0, y: 0, width: 1, height: 1))
    var endOfWordsView = UILabel()
    override func viewDidLoad() {
        super.viewDidLoad()
        if(frame != nil){
            view.frame = frame!
        }
        contentView = MainView(frame: view.frame)
        contentView.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
        view.addSubview(contentView)
        
        edit_text = contentView.editTextSecond
        text = contentView.editTextFirst
        
        submit_btn = contentView.nextButton
        submit_btn_old_frame = submit_btn.frame
        submit_btn.addTarget(self, action: #selector(next_btn_pressed(_:)), for: .touchUpInside)
        forgot_btn = contentView.forgotButton
        forgot_btn.addTarget(self, action: #selector(next_btn_pressed(_:)), for: .touchUpInside)
        
        contentView.deleteButton.addTarget(self, action: #selector(Delete(_:)), for: .touchUpInside)
        contentView.editButton.addTarget(self, action: #selector(ChangeWord(_:)), for: .touchUpInside)
        
        self.edit_text.delegate = self
        
        endOfWordsView = {
            let field = UILabel(frame: CGRect(x: 0, y: 0, width: 0.85*view.frame.width, height: 0.4*view.frame.height))
            field.center = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2)
            field.backgroundColor = .clear
            field.textColor = .white
            field.font = UIFont(name: "Helvetica", size: 42)
            field.textAlignment = .center
            field.numberOfLines = 3
            field.adjustsFontSizeToFitWidth = true
            field.tag = 1010101010101
            
            return field
        }()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("View will appear reached")
        checkWordsUpdate()
    }
    
    func checkWordsUpdate(){
        print("Checking for words, count = \(words.count)")
        contentView.removeFromSuperview()
        endOfWordsView.removeFromSuperview()
        if(words.count > 0){
            self.text.text = words[0].russian
            self.submit_btn.isEnabled = true
            self.forgot_btn.isEnabled = true
            view.addSubview(contentView)
        }else{
            print("No words for today")
            view.addSubview(endOfWordsView)
            endOfWordsView.text = no_words_for_today
        }
    }
    
    @objc func ChangeWord(_ sender: UIButton) {
        main_vc.performSegue(withIdentifier: "create_word_segue", sender: main_vc)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        edit_text.resignFirstResponder()
        return true
    }

}
