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

class ViewController: UIViewController, UITextFieldDelegate {

    var edit_text: UITextField!
    var text: UITextField!
    var submit_btn: UIButton!
    var forgot_btn: UIButton!
    
    var archive_amount = 0
    
    let dateFormatter = DateFormatter()
    
    var answering = true
    
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
    
    func Submit(sender: Int) {
        if (sender == submit_btn.tag && (edit_text.text == "" || edit_text.text == " ")){
            messageAlert(vc: self, message: message_no_word, text_error: alert_no_word_description)
            submit_btn.isEnabled = true
            forgot_btn.isEnabled = true
            return
        }
        guard let eng = edit_text.text?.formatted() else { return }
        if (sender == submit_btn.tag) && (eng == words[0].english.formatted()) {
            (view.viewWithTag(101) as? UIImageView)?.tintColor = UIColor.init(rgb: green_clr)
            edit_text.textColor = UIColor.init(rgb: green_clr)
            switch words[0].level{
            case 0:
                UpdateCard(id: words[0].db_index, date: week_date, level: words[0].level + 1)
            case 1:
                UpdateCard(id: words[0].db_index, date: month_date, level: words[0].level + 1)
            case 2:
                UpdateCard(id: words[0].db_index, date: three_month_date, level: words[0].level + 1)
            case 3:
                UpdateCard(id: words[0].db_index, date: six_month_date, level: words[0].level + 1)
            default:
                MoveCardToArchive(id: words[0].db_index)
            }
            contentView.resetTint(deadline: .now() + 0.9) {
                self.Next()
            }
        }else{
            answering = false
            UpdateCard(id: words[0].db_index, date: next_date, level: 0)
            contentView.animateIncorrectAnswer(ans: edit_text.text!, correct: words[0].english, status: sender)
        }
    }
    
    @objc func Next() {
        words.remove(at: 0)
        if(answering == false){
            answering = true
            contentView.animateNextWord()
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
    
    //Database
    
    func UpdateCard(id: String, date: Date, level: Int){
        ref.child("words").child(id).child("date").setValue(date.toDatabaseFormat())
        ref.child("words").child(id).child("level").setValue(level)
    }
    
    func MoveCardToArchive(id: String){
        ref.child("words").child(id).child("level").setValue(-1)
    }
    
    @objc func Delete(_ sender: Any) {
        let alert = UIAlertController(title: delete_alert_question, message: delete_alert_warning, preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: delete_alert_delete, style: UIAlertAction.Style.default, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
            ref.child("words").child(words[0].db_index).removeValue()
            self.Next()
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
            field.tag = 1010101010
            
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
