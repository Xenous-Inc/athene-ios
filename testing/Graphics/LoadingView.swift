//
//  SwiftUIView.swift
//  testing
//
//  Created by Vadim on 02/04/2020.
//  Copyright © 2020 Vadim Zaripov. All rights reserved.
//

import Foundation
import UIKit

class LoadingView: UIView {
    
    let indicator = UIActivityIndicatorView()
    
    func set(frame: CGRect){
        self.frame = frame
        self.backgroundColor = UIColor.init(white: 0, alpha: 0.5)
        indicator.style = .whiteLarge
        indicator.center = CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2)
        self.addSubview(indicator)
        self.alpha = 0
    }
    
    func show(){
        UIView.animate(withDuration: 0.1, animations: {
            self.alpha = 1
        }, completion: {(finished: Bool) in
            self.indicator.startAnimating()
        })
    }
    
}
