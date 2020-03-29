//
//  RegisterViewController.swift
//  testing
//
//  Created by Vadim on 02/04/2019.
//  Copyright © 2019 Vadim Zaripov. All rights reserved.
//

import UIKit
import Firebase
import os

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
                    self.errorAlert(text_error: "Unknown error while registrating, try again")
                    return
                }
                user = Auth.auth().currentUser!
                Database.database().reference().child("users").child(user?.uid ?? "").child("username").setValue(self.ed_text_username.text!)
                Auth.auth().currentUser?.sendEmailVerification { (error) in
                    os_log("Error while sending verification email")
                    self.errorAlert(text_error: "Error while sending verification email")
                    return
                }
                do{
                    try Auth.auth().signOut()
                    let alert = UIAlertController(title: "Verification email sent", message: "Please check you email address to verify your email", preferredStyle: UIAlertController.Style.alert)
                    
                    alert.addAction(UIAlertAction(title: "Got it", style: UIAlertAction.Style.default, handler: {(action) in
                        alert.dismiss(animated: true, completion: nil)
                        self.performSegue(withIdentifier: "to_login_after_reg", sender: RegisterViewController.self)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }catch _ as NSError{
                    self.errorAlert(text_error: "Unknown error. check internet connection and try again")
                    os_log("error")
                }
                
            }
            
            
        }else{
            errorAlert(text_error: "Passwords are different")
        }
    }
    
    func errorAlert(text_error: String){
        let alert = UIAlertController(title: "Error", message: text_error, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Back", style: UIAlertAction.Style.default, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
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
