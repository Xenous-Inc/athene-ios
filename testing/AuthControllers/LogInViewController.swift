//
//  LogInViewController.swift
//  testing
//
//  Created by Vadim on 02/04/2019.
//  Copyright © 2019 Vadim Zaripov. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import os

class LogInViewController: UIViewController, UITextFieldDelegate, GIDSignInDelegate {
    

    var ed_text_email = UITextField()
    var ed_text_password = UITextField()
    
    var reset_password = UIButton()
    var submit_btn = UIButton()
    var to_sign_up_btn = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        //GIDSignIn.sharedInstance().signIn()
        GIDSignIn.sharedInstance()?.delegate = self

        view.addSubview(LoginView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)))
        
        (view.viewWithTag(802) as! UIButton).addTarget(self, action: #selector(googleAuth(_sender:)), for: .touchUpInside)
        
        submit_btn = view.viewWithTag(800) as! UIButton
        reset_password = view.viewWithTag(100) as! UIButton
        to_sign_up_btn = view.viewWithTag(101) as! UIButton
        
        submit_btn.addTarget(self, action: #selector(LogIn(_:)), for: .touchUpInside)
        reset_password.addTarget(self, action: #selector(Reset(_:)), for: .touchUpInside)
        to_sign_up_btn.addTarget(self, action: #selector(toSignUp(_:)), for: .touchUpInside)
        
        ed_text_email = view.viewWithTag(1) as! UITextField
        ed_text_email.text = email
        ed_text_password = view.viewWithTag(2) as! UITextField

        self.ed_text_email.delegate = self
        self.ed_text_password.delegate = self
    }
    
    @objc func googleAuth(_sender: Any){
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let err = error{
            print("Failed to log into Google: ", err)
            return
        }
        
        guard let idtoken = user.authentication.idToken else {return}
        guard let accesstoken = user.authentication.accessToken else {return}
        
        let credentials = GoogleAuthProvider.credential(withIDToken: idtoken, accessToken: accesstoken)
        
        let v = LoadingView()
        v.set(frame: view.frame)
        view.addSubview(v)
        v.show()
        
        Auth.auth().signIn(with: credentials, completion: {(res, error) in
            v.removeFromSuperview()
            if let e = error{
                print("Failed to log in Firebase using Google: ", e)
            }
            self.performSegue(withIdentifier: "to_main", sender: self)
            print("Successfully logged in Firebase", res!.user.uid)
        })
        
        print("Successfully logged into Google ", user)
    }
    
    @objc func LogIn(_ sender: Any) {
        if(ed_text_email.text == "" || ed_text_password.text == ""){return}
        os_log("HELLO")
        view.isUserInteractionEnabled = false
        let v = LoadingView()
        v.set(frame: view.frame)
        view.addSubview(v)
        v.show()
        self.reset_password.isEnabled = true
        Auth.auth().signIn(withEmail: ed_text_email.text!, password: ed_text_password.text!, completion: { (u, err) in
            self.view.layer.removeAllAnimations()
            self.view.isUserInteractionEnabled = true
            v.removeFromSuperview()
            if let error = err{
                let err_code = AuthErrorCode(rawValue: error._code)
                switch err_code{
                case .wrongPassword?:
                    self.messageAlert(message: error_title, text_error: error_texts[0])
                case .invalidEmail?:
                    self.messageAlert(message: error_title, text_error: error_texts[1])
                default:
                    self.messageAlert(message: error_title, text_error: error_texts[2])
                }
            }else{
                os_log("NO ERROR")
                user = Auth.auth().currentUser!
                if(user!.isEmailVerified){
                    self.performSegue(withIdentifier: "to_main", sender: LogInViewController.self)
                }else{
                    self.messageAlert(message: error_title, text_error: error_texts[3])
                }
            }
        })
    }
    
    func messageAlert(message: String, text_error: String){
        let alert = UIAlertController(title: message, message: text_error, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: alert_ok, style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func Reset(_ sender: Any) {
        if(ed_text_email.text != ""){
            Auth.auth().sendPasswordReset(withEmail: ed_text_email.text!, completion: nil)
            self.reset_password.isEnabled = false
            self.messageAlert(message: reset_password_title, text_error: reset_password_describtion)
        }
    }
    
    @objc func toSignUp(_ sender: Any){
        self.performSegue(withIdentifier: "move_to_sign_up", sender: self)
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
