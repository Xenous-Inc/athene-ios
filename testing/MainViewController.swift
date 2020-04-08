//
//  MainViewController.swift
//  testing
//
//  Created by Vadim on 28/03/2020.
//  Copyright © 2020 Vadim Zaripov. All rights reserved.
//

import Foundation
import UIKit
import os
import Firebase

var main_vc = MainViewController()

class MainViewController: UIViewController, UIPageViewControllerDataSource, UINavigationControllerDelegate, UIPageViewControllerDelegate {
    
    
    @IBOutlet weak var sign_out_btn: UIButton!
    @IBOutlet weak var btn_top_constraint: NSLayoutConstraint!
    @IBOutlet weak var spacing1: NSLayoutConstraint!
    @IBOutlet weak var spacing2: NSLayoutConstraint!
    @IBOutlet weak var nav_btn1: UIButton!
    @IBOutlet weak var nav_btn2: UIButton!
    
    var currentPageIndex:Int = 1 // holds the current page index
    var pageviewcontroller:UIPageViewController! // self explanatory
    var ViewControllers: [UIViewController] = [UIViewController]()
    
    let dateFormatter = DateFormatter()
    
    var lastPendingViewControllerIndex = 0
    
    let pager_view = CustomPageControl()
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = ViewControllers.index(of: viewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else {
            return nil
        }
        guard ViewControllers.count > previousIndex else {
            return nil
        }
        return ViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = ViewControllers.index(of: viewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex + 1
        guard previousIndex >= 0 else {
            return nil
        }
        guard ViewControllers.count > previousIndex else {
            return nil
        }
        return ViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]){
        if pendingViewControllers.count > 0 {
            lastPendingViewControllerIndex = ViewControllers.index(of: pendingViewControllers.first!)!
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed{
            if(currentPageIndex == 1 && lastPendingViewControllerIndex == 0){
                UIView.animate(withDuration: 0.4, animations: {
                    self.nav_btn1.alpha = 1
                    self.nav_btn2.alpha = 1
                    self.nav_btn1.isUserInteractionEnabled = true
                    self.nav_btn2.isUserInteractionEnabled = true
                })
            }else if(currentPageIndex == 0 && lastPendingViewControllerIndex == 1){
                UIView.animate(withDuration: 0.4, animations: {
                    self.nav_btn1.alpha = 0
                    self.nav_btn2.alpha = 0
                    self.nav_btn1.isUserInteractionEnabled = false
                    self.nav_btn2.isUserInteractionEnabled = false
                })
            }
            currentPageIndex = lastPendingViewControllerIndex
            pager_view.moveTo(tab: currentPageIndex)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        main_vc = self
        
        if(UserDefaults.isFirstLaunch()){
            //Run tutorial
            //return
        }
        if(Auth.auth().currentUser == nil){
            os_log("Signing out...")
            DispatchQueue.main.async(){
                self.performSegue(withIdentifier: "signing_out", sender: self)
            }
            return
        }
        
        user = Auth.auth().currentUser!
        
        pager_view.set(width: self.view.frame.width, height: 0.05*self.view.frame.height, tabs: 3, start: 1)
        pager_view.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height - pager_view.frame.height / 2)
        view.addSubview(pager_view)
        
        let padding = 0.02*view.bounds.height
        btn_top_constraint.constant = padding
        
        spacing1.constant = padding
        spacing2.constant = padding
        
        let sz = CGSize(width: 0.25*view.bounds.width, height: 0.056*view.bounds.height)
        let f_sz = CGFloat(FontHelper().getFontSize(strings: [archive_title, categories_title], font: "Helvetica", maxFontSize: 120, width: sz.width - 0.5*sz.height, height: sz.height))
        nav_btn1.setTitle(categories_title, for: .normal)
        nav_btn2.setTitle(archive_title, for: .normal)
        for nav_btn in [nav_btn1, nav_btn2]{
            nav_btn?.titleLabel!.font = UIFont(name: "Helvetica", size: f_sz)
            nav_btn?.layer.cornerRadius = sz.height / 2
            nav_btn?.layer.borderColor = UIColor.white.cgColor
            nav_btn?.layer.borderWidth = 2
            nav_btn?.alpha = 0
        }
        
        self.pageviewcontroller = (self.storyboard?.instantiateViewController(withIdentifier: "PageVC") as! UIPageViewController)
        self.pageviewcontroller.dataSource = self
        self.pageviewcontroller.delegate = self
        let top = sign_out_btn.frame.maxY + padding
        self.pageviewcontroller.view.frame = CGRect(x: 0, y: top, width: self.view.frame.width, height: self.view.frame.height-self.pager_view.frame.height - top)
        ViewControllers.append(ArchiveViewController(frame: CGRect(x: 0, y: 0, width: self.pageviewcontroller.view.bounds.width, height: self.pageviewcontroller.view.bounds.height)))
        ViewControllers.append(ViewController(frame: CGRect(x: 0, y: 0, width: self.pageviewcontroller.view.bounds.width, height: self.pageviewcontroller.view.bounds.height)))
        ViewControllers.append(NewWordViewController(frame: CGRect(x: 0, y: 0, width: self.pageviewcontroller.view.bounds.width, height: self.pageviewcontroller.view.bounds.height)))
        self.pageviewcontroller.setViewControllers([ViewControllers[1]], direction: .forward, animated: true, completion: nil)
        
        let v = LoadingView()
        v.set(frame: view.frame)
        view.addSubview(v)
        v.show()
        updateWordsFromDatabase(completion: {(finished: Bool) in
            v.removeFromSuperview()
            self.addChild(self.pageviewcontroller)
            self.view.addSubview(self.pageviewcontroller.view)
            self.pageviewcontroller.didMove(toParent: self)
            (self.ViewControllers[1] as! ViewController).checkWordsUpdate()
        })
    }
    
    @IBAction func logOut(_ sender: Any) {
        let alert = UIAlertController(title: sign_out_question, message: nil, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: sign_out_text, style: UIAlertAction.Style.default, handler: {(action) in
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "signing_out", sender: self)
                }
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
        }))
        alert.addAction(UIAlertAction(title: sign_out_cancel, style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)    }
    
}
