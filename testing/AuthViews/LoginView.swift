//
//  LoginView.swift
//  testing
//
//  Created by Vadim Zaripov on 28.05.2020.
//  Copyright © 2020 Vadim Zaripov. All rights reserved.
//

import UIKit
import AuthenticationServices

class LoginView: UIView {

    let font = "Helvetica"
    
    var emailField, passwordField: UITextField!
    var passwordResetButton, signUpButton: UIButton!
    var submitButton, loginWithGoogleButton: UIButton!
    
    override init(frame: CGRect){
        super.init(frame: frame)
        
        let height = 0.05*frame.height
        let font_sz = CGFloat(FontHelper().getInterfaceFontSize(font: font, height: height))
        
        let titleLabel: UILabel = {
            let label = UILabel()
            label.bounds = CGRect(x: 0, y: 0, width: 0.8*frame.width, height: frame.height / 18)
            label.center = CGPoint(x: 0.5*frame.width, y: frame.height / 5)
            label.text = log_in_title
            label.textAlignment = .center
            let f_size = FontHelper().getFontSize(strings: [log_in_title], font: font, maxFontSize: 120, width: label.bounds.width, height: label.bounds.height)
            label.font = UIFont(name: font, size: CGFloat(f_size))
            label.textColor = UIColor.white
            label.tag = 1000
            
            return label
        }()
        self.addSubview(titleLabel)
        
        for i in 0..<2 {
            let y = 0.4*frame.height + ((i == 0) ? -1.5*height : 0.5*height)
            let ed_text = UITextField()
            ed_text.bounds = CGRect(x: 0, y: 0, width: 0.8*frame.width, height: height)
            ed_text.center = CGPoint(x: frame.width / 2, y: y + ed_text.bounds.height / 2)
            ed_text.text = ""
            ed_text.font = UIFont(name: font, size: font_sz)
            ed_text.textColor = UIColor.white
            
            if(i == 0){ed_text.keyboardType = .emailAddress}
            ed_text.isSecureTextEntry = (i == 1)
            
            let bottomLine = CALayer()
            bottomLine.frame = CGRect(origin: CGPoint(x: 0, y:ed_text.frame.height - 1), size: CGSize(width: ed_text.frame.width, height: 2))
            bottomLine.backgroundColor = UIColor.white.cgColor
            ed_text.borderStyle = .none
            ed_text.layer.addSublayer(bottomLine)
            
            ed_text.tag = i + 1
            ed_text.backgroundColor = UIColor.clear
            ed_text.isUserInteractionEnabled = true
            ed_text.textAlignment = .left
            ed_text.attributedPlaceholder = NSAttributedString(string: auth_placeholders[i], attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(white: 1.0, alpha: 0.5)])
            self.addSubview(ed_text)
            
            if(i == 0){
                emailField = ed_text
            }else{
                passwordField = ed_text
            }
        }
        
        var s: CGFloat = 0
        let f_sz_small = CGFloat(FontHelper().getInterfaceFontSize(font: font, height: 0.75*height))
        for i in 0..<2{
            let btn = UIButton(frame: CGRect(x: self.subviews.last!.frame.minX, y: ((i == 0) ? (self.subviews.last!.frame.maxY + 0.75*height) : 0.87*frame.height), width: self.subviews.last!.frame.width, height: 0.75*height))
            s += btn.center.y
            btn.setTitle(((i == 0) ? forgot_text : sign_up_invite_text), for: .normal)
            btn.titleLabel?.font = UIFont(name: font, size: f_sz_small)
            btn.contentHorizontalAlignment = .left
            btn.titleLabel?.numberOfLines = i + 1
            btn.backgroundColor = UIColor.clear
            btn.setTitleColor(UIColor.init(white: 1, alpha: 0.8 + 0.2*CGFloat(i)), for: .normal)
            btn.tag = 100 + i
            self.addSubview(btn)
            if(i == 0){
                passwordResetButton = btn
            }else{
                signUpButton = btn
            }
        }
        
        let pd = 0.05*frame.width
        
        submitButton = {
            let button = UIButton()
            button.bounds = CGRect(x: 0, y: 0, width: 0.4*frame.width, height: frame.height / 18)
            button.setTitle("", for: .normal)
            button.setTitleColor(UIColor.white, for: .normal)
            button.backgroundColor = UIColor.clear
            button.layer.borderWidth = 2
            button.layer.borderColor = UIColor.white.cgColor
            button.center = CGPoint(x: (frame.width - 2*button.bounds.width - pd) / 2 + button.bounds.width / 2, y: 0.5*s)
            button.layer.cornerRadius = button.bounds.height / 2
            button.tag = 800
            button.isUserInteractionEnabled = true
            
            return button
        }()

        self.addSubview(submitButton)
        
        let f_img = UIImageView(image: UIImage(named: "next"))
        f_img.bounds = CGRect(x: 0, y: 0, width: 0.35*submitButton.bounds.width, height: 0.7*submitButton.bounds.height)
        f_img.center = submitButton.center
        f_img.tag = 801
        self.addSubview(f_img)
        
        loginWithGoogleButton = {
            let button = UIButton()
            button.bounds = submitButton.bounds
            button.center = CGPoint(x: submitButton.frame.maxX + pd + button.bounds.width / 2, y: s / 2)
            button.backgroundColor = UIColor.white
            button.layer.cornerRadius = button.bounds.height / 2
            button.tag = 802

            return button
        }()
        self.addSubview(loginWithGoogleButton)
        
        let img = UIImage(named: "google_logo")
        let h = 0.9*loginWithGoogleButton.bounds.height
        let newSize = CGSize(width: h*(img!.size.width / img!.size.height), height: h)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        let imageView = UIImageView(image: img)
        imageView.bounds = rect
        imageView.center = loginWithGoogleButton.center
        
        self.addSubview(imageView)

        if #available(iOS 13.0, *) {
            let appleButton : ASAuthorizationAppleIDButton = {
                let button = ASAuthorizationAppleIDButton(type: .default, style: .white)
                let width = 0.6*frame.width
                button.frame = CGRect(
                    x: (frame.width - width) / 2,
                    y: loginWithGoogleButton.frame.maxY + 0.02*frame.height,
                    width: width,
                    height: loginWithGoogleButton.bounds.height)
                button.tag = 803
                button.cornerRadius = button.frame.height / 2
                
                return button
            }()
            addSubview(appleButton)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
