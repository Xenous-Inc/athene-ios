//
//  Test.swift
//  testing
//
//  Created by Vadim on 26/03/2020.
//  Copyright © 2020 Vadim Zaripov. All rights reserved.
//

import UIKit
import Firebase
import os


class TestViewController: UIViewController, UITextFieldDelegate {
    
    var gb = GraphicBuilder(width: 0, height: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gb = GraphicBuilder(width: view.frame.size.width, height: view.frame.size.height)
        let v = gb.buildMainView()
        view.addSubview(v)
    }
    
}
