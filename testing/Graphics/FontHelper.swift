//
//  FontHelper.swift
//  testing
//
//  Created by Vadim on 19/03/2020.
//  Copyright © 2020 Vadim Zaripov. All rights reserved.
//

import UIKit

class FontHelper: NSObject{
    func getFontSize(strings: [String], font: String, maxFontSize: Int, width: CGFloat, height: CGFloat) -> Int{
        var l: Int = 1
        var r: Int = maxFontSize
        var m: Int
        while(r-l > 1){
            m = (l+r)/2
            let d = [NSAttributedString.Key.font:UIFont(name:font, size:CGFloat(m))!]
            var valid: Bool = true
            for s in strings{
                let sized_str = (s as NSString).size(withAttributes: d)
                valid = valid && (sized_str.width <= width && sized_str.height <= height)
            }
            if(valid){
                l = m
            }else{
                r = m
            }
        }
        return l
    }
    
    func getFontSizeByHeight(text: String, font: String, maxFontSize: Int, height: CGFloat) -> Int{
        var l: Int = 1
        var r: Int = maxFontSize
        var m: Int
        while(r-l > 1){
            m = (l+r)/2
            let d = [NSAttributedString.Key.font:UIFont(name:font, size:CGFloat(m))!]
            let sized_str = (text as NSString).size(withAttributes: d)
            if(sized_str.height <= height){
                l = m
            }else{
                r = m
            }
        }
        return l
    }
    
    func getInterfaceFontSize(font: String, height: CGFloat) -> Int{
        return self.getFontSizeByHeight(text: "ABC", font: font, maxFontSize: 120, height: height)
    }
}
