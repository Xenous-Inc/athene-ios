//
//  Word.swift
//  testing
//
//  Created by Vadim on 17/03/2020.
//  Copyright © 2020 Vadim Zaripov. All rights reserved.
//

import Foundation


class Word{
    var english, russian, category: String;
    var level, db_index: Int
    init(eng: String, rus: String, ct: String, lvl: Int, ind: Int) {
        english = eng
        russian = rus
        category = ct
        level = lvl
        db_index = ind
    }
}
