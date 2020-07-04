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

    var archive_amount = 0
    let dateFormatter = DateFormatter()
    var answering = true
    var frame: CGRect? = nil
    var contentView: MainView!
    
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
    
    @objc func onNextButtonPressed(_ sender: UIButton){
        if(words.count == 0){return}
        contentView.nextButton.isEnabled = false
        contentView.forgotButton.isEnabled = false
        if(answering){
            submit(sender: sender.tag)
        }else{
            next()
        }
    }
    
    func submit(sender: Int) {
        if (sender == contentView.nextButton.tag && (contentView.editTextSecond.text == "" || contentView.editTextSecond.text == " ")){
            messageAlert(vc: self, message: message_no_word, text_error: alert_no_word_description)
            contentView.nextButton.isEnabled = true
            contentView.forgotButton.isEnabled = true
            return
        }
        guard let eng = contentView.editTextSecond.text?.formatted() else { return }
        if (sender == contentView.nextButton.tag) && (eng == words[0].english.formatted()) {
            (view.viewWithTag(101) as? UIImageView)?.tintColor = UIColor.init(rgb: green_clr)
            contentView.editTextSecond.textColor = UIColor.init(rgb: green_clr)
            switch words[0].level{
            case 0:
                updateCard(id: words[0].db_index, date: week_date, level: words[0].level + 1)
            case 1:
                updateCard(id: words[0].db_index, date: month_date, level: words[0].level + 1)
            case 2:
                updateCard(id: words[0].db_index, date: three_month_date, level: words[0].level + 1)
            case 3:
                updateCard(id: words[0].db_index, date: six_month_date, level: words[0].level + 1)
            default:
                moveCardToArchive(id: words[0].db_index)
            }
            contentView.resetTint(deadline: .now() + 0.9) {
                self.next()
            }
        }else{
            answering = false
            updateCard(id: words[0].db_index, date: next_date, level: 0)
            contentView.animateIncorrectAnswer(ans: contentView.editTextSecond.text!, correct: words[0].english, status: sender)
        }
    }
    
    @objc func next() {
        words.remove(at: 0)
        if(answering == false){
            answering = true
            contentView.animateNextWord(nextWord: words.first?.russian, completion: {
                if(words.count == 0){
                    self.contentView.showEndOfWordsView(animated: true){
                        main_vc.cheerView.startConfetti()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            main_vc.cheerView.stopConfetti()
                        }
                    }
                }
            })
        }else if(words.count == 0){
            contentView.showEndOfWordsView(animated: true){
                main_vc.cheerView.startConfetti()
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    main_vc.cheerView.stopConfetti()
                }
            }
        }else{
            contentView.switchTextFields(text: words[0].russian)
            contentView.nextButton.isEnabled = true
            contentView.forgotButton.isEnabled = true
        }
    }
    
    //Database
    
    func updateCard(id: String, date: Date, level: Int){
        ref.child("words").child(id).child("date").setValue(date.toDatabaseFormat())
        ref.child("words").child(id).child("level").setValue(level)
    }
    
    func moveCardToArchive(id: String){
        ref.child("words").child(id).child("level").setValue(-1)
    }
    
    @objc func deleteWord(_ sender: Any) {
        let alert = UIAlertController(title: delete_alert_question, message: delete_alert_warning, preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: delete_alert_delete, style: UIAlertAction.Style.default, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
            ref.child("words").child(words[0].db_index).removeValue()
            self.next()
        }))
        
        alert.addAction(UIAlertAction(title: delete_alert_cancel, style: UIAlertAction.Style.default, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(frame != nil){
            view.frame = frame!
        }
        contentView = MainView(frame: view.frame)
        contentView.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
        view.addSubview(contentView)
        
        contentView.nextButton.addTarget(self, action: #selector(onNextButtonPressed(_:)), for: .touchUpInside)
        contentView.forgotButton.addTarget(self, action: #selector(onNextButtonPressed(_:)), for: .touchUpInside)
        
        contentView.deleteButton.addTarget(self, action: #selector(deleteWord(_:)), for: .touchUpInside)
        contentView.editButton.addTarget(self, action: #selector(changeWord(_:)), for: .touchUpInside)
        
        self.contentView.editTextSecond.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("View will appear reached")
        checkWordsUpdate()
    }
    
    func checkWordsUpdate(){
        print("Checking for words, count = \(words.count)")
        contentView.clear()
        if(words.count > 0){
            self.contentView.editTextFirst.text = words[0].russian
            self.contentView.nextButton.isEnabled = true
            self.contentView.forgotButton.isEnabled = true
            contentView.showContainerView()
        }else{
            print("No words for today")
            contentView.showEndOfWordsView(animated: false)
            contentView.endOfWordsView.text = no_words_for_today
        }
    }
    
    @objc func changeWord(_ sender: UIButton) {
        main_vc.performSegue(withIdentifier: "create_word_segue", sender: main_vc)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        contentView.editTextSecond.resignFirstResponder()
        return true
    }

}
