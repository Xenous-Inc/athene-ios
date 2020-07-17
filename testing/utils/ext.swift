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
import UserNotifications

extension Date {
    func toDatabaseFormat() -> Int64 { Int64((self.timeIntervalSince1970 * 1000.0).rounded()) }
    
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

extension String {
    func formatted() -> String { self.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) }
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

func messageAlert(vc: UIViewController, message: String, text_error: String?){
    let alert = UIAlertController(title: message, message: text_error, preferredStyle: UIAlertController.Style.alert)
    
    alert.addAction(UIAlertAction(title: alert_ok, style: UIAlertAction.Style.default, handler: nil))
    vc.present(alert, animated: true, completion: nil)
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
