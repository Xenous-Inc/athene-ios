//
//  NewWordViewController.swift
//  testing
//
//  Created by Vadim on 16/03/2019.
//  Copyright © 2019 Vadim Zaripov. All rights reserved.
//

import UIKit

class NewWordViewController: UIViewController, UITextFieldDelegate {

    var ed_text_english: UITextField!
    var ed_text_russian: UITextField!
  
    var cross_btn = UIButton()
    var category_label = UILabel()
    var submit_btn = UIButton()
    
    
    var opened = false
    var gb = GraphicBuilder(width: 0, height: 0)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gb = GraphicBuilder(width: view.frame.size.width, height: view.frame.size.height)
        let v = gb.buildCreateWord(categories: default_categories)
        v.center = CGPoint(x: view.frame.size.width / 2, y: view.frame.size.height / 2)
        let category_view = v.viewWithTag(300)!
        let rec1 = UITapGestureRecognizer(target: self, action: #selector(expandBottomBar(gesture: )))
        category_view.addGestureRecognizer(rec1)
        view.addSubview(v)
        
        cross_btn = v.viewWithTag(500) as! UIButton
        cross_btn.addTarget(self, action: #selector(shrinkBottomBar(_:)), for: .touchUpInside)
        cross_btn.isUserInteractionEnabled = false
        
        category_label = v.viewWithTag(700) as! UILabel
        
        submit_btn = v.viewWithTag(800) as! UIButton
        submit_btn.addTarget(self, action: #selector(submit(_:)), for: .touchUpInside)
        
        ed_text_russian = (v.viewWithTag(100) as! UITextField)
        ed_text_english = (v.viewWithTag(101) as! UITextField)
        self.ed_text_english.delegate = self
        self.ed_text_russian.delegate = self
    }
    
    @IBAction func submit(_ sender: Any) {
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    self.performSegue(withIdentifier: "return_make_new_word", sender: self)
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
    
    @IBAction func Cancel(_ sender: Any) {
        performSegue(withIdentifier: "return_make_new_word", sender: self)
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
            for i in 0..<default_categories.count{
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
            for i in 0..<default_categories.count{
                let cat = scroll.viewWithTag(i + 1) as! UIButton
                cat.center = CGPoint(x: scroll.bounds.width / 2, y: cat.bounds.height / 2)
                cat.alpha = 0
            }
        }, completion: {(finished: Bool) in
            v.isUserInteractionEnabled = true
        })
    }

}
