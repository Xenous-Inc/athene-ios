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
var email = ""
class RegisterViewController: UIViewController, UITextFieldDelegate {

    var ed_text_email = UITextField()
    var ed_text_password = UITextField()
    var ed_text_password_confirm = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        email = ""
        let gb = AuthGraphicBuilder(width: view.bounds.width, height: view.bounds.height)
        view.addSubview(gb.buildSignUpView())
        
        (view.viewWithTag(800) as! UIButton).addTarget(self, action: #selector(Register(_:)), for: .touchUpInside)
        
        ed_text_email = view.viewWithTag(1) as! UITextField
        ed_text_password = view.viewWithTag(2) as! UITextField
        ed_text_password_confirm = view.viewWithTag(3) as! UITextField
        
        self.ed_text_email.delegate = self
        self.ed_text_password.delegate = self
        self.ed_text_password_confirm.delegate = self
    }
    
    @objc func Register(_ sender: Any) {
        if(ed_text_password.text! == ed_text_password_confirm.text!){
            view.isUserInteractionEnabled = false
            let v = UIView(frame: view.frame)
            v.backgroundColor = UIColor.init(white: 0, alpha: 0.5)
            v.alpha = 0
            view.addSubview(v)
            let indicator = UIActivityIndicatorView()
            indicator.style = .whiteLarge
            indicator.center = view.center
            UIView.animate(withDuration: 0.1, animations: {
                v.alpha = 1
            }, completion: {(finished: Bool) in
                self.view.addSubview(indicator)
                indicator.startAnimating()
            })
            email = ed_text_email.text!
            Auth.auth().createUser(withEmail: ed_text_email.text!, password: ed_text_password.text!) { authResult, error in
                self.view.layer.removeAllAnimations()
                self.view.isUserInteractionEnabled = true
                v.removeFromSuperview()
                indicator.removeFromSuperview()
                if error != nil{
                    self.messageAlert(message: error_title, text_error: error_texts_sign_up[1])
                    return
                }
                user = Auth.auth().currentUser!
                Auth.auth().currentUser?.sendEmailVerification { (error) in
                    os_log("Error while sending verification email")
                    self.messageAlert(message: error_title, text_error: error_texts_sign_up[2])
                    return
                }
                do{
                    try Auth.auth().signOut()
                    let alert = UIAlertController(title: verification_sent_text, message: verification_sent_describtion, preferredStyle: UIAlertController.Style.alert)
                    
                    alert.addAction(UIAlertAction(title: alert_ok, style: UIAlertAction.Style.default, handler: {(action) in
                        alert.dismiss(animated: true, completion: nil)
                        self.performSegue(withIdentifier: "to_log_in_segue", sender: RegisterViewController.self)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }catch _ as NSError{
                    self.messageAlert(message: error_title, text_error: error_texts_sign_up[1])
                    os_log("error")
                }
                
            }
        }else{
            messageAlert(message: error_title, text_error: error_texts_sign_up[0])
        }
    }
    
    func messageAlert(message: String, text_error: String){
        let alert = UIAlertController(title: message, message: text_error, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: alert_ok, style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        ed_text_email.resignFirstResponder()
        ed_text_password.resignFirstResponder()
        ed_text_password_confirm.resignFirstResponder()
        return true
    }

}
