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
    
    init(width: CGFloat, height: CGFloat) {
        window_width = width
        window_height = height
    }
    
    func buildCreateWord(categories: [String]) -> UIView{
        let view = UIView(frame: CGRect(x: 0, y: 0, width: window_width, height: window_height))
        
        let title_label = UILabel()
        title_label.bounds = CGRect(x: 0, y: 0, width: 0.8*window_width, height: window_height / 18)
        title_label.center = CGPoint(x: 0.5*window_width, y: window_height / 6)
        title_label.text = add_word_title
        title_label.textAlignment = .center
        let f_size = FontHelper().getFontSize(strings: [add_word_title, choose_category], font: font, maxFontSize: 120, width: title_label.bounds.width, height: title_label.bounds.height)
        title_label.font = UIFont(name: font, size: CGFloat(f_size))
        title_label.textColor = UIColor.white
        view.addSubview(title_label)
        
        for i in 0..<2{
            let ed_text = UITextField()
            ed_text.bounds =  CGRect(x: 0, y: 0, width: 0.6*window_width, height: window_height / 18)
            ed_text.center = CGPoint(x: 0.5*window_width, y: CGFloat(5 + 2*i) * window_height / 18)
            ed_text.textColor = UIColor.white
            ed_text.attributedPlaceholder = NSAttributedString(string: ((i == 0) ? russian_field_placeholder : english_field_placeholder),
                                                                       attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(white: 1.0, alpha: 0.5)])
            let bottomLine = CALayer()
            bottomLine.frame = CGRect(origin: CGPoint(x: 0, y:ed_text.frame.height - 1), size: CGSize(width: ed_text.frame.width, height: 2))
            bottomLine.backgroundColor = UIColor.init(white: 1, alpha: 0.8).cgColor
            ed_text.borderStyle = .none
            ed_text.layer.addSublayer(bottomLine)
            ed_text.tag = i + 100
            ed_text.backgroundColor = UIColor.clear
            view.addSubview(ed_text)
        }
        
        let cat_label = UILabel()
        cat_label.bounds = CGRect(x: 0, y: 0, width: title_label.bounds.width, height: title_label.bounds.height)
        cat_label.center = CGPoint(x: 0.5*window_width, y: 0.5*window_height)
        cat_label.text = choose_category
        cat_label.textAlignment = .center
        cat_label.font = UIFont(name: font, size: CGFloat(f_size))
        cat_label.textColor = UIColor.white
        view.addSubview(cat_label)
        
        let describtion_label = UILabel()
        describtion_label.bounds = CGRect(x: 0, y: 0, width: cat_label.bounds.width, height: 3 * cat_label.bounds.height / 4)
        describtion_label.center = CGPoint(x: 0.5*window_width, y: 0.5*window_height + cat_label.bounds.height / 2 + describtion_label.bounds.height / 2)
        describtion_label.text = choose_cat_describtion
        describtion_label.textAlignment = .center
        let f_size_small = FontHelper().getFontSize(strings: [choose_cat_describtion], font: font, maxFontSize: 120, width: describtion_label.bounds.width, height: describtion_label.bounds.height)
        describtion_label.font = UIFont(name: font, size: CGFloat(f_size_small))
        describtion_label.textColor = UIColor.white
        view.addSubview(describtion_label)
        
        
        bottom_bar_width_small = 0.6*window_width
        bottom_bar_height_small = title_label.bounds.height
        let finish_btn = UIButton()
        finish_btn.bounds = CGRect(x: 0, y: 0, width: 0.45*window_width, height: bottom_bar_height_small)
        finish_btn.setTitle("", for: .normal)
        finish_btn.setTitleColor(UIColor.white, for: .normal)
        finish_btn.backgroundColor = UIColor.clear
        finish_btn.layer.borderWidth = 2
        finish_btn.layer.borderColor = UIColor.white.cgColor
        finish_btn.center = CGPoint(x: window_width / 2, y: window_height - 0.18*window_height - finish_btn.bounds.height / 2)
        finish_btn.layer.cornerRadius = finish_btn.bounds.height / 2
        finish_btn.tag = 800
        finish_btn.isUserInteractionEnabled = true
        view.addSubview(finish_btn)
        
        let finish_describtion = UILabel()
        finish_describtion.text = create_word_text
        finish_describtion.bounds = CGRect(x: 0, y: 0, width: 0.9*finish_btn.bounds.width, height: describtion_label.bounds.height / 2)
        finish_describtion.center = CGPoint(x: window_width / 2, y: finish_btn.center.y + finish_btn.bounds.height / 2 + 0.9*finish_describtion.bounds.height)
        finish_describtion.textAlignment = .center
        finish_describtion.backgroundColor = UIColor.clear
        finish_describtion.textColor = UIColor.white
        let f_size_smallx2 = FontHelper().getFontSize(strings: [create_word_text], font: font, maxFontSize: 120, width: finish_describtion.bounds.width, height: finish_describtion.bounds.height)
        finish_describtion.font = UIFont(name: font, size: CGFloat(f_size_smallx2))
        finish_describtion.alpha = 0.7
        view.addSubview(finish_describtion)
        
        let f_img = UIImageView(image: UIImage(named: "plus"))
        f_img.bounds = CGRect(x: 0, y: 0, width: 0.25*finish_btn.bounds.width, height: 0.7*finish_btn.bounds.height)
        f_img.center = finish_btn.center
        view.addSubview(f_img)
        
        let ans_view = UILabel()
        ans_view.text = ""
        ans_view.textAlignment = .center
        ans_view.textColor = UIColor.white
        ans_view.bounds = CGRect(x: 0, y: 0, width: bottom_bar_width_small, height: bottom_bar_height_small)
        ans_view.center = CGPoint(x: 0.5*window_width, y: describtion_label.center.y + describtion_label.bounds.height / 2 + ans_view.bounds.height / 2 + 0.015*window_height)
        ans_view.backgroundColor = UIColor.clear
        ans_view.tag = 700
        view.addSubview(ans_view)
        
        let category_view = UIView()
        category_view.bounds = CGRect(x: 0, y: 0, width: bottom_bar_width_small, height: bottom_bar_height_small)
        category_view.center = CGPoint(x: 0.5*window_width, y: describtion_label.center.y + describtion_label.bounds.height / 2 + category_view.bounds.height / 2 + 0.015*window_height)
        category_view.backgroundColor = UIColor.white
        category_view.alpha = 0.5
        category_view.tag = 300
        category_view.layer.cornerRadius = min(category_view.bounds.height, category_view.bounds.width) / 2
        view.addSubview(category_view)
        bottom_bar_width = 0.8*window_width
        bottom_bar_height = window_height - category_view.center.y + category_view.bounds.height / 2 - ((window_width - bottom_bar_width) / 2)
        
        let cross_sz = 0.07*bottom_bar_width
        let d = [NSAttributedString.Key.font:UIFont(name:font, size:CGFloat(f_size_small))!]
        let block_height = (categories[0] as NSString).size(withAttributes: d).height + 0.015*window_height
        
        let scroll = UIScrollView()
        scroll.bounds = CGRect(x: 0, y: 0, width: bottom_bar_width - 2*category_view.layer.cornerRadius, height: bottom_bar_height - 3*category_view.layer.cornerRadius - block_height)
        scroll.backgroundColor = UIColor.clear
        scroll.center = CGPoint(x: bottom_bar_width / 2, y: category_view.layer.cornerRadius + scroll.bounds.height / 2)
        scroll.tag = 400
        scroll.isUserInteractionEnabled = true
        category_view.addSubview(scroll)
        
        let min_len = 0.12*window_width
        let padding = 0.04*window_width
        var block_lens: [CGFloat] = []
        for i in 0..<categories.count{
            let l1 = 2*padding + (categories[i] as NSString).size(withAttributes: d).width
            block_lens.append(max(l1, min_len))
        }
        var start_line = 0
        var current_len: CGFloat = -padding
        var y: CGFloat = block_height / 2
        categories_centers = []
        var trig = true
        for i in 0..<categories.count{
            let limit = trig ? scroll.bounds.width - padding - cross_sz : scroll.bounds.width
            if(current_len + padding + block_lens[i] > limit){
                trig = false
                let n = i - start_line
                var actual_pd = (limit - (current_len - CGFloat(n-1)*padding)) / CGFloat(n + 1)
                var border_pd = actual_pd
                if(actual_pd < padding){
                    actual_pd = padding
                    border_pd = (limit - current_len) / 2
                }
                var x = border_pd
                for j in start_line..<i{
                    categories_centers.append(CGPoint(x: x + block_lens[j] / 2, y: y))
                    x += block_lens[j] + actual_pd
                }
                y += block_height + padding
                start_line = i
                current_len = block_lens[i]
            }else{
                current_len += padding + block_lens[i]
            }
        }
        let n = categories.count - start_line
        var actual_pd = (scroll.bounds.width - (current_len - CGFloat(n-1)*padding)) / CGFloat(n + 1)
        var border_pd = actual_pd
        if(actual_pd < padding){
            actual_pd = padding
            border_pd = (scroll.bounds.width - current_len) / 2
        }
        var x = border_pd
        for j in start_line..<categories.count{
            categories_centers.append(CGPoint(x: x + block_lens[j] / 2, y: y))
            x += block_lens[j] + actual_pd
        }
        
        for i in 0..<categories.count{
            let cur = UIButton()
            cur.bounds = CGRect(x: 0, y: 0, width: block_lens[i], height: block_height)
            cur.setTitle(categories[i], for: .normal)
            cur.titleLabel?.font = UIFont(name: font, size: CGFloat(f_size_small))
            cur.backgroundColor = UIColor.init(rgb: colors[i % colors.count])
            cur.setTitleColor(UIColor.white, for: .normal)
            cur.center = CGPoint(x: scroll.bounds.width / 2, y: block_height / 2)
            cur.alpha = 0
            cur.clipsToBounds = true
            cur.layer.cornerRadius = min(block_lens[i], block_height) / 2
            cur.tag = i + 1
            cur.isUserInteractionEnabled = false
            scroll.addSubview(cur)
        }
        scroll.contentSize.height = categories_centers.last!.y + block_height / 2
        scroll.isScrollEnabled = false
        
        let add_btn = UIButton()
        add_btn.bounds = CGRect(x: 0, y: 0, width: 2*padding + (add_cat_text as NSString).size(withAttributes: d).width, height: block_height)
        add_btn.setTitle(add_cat_text, for: .normal)
        add_btn.titleLabel?.font = UIFont(name: font, size: CGFloat(f_size_small))
        add_btn.setTitleColor(UIColor.init(rgb: add_cat_color), for: .normal)
        add_btn.backgroundColor = UIColor.clear
        add_btn.layer.borderWidth = 2
        add_btn.layer.borderColor = UIColor.init(rgb: add_cat_color).cgColor
        add_btn.center = CGPoint(x: bottom_bar_width_small / 2, y: bottom_bar_height - category_view.layer.cornerRadius - add_btn.bounds.height / 2)
        add_btn.alpha = 0
        add_btn.clipsToBounds = true
        add_btn.layer.cornerRadius = block_height / 2
        add_btn.tag = 600
        add_btn.isUserInteractionEnabled = false
        category_view.addSubview(add_btn)
        
        let cross = UIButton()
        cross.frame = CGRect(x: bottom_bar_width - category_view.layer.cornerRadius -  cross_sz - (bottom_bar_width - category_view.bounds.width) / 2, y: category_view.layer.cornerRadius, width: cross_sz, height: cross_sz)
        drawLine(view: cross, start: CGPoint(x: 0, y: 0), end: CGPoint(x: cross_sz, y: cross_sz), color: UIColor.init(rgb: cross_color).cgColor, width: 2)
        drawLine(view: cross, start: CGPoint(x: 0, y: cross_sz), end: CGPoint(x: cross_sz, y: 0), color: UIColor.init(rgb: cross_color).cgColor, width: 2)
        cross.tag = 500
        cross.alpha = 0
        cross.backgroundColor = UIColor.clear
        category_view.addSubview(cross)
        
        return view
    }
    
    func buildMainView() -> UIView{
        let view = UIView(frame: CGRect(x: 0, y: 0, width: window_width, height: window_height))
        let height = window_height / 18
        let font_sz = CGFloat(FontHelper().getInterfaceFontSize(font: font, height: height))
        
        let title_label = UILabel(frame: CGRect(x: 0.05*window_width, y: 0.17*window_height, width: 0.9*window_width, height: height))
        title_label.text = main_page_title
        title_label.font = UIFont(name: font, size: font_sz)
        title_label.textColor = UIColor.white
        title_label.textAlignment = .center
        view.addSubview(title_label)
        
        for i in 0..<2{
            let y = window_height / 2 + ((i == 0) ? -1.5*height : 0.5*height)
            let ed_text = UITextField(frame: CGRect(x: 0.1*window_width, y: y, width: 0.8*window_width, height: height))
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
            ed_text.isUserInteractionEnabled = (i == 1)
            ed_text.textAlignment = .center
            if(i == 1){
                ed_text.attributedPlaceholder = NSAttributedString(string: main_page_placeholders[i], attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(white: 1.0, alpha: 0.5)])
            }
            view.addSubview(ed_text)
        }
        
        let next_btn = UIButton(frame: CGRect(x: 0.275*window_width, y: 0.83*window_height - height, width: 0.45*window_width, height: height))
        next_btn.setTitle("", for: .normal)
        next_btn.setTitleColor(UIColor.white, for: .normal)
        next_btn.backgroundColor = UIColor.clear
        next_btn.layer.borderWidth = 2
        next_btn.layer.borderColor = UIColor.white.cgColor
        next_btn.layer.cornerRadius = next_btn.bounds.height / 2
        next_btn.tag = 100
        next_btn.isUserInteractionEnabled = true
        let arrow_img = UIImageView(image: UIImage(named: "plus"))
        arrow_img.bounds = CGRect(x: 0, y: 0, width: 0.33*next_btn.bounds.width, height: 0.7*next_btn.bounds.height)
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
        describtionlabel.alpha = 0.5
        describtionlabel.textAlignment = .center
        describtionlabel.tag = 102
        view.addSubview(describtionlabel)
        
        return view
    }
    
}
