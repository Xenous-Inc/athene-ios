//
//  FirstLogInViewController.swift
//  testing
//
//  Created by Vadim on 02/04/2019.
//  Copyright © 2019 Vadim Zaripov. All rights reserved.
//

import UIKit

class FirstLogInViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    @IBAction func LogIn(_ sender: UIButton) {
        performSegue(withIdentifier: "choose_log_in", sender: self)
    }
    
    @IBAction func Register(_ sender: UIButton) {
        performSegue(withIdentifier: "choose_register", sender: self)
    }
}
