//
//  RegisterViewController.swift
//  testing
//
//  Created by Vadim on 02/04/2019.
//  Copyright © 2019 Vadim Zaripov. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import os

var email = ""
class RegisterViewController: UIViewController, UITextFieldDelegate, GIDSignInDelegate {

    var ed_text_email = UITextField()
    var ed_text_password = UITextField()
    var ed_text_password_confirm = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        email = ""
        let gb = AuthGraphicBuilder(width: view.bounds.width, height: view.bounds.height)
        view.addSubview(gb.buildSignUpView())
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().signIn()
        GIDSignIn.sharedInstance()?.delegate = self
        
        (view.viewWithTag(800) as! UIButton).addTarget(self, action: #selector(Register(_:)), for: .touchUpInside)
        (view.viewWithTag(802) as! UIButton).addTarget(self, action: #selector(googleAuth(_sender:)), for: .touchUpInside)
        
        ed_text_email = view.viewWithTag(1) as! UITextField
        ed_text_password = view.viewWithTag(2) as! UITextField
        ed_text_password_confirm = view.viewWithTag(3) as! UITextField
        
        self.ed_text_email.delegate = self
        self.ed_text_password.delegate = self
        self.ed_text_password_confirm.delegate = self
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
            self.performSegue(withIdentifier: "to_main_from_sign_up", sender: self)
            print("Successfully logged in Firebase", res!.user.uid)
        })
        
        print("Successfully logged into Google ", user)
    }
    
    @objc func googleAuth(_sender: Any){
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    @objc func Register(_ sender: Any) {
        if(ed_text_password.text! == ed_text_password_confirm.text!){
            view.isUserInteractionEnabled = false
            let v = LoadingView()
            v.set(frame: view.frame)
            view.addSubview(v)
            v.show()
            email = ed_text_email.text!
            Auth.auth().createUser(withEmail: ed_text_email.text!, password: ed_text_password.text!) { authResult, error in
                self.view.layer.removeAllAnimations()
                self.view.isUserInteractionEnabled = true
                v.removeFromSuperview()
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
