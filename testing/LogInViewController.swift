//
//  LogInViewController.swift
//  testing
//
//  Created by Vadim on 02/04/2019.
//  Copyright © 2019 Vadim Zaripov. All rights reserved.
//

import UIKit
import Firebase
import os

class LogInViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var ed_text_email: UITextField!
    @IBOutlet weak var ed_text_password: UITextField!
    
    @IBOutlet weak var reset_password: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reset_password.isEnabled = false

        self.ed_text_email.delegate = self
        self.ed_text_password.delegate = self
    }
    
    @IBAction func LogIn(_ sender: Any) {
        os_log("HELLO")
        self.reset_password.setTitle("", for: .normal)
        Auth.auth().signIn(withEmail: ed_text_email.text!, password: ed_text_password.text!, completion: { (u, err) in
            if let error = err{
                let err_code = AuthErrorCode(rawValue: error._code)
                switch err_code{
                case .wrongPassword?:
                    os_log("wrong password")
                    self.reset_password.setTitle("Forgot password? Tap to reset", for: .normal)
                    self.reset_password.isEnabled = true
                case .invalidEmail?:
                    os_log("invalid email")
                    self.reset_password.setTitle("Invalid Email", for: .normal)
                default:
                    os_log("error")
                    self.errorAlert(text_error: "Unknown authorization error. Check internet connection and try again")
                    // self.reset_password.setTitle("Authorization Error", for: .normal)
                }
            }else{
                os_log("NO ERROR")
                user = Auth.auth().currentUser!
                if(user!.isEmailVerified){
                    self.performSegue(withIdentifier: "start_from_log_in", sender: LogInViewController.self)
                }else{
                    self.errorAlert(text_error: "Email is not verified. Check your email address")
                    os_log("Email is not verified")
                }
            }
        })
    }
    
    func errorAlert(text_error: String){
        let alert = UIAlertController(title: "Error", message: text_error, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Back", style: UIAlertAction.Style.default, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func Reset(_ sender: Any) {
        if(ed_text_email.text != ""){
            Auth.auth().sendPasswordReset(withEmail: ed_text_email.text!, completion: nil)
            self.reset_password.isEnabled = false
            self.reset_password.setTitle("We sent an email for password reset", for: .normal)
        }
    }
    
    @IBAction func Back(_ sender: Any) {
        performSegue(withIdentifier: "back_from_log_in", sender: self)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        ed_text_email.resignFirstResponder()
        ed_text_password.resignFirstResponder()
        return true
    }
}
