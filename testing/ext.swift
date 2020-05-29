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
import UserNotifications

extension Date {
    func toDatabaseFormat() -> Int64{
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}

extension UserDefaults{
    static func isFirstLaunch() -> Bool{
        let hasBeenLaunchedBeforeFlag = "LetthasBeenLaunchedBefore"
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: hasBeenLaunchedBeforeFlag)
        print("Fist: \(isFirstLaunch)")
        return isFirstLaunch
    }
    
    static func setFirstLaunchToFalse(){
        let hasBeenLaunchedBeforeFlag = "LetthasBeenLaunchedBefore"
        UserDefaults.standard.set(true, forKey: hasBeenLaunchedBeforeFlag)
        UserDefaults.standard.synchronize()
    }
}

extension UIViewController {
    func attachToTop(_ customView: UIView, with margin: CGFloat = 0){
        if #available(iOS 11.0, *) {
            customView.topAnchor.constraint(
              equalTo: view.safeAreaLayoutGuide.topAnchor,
              constant: margin
            ).isActive = true
        } else {
            print("Attaching view to top")
            customView.topAnchor.constraint(
              equalTo: topLayoutGuide.topAnchor,
              constant: margin
            ).isActive = true
        }
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
    now_date = Calendar.current.startOfDay(for: Date())
    next_date = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: Date())!)
    week_date = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 7, to: Date())!)
    month_date = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .month, value: 1, to: Date())!)
    three_month_date = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .month, value: 3, to: Date())!)
    six_month_date = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .month, value: 6, to: Date())!)
}

func messageAlert(vc: UIViewController, message: String, text_error: String){
    let alert = UIAlertController(title: message, message: text_error, preferredStyle: UIAlertController.Style.alert)
    
    alert.addAction(UIAlertAction(title: alert_ok, style: UIAlertAction.Style.default, handler: nil))
    vc.present(alert, animated: true, completion: nil)
}

var russian_list: [String] = []
var english_list: [String] = []

func updateWordsFromDatabase(completion: ((Bool) -> Void)?){
    user_id = Auth.auth().currentUser!.uid
    var _archive: [Word] = []
    var _words: [Word] = []
    var _russian_list: [String] = []
    var _english_list: [String] = []
    var _categories_words: [String: [Word]] = [:]
    var _categories: [String] = default_categories + [no_category]
    number_of_words = 0
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
        number_of_words = Int(snapshot.childrenCount)
        var date: Date, count: Int
        let enumerator = snapshot.children
        while let snap = enumerator.nextObject() as? DataSnapshot{
            date = Date(milliseconds: snap.childSnapshot(forPath: "date").value as? Int64 ?? 0)
            count = Calendar.current.dateComponents([.day], from: date, to: now_date).day!
            let eng = snap.childSnapshot(forPath: "English").value as? String ?? ""
            let rus = snap.childSnapshot(forPath: "Russian").value as? String ?? ""
            let category = snap.childSnapshot(forPath: "category").value as? String ?? ""
            var level = snap.childSnapshot(forPath: "level").value as? Int ?? 0
            _russian_list.append(rus)
            _english_list.append(eng)
            if(category != no_category){
                if(_categories_words[category] != nil){
                    _categories_words[category]!.append(Word(eng: eng, rus: rus, ct: category, lvl: level, ind: Int(snap.key)!))
                }else{
                    _categories_words[category] = [Word(eng: eng, rus: rus, ct: category, lvl: level, ind: Int(snap.key)!)]
                }
            }
            if(level == -1){
                _archive.append(Word(eng: eng, rus: rus, ct: category, lvl: -1, ind: Int(snap.key)!))
            }else if(level != -2 && count > 0){
                ref.child("words").child(snap.key).child("date").setValue(now_date.toDatabaseFormat())
                if(count >= 3 && (level == 1 || level == 2)){
                    level = 0
                }
                ref.child("words").child(snap.key).child("level").setValue(level)
                _words.append(Word(eng: eng, rus: rus, ct: category, lvl: level, ind: Int(snap.key)!))
            }else if(level != -2 && count == 0){
                _words.append(Word(eng: eng, rus: rus, ct: category, lvl: level, ind: Int(snap.key)!))
            }
        }
        archive = _archive
        words = _words
        russian_list = _russian_list
        english_list = _english_list
        categories_words = _categories_words
        categories = _categories
        if let comp = completion{
            comp(true)
            for i in categories_words{
                for j in i.value{
                    print(j.english, terminator: " ")
                }
            }
        }
    })
}

func downloadCategory(completion: ((Bool) -> Void)?){
    guard let category = category_shared else {return}
    guard let id = user_shared_id else {return}
    updateWordsFromDatabase(completion: {(finished: Bool) in
        if(!categories.contains(category)){
            ref.child("categories").child(String(categories.count - default_categories.count - 1)).setValue(category)
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
                    ref.child("words").child(String(number_of_words)).child("English").setValue(eng)
                    ref.child("words").child(String(number_of_words)).child("Russian").setValue(rus)
                    ref.child("words").child(String(number_of_words)).child("category").setValue(cat)
                    ref.child("words").child(String(number_of_words)).child("level").setValue(-2)
                    ref.child("words").child(String(number_of_words)).child("date").setValue(now_date.toDatabaseFormat())
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

func scheduleNotification() {
    let content = UNMutableNotificationContent()
    
    content.title = notification_title
    content.body = notification_text
    content.sound = UNNotificationSound.default
    content.badge = 1
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm:ss.SSS"
    let triggerDaily = Calendar.current.dateComponents([.hour,.minute,.second,], from: dateFormatter.date(from: notification_time)!)
    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDaily, repeats: true)
    
    let identifier = "Local Notification"
    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

    UNUserNotificationCenter.current().add(request) { (error) in
        if let error = error {
            print("Error \(error.localizedDescription)")
        }
    }
}
