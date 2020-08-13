//
//  ChangeWordViewController.swift
//  testing
//
//  Created by Vadim on 16/03/2019.
//  Copyright © 2019 Vadim Zaripov. All rights reserved.
//

import UIKit
import os

class ChangeWordViewController: NewWordViewController {
    
    override func initialSetting() {
        mainView = ChangeWordView(frame: view.bounds, categories: categories)
        for cat in mainView.categoriesButtons{
            cat.addTarget(self, action: #selector(self.chooseCategory(sender:)), for: .touchUpInside)
        }
        mainView.tag = 12345
        view.addSubview(mainView)
        setView()
    }
    
    override func setView() {
        super.setView()
        ed_text_english.text = words[0].english
        ed_text_russian.text = words[0].russian
        mainView.categoryLabel.text = words[0].category
        let cancel_btn = view.viewWithTag(801) as! Button
        cancel_btn.addTarget(self, action: #selector(cancel(_:)), for: .touchUpInside)
    }
    
    override func submit(_ sender: Any) {
        guard let eng = ed_text_english.text?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        guard let rus = ed_text_russian.text?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        if(eng == "" || rus == "") {
            messageAlert(vc: self, message: "Введите слово", text_error: "Вы ничего не ввели")
            return
        }
        ref.child("words").child(words[0].db_index).child("English").setValue(eng)
        ref.child("words").child(words[0].db_index).child("Russian").setValue(rus)
        ref.child("words").child(words[0].db_index).child("category").setValue(mainView.categoryLabel.text!)
        
        if(words[0].category != mainView.categoryLabel.text!){
            if(words[0].category != no_category){
                let ind = (categories.first(where: { $0.title == words[0].category.formatted() })?.words.firstIndex(
                        where: { $0.english == words[0].english }))!
                categories.first(where: { $0.title == words[0].category.formatted() })?.words.remove(at: ind)

            }
            words[0].category = mainView.categoryLabel.text!
            if(words[0].category != no_category){
                categories.first(where: { $0.title == words[0].category.formatted() })?.words.append(words[0])
            }
        }
        currentPageIndex = 1
        performSegue(withIdentifier: "back_from_word_edit", sender: self)
    }
    
    override func viewDidAppear(_ animated: Bool) { }
    
    @objc func cancel(_ sender: Any) {
        currentPageIndex = 1
        performSegue(withIdentifier: "back_from_word_edit", sender: self)
    }

}
