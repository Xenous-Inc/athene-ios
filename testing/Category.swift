//
// Created by Vadim Zaripov on 17.07.2020.
// Copyright (c) 2020 Vadim Zaripov. All rights reserved.
//

import Foundation

class Category{
    var title: String!
    var databaseId: String?
    var words: [Word] = []

    init(title: String, databaseId: String? = nil, words: [Word] = []){
        self.title = title
        self.databaseId = databaseId
        self.words = words
    }
}