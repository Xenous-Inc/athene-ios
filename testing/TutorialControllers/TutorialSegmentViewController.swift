//
//  TutorialSegmentViewController.swift
//  testing
//
//  Created by Vadim on 14/04/2020.
//  Copyright © 2020 Vadim Zaripov. All rights reserved.
//

import UIKit

class TutorialSegmentViewController: UIViewController {

    var image_name: String = ""
    var frame: CGRect? = nil
    var is_last = false
    
    init(frame: CGRect, image: String, is_last: Bool){
        super.init(nibName: nil, bundle: nil)
        self.frame = frame
        self.image_name = image
        self.is_last = is_last
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let new_frame = frame{
            view.frame = new_frame
        }

        let imageView: UIImageView = {
            let img_view = UIImageView(frame: CGRect(x: 0, y: 0, width: 0.8*self.view.bounds.width, height: 0.8*self.view.bounds.height))
            img_view.center = CGPoint(x: self.view.bounds.width / 2, y: 0.45*self.view.bounds.height)
            img_view.image = UIImage(named: self.image_name)
            img_view.contentMode = .scaleAspectFit
            return img_view
        }()
        view.addSubview(imageView)
        
        if(is_last){
            print("Last tab")
            let finish_btn: Button = {
                let btn = Button(frame: CGRect(x: 0.1*imageView.bounds.width + imageView.frame.minX, y: imageView.frame.maxY + 0.02*view.bounds.width, width: 0.8*imageView.bounds.width, height: 0.06*view.bounds.height))
                btn.setTitle("Понятно", for: .normal)
                btn.setTitleColor(UIColor.init(rgb: colors[2]), for: .normal)
                btn.layer.borderColor = UIColor.init(rgb: colors[2]).cgColor
                btn.layer.cornerRadius = btn.bounds.height / 2
                btn.layer.borderWidth = 2
                return btn
            }()
            finish_btn.addTarget(self, action: #selector(finishTutorial(_:)), for: .touchUpInside)
            view.addSubview(finish_btn)
        }
    }
    
    @objc func finishTutorial(_ sender: Any){
        UserDefaults.setFirstLaunchToFalse()
        tutorial_vc.performSegue(withIdentifier: "finished_tutorial", sender: tutorial_vc)
    }

}
