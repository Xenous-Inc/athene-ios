//
//  NewWordself.swift
//  testing
//
//  Created by Vadim Zaripov on 27.05.2020.
//  Copyright © 2020 Vadim Zaripov. All rights reserved.
//

import UIKit

class NewWordView: UIView {
    
    let font = "Helvetica"
    
    var categories_centers: [CGPoint] = []
    
    var bottom_bar_height: CGFloat = 0
    var bottom_bar_width: CGFloat = 0
    var bottom_bar_height_small: CGFloat = 0
    var bottom_bar_width_small: CGFloat = 0
    
    var min_len: CGFloat = 0
    var padding: CGFloat = 0

    var finishButton = UIButton(), addButton = UIButton()
    var categoryView = UIView()
    var categoryLabel = UILabel()
    
    init(frame: CGRect, categories: [String]){
        super.init(frame: frame)
        if(categories.count == 0) {return};
        
        min_len = 0.12*frame.width
        padding = 0.04*frame.width
        
        let titleLabel: UILabel = {
            let title_label = UILabel()
            title_label.bounds = CGRect(x: 0, y: 0, width: 0.8*frame.width, height: 0.07*frame.height)
            title_label.center = CGPoint(x: 0.5*frame.width, y: 0.1*frame.height)
            title_label.text = add_word_title
            title_label.textAlignment = .center
            let f_size = FontHelper().getFontSize(strings: [add_word_title, choose_category], font: font, maxFontSize: 120, width: title_label.bounds.width, height: title_label.bounds.height)
            title_label.font = UIFont(name: font, size: CGFloat(f_size))
            title_label.textColor = UIColor.white
            title_label.tag = 1000
            
            return title_label
        }()
        self.addSubview(titleLabel)
        
        for i in 0..<2{
            let ed_text = UITextField()
            ed_text.bounds =  CGRect(x: 0, y: 0, width: 0.6*frame.width, height: 0.07*frame.height)
            ed_text.center = CGPoint(x: 0.5*frame.width, y: CGFloat(3 + 2*i) * 0.07*frame.height)
            ed_text.textColor = UIColor.white
            ed_text.attributedPlaceholder = NSAttributedString(string: ((i == 0) ? russian_field_placeholder : english_field_placeholder),
                                                                       attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(white: 1.0, alpha: 0.5)])
            let font_sz = CGFloat(FontHelper().getInterfaceFontSize(font: font, height: 0.8*ed_text.bounds.height))
            ed_text.font = UIFont(name: font, size: font_sz)
            
            let bottomLine = CALayer()
            bottomLine.frame = CGRect(origin: CGPoint(x: 0, y:ed_text.frame.height - 1), size: CGSize(width: ed_text.frame.width, height: 2))
            bottomLine.backgroundColor = UIColor.init(white: 1, alpha: 0.8).cgColor
            ed_text.borderStyle = .none
            ed_text.layer.addSublayer(bottomLine)
            ed_text.tag = i + 100
            ed_text.backgroundColor = UIColor.clear
            self.addSubview(ed_text)
        }
        
        let chooseCategoryLabel: UILabel = {
            let cat_label = UILabel()
            cat_label.bounds = CGRect(x: 0, y: 0, width: titleLabel.bounds.width, height: titleLabel.bounds.height)
            cat_label.center = CGPoint(x: 0.5*frame.width, y: 0.5*frame.height)
            cat_label.text = choose_category
            cat_label.textAlignment = .center
            cat_label.font = titleLabel.font
            cat_label.textColor = UIColor.white
            
            return cat_label
        }()
        self.addSubview(chooseCategoryLabel)
        
        let categoriesDescriptionLabel: UILabel = {
            let describtion_label = UILabel()
            describtion_label.bounds = CGRect(x: 0, y: 0, width: chooseCategoryLabel.bounds.width, height: 3 * chooseCategoryLabel.bounds.height / 4)
            describtion_label.center = CGPoint(x: 0.5*frame.width, y: 0.5*frame.height + chooseCategoryLabel.bounds.height / 2 + describtion_label.bounds.height / 2)
            describtion_label.text = choose_cat_describtion
            describtion_label.textAlignment = .center
            let f_size_small = FontHelper().getFontSize(strings: [choose_cat_describtion], font: font, maxFontSize: 120, width: describtion_label.bounds.width, height: describtion_label.bounds.height)
            describtion_label.font = UIFont(name: font, size: CGFloat(f_size_small))
            describtion_label.textColor = UIColor.white
            
            return describtion_label
        }()
        self.addSubview(categoriesDescriptionLabel)
        
        let small_font = categoriesDescriptionLabel.font
        
        bottom_bar_width_small = 0.6*frame.width
        bottom_bar_height_small = titleLabel.bounds.height
        
        finishButton = {
            let finish_btn = UIButton()
            finish_btn.bounds = CGRect(x: 0, y: 0, width: 0.45*frame.width, height: bottom_bar_height_small)
            finish_btn.setTitle("", for: .normal)
            finish_btn.setTitleColor(UIColor.white, for: .normal)
            finish_btn.backgroundColor = UIColor.clear
            finish_btn.layer.borderWidth = 2
            finish_btn.layer.borderColor = UIColor.white.cgColor
            finish_btn.center = CGPoint(x: frame.width / 2, y: frame.height - 0.18*frame.height - finish_btn.bounds.height / 2)
            finish_btn.layer.cornerRadius = finish_btn.bounds.height / 2
            finish_btn.tag = 800
            finish_btn.isUserInteractionEnabled = true
            
            return finish_btn
        }()
        self.addSubview(finishButton)
        
        let finishButtonDescription: UILabel = {
            let finish_describtion = UILabel()
            finish_describtion.text = create_word_text
            finish_describtion.bounds = CGRect(x: 0, y: 0, width: 0.9*finishButton.bounds.width, height: categoriesDescriptionLabel.bounds.height / 2)
            finish_describtion.center = CGPoint(x: frame.width / 2, y: finishButton.center.y + finishButton.bounds.height / 2 + 0.9*finish_describtion.bounds.height)
            finish_describtion.textAlignment = .center
            finish_describtion.backgroundColor = UIColor.clear
            finish_describtion.textColor = UIColor.white
            let f_size_smallx2 = FontHelper().getFontSize(strings: [create_word_text], font: font, maxFontSize: 120, width: finish_describtion.bounds.width, height: finish_describtion.bounds.height)
            finish_describtion.font = UIFont(name: font, size: CGFloat(f_size_smallx2))
            finish_describtion.alpha = 0.8
            finish_describtion.tag = 1001
            
            return finish_describtion
        }()
        self.addSubview(finishButtonDescription)
        
        let finishImage: UIImageView = {
            let f_img = UIImageView(image: UIImage(named: "plus"))
            f_img.bounds = CGRect(x: 0, y: 0, width: 0.25*finishButton.bounds.width, height: 0.7*finishButton.bounds.height)
            f_img.center = finishButton.center
            f_img.tag = 1002
            
            return f_img
        }()
        self.addSubview(finishImage)
        
        categoryLabel = {
            let cat_label = UILabel()
            cat_label.text = ""
            cat_label.textAlignment = .center
            cat_label.textColor = UIColor.white
            cat_label.bounds = CGRect(x: 0, y: 0, width: bottom_bar_width_small, height: bottom_bar_height_small)
            cat_label.center = CGPoint(x: 0.5*frame.width, y: categoriesDescriptionLabel.center.y + categoriesDescriptionLabel.bounds.height / 2 + cat_label.bounds.height / 2 + 0.015*frame.height)
            cat_label.backgroundColor = UIColor.clear
            cat_label.tag = 700
            
            return cat_label
        }()
        self.addSubview(categoryLabel)
        
        categoryView = {
            let category_view = UIView()
            category_view.bounds = CGRect(x: 0, y: 0, width: bottom_bar_width_small, height: bottom_bar_height_small)
            category_view.center = CGPoint(x: 0.5*frame.width, y: categoriesDescriptionLabel.center.y + categoriesDescriptionLabel.bounds.height / 2 + category_view.bounds.height / 2 + 0.015*frame.height)
            category_view.backgroundColor = UIColor.white
            category_view.alpha = 0.5
            category_view.tag = 300
            category_view.layer.cornerRadius = min(category_view.bounds.height, category_view.bounds.width) / 2
            
            return category_view
        }()
        self.addSubview(categoryView)
        
        bottom_bar_width = 0.8*frame.width
        bottom_bar_height = frame.height - categoryView.center.y + categoryView.bounds.height / 2 - ((frame.width - bottom_bar_width) / 2)
        
        let d = [NSAttributedString.Key.font: small_font!]
        let block_height = (categories[0] as NSString).size(withAttributes: d).height + 0.015*frame.height
        
        let scroll = UIScrollView()
        scroll.bounds = CGRect(x: 0, y: 0, width: bottom_bar_width - 2*categoryView.layer.cornerRadius, height: bottom_bar_height - 3*categoryView.layer.cornerRadius - block_height)
        scroll.backgroundColor = UIColor.clear
        scroll.center = CGPoint(x: bottom_bar_width / 2, y: categoryView.layer.cornerRadius + scroll.bounds.height / 2)
        scroll.tag = 400
        scroll.isUserInteractionEnabled = true
        categoryView.addSubview(scroll)
        
        var block_lens: [CGFloat] = []
        for i in 0..<categories.count{
            let l1 = 2*padding + (categories[i] as NSString).size(withAttributes: d).width
            block_lens.append(min(max(l1, min_len), scroll.bounds.width))
        }
        
        var start_line = 0
        var current_len: CGFloat = -padding
        var y: CGFloat = block_height / 2
        categories_centers = []
        var trig = true
        
        for i in 0..<categories.count{
            let limit = trig ? scroll.bounds.width - padding : scroll.bounds.width
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
            cur.titleLabel?.font = small_font
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
        
        addButton = {
            let add_btn = UIButton()
            add_btn.bounds = CGRect(x: 0, y: 0, width: 2*padding + (add_cat_text as NSString).size(withAttributes: d).width, height: block_height)
            add_btn.setTitle(add_cat_text, for: .normal)
            add_btn.titleLabel?.font = small_font
            add_btn.setTitleColor(UIColor.init(rgb: add_cat_color), for: .normal)
            add_btn.backgroundColor = UIColor.clear
            add_btn.layer.borderWidth = 2
            add_btn.layer.borderColor = UIColor.init(rgb: add_cat_color).cgColor
            add_btn.center = CGPoint(x: bottom_bar_width_small / 2, y: bottom_bar_height - categoryView.layer.cornerRadius - add_btn.bounds.height / 2)
            add_btn.alpha = 0
            add_btn.clipsToBounds = true
            add_btn.layer.cornerRadius = block_height / 2
            add_btn.tag = 600
            add_btn.isUserInteractionEnabled = false
            
            return add_btn
        }()
        categoryView.addSubview(addButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

}
