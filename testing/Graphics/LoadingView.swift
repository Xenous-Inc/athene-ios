//
//  SwiftUIView.swift
//  testing
//
//  Created by Vadim on 02/04/2020.
//  Copyright © 2020 Vadim Zaripov. All rights reserved.
//

import Foundation
import UIKit
import Lottie

class LoadingView: UIView {
    
    var animationView: Lottie.AnimationView!
    
    func set(frame: CGRect){
        self.frame = frame
        self.backgroundColor = UIColor.init(white: 0, alpha: 0.5)
        self.tag = 54321

        animationView = Lottie.AnimationView(name: "loading_animation")
        animationView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        animationView.center = self.center
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .loop
        self.addSubview(animationView)
        
        self.alpha = 0
    }
    
    func show(){
        UIView.animate(withDuration: 0.1, animations: {
            self.alpha = 1
        }, completion: {(finished: Bool) in
            self.animationView.play()
        })
    }
    
}
