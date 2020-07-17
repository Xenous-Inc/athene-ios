//
//  SignupView.swift
//  testing
//
//  Created by Vadim Zaripov on 28.05.2020.
//  Copyright © 2020 Vadim Zaripov. All rights reserved.
//

import UIKit
import AuthenticationServices

class SignupView: UIView {

    let font = "Helvetica"

    var emailField, passwordField, passwordConfirmField: UITextField!
    var submitButton, loginWithGoogleButton: Button!
    var backButton: Button!
    
    override init(frame: CGRect){
        super.init(frame: frame)
        
        let height = 0.05*frame.height
        let font_sz = CGFloat(FontHelper().getInterfaceFontSize(font: font, height: height))
        
        let titleLabel: UILabel = {
            let label = UILabel()
            label.bounds = CGRect(x: 0, y: 0, width: 0.7*frame.width, height: frame.height / 18)
            label.center = CGPoint(x: 0.55*frame.width, y: frame.height / 5)
            label.text = sign_up_title
            label.textAlignment = .center
            let f_size = FontHelper().getFontSize(strings: [sign_up_title], font: font, maxFontSize: 120, width: label.bounds.width, height: label.bounds.height)
            label.font = UIFont(name: font, size: CGFloat(f_size))
            label.textColor = UIColor.white
            label.tag = 1000
            return label
        }()
        addSubview(titleLabel)

        backButton = {
            let buttonSize = 0.045*frame.height
            let button = Button(frame: CGRect(
                    x: 0.1*frame.width,
                    y: titleLabel.center.y - buttonSize / 2,
                    width: buttonSize,
                    height: buttonSize))
            button.setBackgroundImage(UIImage(named: "back"), for: .normal)
            button.layoutIfNeeded()
            button.subviews.first?.contentMode = .scaleAspectFit

            return button
        }()
        addSubview(backButton)
        
        for i in 0..<3{
            let y = frame.height / 2 + (CGFloat(2*i) - 2.5)*height
            let ed_text = UITextField()
            ed_text.bounds = CGRect(x: 0, y: 0, width: 0.8*frame.width, height: height)
            ed_text.center = CGPoint(x: frame.width / 2, y: y + ed_text.bounds.height / 2)
            ed_text.text = ""
            ed_text.font = UIFont(name: font, size: font_sz)
            ed_text.textColor = UIColor.white
            
            if(i == 0){ed_text.keyboardType = .emailAddress}
            ed_text.isSecureTextEntry = (i > 0)
            
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
            }else if(i == 1){
                passwordField = ed_text
            }else{
                passwordConfirmField = ed_text
            }
        }
        
        let pd = 0.05*frame.width

        loginWithGoogleButton = {
            let button = Button()
            button.bounds = CGRect(x: 0, y: 0, width: 0.4*frame.width, height: frame.height / 18)
            button.center = CGPoint(
                    x: (frame.width - 2*button.bounds.width - pd) / 2 + button.bounds.width / 2,
                    y: 0.85*frame.height - button.bounds.height / 2)
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
        
        submitButton = {
            let button = Button()
            button.bounds = loginWithGoogleButton.bounds
            button.setTitle("", for: .normal)
            button.setTitleColor(UIColor.white, for: .normal)
            button.backgroundColor = UIColor.clear
            button.layer.borderWidth = 2
            button.layer.borderColor = UIColor.white.cgColor
            button.center = CGPoint(
                    x: loginWithGoogleButton.frame.maxX + pd + button.bounds.width / 2,
                    y: 0.85*frame.height - button.bounds.height / 2)
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

//        let appleButton: Button = {
//            let width = 0.6*frame.width
//            let button = Button(frame: CGRect(
//                    x: (frame.width - width) / 2,
//                    y: google_btn.frame.maxY + 0.02*frame.height,
//                    width: width, height: finish_btn.bounds.height))
//            button.backgroundColor = .clear
//            button.layer.borderWidth = 2
//            button.layer.borderColor = UIColor.white.cgColor
//            button.layer.cornerRadius = button.bounds.height / 2
//            button.setTitleColor(UIColor.white, for: .normal)
//            button.setTitle(login_with_apple_title, for: .normal)
//            button.titleLabel?.font = UIFont(name: font, size: CGFloat(FontHelper().getFontSize(
//                    strings: [login_with_apple_title],
//                    font: font,
//                    maxFontSize: 120,
//                    width: 0.8*button.frame.width,
//                    height: 0.7*button.frame.height)))
//            button.tag = 803
//            return button
//        }()
        
        if #available(iOS 13.0, *) {
            let appleButton : ASAuthorizationAppleIDButton = {
                let button = ASAuthorizationAppleIDButton(type: .default, style: .white)
                let width = 0.6*frame.width
                button.frame = CGRect(
                    x: (frame.width - width) / 2,
                    y: loginWithGoogleButton.frame.maxY + 0.02*frame.height,
                    width: width,
                    height: submitButton.bounds.height)
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
