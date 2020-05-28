//
//  NewWordViewController.swift
//  testing
//
//  Created by Vadim on 16/03/2019.
//  Copyright © 2019 Vadim Zaripov. All rights reserved.
//

import UIKit
import Firebase

var categories: [String] = []

class NewWordViewController: UIViewController, UITextFieldDelegate {

    var ed_text_english: UITextField!
    var ed_text_russian: UITextField!
    
    var cat_count = 0
    
    var frame: CGRect? = nil
    
    var mainView = NewWordView(frame: CGRect.init(), categories: [])
    
    init(frame: CGRect)   {
        print("init nibName style")
        super.init(nibName: nil, bundle: nil)
        self.frame = frame
    }

    // note slightly new syntax for 2017
    required init?(coder aDecoder: NSCoder) {
        print("init coder style")
        super.init(coder: aDecoder)
        
    }
    
    var opened = false
    override func viewDidLoad() {
        super.viewDidLoad()
        if(frame != nil){
            view.frame = frame!
        }
        cat_count = categories.count - default_categories.count - 1
        initialSetting()
    }
    
    func initialSetting(){
        mainView = NewWordView(frame: view.bounds, categories: categories)
        for cat in mainView.categoriesButtons{
            cat.addTarget(self, action: #selector(self.chooseCategory(sender:)), for: .touchUpInside)
        }
        mainView.tag = 12345
        self.view.addSubview(mainView)
        self.setView()
    }
    
    @objc func createCategory(_ sender: Any){
        let alert = UIAlertController(title: add_category, message: nil, preferredStyle: .alert)

        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = add_cat_placeholder
            textField.borderStyle = .roundedRect
            
        })
        
        alert.addAction(UIAlertAction(title: save_category, style: .default, handler: { action in
            if let cat = alert.textFields?.first?.text {
                ref.child("categories").child(String(self.cat_count)).setValue(cat)
                
                self.mainView.shrinkBottomBar(nil)
                self.cat_count += 1
                categories.append(cat)
                self.mainView.categoryLabel.text = cat
                print("SUCCESS")
                
                var m: CGFloat = 0
                var s: CGFloat = 0
                var cnt = 0
                let scroll = self.view.viewWithTag(400) as! UIScrollView
                for i in 0..<(categories.count - 1){
                    if(self.mainView.categories_centers[i].y > m){
                        m = self.mainView.categories_centers[i].y
                        s = scroll.viewWithTag(i + 1)!.bounds.width
                        cnt = 1
                    }else if(abs(Int(self.mainView.categories_centers[i].y) - Int(m)) <= 2){
                        s += scroll.viewWithTag(i + 1)!.bounds.width
                        cnt += 1
                    }
                }
                
                let comp_btn = scroll.viewWithTag(1) as! UIButton
                
                let d = [NSAttributedString.Key.font:comp_btn.titleLabel?.font!]
                let l1 = 2*self.mainView.padding + (cat as NSString).size(withAttributes: d as [NSAttributedString.Key : Any]).width
                let len = min(max(l1, self.mainView.min_len), scroll.bounds.width)
                
                let cur = UIButton()
                cur.bounds = CGRect(x: 0, y: 0, width: len, height: comp_btn.bounds.height)
                cur.setTitle(cat, for: .normal)
                cur.titleLabel?.font = comp_btn.titleLabel?.font
                cur.backgroundColor = UIColor.init(rgb: colors[(categories.count - 1) % colors.count])
                cur.setTitleColor(UIColor.white, for: .normal)
                cur.center = CGPoint(x: scroll.bounds.width / 2, y: cur.bounds.height / 2)
                cur.alpha = 0
                cur.clipsToBounds = true
                cur.layer.cornerRadius = cur.bounds.height / 2
                cur.tag = categories.count
                cur.isUserInteractionEnabled = false
                scroll.addSubview(cur)
                
                if(s + CGFloat(cnt)*self.mainView.padding + cur.bounds.width <= scroll.bounds.width){
                    var actual_pd = (scroll.bounds.width - (s + cur.bounds.width)) / CGFloat(cnt + 2)
                    var border_pd = actual_pd
                    if(actual_pd < self.mainView.padding){
                        actual_pd = self.mainView.padding
                        border_pd = (scroll.bounds.width - s - CGFloat(cnt)*self.mainView.padding - cur.bounds.width) / 2
                    }
                    var x = border_pd
                    for j in 0..<(categories.count - 1){
                        if(self.mainView.categories_centers[j].y < m - 1){
                            continue
                        }
                        let v = scroll.viewWithTag(j + 1)!
                        self.mainView.categories_centers[j] = CGPoint(x: x + v.bounds.width / 2, y: m)
                        x += v.bounds.width + actual_pd
                    }
                    self.mainView.categories_centers.append(CGPoint(x: x + cur.bounds.width / 2, y: m))
                }else{
                    self.mainView.categories_centers.append(CGPoint(x: scroll.bounds.width / 2, y: m + self.mainView.padding + cur.bounds.height))
                    scroll.contentSize = CGSize(width: scroll.bounds.width, height: m + self.mainView.padding + 1.5*cur.bounds.height)
                }
            }
        }))
        
        alert.addAction(UIAlertAction(title: delete_alert_cancel, style: .default, handler: nil))

        self.present(alert, animated: true)
        
        if let textFields = alert.textFields {
            if textFields.count > 0{
                textFields[0].superview!.superview!.subviews[0].removeFromSuperview()
                textFields[0].superview!.backgroundColor = UIColor.clear
            }
        }
    }
    
    func setView(){
        view.center = CGPoint(x: view.frame.size.width / 2, y: view.frame.size.height / 2)
        
        mainView.categoryLabel.text = no_category
        
        mainView.finishButton.addTarget(self, action: #selector(submit(_:)), for: .touchUpInside)
        
        mainView.addButton.addTarget(self, action: #selector(createCategory(_:)), for: .touchUpInside)
        
        ed_text_russian = (view.viewWithTag(100) as! UITextField)
        ed_text_english = (view.viewWithTag(101) as! UITextField)
        self.ed_text_english.delegate = self
        self.ed_text_russian.delegate = self
    }
    
    @objc func submit(_ sender: Any) {
        guard let eng = ed_text_english.text?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        guard let rus = ed_text_russian.text?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        ref.child("words").child(String(number_of_words)).child("English").setValue(eng)
        ref.child("words").child(String(number_of_words)).child("Russian").setValue(rus)
        ref.child("words").child(String(number_of_words)).child("date").setValue(next_date.toDatabaseFormat())
        ref.child("words").child(String(number_of_words)).child("level").setValue(0)
        ref.child("words").child(String(number_of_words)).child("category").setValue(mainView.categoryLabel.text!)
        
        number_of_words += 1
        print(number_of_words)
        self.view.isUserInteractionEnabled = false
        let oldValue = mainView.finishButton.layer.cornerRadius
        mainView.finishButton.setTitle("", for: .normal)
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.8)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeInEaseOut))

        UIView.animate(withDuration: 0.8, animations: {
            for i in self.mainView.finishButton.superview!.subviews{
                if(i.tag != self.mainView.finishButton.tag){
                    i.alpha = 0
                    i.isUserInteractionEnabled = false
                }
            }
            self.mainView.finishButton.bounds = CGRect(x: 0, y: 0, width: 0.35*self.mainView.frame.width, height: 0.35*self.mainView.frame.width)
            self.mainView.finishButton.center = CGPoint(x: self.mainView.frame.width / 2, y: self.mainView.frame.height / 2)
        }, completion: {(finished: Bool) in
            let s_img = UIImageView(image: UIImage(named: "checkmark"))
            s_img.bounds = CGRect(x: 0, y: 0, width: 0.4*self.mainView.finishButton.bounds.width, height: 0.23*self.mainView.finishButton.bounds.width)
            s_img.center = self.mainView.finishButton.center
            s_img.alpha = 0
            self.mainView.finishButton.superview!.addSubview(s_img)
            UIView.animate(withDuration: 0.2, animations: {
                s_img.alpha = 1
            }, completion: {(finished: Bool) in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.view.alpha = 0
                    }, completion: {(finished: Bool) in
                        let v = NewWordView(frame: self.view.frame, categories: categories)
                        v.tag = 12345
                        for subview in self.view.subviews{
                            subview.removeFromSuperview()
                        }
                        self.view.addSubview(v)
                        UIView.animate(withDuration: 0.3, animations: {
                            self.view.alpha = 1
                        }, completion: {(finished: Bool) in
                            self.view.isUserInteractionEnabled = true
                            self.setView()
                        })
                    })
                })
            })
        })
        
        let cornerAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.cornerRadius))
        cornerAnimation.fromValue = oldValue
        cornerAnimation.toValue = mainView.finishButton.bounds.height / 2

        mainView.finishButton.layer.cornerRadius = mainView.finishButton.bounds.height / 2
        mainView.finishButton.layer.add(cornerAnimation, forKey: #keyPath(CALayer.cornerRadius))

        CATransaction.commit()
 
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        let touch = touches.first
        guard let location = touch?.location(in: view) else { return }
        if !mainView.categoryLabel.frame.contains(location) {
            mainView.shrinkBottomBar(nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        ed_text_english.resignFirstResponder()
        ed_text_russian.resignFirstResponder()
        return true
    }
    
    @objc func chooseCategory(sender: UIButton){
        print("nice")
        mainView.categoryLabel.text = sender.title(for: .normal)
        mainView.shrinkBottomBar(nil)
    }

}
