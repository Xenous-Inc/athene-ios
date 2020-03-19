//
//  ChangeWordViewController.swift
//  testing
//
//  Created by Vadim on 16/03/2019.
//  Copyright © 2019 Vadim Zaripov. All rights reserved.
//

import UIKit
import os

class ChangeWordViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var ed_text_english: UITextField!
    @IBOutlet weak var ed_text_russian: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.ed_text_english.delegate = self
        self.ed_text_russian.delegate = self
    }
    
    @IBAction func Submit(_ sender: Any) {
        ref.child("words").child(String(words[current - 1].db_index)).child("English").setValue(ed_text_english.text!)
        ref.child("words").child(String(words[current - 1].db_index)).child("Russian").setValue(ed_text_russian.text!)
        performSegue(withIdentifier: "back_from_change_word", sender: self)
    }
    
    @IBAction func Delete(_ sender: Any) {
        let alert = UIAlertController(title: "Delete?", message: "Do you really want to delete word?", preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.default, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
            os_log("Deleting...")
            pushCard(ind: words[current - 1].db_index)
            self.performSegue(withIdentifier: "back_from_change_word", sender: self)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func Cancel(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "back_from_change_word", sender: self)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        ed_text_english.resignFirstResponder()
        ed_text_russian.resignFirstResponder()
        return true
    }

}

func pushCard(ind: Int){
    let last = number_of_words - 1
    number_of_words -= 1
    ref.child("words").child(String(last)).observeSingleEvent(of: .value, with: { (snap) in
        ref.child("words").child(String(ind)).child("English").setValue(snap.childSnapshot(forPath: "English").value)
        ref.child("words").child(String(ind)).child("Russian").setValue(snap.childSnapshot(forPath: "Russian").value)
        ref.child("words").child(String(ind)).child("date").setValue(snap.childSnapshot(forPath: "date").value)
        ref.child("words").child(String(ind)).child("level").setValue(snap.childSnapshot(forPath: "level").value)
        ref.child("words").child(String(ind)).child("category").setValue(snap.childSnapshot(forPath: "category").value)
        
        ref.child("words").child(String(last)).removeValue()
        print(number_of_words)
    })
}
