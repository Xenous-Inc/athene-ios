//
//  CategoryViewCell.swift
//  testing
//
//  Created by Vadim Zaripov on 06.07.2020.
//  Copyright © 2020 Vadim Zaripov. All rights reserved.
//

import UIKit

import UIKit
class CategoryViewCell : UIView {
    
    var opened = false
    
    var heightSmall: CGFloat!
    var heightBig: CGFloat!
    
    var deleteButton: UIButton!
    var shareButton: UIButton!
    var learnButton: UIButton!
    var infoButton: UIButton!
    var title = ""
     
    init(frame: CGRect, text: String){
        super.init(frame: frame)
        
        clipsToBounds = true
        title = text
        
        heightSmall = frame.height
        heightBig = 2.3*frame.height
        
        backgroundColor = UIColor.init(white: 1, alpha: 0.4)
        layer.cornerRadius = frame.height / 2
        
        let titleLabel: UILabel = {
            let label = UILabel(frame: CGRect(x: layer.cornerRadius, y: 0.1*frame.height, width: frame.width - 2*layer.cornerRadius, height: 0.8*frame.height))
            label.text = text
            label.textColor = .white
            label.font = UIFont(name: "Helvetica", size: CGFloat(FontHelper().getFontSizeByHeight(text: text, font: "Helvetica", maxFontSize: 120, height: label.frame.height)))
            return label
        }()
        addSubview(titleLabel)
        
        let imageNames = ["share", "book", "cross", "info"]
        let imageHeight = 0.5*(heightBig - heightSmall)
        let imagePadding = (frame.width - CGFloat(imageNames.count)*imageHeight) / CGFloat(imageNames.count+1)
        var x = imagePadding
        for i in 0..<4{
            let button = UIButton(frame: CGRect(x: x, y: heightSmall + (heightBig - heightSmall - imageHeight) / 2, width: imageHeight, height: imageHeight))
            button.setBackgroundImage(UIImage(named: imageNames[i]), for: .normal)
            button.layoutIfNeeded()
            button.subviews.first?.contentMode = .scaleAspectFit
            x += button.bounds.width + imagePadding
            
            addSubview(button)
            switch i {
            case 0:
                shareButton = button
                break
            case 1:
                learnButton = button
                break
            case 2:
                deleteButton = button
                break
            case 3:
                infoButton = button
                break
            default:
                break
            }
        }
    }
    
    func handleTap(){
        opened = !opened
        if(opened){
            expand()
        }else{
            shrink()
        }
    }
    
    private func expand(){
        self.frame = CGRect(x: self.frame.minX, y: self.frame.minY, width: self.frame.width, height: self.heightBig)
    }
    
    private func shrink(){
        self.frame = CGRect(x: self.frame.minX, y: self.frame.minY, width: self.frame.width, height: self.heightSmall)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
 
}
