//
//  TestViewController.swift
//  testing
//
//  Created by Vadim Zaripov on 13.08.2020.
//  Copyright © 2020 Vadim Zaripov. All rights reserved.
//

import Foundation
import UIKit

class TestViewController: UIViewController{
    @IBAction func back(_ sender: Any) {
        performSegue(withIdentifier: "test2", sender: self)
    }
}
