//
//  AuthGraphicBuilder.swift
//  testing
//
//  Created by Vadim on 31/03/2020.
//  Copyright © 2020 Vadim Zaripov. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import GoogleSignIn

class AuthGraphicBuilder: NSObject{
    
    var window_width: CGFloat
    var window_height: CGFloat
    let font = "Helvetica"
    
    init(width: CGFloat, height: CGFloat) {
        window_width = width
        window_height = height
    }
    
    func buildBuildLogInView() -> UIView{
        let view = UIView(frame: CGRect(x: 0, y: 0, width: window_width, height: window_height))
        
        let height = 0.05*window_height
        let font_sz = CGFloat(FontHelper().getInterfaceFontSize(font: font, height: height))
        
        let title_label = UILabel()
        title_label.bounds = CGRect(x: 0, y: 0, width: 0.8*window_width, height: window_height / 18)
        title_label.center = CGPoint(x: 0.5*window_width, y: window_height / 5)
        title_label.text = log_in_title
        title_label.textAlignment = .center
        let f_size = FontHelper().getFontSize(strings: [log_in_title], font: font, maxFontSize: 120, width: title_label.bounds.width, height: title_label.bounds.height)
        title_label.font = UIFont(name: font, size: CGFloat(f_size))
        title_label.textColor = UIColor.white
        title_label.tag = 1000
        view.addSubview(title_label)
        
        for i in 0..<2{
            let y = 0.4*window_height + ((i == 0) ? -1.5*height : 0.5*height)
            let ed_text = UITextField()
            ed_text.bounds = CGRect(x: 0, y: 0, width: 0.8*window_width, height: height)
            ed_text.center = CGPoint(x: window_width / 2, y: y + ed_text.bounds.height / 2)
            ed_text.text = ""
            ed_text.font = UIFont(name: font, size: font_sz)
            ed_text.textColor = UIColor.white
            
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
            view.addSubview(ed_text)
        }
        var s: CGFloat = 0
        let f_sz_small = CGFloat(FontHelper().getInterfaceFontSize(font: font, height: 0.75*height))
        for i in 0..<2{
            let btn = UIButton(frame: CGRect(x: view.subviews.last!.frame.minX, y: ((i == 0) ? (view.subviews.last!.frame.maxY + 0.75*height) : 0.87*window_height), width: view.subviews.last!.frame.width, height: 0.75*height))
            s += btn.center.y
            btn.setTitle(((i == 0) ? forgot_text : sign_up_invite_text), for: .normal)
            btn.titleLabel?.font = UIFont(name: font, size: f_sz_small)
            btn.contentHorizontalAlignment = .left
            btn.titleLabel?.numberOfLines = i + 1
            btn.backgroundColor = UIColor.clear
            btn.setTitleColor(UIColor.init(white: 1, alpha: 0.8 + 0.2*CGFloat(i)), for: .normal)
            btn.tag = 100 + i
            view.addSubview(btn)
        }
        
        let pd = 0.05*window_width
        
        let finish_btn = UIButton()
        finish_btn.bounds = CGRect(x: 0, y: 0, width: 0.4*window_width, height: window_height / 18)
        finish_btn.setTitle("", for: .normal)
        finish_btn.setTitleColor(UIColor.white, for: .normal)
        finish_btn.backgroundColor = UIColor.clear
        finish_btn.layer.borderWidth = 2
        finish_btn.layer.borderColor = UIColor.white.cgColor
        finish_btn.center = CGPoint(x: (window_width - 2*finish_btn.bounds.width - pd) / 2 + finish_btn.bounds.width / 2, y: s / 2)
        finish_btn.layer.cornerRadius = finish_btn.bounds.height / 2
        finish_btn.tag = 800
        finish_btn.isUserInteractionEnabled = true
        view.addSubview(finish_btn)
        
        let f_img = UIImageView(image: UIImage(named: "next"))
        f_img.bounds = CGRect(x: 0, y: 0, width: 0.35*finish_btn.bounds.width, height: 0.7*finish_btn.bounds.height)
        f_img.center = finish_btn.center
        f_img.tag = 801
        view.addSubview(f_img)
        
        let google_btn = UIButton()
        google_btn.bounds = finish_btn.bounds
        google_btn.center = CGPoint(x: finish_btn.frame.maxX + pd + google_btn.bounds.width / 2, y: s / 2)
        google_btn.backgroundColor = UIColor.white
        google_btn.layer.cornerRadius = google_btn.bounds.height / 2
        google_btn.tag = 802
        view.addSubview(google_btn)
        
        let img = UIImage(named: "google_logo")
        let h = 0.9*google_btn.bounds.height
        let newSize = CGSize(width: h*(img!.size.width / img!.size.height), height: h)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        let imageView = UIImageView(image: img)
        imageView.bounds = rect
        imageView.center = google_btn.center
        
        view.addSubview(imageView)

        
        return view
    }
    
    func buildSignUpView() -> UIView{
        let view = UIView(frame: CGRect(x: 0, y: 0, width: window_width, height: window_height))
        
        let height = 0.05*window_height
        let font_sz = CGFloat(FontHelper().getInterfaceFontSize(font: font, height: height))
        
        let title_label = UILabel()
        title_label.bounds = CGRect(x: 0, y: 0, width: 0.8*window_width, height: window_height / 18)
        title_label.center = CGPoint(x: 0.5*window_width, y: window_height / 5)
        title_label.text = sign_up_title
        title_label.textAlignment = .center
        let f_size = FontHelper().getFontSize(strings: [sign_up_title], font: font, maxFontSize: 120, width: title_label.bounds.width, height: title_label.bounds.height)
        title_label.font = UIFont(name: font, size: CGFloat(f_size))
        title_label.textColor = UIColor.white
        title_label.tag = 1000
        view.addSubview(title_label)
        
        for i in 0..<3{
            let y = window_height / 2 + (CGFloat(2*i) - 2.5)*height
            let ed_text = UITextField()
            ed_text.bounds = CGRect(x: 0, y: 0, width: 0.8*window_width, height: height)
            ed_text.center = CGPoint(x: window_width / 2, y: y + ed_text.bounds.height / 2)
            ed_text.text = ""
            ed_text.font = UIFont(name: font, size: font_sz)
            ed_text.textColor = UIColor.white
            
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
            view.addSubview(ed_text)
        }
        
        let finish_btn = UIButton()
        finish_btn.bounds = CGRect(x: 0, y: 0, width: 0.45*window_width, height: window_height / 18)
        finish_btn.setTitle("", for: .normal)
        finish_btn.setTitleColor(UIColor.white, for: .normal)
        finish_btn.backgroundColor = UIColor.clear
        finish_btn.layer.borderWidth = 2
        finish_btn.layer.borderColor = UIColor.white.cgColor
        finish_btn.center = CGPoint(x: window_width / 2, y: 0.85*window_height - finish_btn.bounds.height / 2)
        finish_btn.layer.cornerRadius = finish_btn.bounds.height / 2
        finish_btn.tag = 800
        finish_btn.isUserInteractionEnabled = true
        view.addSubview(finish_btn)
        
        let f_img = UIImageView(image: UIImage(named: "next"))
        f_img.bounds = CGRect(x: 0, y: 0, width: 0.25*finish_btn.bounds.width, height: 0.7*finish_btn.bounds.height)
        f_img.center = finish_btn.center
        f_img.tag = 801
        view.addSubview(f_img)

        
        return view
    }
    
}
