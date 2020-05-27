//
//  GraphicBuilder.swift
//  testing
//
//  Created by Vadim on 19/03/2020.
//  Copyright © 2020 Vadim Zaripov. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class GraphicBuilder: NSObject{
    
    var window_width: CGFloat
    var window_height: CGFloat
    let font = "Helvetica"
    
    var categories_centers: [CGPoint] = []
    
    var bottom_bar_height: CGFloat = 0
    var bottom_bar_width: CGFloat = 0
    var bottom_bar_height_small: CGFloat = 0
    var bottom_bar_width_small: CGFloat = 0
    
    let min_len: CGFloat
    let padding: CGFloat
    
    init(width: CGFloat, height: CGFloat) {
        window_width = width
        window_height = height
        min_len = 0.12*window_width
        padding = 0.04*window_width
    }
    
    func buildMainView() -> UIView{
        let view = UIView(frame: CGRect(x: 0, y: 0, width: window_width, height: window_height))
        let height = 0.07*window_height
        let font_sz = CGFloat(FontHelper().getInterfaceFontSize(font: font, height: height))
        
        let title_label = UILabel(frame: CGRect(x: 0.05*window_width, y: 0.1*window_height, width: 0.9*window_width, height: height))
        title_label.text = main_page_title
        title_label.font = UIFont(name: font, size: font_sz)
        title_label.textColor = UIColor.white
        title_label.textAlignment = .center
        view.addSubview(title_label)
        
        for i in 0..<2{
            let y = 0.45*window_height + ((i == 0) ? -1.5*height : 0.5*height)
            let ed_text = UITextField(frame: CGRect(x: 0.1*window_width, y: y, width: 0.8*window_width, height: height))
            ed_text.text = (i == 0) ? loading_text : ""
            ed_text.font = UIFont(name: font, size: font_sz)
            ed_text.textColor = UIColor.white
            
            ed_text.adjustsFontSizeToFitWidth = true
            
            ed_text.autocorrectionType = .no
            
            let bottomLine = CALayer()
            bottomLine.frame = CGRect(origin: CGPoint(x: 0, y:ed_text.frame.height - 1), size: CGSize(width: ed_text.frame.width, height: 2))
            bottomLine.backgroundColor = UIColor.white.cgColor
            ed_text.borderStyle = .none
            ed_text.layer.addSublayer(bottomLine)
            
            ed_text.tag = i + 1
            ed_text.backgroundColor = UIColor.clear
            ed_text.isUserInteractionEnabled = (i == 1)
            ed_text.textAlignment = .center
            if(i == 1){
                ed_text.attributedPlaceholder = NSAttributedString(string: main_page_placeholders[i], attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(white: 1.0, alpha: 0.5)])
            }
            view.addSubview(ed_text)
        }
        
        let next_btn = UIButton(frame: CGRect(x: 0.275*window_width, y: 0.77*window_height - height, width: 0.45*window_width, height: height))
        next_btn.setTitle("", for: .normal)
        next_btn.setTitleColor(UIColor.white, for: .normal)
        next_btn.backgroundColor = UIColor.clear
        next_btn.layer.borderWidth = 2
        next_btn.layer.borderColor = UIColor.white.cgColor
        next_btn.layer.cornerRadius = next_btn.bounds.height / 2
        next_btn.tag = 100
        next_btn.isUserInteractionEnabled = true
        
        let arr_img = UIImage(named: "next")
        let newSize = CGSize(width: 0.33*next_btn.bounds.width, height: 0.7*next_btn.bounds.height)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        arr_img?.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let arrow_img = UIImageView(image: newImage!.withRenderingMode(.alwaysTemplate))
        arrow_img.contentMode = .right
        arrow_img.clipsToBounds = true
        arrow_img.tintColor = UIColor.white
        arrow_img.bounds = rect
        arrow_img.center = next_btn.center
        arrow_img.tag = 101
        view.addSubview(arrow_img)
        view.addSubview(next_btn)
        
        let describtionlabel = UILabel(frame: CGRect(x: 0, y: 0, width: next_btn.bounds.width, height: 0.35*next_btn.bounds.height))
        describtionlabel.center = CGPoint(x: window_width / 2, y: next_btn.frame.maxY + describtionlabel.bounds.height / 2)
        describtionlabel.text = main_page_describtion_check
        let f_sz_small = CGFloat(FontHelper().getInterfaceFontSize(font: font, height: describtionlabel.bounds.height))
        describtionlabel.font = UIFont(name: font, size: f_sz_small)
        describtionlabel.textColor = UIColor.white
        describtionlabel.alpha = 0.8
        describtionlabel.textAlignment = .center
        describtionlabel.tag = 102
        view.addSubview(describtionlabel)
        
        let forgot_btn = UIButton(frame: CGRect(x: 0, y: 0, width: 0.45*window_width, height: height))
        forgot_btn.center = CGPoint(x: window_width / 2, y: describtionlabel.frame.maxY + forgot_btn.bounds.height)
        forgot_btn.setTitle(main_page_forgot_word_text, for: .normal)
        forgot_btn.setTitleColor(UIColor.white, for: .normal)
        forgot_btn.backgroundColor = UIColor.clear
        forgot_btn.layer.borderWidth = 2
        forgot_btn.layer.borderColor = UIColor.white.cgColor
        forgot_btn.layer.cornerRadius = next_btn.bounds.height / 2
        forgot_btn.tag = 103
        forgot_btn.isUserInteractionEnabled = true
        view.addSubview(forgot_btn)
        
        //Incorrect answer
        
        let incorrect_label = UILabel(frame: CGRect(x: 0, y: window_height / 2 - 3.5*height, width: window_width, height: height))
        incorrect_label.textColor = UIColor.white
        incorrect_label.text = main_page_incorrect
        incorrect_label.font = UIFont(name: font, size: font_sz)
        incorrect_label.textAlignment = .center
        incorrect_label.tag = 200
        incorrect_label.alpha = 0
        incorrect_label.isUserInteractionEnabled = false
        view.addSubview(incorrect_label)
        
        for i in 0..<2{
            let btn = UIButton(frame: CGRect(x: window_width / 2 + CGFloat(3*i - 2)*height, y: 0.45*window_height + 2.1*height, width: height, height: height))
            btn.backgroundColor = UIColor.clear
            btn.setImage(UIImage(named: ((i == 0) ? "edit" : "cross")), for: .normal)
            btn.setTitle("", for: .normal)
            btn.tag = 205 + i
            btn.isUserInteractionEnabled = false
            btn.alpha = 0
            view.addSubview(btn)
            
            let descr = UILabel()
            let d = [NSAttributedString.Key.font:UIFont(name:font, size:CGFloat(f_sz_small))!]
            descr.bounds = CGRect(x: 0, y: 0, width: (main_page_img_describtions[i] as NSString).size(withAttributes: d).width, height: describtionlabel.bounds.height)
            descr.center = CGPoint(x: btn.center.x, y: btn.frame.maxY + descr.bounds.height)
            descr.font = UIFont(name: font, size: f_sz_small)
            descr.text = main_page_img_describtions[i]
            descr.textColor = UIColor.white
            descr.textAlignment = .center
            descr.alpha = 0
            descr.isUserInteractionEnabled = false
            descr.tag = 201 + i
            view.addSubview(descr)
        }
        
        return view
    }
    
}
