//
//  SmoothSegue.swift
//  testing
//
//  Created by Vadim on 30/03/2020.
//  Copyright © 2020 Vadim Zaripov. All rights reserved.
//

import UIKit

class SmoothSegue: UIStoryboardSegue {
    
    let duration: TimeInterval = 0.6
    
    override func perform(){
        let first = source.view!
        let second = destination.view!
        
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        
        second.frame = CGRect(x: 0, y: 0, width: width, height: height)
        second.alpha = 0
        
        
        let bg = UIImageView(image: UIImage(named: "bg"))
        bg.contentMode = .scaleToFill
        bg.frame = first.frame
        
        let window = UIApplication.shared.keyWindow
        window?.insertSubview(bg, at: 0)
        window?.insertSubview(second, at: 1)
        
        UIView.animate(withDuration: duration / 2, animations: {
            first.alpha = 0
        }, completion: {(finished: Bool) in
            UIView.animate(withDuration: self.duration / 2, animations: {
                second.alpha = 1
            }, completion: {(finished: Bool) in
                self.source.present(self.destination, animated: false, completion: nil)
            })
        })
    }
}
