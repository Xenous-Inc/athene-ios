//
//  Word.swift
//  testing
//
//  Created by Vadim on 17/03/2020.
//  Copyright © 2020 Vadim Zaripov. All rights reserved.
//

import Foundation


class Word{
    var english, russian, category, db_index: String
    var level: Int
    init(eng: String, rus: String, ct: String, lvl: Int, id: String) {
        english = eng
        russian = rus
        category = ct
        level = lvl
        db_index = id
    }
}
