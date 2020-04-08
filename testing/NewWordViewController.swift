//
//  NewWordViewController.swift
//  testing
//
//  Created by Vadim on 16/03/2019.
//  Copyright © 2019 Vadim Zaripov. All rights reserved.
//

import UIKit
import Firebase

class NewWordViewController: UIViewController, UITextFieldDelegate {

    var ed_text_english: UITextField!
    var ed_text_russian: UITextField!
  
    var cross_btn = UIButton()
    var category_label = UILabel()
    var submit_btn = UIButton()
    
    var categories = default_categories
    var cat_count = 0
    
    var frame: CGRect? = nil
    
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
    var gb = GraphicBuilder(width: 0, height: 0)
    override func viewDidLoad() {
        super.viewDidLoad()
        if(frame != nil){
            view.frame = frame!
        }
        print("test")
        gb = GraphicBuilder(width: view.frame.size.width, height: view.frame.size.height)
        initialSetting()
    }
    
    func initialSetting(){
        categories = default_categories + [no_category]
        ref.observeSingleEvent(of: .value, with: {(snapshot) in
            self.cat_count = Int(snapshot.childrenCount)
            number_of_words = Int(snapshot.childSnapshot(forPath: "words").childrenCount)
            let enumerator = snapshot.childSnapshot(forPath: "categories").children
            while let snap = enumerator.nextObject() as? DataSnapshot{
                self.categories.append(snap.value as! String)
            }
            let v = self.gb.buildCreateWord(categories: self.categories)
            v.tag = 12345
            self.view.addSubview(v)
            self.setView()
        })
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
                
                self.shrinkBottomBar(nil)
                self.cat_count += 1
                self.categories.append(cat)
                self.category_label.text = cat
                print("SUCCESS")
                
                var m: CGFloat = 0
                var s: CGFloat = 0
                var cnt = 0
                let scroll = self.view.viewWithTag(400) as! UIScrollView
                for i in 0..<(self.categories.count - 1){
                    if(self.gb.categories_centers[i].y > m){
                        m = self.gb.categories_centers[i].y
                        s = scroll.viewWithTag(i + 1)!.bounds.width
                        cnt = 1
                    }else if(abs(Int(self.gb.categories_centers[i].y) - Int(m)) <= 2){
                        s += scroll.viewWithTag(i + 1)!.bounds.width
                        cnt += 1
                    }
                }
                
                let comp_btn = scroll.viewWithTag(1) as! UIButton
                
                let d = [NSAttributedString.Key.font:comp_btn.titleLabel?.font!]
                let l1 = 2*self.gb.padding + (cat as NSString).size(withAttributes: d as [NSAttributedString.Key : Any]).width
                let len = min(max(l1, self.gb.min_len), scroll.bounds.width)
                
                let cur = UIButton()
                cur.bounds = CGRect(x: 0, y: 0, width: len, height: comp_btn.bounds.height)
                cur.setTitle(cat, for: .normal)
                cur.titleLabel?.font = comp_btn.titleLabel?.font
                cur.backgroundColor = UIColor.init(rgb: colors[(self.categories.count - 1) % colors.count])
                cur.setTitleColor(UIColor.white, for: .normal)
                cur.center = CGPoint(x: scroll.bounds.width / 2, y: cur.bounds.height / 2)
                cur.alpha = 0
                cur.clipsToBounds = true
                cur.layer.cornerRadius = cur.bounds.height / 2
                cur.tag = self.categories.count
                cur.isUserInteractionEnabled = false
                scroll.addSubview(cur)
                
                if(s + CGFloat(cnt)*self.gb.padding + cur.bounds.width <= scroll.bounds.width){
                    var actual_pd = (scroll.bounds.width - (s + cur.bounds.width)) / CGFloat(cnt + 2)
                    var border_pd = actual_pd
                    if(actual_pd < self.gb.padding){
                        actual_pd = self.gb.padding
                        border_pd = (scroll.bounds.width - s - CGFloat(cnt)*self.gb.padding - cur.bounds.width) / 2
                    }
                    var x = border_pd
                    for j in 0..<(self.categories.count - 1){
                        if(self.gb.categories_centers[j].y < m - 1){
                            continue
                        }
                        let v = scroll.viewWithTag(j + 1)!
                        self.gb.categories_centers[j] = CGPoint(x: x + v.bounds.width / 2, y: m)
                        x += v.bounds.width + actual_pd
                    }
                    self.gb.categories_centers.append(CGPoint(x: x + cur.bounds.width / 2, y: m))
                }else{
                    self.gb.categories_centers.append(CGPoint(x: scroll.bounds.width / 2, y: m + self.gb.padding + cur.bounds.height))
                    scroll.contentSize = CGSize(width: scroll.bounds.width, height: m + self.gb.padding + 1.5*cur.bounds.height)
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
        let category_view = view.viewWithTag(300)!
        let rec1 = UITapGestureRecognizer(target: self, action: #selector(expandBottomBar(gesture: )))
        category_view.addGestureRecognizer(rec1)
        
        cross_btn = view.viewWithTag(500) as! UIButton
        cross_btn.addTarget(self, action: #selector(shrinkBottomBar(_:)), for: .touchUpInside)
        cross_btn.isUserInteractionEnabled = false
        
        category_label = view.viewWithTag(700) as! UILabel
        category_label.text = no_category
        
        submit_btn = view.viewWithTag(800) as! UIButton
        submit_btn.addTarget(self, action: #selector(submit(_:)), for: .touchUpInside)
        
        let add_btn = view.viewWithTag(600) as! UIButton
        add_btn.addTarget(self, action: #selector(createCategory(_:)), for: .touchUpInside)
        
        ed_text_russian = (view.viewWithTag(100) as! UITextField)
        ed_text_english = (view.viewWithTag(101) as! UITextField)
        self.ed_text_english.delegate = self
        self.ed_text_russian.delegate = self
    }
    
    @objc func submit(_ sender: Any) {
        ref.child("words").child(String(number_of_words)).child("English").setValue(ed_text_english.text!)
        ref.child("words").child(String(number_of_words)).child("Russian").setValue(ed_text_russian.text!)
        ref.child("words").child(String(number_of_words)).child("date").setValue(next_date)
        ref.child("words").child(String(number_of_words)).child("level").setValue(0)
        ref.child("words").child(String(number_of_words)).child("category").setValue(category_label.text!)
        
        number_of_words += 1
        print(number_of_words)
        
        let oldValue = submit_btn.layer.cornerRadius
        submit_btn.setTitle("", for: .normal)
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.8)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeInEaseOut))

        UIView.animate(withDuration: 0.8, animations: {
            for i in self.submit_btn.superview!.subviews{
                if(i.tag != self.submit_btn.tag){
                    i.alpha = 0
                    i.isUserInteractionEnabled = false
                }
            }
            self.submit_btn.bounds = CGRect(x: 0, y: 0, width: 0.35*self.gb.window_width, height: 0.35*self.gb.window_width)
            self.submit_btn.center = CGPoint(x: self.gb.window_width / 2, y: self.gb.window_height / 2)
        }, completion: {(finished: Bool) in
            let s_img = UIImageView(image: UIImage(named: "checkmark"))
            s_img.bounds = CGRect(x: 0, y: 0, width: 0.4*self.submit_btn.bounds.width, height: 0.23*self.submit_btn.bounds.width)
            s_img.center = self.submit_btn.center
            s_img.alpha = 0
            self.submit_btn.superview!.addSubview(s_img)
            UIView.animate(withDuration: 0.2, animations: {
                s_img.alpha = 1
            }, completion: {(finished: Bool) in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.view.alpha = 0
                    }, completion: {(finished: Bool) in
                        let v = self.gb.buildCreateWord(categories: default_categories)
                        self.view.viewWithTag(12345)?.removeFromSuperview()
                        self.view.addSubview(v)
                        UIView.animate(withDuration: 0.3, animations: {
                            self.view.alpha = 1
                        }, completion: {(finished: Bool) in
                            self.setView()
                        })
                    })
                })
            })
        })
        
        let cornerAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.cornerRadius))
        cornerAnimation.fromValue = oldValue
        cornerAnimation.toValue = submit_btn.bounds.height / 2

        submit_btn.layer.cornerRadius = submit_btn.bounds.height / 2
        submit_btn.layer.add(cornerAnimation, forKey: #keyPath(CALayer.cornerRadius))

        CATransaction.commit()
 
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        ed_text_english.resignFirstResponder()
        ed_text_russian.resignFirstResponder()
        return true
    }
    
    @objc func expandBottomBar(gesture: UITapGestureRecognizer){
        if(opened){
            return
        }
        print("test")
        opened = true
        let v = gesture.view!
        let scroll = v.viewWithTag(400) as! UIScrollView
        if(scroll.contentSize.height > scroll.bounds.height){
            scroll.isScrollEnabled = true
        }
        let add_btn = v.viewWithTag(600) as! UIButton
        let change_cross_pos = (gb.bottom_bar_width - v.bounds.width) / 2
        UIView.animate(withDuration: 0.5, animations: {
            v.bounds = CGRect(x: 0, y: 0, width: self.gb.bottom_bar_width, height: self.gb.bottom_bar_height)
            v.center = CGPoint(x: 0.5 * self.gb.window_width, y: self.gb.window_height - (self.gb.window_width - self.gb.bottom_bar_width) / 2 - v.bounds.height / 2)
            v.alpha = 1
            add_btn.center = CGPoint(x: self.gb.bottom_bar_width / 2, y: add_btn.center.y)
            add_btn.alpha = 1
            self.cross_btn.alpha = 1
            self.cross_btn.center = CGPoint(x: self.cross_btn.center.x + change_cross_pos, y: self.cross_btn.center.y)
            for i in 0..<self.categories.count{
                let cat = scroll.viewWithTag(i + 1) as! UIButton
                cat.addTarget(self, action: #selector(self.chooseCategory(sender:)), for: .touchUpInside)
                cat.isUserInteractionEnabled = true
                cat.center = self.gb.categories_centers[i]
                cat.alpha = 1
            }
        }, completion: {(finished: Bool) in
            add_btn.isUserInteractionEnabled = true
            self.cross_btn.isUserInteractionEnabled = true
        })
    }
    
    @objc func chooseCategory(sender: UIButton){
        print("nice")
        category_label.text = sender.title(for: .normal)
        shrinkBottomBar(nil)
    }
    
    @objc func shrinkBottomBar(_ sender: UIButton?){
        opened = false
        let v = cross_btn.superview!
        let scroll = v.viewWithTag(400) as! UIScrollView
        scroll.isScrollEnabled = false
        let change_cross_pos = (gb.bottom_bar_width - gb.bottom_bar_width_small) / 2
        let add_btn = v.viewWithTag(600) as! UIButton
        add_btn.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.5, animations: {
            v.bounds = CGRect(x: 0, y: 0, width: self.gb.bottom_bar_width_small, height: self.gb.bottom_bar_height_small)
            v.center = CGPoint(x: 0.5 * self.gb.window_width, y: self.gb.window_height - (self.gb.window_width - self.gb.bottom_bar_width) / 2 - self.gb.bottom_bar_height + self.gb.bottom_bar_height_small / 2)
            v.alpha = 0.5
            add_btn.alpha = 0
            add_btn.center = CGPoint(x: self.gb.bottom_bar_width_small / 2, y: add_btn.center.y)
            self.cross_btn.alpha = 0
            self.cross_btn.center = CGPoint(x: self.cross_btn.center.x - change_cross_pos, y: self.cross_btn.center.y)
            for i in 0..<self.categories.count{
                let cat = scroll.viewWithTag(i + 1) as! UIButton
                cat.center = CGPoint(x: scroll.bounds.width / 2, y: cat.bounds.height / 2)
                cat.alpha = 0
            }
        }, completion: {(finished: Bool) in
            v.isUserInteractionEnabled = true
        })
    }

}
