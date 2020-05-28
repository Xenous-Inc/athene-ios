//
//  SignupView.swift
//  testing
//
//  Created by Vadim Zaripov on 28.05.2020.
//  Copyright © 2020 Vadim Zaripov. All rights reserved.
//

import UIKit

class SignupView: UIView {

    let font = "Helvetica"
    
    override init(frame: CGRect){
        super.init(frame: frame)
        
        let height = 0.05*frame.height
        let font_sz = CGFloat(FontHelper().getInterfaceFontSize(font: font, height: height))
        
        let title_label = UILabel()
        title_label.bounds = CGRect(x: 0, y: 0, width: 0.8*frame.width, height: frame.height / 18)
        title_label.center = CGPoint(x: 0.5*frame.width, y: frame.height / 5)
        title_label.text = sign_up_title
        title_label.textAlignment = .center
        let f_size = FontHelper().getFontSize(strings: [sign_up_title], font: font, maxFontSize: 120, width: title_label.bounds.width, height: title_label.bounds.height)
        title_label.font = UIFont(name: font, size: CGFloat(f_size))
        title_label.textColor = UIColor.white
        title_label.tag = 1000
        self.addSubview(title_label)
        
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
        }
        
        let pd = 0.05*frame.width
        
        let finish_btn = UIButton()
        finish_btn.bounds = CGRect(x: 0, y: 0, width: 0.4*frame.width, height: frame.height / 18)
        finish_btn.setTitle("", for: .normal)
        finish_btn.setTitleColor(UIColor.white, for: .normal)
        finish_btn.backgroundColor = UIColor.clear
        finish_btn.layer.borderWidth = 2
        finish_btn.layer.borderColor = UIColor.white.cgColor
        finish_btn.center = CGPoint(x: (frame.width - 2*finish_btn.bounds.width - pd) / 2 + finish_btn.bounds.width / 2, y: 0.85*frame.height - finish_btn.bounds.height / 2)
        finish_btn.layer.cornerRadius = finish_btn.bounds.height / 2
        finish_btn.tag = 800
        finish_btn.isUserInteractionEnabled = true
        self.addSubview(finish_btn)
        
        let f_img = UIImageView(image: UIImage(named: "next"))
        f_img.bounds = CGRect(x: 0, y: 0, width: 0.35*finish_btn.bounds.width, height: 0.7*finish_btn.bounds.height)
        f_img.center = finish_btn.center
        f_img.tag = 801
        self.addSubview(f_img)
        
        let google_btn = UIButton()
        google_btn.bounds = finish_btn.bounds
        google_btn.center = CGPoint(x: finish_btn.frame.maxX + pd + google_btn.bounds.width / 2, y: 0.85*frame.height - finish_btn.bounds.height / 2)
        google_btn.backgroundColor = UIColor.white
        google_btn.layer.cornerRadius = google_btn.bounds.height / 2
        google_btn.tag = 802
        self.addSubview(google_btn)
        
        let img = UIImage(named: "google_logo")
        let h = 0.9*google_btn.bounds.height
        let newSize = CGSize(width: h*(img!.size.width / img!.size.height), height: h)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        let imageView = UIImageView(image: img)
        imageView.bounds = rect
        imageView.center = google_btn.center
        self.addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
