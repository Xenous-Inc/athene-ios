//
//  ChangeWordView.swift
//  testing
//
//  Created by Vadim Zaripov on 27.05.2020.
//  Copyright © 2020 Vadim Zaripov. All rights reserved.
//

import UIKit

class ChangeWordView: NewWordView {

    var cancelButton = UIButton()
    
    override init(frame: CGRect, categories: [String]) {
        let pd_top = 0.15*frame.height, pd_bottom = 0.05*frame.height
        let newFrame = CGRect(x: frame.minX, y: frame.minY + pd_top, width: frame.width, height: frame.height - pd_top - pd_bottom)
        super.init(frame: newFrame, categories: categories)
        
        (viewWithTag(1000) as! UILabel).text = edit_page_title
        
        finishButton.frame = CGRect(x: 0.1*newFrame.width, y: newFrame.height - 0.18*newFrame.height - bottom_bar_height_small, width: 0.37*newFrame.width, height: bottom_bar_height_small)
        viewWithTag(1002)?.center = finishButton.center
        
        (viewWithTag(1001) as! UILabel).text = edit_page_describtion
        (viewWithTag(1001) as! UILabel).center = CGPoint(x: finishButton.center.x, y: finishButton.center.y + finishButton.bounds.height / 2 + 0.9*(viewWithTag(1001) as! UILabel).bounds.height)
        
        cancelButton = {
            let cancel_btn = UIButton()
            cancel_btn.bounds = finishButton.bounds
            cancel_btn.setTitle(edit_page_cancel_text, for: .normal)
            cancel_btn.setTitleColor(UIColor.white, for: .normal)
            cancel_btn.backgroundColor = UIColor.clear
            cancel_btn.layer.borderWidth = 2
            cancel_btn.layer.borderColor = UIColor.white.cgColor
            cancel_btn.center = CGPoint(x: 0.9*newFrame.width - cancel_btn.bounds.width / 2, y: finishButton.center.y)
            cancel_btn.layer.cornerRadius = cancel_btn.bounds.height / 2
            cancel_btn.tag = 801
            cancel_btn.isUserInteractionEnabled = true
            
            return cancel_btn
        }()
        self.addSubview(cancelButton)
        self.sendSubviewToBack(cancelButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
