//
//  ext.swift
//  testing
//
//  Created by Vadim on 20/03/2020.
//  Copyright © 2020 Vadim Zaripov. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Firebase

extension Date {
    func string(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

extension UserDefaults{
    static func isFirstLaunch() -> Bool{
        let hasBeenLaunchedBeforeFlag = "hasBeenLaunchedBeforeFlag"
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: hasBeenLaunchedBeforeFlag)
        if (isFirstLaunch) {
            UserDefaults.standard.set(true, forKey: hasBeenLaunchedBeforeFlag)
            UserDefaults.standard.synchronize()
        }
        return isFirstLaunch
    }
}

extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}

func drawLine(view: UIView, start: CGPoint, end: CGPoint, color: CGColor, width: CGFloat){
    let aPath = UIBezierPath()
    aPath.move(to: start)
    aPath.addLine(to: end)
    aPath.close()
    aPath.lineCapStyle = .round
    
    let layer = CAShapeLayer()
    layer.path = aPath.cgPath
    layer.strokeColor = color
    layer.lineWidth = width
    layer.fillColor = UIColor.clear.cgColor
    
    view.layer.addSublayer(layer)
}

func SetDates(){
    now_date = Date().string(format: "yyyy-MM-dd")
    next_date = (Calendar.current.date(byAdding: .day, value: 1, to: Date())!).string(format: "yyyy-MM-dd")
    week_date = (Calendar.current.date(byAdding: .day, value: 7, to: Date())!).string(format: "yyyy-MM-dd")
    month_date = (Calendar.current.date(byAdding: .month, value: 1, to: Date())!).string(format: "yyyy-MM-dd")
    three_month_date = (Calendar.current.date(byAdding: .month, value: 3, to: Date())!).string(format: "yyyy-MM-dd")
    six_month_date = (Calendar.current.date(byAdding: .month, value: 6, to: Date())!).string(format: "yyyy-MM-dd")
}

func updateWordsFromDatabase(completion: ((Bool) -> Void)?){
    user_id = Auth.auth().currentUser!.uid
    archive = []
    words = []
    current = 0
    number_of_words = 0
    categories_words = [:]
    SetDates()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    ref = Database.database().reference().child("users").child(user_id)
    ref.observeSingleEvent(of: .value, with: { (snp) in
        categories = default_categories + [no_category]
        let en = snp.childSnapshot(forPath: "categories").children
        while let snap = en.nextObject() as? DataSnapshot{
            categories.append(snap.value as! String)
        }
        let snapshot = snp.childSnapshot(forPath: "words")
        number_of_words = Int(snapshot.childrenCount)
        var date: Date, count: Int
        let enumerator = snapshot.children
        while let snap = enumerator.nextObject() as? DataSnapshot{
            date = dateFormatter.date(from: snap.childSnapshot(forPath: "date").value as? String ?? "")!
            let n_date = dateFormatter.date(from: now_date)!
            count = Calendar.current.dateComponents([.day], from: date, to: n_date).day!
            let eng = snap.childSnapshot(forPath: "English").value as? String ?? ""
            let rus = snap.childSnapshot(forPath: "Russian").value as? String ?? ""
            let category = snap.childSnapshot(forPath: "category").value as? String ?? ""
            var level = snap.childSnapshot(forPath: "level").value as? Int ?? 0
            if(category != no_category){
                if(categories_words[category] != nil){
                    categories_words[category]!.append(Word(eng: eng, rus: rus, ct: category, lvl: level, ind: Int(snap.key)!))
                }else{
                    categories_words[category] = [Word(eng: eng, rus: rus, ct: category, lvl: level, ind: Int(snap.key)!)]
                }
            }
            if(level == -1){
                archive.append(Word(eng: eng, rus: rus, ct: category, lvl: -1, ind: Int(snap.key)!))
            }else if(level != -2 && count > 0){
                ref.child("words").child(snap.key).child("date").setValue(now_date)
                if(count >= 3 && (level == 1 || level == 2)){
                    level = 0
                }
                ref.child("words").child(snap.key).child("level").setValue(level)
                words.append(Word(eng: eng, rus: rus, ct: category, lvl: level, ind: Int(snap.key)!))
            }else if(level != -2 && count == 0){
                words.append(Word(eng: eng, rus: rus, ct: category, lvl: level, ind: Int(snap.key)!))
            }
        }
        if let comp = completion{
            comp(true)
            print(words.count)
        }
    })
}


func downloadCategory(completion: ((Bool) -> Void)?){
    guard let category = category_shared else {return}
    guard let id = user_shared_id else {return}
    updateWordsFromDatabase(completion: {(finished: Bool) in
        let other_user_ref = Database.database().reference().child("users").child(id)
        other_user_ref.child("words").observeSingleEvent(of: .value, with: {(snapshot) in
            let enumerator = snapshot.children
            while let snap = enumerator.nextObject() as? DataSnapshot{
                let eng = snap.childSnapshot(forPath: "English").value as? String ?? ""
                let rus = snap.childSnapshot(forPath: "Russian").value as? String ?? ""
                let cat = snap.childSnapshot(forPath: "category").value as? String ?? ""
                if(cat.elementsEqual(category)){
                    ref.child("words").child(String(number_of_words)).child("English").setValue(eng)
                    ref.child("words").child(String(number_of_words)).child("Russian").setValue(rus)
                    ref.child("words").child(String(number_of_words)).child("category").setValue(cat)
                    ref.child("words").child(String(number_of_words)).child("level").setValue(-2)
                    ref.child("words").child(String(number_of_words)).child("date").setValue(now_date)
                    if(categories_words[category] != nil){
                        categories_words[category]!.append(Word(eng: eng, rus: rus, ct: category, lvl: -2, ind: number_of_words))
                    }else{
                        categories_words[category] = [Word(eng: eng, rus: rus, ct: category, lvl: -2, ind: number_of_words)]
                    }
                    number_of_words += 1
                }
            }
            if let comp = completion{
                comp(true)
                print(words.count)
            }
        })
    })
}
