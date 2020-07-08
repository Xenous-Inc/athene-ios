//
//  links.swift
//  testing
//
//  Created by Vadim Zaripov on 08.07.2020.
//  Copyright © 2020 Vadim Zaripov. All rights reserved.
//

import Foundation
import Firebase

func handleCategoryLink(user_shared_id: String, category_shared: String, v_controller: UIViewController){
    let alertController = UIAlertController(title: "Добавить слова категории \(category_shared)?", message: nil, preferredStyle: .actionSheet)
    alertController.addAction(UIAlertAction(title: alert_yes, style: .default, handler: { (action) in
        var v = LoadingView()
        v.tag = 54321
        v.set(frame: v_controller.view.frame)
        if let loading_v = v_controller.view.viewWithTag(54321){
            v = loading_v as! LoadingView
        }else{
            v_controller.view.addSubview(v)
            v_controller.view.bringSubviewToFront(v)
        }
        v.show()
        downloadCategory(id: user_shared_id, category: category_shared, completion: {(finished: Bool) in
            v.removeFromSuperview()
            v_controller.viewDidAppear(false)
        })
    }))
    alertController.addAction(UIAlertAction(title: alert_cancel, style: .default, handler: nil))
    v_controller.present(alertController, animated: true, completion: nil)
}

func handleClassroomLink(teacherId: String, classId: String, v_controller: UIViewController){
    let teacherRef = Database.database().reference().child("teachers").child(teacherId)
    teacherRef.observeSingleEvent(of: .value) { (snapshot) in
        let en = snapshot.childSnapshot(forPath: "classes").childSnapshot(forPath: classId).childSnapshot(forPath: "students").children
        var isInClass = false
        while let snap = en.nextObject() as? DataSnapshot{
            if(snap.childSnapshot(forPath: "id").value as! String == Auth.auth().currentUser!.uid){
                isInClass = true
                break
            }
        }
        if(isInClass){
            messageAlert(vc: v_controller, message: "Вы уже добавлены в этот класс", text_error: nil)
        }else{
            let alertController  = UIAlertController(
                title: "\(snapshot.childSnapshot(forPath: "name").value as! String) приглашает вас в класс \"\(snapshot.childSnapshot(forPath: "classes").childSnapshot(forPath: classId).childSnapshot(forPath: "name").value as! String)\" ",
                message: nil,
                preferredStyle: .alert)
            
            alertController.addTextField { textField in
                textField.placeholder = "Ваше имя (для учителя)"
                textField.borderStyle = .roundedRect
            }
            alertController.addAction(UIAlertAction(title: "Принять", style: .default, handler: { (action) in
                let newStudentRef = teacherRef.child("classes").child(classId).child("students").childByAutoId()
                newStudentRef.child("id").setValue(Auth.auth().currentUser!.uid)
                newStudentRef.child("name").setValue(alertController.textFields?.first?.text!)
                
                var v = LoadingView()
                v.tag = 54321
                v.set(frame: v_controller.view.frame)
                if let loading_v = v_controller.view.viewWithTag(54321){
                    v = loading_v as! LoadingView
                }else{
                    v_controller.view.addSubview(v)
                    v_controller.view.bringSubviewToFront(v)
                }
                v.show()
                downloadClassesCategories(snapshot: snapshot, classId: classId) {
                    v.removeFromSuperview()
                    v_controller.viewDidAppear(false)
                }
            }))
            alertController.addAction(UIAlertAction(title: alert_cancel, style: .default, handler: nil))
            
            v_controller.present(alertController, animated: true, completion: nil)
            if let textFields = alertController.textFields {
                if textFields.count > 0{
                    textFields[0].superview!.superview!.subviews[0].removeFromSuperview()
                    textFields[0].superview!.backgroundColor = UIColor.clear
                }
            }
        }
    }
}
