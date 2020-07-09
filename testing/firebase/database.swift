//
//  database.swift
//  testing
//
//  Created by Vadim Zaripov on 29.05.2020.
//  Copyright © 2020 Vadim Zaripov. All rights reserved.
//

import Foundation
import Firebase

var ref: DatabaseReference!
var user_id = ""

var next_date: Date = Date()
var archive : [Word] = []

var words: [Word] = []

var user : User? = nil

var now_date: Date = Date()
var week_date: Date = Date()
var month_date: Date = Date()
var three_month_date: Date = Date()
var six_month_date: Date = Date()

var categories_words: [String: [Word]] = [:]
var categories: [String] = []

var russian_list: [String] = []
var english_list: [String] = []

var shouldUpdate = true

func updateWordsFromDatabase(completion: ((Bool) -> Void)?){
    if(!shouldUpdate) {return}
    shouldUpdate = true
    
    user_id = Auth.auth().currentUser!.uid
    var _archive: [Word] = []
    var _words: [Word] = []
    var _russian_list: [String] = []
    var _english_list: [String] = []
    var _categories_words: [String: [Word]] = [:]
    var _categories: [String] = [no_category] + default_categories
    SetDates()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    ref = Database.database().reference().child("users").child(user_id)
    ref.observeSingleEvent(of: .value, with: { (snp) in
        let en = snp.childSnapshot(forPath: "categories").children
        while let snap = en.nextObject() as? DataSnapshot{
            _categories.append(snap.value as! String)
        }
        let snapshot = snp.childSnapshot(forPath: "words")
        var date: Date, count: Int
        let enumerator = snapshot.children
        while let snap = enumerator.nextObject() as? DataSnapshot{
            date = Date(milliseconds: snap.childSnapshot(forPath: "date").value as? Int64 ?? 0)
            count = Calendar.current.dateComponents([.day], from: date, to: now_date).day!
            let eng = snap.childSnapshot(forPath: "English").value as? String ?? ""
            let rus = snap.childSnapshot(forPath: "Russian").value as? String ?? ""
            let category = (snap.childSnapshot(forPath: "category").value as? String ?? "").formatted()
            var level = snap.childSnapshot(forPath: "level").value as? Int ?? 0
            _russian_list.append(rus)
            _english_list.append(eng)
            if(category.formatted() != no_category){
                if(_categories_words[category] != nil){
                    _categories_words[category]!.append(Word(eng: eng, rus: rus, ct: category.formatted(), lvl: level, id: snap.key))
                }else{
                    _categories_words[category] = [Word(eng: eng, rus: rus, ct: category.formatted(), lvl: level, id: snap.key)]
                }
            }
            if(level == -1){
                _archive.append(Word(eng: eng, rus: rus, ct: category, lvl: -1, id: snap.key))
            }else if(level != -2 && count > 0){
                ref.child("words").child(snap.key).child("date").setValue(now_date.toDatabaseFormat())
                if(count >= 3 && (level == 1 || level == 2)){
                    level = 0
                }
                ref.child("words").child(snap.key).child("level").setValue(level)
                _words.append(Word(eng: eng, rus: rus, ct: category, lvl: level, id: snap.key))
            }else if(level != -2 && count == 0){
                _words.append(Word(eng: eng, rus: rus, ct: category, lvl: level, id: snap.key))
            }
        }
        archive = _archive
        words = _words
        russian_list = _russian_list
        english_list = _english_list
        categories_words = _categories_words
        categories = _categories
        if let comp = completion{
            comp(true)        }
    })
}

func downloadCategory(id: String, category: String, completion: ((Bool) -> Void)?){
    updateWordsFromDatabase(completion: {(finished: Bool) in
        if(!categories.contains(category)){
            ref.child("categories").childByAutoId().setValue(category)
            categories.append(category)
        }
        let other_user_ref = Database.database().reference().child("users").child(id)
        other_user_ref.child("words").observeSingleEvent(of: .value, with: {(snapshot) in
            let enumerator = snapshot.children
            while let snap = enumerator.nextObject() as? DataSnapshot{
                let eng = snap.childSnapshot(forPath: "English").value as? String ?? ""
                let rus = snap.childSnapshot(forPath: "Russian").value as? String ?? ""
                let cat = snap.childSnapshot(forPath: "category").value as? String ?? ""
                if(english_list.contains(eng) || russian_list.contains(rus)){continue}
                if(cat.elementsEqual(category)){
                    let wordRef = ref.child("words").childByAutoId()
                    wordRef.child("English").setValue(eng)
                    wordRef.child("Russian").setValue(rus)
                    wordRef.child("category").setValue(cat)
                    wordRef.child("level").setValue(-2)
                    wordRef.child("date").setValue(now_date.toDatabaseFormat())
                    if(categories_words[category] != nil){
                        categories_words[category]!.append(Word(eng: eng, rus: rus, ct: category, lvl: -2, id: wordRef.key!))
                    }else{
                        categories_words[category] = [Word(eng: eng, rus: rus, ct: category, lvl: -2, id: wordRef.key!)]
                    }                }
            }
            if let comp = completion{
                comp(true)
                print(words.count)
            }
        })
    })
}

func downloadClassesCategories(snapshot: DataSnapshot, classId: String, completion: @escaping () -> Void){
    updateWordsFromDatabase(completion: {(finished: Bool) in
        let enumerator = snapshot.childSnapshot(forPath: "classes").childSnapshot(forPath: classId).childSnapshot(forPath: "categories").children
        while let catId = enumerator.nextObject() as? String{
            let catName = snapshot.childSnapshot(forPath: "categories").childSnapshot(forPath: catId).childSnapshot(forPath: "name").value as! String
            if(!categories.contains(catName)){
                ref.child("categories").childByAutoId().setValue(catName)
                categories.append(catName)
            }
            while let wordSnapshot = snapshot.childSnapshot(forPath: "categories").childSnapshot(forPath: catId).childSnapshot(forPath: "words").children.nextObject() as? DataSnapshot{
                let eng = wordSnapshot.childSnapshot(forPath: "english").value as? String ?? ""
                let rus = wordSnapshot.childSnapshot(forPath: "russian").value as? String ?? ""
                if(english_list.contains(eng) || russian_list.contains(rus)){continue}
                
                let wordRef = ref.child("words").childByAutoId()
                wordRef.child("English").setValue(eng)
                wordRef.child("Russian").setValue(rus)
                wordRef.child("category").setValue(catName)
                wordRef.child("level").setValue(-2)
                wordRef.child("date").setValue(now_date.toDatabaseFormat())
                if(categories_words[catName] != nil){
                    categories_words[catName]!.append(Word(eng: eng, rus: rus, ct: catName, lvl: -2, id: wordRef.key!))
                }else{
                    categories_words[catName] = [Word(eng: eng, rus: rus, ct: catName, lvl: -2, id: wordRef.key!)]
                }
            }
        }
        completion()
    })
}

func deleteWordFromDatabase(word: Word){
    ref.child("words").child(word.db_index).removeValue()
    if let ind = (archive.map { $0.english }).firstIndex(of: words[0].english){
        archive.remove(at: ind)
    }
    if word.category != no_category{
        if let ind = categories_words[word.category]?.firstIndex(where: { $0.english == word.english}){
            categories_words[word.category]?.remove(at: ind)
        }
    }
}

func deleteCategoryFromDatabase(name: String, deleteWords: Bool){
    for word in categories_words[name]!{
        if(deleteWords){
            ref.child("words").child(String(word.db_index)).removeValue()
        }else{
            ref.child("words").child(String(word.db_index)).child("category").setValue(no_category)
        }
    }
    let catInd = categories.firstIndex(of: name)! - 1 - default_categories.count
    if(catInd >= 0){
        ref.child("categories").child(String(catInd)).removeValue()
        categories.remove(at: categories.firstIndex(of: name)!)
    }
    categories_words.removeValue(forKey: name)
}
