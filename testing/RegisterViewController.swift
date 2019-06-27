//
//  RegisterViewController.swift
//  testing
//
//  Created by Vadim on 02/04/2019.
//  Copyright © 2019 Vadim Zaripov. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var ed_text_username: UITextField!
    @IBOutlet weak var ed_text_email: UITextField!
    @IBOutlet weak var ed_text_password: UITextField!
    @IBOutlet weak var ed_text_password_confirm: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.ed_text_username.delegate = self
        self.ed_text_email.delegate = self
        self.ed_text_password.delegate = self
        self.ed_text_password_confirm.delegate = self
    }
    
    @IBAction func Register(_ sender: Any) {
        if(ed_text_password.text! == ed_text_password_confirm.text!){
            Auth.auth().createUser(withEmail: ed_text_email.text!, password: ed_text_password.text!) { authResult, error in
                if error != nil{
                    //Registration error
                    return
                }
                user = Auth.auth().currentUser!
                Database.database().reference().child("users").child(user?.uid ?? "").child("username").setValue(self.ed_text_username.text!)
                self.performSegue(withIdentifier: "start_from_registration", sender: RegisterViewController.self)
                
            }
            Auth.auth().currentUser?.sendEmailVerification { (error) in
                // Error
            }
        }else{
            //Passwords are diffrent
        }
    }
    
    @IBAction func Back(_ sender: Any) {
        performSegue(withIdentifier: "back_from_register", sender: self)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        ed_text_username.resignFirstResponder()
        ed_text_email.resignFirstResponder()
        ed_text_password.resignFirstResponder()
        ed_text_password_confirm.resignFirstResponder()
        return true
    }

}
