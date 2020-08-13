//
//  MainView.swift
//  testing
//
//  Created by Vadim Zaripov on 28.05.2020.
//  Copyright © 2020 Vadim Zaripov. All rights reserved.
//

import UIKit

class MainView: UIView {

    let font = "Helvetica"
    var submit_btn_old_frame = CGRect()
    
    var editTextFirst, editTextSecond, editTextThird: UITextField!
    var nextButton, forgotButton: Button!
    var editButton, deleteButton: Button!
    var containerView: UIView!
    var endOfWordsView: UILabel!
    
    var arrowImageView: UIImageView!
    var nextButtonDescriptionLabel: UILabel!
    var editButtonDescription, deleteButtonDescription: UILabel!
    var titleLabel: UILabel!
    
    override init(frame: CGRect){
        super.init(frame: frame)
        containerView = UIView(frame: bounds)
        containerView.backgroundColor = .clear
        addSubview(containerView)
        
        let height = 0.07*frame.height
        let font_sz = CGFloat(FontHelper().getInterfaceFontSize(font: font, height: height))
        
        titleLabel = {
            let title_label = UILabel(frame: CGRect(x: 0.05*frame.width, y: 0.1*frame.height, width: 0.9*frame.width, height: height))
            title_label.text = main_page_title
            title_label.font = UIFont(name: font, size: font_sz)
            title_label.textColor = UIColor.white
            title_label.textAlignment = .center
            
            return title_label
        }()
        containerView.addSubview(titleLabel)
        
        for i in 0..<3{
            let y = 0.45*frame.height + ((i == 0) ? -1.5*height : 0.5*height)
            let ed_text = UITextField(frame: CGRect(x: 0.1*frame.width, y: y, width: 0.8*frame.width, height: height))
            ed_text.text = (i == 0) ? loading_text : ""
            ed_text.font = UIFont(name: font, size: font_sz)
            ed_text.textColor = UIColor.white
            
            ed_text.adjustsFontSizeToFitWidth = true
            
            ed_text.autocorrectionType = .no
            
            let bottomLine = CALayer()
            bottomLine.frame = CGRect(origin: CGPoint(x: 0, y:ed_text.frame.height - 1), size: CGSize(width: ed_text.frame.width, height: 2))
            bottomLine.backgroundColor = UIColor.white.cgColor
            ed_text.borderStyle = .none
            ed_text.layer.addSublayer(bottomLine)
            
            ed_text.tag = i + 1
            ed_text.backgroundColor = UIColor.clear
            ed_text.isUserInteractionEnabled = (i == 1)
            ed_text.textAlignment = .center
            if(i == 1){
                ed_text.attributedPlaceholder = NSAttributedString(string: main_page_placeholders[i], attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(white: 1.0, alpha: 0.5)])
                editTextSecond = ed_text
                containerView.addSubview(ed_text)
            }else if(i == 0){
                editTextFirst = ed_text
                containerView.addSubview(ed_text)
            }else{
                editTextThird = ed_text
                editTextThird.textColor = UIColor.init(rgb: green_clr)
            }
        }
        
        nextButton = {
            let next_btn = Button(frame: CGRect(x: 0.275*frame.width, y: 0.77*frame.height - height, width: 0.45*frame.width, height: height))
            next_btn.setTitle("", for: .normal)
            next_btn.setTitleColor(UIColor.white, for: .normal)
            next_btn.backgroundColor = UIColor.clear
            next_btn.layer.borderWidth = 2
            next_btn.layer.borderColor = UIColor.white.cgColor
            next_btn.layer.cornerRadius = next_btn.bounds.height / 2
            next_btn.isUserInteractionEnabled = true
            
            return next_btn
        }()
        nextButton.tag = 100
        
        arrowImageView = {
            let arr_img = UIImage(named: "next")
            let newSize = CGSize(width: 0.33*nextButton.bounds.width, height: 0.7*nextButton.bounds.height)
            let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            arr_img?.draw(in: rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            let arrow_img = UIImageView(image: newImage!.withRenderingMode(.alwaysTemplate))
            arrow_img.contentMode = .right
            arrow_img.clipsToBounds = true
            arrow_img.tintColor = UIColor.white
            arrow_img.bounds = rect
            arrow_img.center = nextButton.center
            
            return arrow_img
        }()
        
        containerView.addSubview(arrowImageView)
        containerView.addSubview(nextButton)
        
        nextButtonDescriptionLabel = {
            let describtionlabel = UILabel(frame: CGRect(x: 0, y: 0, width: nextButton.bounds.width, height: 0.35*nextButton.bounds.height))
            describtionlabel.center = CGPoint(x: frame.width / 2, y: nextButton.frame.maxY + describtionlabel.bounds.height / 2)
            describtionlabel.text = main_page_describtion_check
            let f_sz_small = CGFloat(FontHelper().getInterfaceFontSize(font: font, height: describtionlabel.bounds.height))
            describtionlabel.font = UIFont(name: font, size: f_sz_small)
            describtionlabel.textColor = UIColor.white
            describtionlabel.alpha = 0.8
            describtionlabel.textAlignment = .center
            
            return describtionlabel
        }()
        containerView.addSubview(nextButtonDescriptionLabel)
        
        forgotButton = {
            let forgot_btn = Button(frame: CGRect(x: 0, y: 0, width: 0.45*frame.width, height: height))
            forgot_btn.center = CGPoint(x: frame.width / 2, y: nextButtonDescriptionLabel.frame.maxY + forgot_btn.bounds.height)
            forgot_btn.setTitle(main_page_forgot_word_text, for: .normal)
            forgot_btn.setTitleColor(UIColor.white, for: .normal)
            forgot_btn.backgroundColor = UIColor.clear
            forgot_btn.layer.borderWidth = 2
            forgot_btn.layer.borderColor = UIColor.white.cgColor
            forgot_btn.layer.cornerRadius = nextButton.bounds.height / 2
            forgot_btn.isUserInteractionEnabled = true
            
            return forgot_btn
        }()
        containerView.addSubview(forgotButton)
        
        //Incorrect answer
        
        for i in 0..<2{
            let btn = Button(frame: CGRect(x: frame.width / 2 + CGFloat(3*i - 2)*height, y: 0.45*frame.height + 2.2*height, width: height, height: height))
            btn.backgroundColor = UIColor.clear
            btn.setImage(UIImage(named: ((i == 0) ? "edit" : "trash")), for: .normal)
            btn.setTitle("", for: .normal)
            btn.isUserInteractionEnabled = false
            btn.alpha = 0
            containerView.addSubview(btn)
            
            let descr = UILabel()
            let d = [NSAttributedString.Key.font: nextButtonDescriptionLabel.font!]
            descr.bounds = CGRect(x: 0, y: 0, width: (main_page_img_describtions[i] as NSString).size(withAttributes: d).width, height: nextButtonDescriptionLabel.bounds.height)
            descr.center = CGPoint(x: btn.center.x, y: btn.frame.maxY + descr.bounds.height)
            descr.font = nextButtonDescriptionLabel.font
            descr.text = main_page_img_describtions[i]
            descr.textColor = UIColor.white
            descr.textAlignment = .center
            descr.alpha = 0
            descr.isUserInteractionEnabled = false
            
            if(i == 0){
                editButton = btn
                editButtonDescription = descr
            }else{
                deleteButton = btn
                deleteButtonDescription = descr
            }
            containerView.addSubview(descr)
        }
        
        submit_btn_old_frame = nextButton.frame
        
        endOfWordsView = {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 0.85*frame.width, height: 0.4*frame.height))
            label.center = CGPoint(x: frame.width / 2, y: frame.height / 2)
            label.backgroundColor = .clear
            label.textColor = .white
            label.font = UIFont(name: "Helvetica", size: 42)
            label.textAlignment = .center
            label.numberOfLines = 3
            label.adjustsFontSizeToFitWidth = true
            
            return label
        }()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showEndOfWordsView(animated: Bool, completion: @escaping () -> Void = { }){
        if(!animated){
            containerView.removeFromSuperview()
            addSubview(endOfWordsView)
            completion()
            return
        }
        self.endOfWordsView.alpha = 0
        self.endOfWordsView.text = end_of_words_text
        self.endOfWordsView.frame = CGRect(x: frame.maxX, y: endOfWordsView.frame.minY, width: endOfWordsView.frame.width, height: endOfWordsView.frame.height)
        self.addSubview(self.endOfWordsView)
        
        UIView.animate(withDuration: 0.4, animations: {
            self.containerView.alpha = 0
            self.containerView.frame = CGRect(
                x: -self.containerView.bounds.width,
                y: self.containerView.frame.minY,
                width: self.containerView.frame.width,
                height: self.containerView.frame.height)
            self.endOfWordsView.center = CGPoint(x: self.frame.width / 2, y: self.endOfWordsView.center.y)
            self.endOfWordsView.alpha = 1
        }, completion: {(finished: Bool) in
            self.containerView.removeFromSuperview()
            self.containerView.center = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
            self.containerView.alpha = 1
            completion()
        })
    }
    
    func showContainerView(){
        endOfWordsView.removeFromSuperview()
        addSubview(containerView)
        editTextFirst.text = ""
        //editTextSecond.text = ""
        //editTextSecond.textColor = .white
    }
    
    func switchTextFields(text: String){
        let height = 0.07*frame.height
        let font_sz = CGFloat(FontHelper().getInterfaceFontSize(font: font, height: height))
        var newFirst = UITextField(), newSecond = UITextField()
        for i in 0..<2{
            let y = 0.45*frame.height + ((i == 0) ? -1.5*height : 0.5*height)
            let ed_text = UITextField(frame: CGRect(x: 0.9*frame.width, y: y, width: 0.8*frame.width, height: height))
            ed_text.text = (i == 0) ? loading_text : ""
            ed_text.font = UIFont(name: font, size: font_sz)
            ed_text.textColor = UIColor.white
            
            ed_text.adjustsFontSizeToFitWidth = true
            
            ed_text.autocorrectionType = .no
            
            let bottomLine = CALayer()
            bottomLine.frame = CGRect(origin: CGPoint(x: 0, y:ed_text.frame.height - 1), size: CGSize(width: ed_text.frame.width, height: 2))
            bottomLine.backgroundColor = UIColor.white.cgColor
            ed_text.borderStyle = .none
            ed_text.layer.addSublayer(bottomLine)
            
            ed_text.tag = i + 1
            ed_text.backgroundColor = UIColor.clear
            ed_text.isUserInteractionEnabled = (i == 1)
            ed_text.textAlignment = .center
            if(i == 1){
                ed_text.attributedPlaceholder = NSAttributedString(string: main_page_placeholders[i], attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(white: 1.0, alpha: 0.5)])
                newSecond = ed_text
            }else{
                ed_text.text = text
                newFirst = ed_text
            }
            ed_text.alpha = 1
            self.containerView.addSubview(ed_text)
        }
        
        UIView.animate(withDuration: 0.4, animations: {
            self.editTextFirst.center = CGPoint(x: self.editTextFirst.center.x - self.editTextFirst.bounds.width, y: self.editTextFirst.center.y)
            self.editTextSecond.center = CGPoint(x: self.editTextSecond.center.x - self.editTextSecond.bounds.width, y: self.editTextSecond.center.y)
            
            newFirst.center = CGPoint(x: newFirst.center.x - newFirst.bounds.width, y: newFirst.center.y)
            newSecond.center = CGPoint(x: newSecond.center.x - newSecond.bounds.width, y: newSecond.center.y)
            
            self.editTextFirst.alpha = 0
            self.editTextSecond.alpha = 0
            newFirst.alpha = 1
            newSecond.alpha = 1
            
            newFirst.delegate = self.editTextFirst.delegate
            newSecond.delegate = self.editTextSecond.delegate
        }, completion: {(finished: Bool) in
            self.editTextFirst.removeFromSuperview()
            self.editTextSecond.removeFromSuperview()
            
            self.editTextFirst = newFirst
            self.editTextSecond = newSecond
        })

    }
    
    func animateIncorrectAnswer(ans: String, correct: String, status: Int){
        let oldValue = nextButton.layer.cornerRadius
        let new_height = 2*nextButton.bounds.height
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.4)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeInEaseOut))
        
        if(status == self.nextButton.tag){
            self.editTextSecond.textColor = UIColor.magenta
            self.editTextThird.text = correct
            self.editTextThird.alpha = 0
            self.editTextThird.center = CGPoint(x: self.editTextThird.center.x, y: 0.45*self.frame.height + 3*self.editTextThird.bounds.height)
            self.editTextSecond.text = ans.formatted()
            self.containerView.addSubview(self.editTextThird)
        }else{
            self.editTextSecond.text = correct
            self.editTextSecond.textColor = UIColor.init(rgb: green_clr)
        }
        
        UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: [], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.9) {
                self.nextButton.bounds = CGRect(x: 0, y: 0, width: 2*self.nextButton.bounds.height, height: new_height)
                self.nextButton.center = CGPoint(x: self.frame.width / 2, y: 0.9*self.frame.height - self.nextButton.bounds.height / 2)
                
                self.arrowImageView.center = self.nextButton.center
                self.arrowImageView.bounds = CGRect(x: 0, y: 0, width: 0.5*self.nextButton.bounds.width, height: self.arrowImageView.bounds.height)
                
                self.nextButtonDescriptionLabel.center = CGPoint(x: self.center.x, y: self.nextButton.frame.maxY + self.nextButtonDescriptionLabel.bounds.height)
                self.nextButtonDescriptionLabel.text = main_page_next_text
                
                self.editButtonDescription.alpha = 0.8
                self.deleteButtonDescription.alpha = 0.8
                
                self.titleLabel.text = main_page_incorrect
                
                self.forgotButton.alpha = 0
                self.deleteButton.alpha = 1
                self.editButton.alpha = 1
                
                self.editTextSecond.isUserInteractionEnabled = false
            }
            if(status == self.nextButton.tag){
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.6) {
                    self.editTextFirst.center = CGPoint(x: self.editTextFirst.center.x, y: self.editTextFirst.center.y - 2*self.editTextThird.bounds.height)
                }
                UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.6) {
                    self.editTextSecond.center = CGPoint(x: self.editTextSecond.center.x, y: self.editTextSecond.center.y - 2*self.editTextThird.bounds.height)
                }
                UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.6) {
                    self.editTextThird.alpha = 1
                    self.editTextThird.center = CGPoint(x: self.editTextThird.center.x, y: self.editTextThird.center.y - 2*self.editTextThird.bounds.height)
                }
            }
            
        }) { (finished) in
            self.nextButton.isEnabled = true
            self.forgotButton.isUserInteractionEnabled = false
            self.deleteButton.isUserInteractionEnabled = true
            self.editButton.isUserInteractionEnabled = true
        }
        
        let cornerAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.cornerRadius))
        cornerAnimation.fromValue = oldValue
        cornerAnimation.toValue = new_height / 2
        nextButton.layer.cornerRadius = new_height / 2
        nextButton.layer.add(cornerAnimation, forKey: #keyPath(CALayer.cornerRadius))

        CATransaction.commit()
    }
    
    func animateNextWord(nextWord: String?, completion: (() -> Void)?){
        let oldValue = nextButton.layer.cornerRadius
        let new_height = nextButton.bounds.height / 2
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.5)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeInEaseOut))
        
        UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: [], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.9) {
                self.nextButton.frame = self.submit_btn_old_frame
                
                self.arrowImageView.center = self.nextButton.center
                self.arrowImageView.bounds = CGRect(x: 0, y: 0, width: 0.33*self.nextButton.bounds.width, height: self.arrowImageView.bounds.height)
                
                self.nextButtonDescriptionLabel.center = CGPoint(x: self.center.x, y: self.nextButton.frame.maxY + self.nextButtonDescriptionLabel.bounds.height)
                self.nextButtonDescriptionLabel.text = main_page_describtion_check
                
                self.editButtonDescription.alpha = 0
                self.deleteButtonDescription.alpha = 0
                
                self.titleLabel.text = main_page_title
                
                self.forgotButton.alpha = 1
                self.deleteButton.alpha = 0
                self.editButton.alpha = 0

                self.editTextSecond.isUserInteractionEnabled = true
            }
            if((self.editTextThird.superview) != nil){
                UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.6) {
                    self.editTextFirst.center = CGPoint(x: self.editTextFirst.center.x, y: self.editTextFirst.center.y + 2*self.editTextThird.bounds.height)
                }
                UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.6) {
                    self.editTextSecond.center = CGPoint(x: self.editTextSecond.center.x, y: self.editTextSecond.center.y + 2*self.editTextThird.bounds.height)
                }
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.6) {
                    self.editTextThird.alpha = 0
                    self.editTextThird.center = CGPoint(x: self.editTextThird.center.x, y: self.editTextThird.center.y + 2*self.editTextThird.bounds.height)
                }
            }
            
        }) { (finished) in
            self.nextButton.isEnabled = true
            self.forgotButton.isUserInteractionEnabled = true
            self.deleteButton.isUserInteractionEnabled = false
            self.editButton.isUserInteractionEnabled = false
            self.editTextThird.removeFromSuperview()
            
            self.nextButton.isEnabled = true
            self.forgotButton.isEnabled = true
            
            guard let word = nextWord else{
                self.showEndOfWordsView(animated: true) {
                    if let compl = completion{
                        compl()
                    }
                }
                return
            }
                
            self.switchTextFields(text: word)
            if let compl = completion{
                compl()
            }
        }
               
        let cornerAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.cornerRadius))
        cornerAnimation.fromValue = oldValue
        cornerAnimation.toValue = new_height / 2
        nextButton.layer.cornerRadius = new_height / 2
        nextButton.layer.add(cornerAnimation, forKey: #keyPath(CALayer.cornerRadius))

        CATransaction.commit()
    }
    
    func resetTint(deadline: DispatchTime, completion: @escaping () -> Void){
        DispatchQueue.main.asyncAfter(deadline: deadline, execute: {
            self.arrowImageView.tintColor = UIColor.white
            completion()
        })
    }
    
    func clear() {
        containerView.removeFromSuperview()
        endOfWordsView.removeFromSuperview()
    }
}
