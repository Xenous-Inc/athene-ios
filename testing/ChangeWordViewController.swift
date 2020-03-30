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
        let gb = GraphicBuilder(width: view.frame.width, height: view.frame.height)
        view.addSubview(gb.buildEditView(categories: default_categories))
        //self.ed_text_english.delegate = self
        //self.ed_text_russian.delegate = self
    }
    
    @IBAction func Submit(_ sender: Any) {
        ref.child("words").child(String(words[current - 1].db_index)).child("English").setValue(ed_text_english.text!)
        ref.child("words").child(String(words[current - 1].db_index)).child("Russian").setValue(ed_text_russian.text!)
        performSegue(withIdentifier: "back_from_change_word", sender: self)
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
