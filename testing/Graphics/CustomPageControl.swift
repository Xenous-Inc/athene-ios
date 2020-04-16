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
    
    var current_tab = UIView()
    
    var color = UIColor()
    
    func set(width: CGFloat, height: CGFloat, tabs: Int, start: Int, color: UIColor){
        self.bounds = CGRect(x: 0, y: 0, width: width, height: height)
        self.backgroundColor = UIColor.clear
        self.color = color
        self.tabs = tabs
        let pd = 0.2*(width / CGFloat(tabs))
        var x = pd
        
        let tab_w = (width - CGFloat(tabs + 1)*pd) / CGFloat(tabs)
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
        
        self.addSubview(current_tab)
    }
    
    func moveTo(tab: Int) {
        if(tab == current){
            return
        }
        let new_cur = UIView()
        var new_x: CGFloat = 0
        if(tab < current){
            new_cur.frame = CGRect(x: cords[tab].maxX, y: cords[tab].minY, width: 0, height: cords[tab].height)
            new_x = current_tab.frame.minX
        }else{
            new_cur.frame = CGRect(x: cords[tab].minX, y: cords[tab].minY, width: 0, height: cords[tab].height)
            new_x = current_tab.frame.maxX
        }
        new_cur.backgroundColor = color
        new_cur.layer.cornerRadius = new_cur.bounds.height / 2
        self.addSubview(new_cur)
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            new_cur.frame = self.cords[tab]
            self.current_tab.frame = CGRect(x: new_x, y: self.current_tab.frame.minY, width: 0, height: self.current_tab.frame.height)
        }, completion: {(finished: Bool) in
            self.current = tab
            self.current_tab.frame = new_cur.frame
            new_cur.removeFromSuperview()
        })
    }
    
}
