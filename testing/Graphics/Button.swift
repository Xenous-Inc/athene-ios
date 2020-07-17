//
// Created by Vadim Zaripov on 17.07.2020.
// Copyright (c) 2020 Vadim Zaripov. All rights reserved.
//

import Foundation
import UIKit

class Button: UIButton{
    override func setTitle(_ title: String?, for state: State) {
        setBackgroundImage(UIImage(named: "clear"), for: .normal)
        super.setTitle(title, for: state)
    }
}