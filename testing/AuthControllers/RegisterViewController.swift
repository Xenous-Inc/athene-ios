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
import AuthenticationServices

#if canImport(CryptoKit)
import CryptoKit
#endif

var email = ""
class RegisterViewController: UIViewController, UITextFieldDelegate, GIDSignInDelegate {

    var ed_text_email = UITextField()
    var ed_text_password = UITextField()
    var ed_text_password_confirm = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        email = ""
        view.addSubview(SignupView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)))
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        //GIDSignIn.sharedInstance().signIn()
        GIDSignIn.sharedInstance()?.delegate = self
        
        (view.viewWithTag(800) as! UIButton).addTarget(self, action: #selector(Register(_:)), for: .touchUpInside)
        (view.viewWithTag(802) as! UIButton).addTarget(self, action: #selector(googleAuth(_sender:)), for: .touchUpInside)
        (view.viewWithTag(803) as! UIButton).addTarget(self, action: #selector(signInWithAppleSelected(_:)), for: .touchUpInside)

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
                if let error = error{
                    let err_code = AuthErrorCode(rawValue: error._code)
                    switch err_code{
                    case .weakPassword:
                        messageAlert(vc: self, message: error_title, text_error: error_texts_sign_up[1])
                        break
                    case .emailAlreadyInUse:
                        messageAlert(vc: self, message: error_title, text_error: error_texts_sign_up[2])
                        break
                    case .accountExistsWithDifferentCredential:
                        messageAlert(vc: self, message: error_title, text_error: error_texts_sign_up[2])
                        break
                    case .invalidEmail:
                        messageAlert(vc: self, message: error_title, text_error: error_texts_sign_up[3])
                        break
                    default:
                        messageAlert(vc: self, message: error_title, text_error: error_texts_sign_up[4])
                    }
                    return
                }
                user = Auth.auth().currentUser!
                Auth.auth().currentUser?.sendEmailVerification { (error) in
                    os_log("Error while sending verification email")
                    messageAlert(vc: self, message: error_title, text_error: error_texts_sign_up[5])
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
                    messageAlert(vc: self, message: error_title, text_error: error_texts_sign_up[4])
                    os_log("error")
                }
                
            }
        }else{
            messageAlert(vc: self, message: error_title, text_error: error_texts_sign_up[0])
        }
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

    @objc func signInWithAppleSelected(_ sender: Any){
        if #available(iOS 13, *) {
            #if canImport(CryptoKit)
            startSignInWithAppleFlow()
            #else
            messageAlert(vc: self, message: login_with_apple_not_available, text_error: nil)
            #endif
        } else {
            messageAlert(vc: self, message: login_with_apple_not_available, text_error: nil)
        }
    }

    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
                Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    // Unhashed nonce.
    fileprivate var currentNonce: String?
    #if canImport(CryptoKit)
    @available(iOS 13, *)
    func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()

        return hashString
    }
    #endif
}

@available(iOS 13.0, *)
extension RegisterViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                    idToken: idTokenString,
                    rawNonce: nonce)
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if (error != nil) {
                    // Error. If error.code == .MissingOrInvalidNonce, make sure
                    // you're sending the SHA256-hashed nonce as a hex string with
                    // your request to Apple.
                    print(error?.localizedDescription as Any)
                    return
                }
                self.performSegue(withIdentifier: "to_main_from_sign_up", sender: self)
                // User is signed in to Firebase with Apple.
                // ...
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
    }

}

