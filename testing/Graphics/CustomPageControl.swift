//
//  CustomPageControl.swift
//  testing
//
//  Created by Vadim on 28/03/2020.
//  Copyright © 2020 Vadim Zaripov. All rights reserved.
//

import Foundation
import UIKit

class CustomPageControl: UIView{
    var tabs: Int = 0
    var current: Int = 0
    var cords: [CGRect] = []
    
    var current_tab = UIView(), next_tab = UIView()
    
    var color = UIColor()
    
    var was_set = false
    
    var tab_w: CGFloat = 0
    
    func set(width: CGFloat, height: CGFloat, tabs: Int, start: Int, color: UIColor){
        if(was_set){return}
        was_set = true
        self.bounds = CGRect(x: 0, y: 0, width: width, height: height)
        self.backgroundColor = UIColor.clear
        self.color = color
        self.tabs = tabs
        let pd = 0.2*(width / CGFloat(tabs))
        var x = pd
        
        tab_w = (width - CGFloat(tabs + 1)*pd) / CGFloat(tabs)
        let tab_h = 0.3*height
        
        for _ in 0..<tabs{
            let tab = UIView(frame: CGRect(x: x, y: (height - tab_h) / 2, width: tab_w, height: tab_h))
            cords.append(tab.frame)
            x += tab_w + pd
            
            tab.layer.borderWidth = 2
            tab.layer.borderColor = self.color.cgColor
            tab.layer.cornerRadius = tab_h / 2
            
            self.addSubview(tab)
        }
        current = start
        current_tab = UIView(frame: self.subviews[start].frame)
        current_tab.backgroundColor = self.color
        current_tab.layer.cornerRadius = current_tab.bounds.height / 2
        
        next_tab = UIView(frame: CGRect(x: current_tab.frame.minX, y: current_tab.frame.minY, width: 0, height: current_tab.frame.height))
        next_tab.backgroundColor = self.color
        next_tab.layer.cornerRadius = next_tab.frame.height / 2
        
        self.addSubview(current_tab)
        self.addSubview(next_tab)
    }
    
    func updateState(from first: Int, to second: Int, progress: CGFloat){
        let firstWidth = (1 - progress)*tab_w
        let secondWidth = progress*tab_w
        
        if(first < second){
            current_tab.frame = CGRect(x: cords[first].maxX - firstWidth, y: cords[first].minY, width: firstWidth, height: cords[first].height)
            next_tab.frame = CGRect(x: cords[second].minX, y: cords[second].minY, width: secondWidth, height: cords[second].height)
        }else{
            current_tab.frame = CGRect(x: cords[first].minX, y: cords[first].minY, width: firstWidth, height: cords[first].height)
            next_tab.frame = CGRect(x: cords[second].maxX - secondWidth, y: cords[second].minY, width: secondWidth, height: cords[second].height)
        }
    }
    
}
