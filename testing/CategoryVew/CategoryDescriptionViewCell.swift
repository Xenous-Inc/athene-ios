//
//  CategoryDescriptionViewCell.swift
//  testing
//
//  Created by Vadim Zaripov on 07.07.2020.
//  Copyright © 2020 Vadim Zaripov. All rights reserved.
//

import UIKit

class CategoryDescriptionViewCell: UIView {

    var word: Word!
    var titleLabel: UILabel!
    var learnButton: UIButton?
    
    init(frame: CGRect, word: Word, canLearn: Bool){
        super.init(frame: frame)
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(flip(gesture:))))

        
        self.word = word
        
        backgroundColor = UIColor.init(white: 1, alpha: 0.4)
        layer.cornerRadius = frame.height / 2
        
        if(canLearn){
            learnButton = {
                let buttonSize = 0.6*frame.height
                let button = UIButton(frame: CGRect(
                    x: frame.width - layer.cornerRadius - buttonSize / 2,
                    y: (frame.height - buttonSize) / 2,
                    width: buttonSize,
                    height: buttonSize))
                button.setBackgroundImage(UIImage(named: "book"), for: .normal)
                button.layoutIfNeeded()
                button.subviews.first?.contentMode = .scaleAspectFit
                return button
            }()
            addSubview(learnButton!)
        }
        
        titleLabel = {
            let wordLabel = UILabel(frame: CGRect(
                x: layer.cornerRadius,
                y: 0.1*frame.height,
                width: frame.width - 2*layer.cornerRadius - ((learnButton == nil) ? 0 : learnButton!.frame.width),
                height: 0.85*frame.height))
            wordLabel.text = word.english
            wordLabel.textColor = .white
            wordLabel.font = UIFont(name: "Helvetica", size: CGFloat(FontHelper().getFontSizeByHeight(text: word.english, font: "Helvetica", maxFontSize: 120, height: wordLabel.frame.height)))
            
            return wordLabel
        }()
        addSubview(titleLabel)
        
    }
    
    @objc func flip(gesture: Any){
        isUserInteractionEnabled = false
        changeTitleLabel(text: word.russian) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9, execute: {
                self.changeTitleLabel(text: self.word.english) {
                    self.isUserInteractionEnabled = true
                }
            })
        }
    }
    
    func changeTitleLabel(text: String, completion: @escaping () -> Void = { }){
        UIView.animate(withDuration: 0.3, animations:{
            self.titleLabel.alpha = 0
        }, completion: {finished in
            self.titleLabel.text = text
            UIView.animate(withDuration: 0.3, animations: {
                self.titleLabel.alpha = 1
            }, completion: {finished in
                completion()
            })
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
