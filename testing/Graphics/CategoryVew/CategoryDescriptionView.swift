//
//  CategoryDescriptionView.swift
//  testing
//
//  Created by Vadim Zaripov on 06.07.2020.
//  Copyright © 2020 Vadim Zaripov. All rights reserved.
//

import UIKit

class CategoryDescriptionView: UIView {
    
    var backButton: UIButton!
    var cells: [CategoryDescriptionViewCell]!
    var title = ""

    init(frame: CGRect, name: String, words: [Word], canLearn: Bool, hasBackButton: Bool){
        super.init(frame: frame)
        title = name
        
        if(hasBackButton){
            backButton = {
                let button = UIButton(frame: CGRect(x: 0.08*frame.width, y: 0.06*frame.height, width: 0.07*frame.height, height: 0.07*frame.height))
                button.setBackgroundImage(UIImage(named: "back"), for: .normal)
                button.layoutIfNeeded()
                button.subviews.first?.contentMode = .scaleAspectFit
                
                return button
            }()
            addSubview(backButton)
        }
        
        let titleLabel: UILabel = {
            let minx = hasBackButton ? backButton.frame.maxX + 0.03*frame.width : 0.1*frame.width
            let label = UILabel(frame: CGRect(x: minx, y: 0.03*frame.height, width: 0.9*frame.width - minx, height: 0.1*frame.height))
            label.text = name
            label.font = UIFont(name: "Helvetica", size: CGFloat(FontHelper().getInterfaceFontSize(font: "Helvetica", height: label.bounds.height)))
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
            y: titleLabel.frame.maxY + 0.02*frame.height,
            width: frame.width,
            height: frame.height - titleLabel.frame.maxY - 0.05*frame.height))
        addSubview(scrollView)
        
        let padding = 0.03*frame.width
        var y = padding
        
        let height = 0.08*frame.height
        cells = []
        for word in words{
            let wordView =  CategoryDescriptionViewCell(frame: CGRect(x: 0.1*frame.width, y: y, width: 0.8*frame.width, height: height), word: word, canLearn: canLearn)
            scrollView.addSubview(wordView)
            cells.append(wordView)
            y += height + padding
        }
        scrollView.contentSize.height = y
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func deleteWord(word: Word){
        guard let index = cells.firstIndex(where: {$0.word.english == word.english}) else {return}
        
        cells[index].isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.4, animations: {
            self.cells[index].alpha = 0
            
            for i in (index+1)..<self.cells.count{
                self.cells[i].center = CGPoint(x: self.cells[i].center.x, y: self.cells[i].center.y - 0.03*self.frame.width - self.cells[i].frame.height)
            }
        }) { (finished) in
            self.cells[index].removeFromSuperview()
            self.cells.remove(at: index)
        }
    }
    
}
