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
    
    var currentPageIndex:Int = 0 // holds the current page index
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
        
        self.pageviewcontroller = (self.storyboard?.instantiateViewController(withIdentifier: "PageVC") as! UIPageViewController)
        self.pageviewcontroller.dataSource = self
        self.pageviewcontroller.delegate = self
        let top = sign_out_btn.frame.maxY + 0.02*view.bounds.height
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
