//
//  NewWordViewController.swift
//  testing
//
//  Created by Vadim on 16/03/2019.
//  Copyright © 2019 Vadim Zaripov. All rights reserved.
//

import UIKit

class NewWordViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var ed_text_english: UITextField!
    @IBOutlet weak var ed_text_russian: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ed_text_english.delegate = self
        self.ed_text_russian.delegate = self
    }
    
    @IBAction func Submit(_ sender: Any) {
        ref.child("words").child(String(number_of_words)).child("English").setValue(ed_text_english.text!)
        ref.child("words").child(String(number_of_words)).child("Russian").setValue(ed_text_russian.text!)
        ref.child("words").child(String(number_of_words)).child("date").setValue(next_date)
        ref.child("words").child(String(number_of_words)).child("level").setValue(0)
        ref.child("words").child(String(number_of_words)).child("category").setValue("default")
        
        number_of_words += 1
        print(number_of_words)
        
        performSegue(withIdentifier: "return_make_new_word", sender: self)
    }
    
    @IBAction func Cancel(_ sender: Any) {
        performSegue(withIdentifier: "return_make_new_word", sender: self)
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
