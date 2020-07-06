//
//  CategoryDescriptionView.swift
//  testing
//
//  Created by Vadim Zaripov on 06.07.2020.
//  Copyright © 2020 Vadim Zaripov. All rights reserved.
//

import UIKit

class CategoryDescriptionView: UIView {

    init(frame: CGRect, name: String, words: [Word]){
        super.init(frame: frame)
        
        let titleLabel: UILabel = {
            let label = UILabel(frame: CGRect(x: 0.1*frame.width, y: 0.03*frame.height, width: 0.8*frame.width, height: 0.1*frame.height))
            label.text = name
            label.font = UIFont(name: "Helvetica", size: CGFloat(FontHelper().getFontSize(
            strings: [name],
            font: "Helvetica",
            maxFontSize: 120,
            width: label.bounds.width,
            height: label.bounds.height)))
            label.textColor = .white
            
            let bottomLine = CALayer()
            bottomLine.frame = CGRect(origin: CGPoint(x: 0, y:label.frame.height - 1), size: CGSize(width: label.frame.width, height: 2))
            bottomLine.backgroundColor = UIColor.white.cgColor
            label.layer.addSublayer(bottomLine)
            
            return label
        }()
        addSubview(titleLabel)
        
        let scrollView = UIScrollView(frame: CGRect(
            x: 0,
            y: titleLabel.frame.maxY + 0.05*frame.height,
            width: frame.width,
            height: frame.height - titleLabel.frame.maxY - 0.05*frame.height))
        addSubview(scrollView)
        
        let padding = 0.03*frame.width
        var y = padding
        
        let height = 0.08*frame.height
        
        for word in words{
            let wordView =  UIView(frame: CGRect(x: 0.1*frame.width, y: y, width: 0.8*frame.width, height: height))
            wordView.backgroundColor = UIColor.init(white: 1, alpha: 0.4)
            wordView.layer.cornerRadius = wordView.frame.height / 2
            
            let wordLabel = UILabel(frame: CGRect(
                x: wordView.layer.cornerRadius,
                y: 0.1*wordView.frame.height,
                width: wordView.frame.width - 2*wordView.layer.cornerRadius,
                height: 0.85*wordView.frame.height))
            wordLabel.text = word.english
            wordLabel.textColor = .white
            wordLabel.font = UIFont(name: "Helvetica", size: CGFloat(FontHelper().getFontSizeByHeight(text: word.english, font: "Helvetica", maxFontSize: 120, height: wordLabel.frame.height)))
            wordView.addSubview(wordLabel)
            
            scrollView.addSubview(wordView)
            
            y += height + padding
        }
        scrollView.contentSize.height = y
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
