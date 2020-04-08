//
//  ArchiveViewController.swift
//  testing
//
//  Created by Vadim on 17/03/2019.
//  Copyright © 2019 Vadim Zaripov. All rights reserved.
//

import UIKit

var categories_words: [String: [Word]] = [:]

class ArchiveViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    var frame: CGRect? = nil
    var tableView: UITableView!
    var bottom_bar_btns: [UIView] = []
    
    var current_tab = 0
    var views: [UIView] = []
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(frame != nil){
            view.frame = frame!
        }
        let pd = 0.02*view.bounds.width
        let bottom_bar = UIView(frame: CGRect(x: 0, y: 0.9*view.bounds.height, width: view.bounds.width, height: 0.1*view.bounds.height))
        for i in 0..<2{
            let width = view.bounds.width / 3
            let btn = UIButton(frame: CGRect(x: CGFloat(i+1)*pd + CGFloat(i)*width, y: pd, width: width, height: bottom_bar.bounds.height - 2*pd))
            btn.layer.borderWidth = 2
            btn.layer.borderColor = UIColor.white.cgColor
            btn.layer.cornerRadius = btn.bounds.height / 2
            btn.setTitle((i == 0) ? categories_title : archive_title, for: .normal)
            let f_sz = FontHelper().getFontSize(strings: [categories_title, archive_title], font: "Helvetica", maxFontSize: 120, width: 0.8*btn.bounds.width, height: 0.9*btn.bounds.height)
            btn.setTitleColor(UIColor.white, for: .normal)
            btn.titleLabel?.font = UIFont(name: "Helvetica", size: CGFloat(f_sz))
            btn.tag = i
            if(i == 0){
                btn.backgroundColor = UIColor.init(white: 1, alpha: 0.4)
            }
            btn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(switchView(gesture:))))
            bottom_bar.addSubview(btn)
            bottom_bar_btns.append(btn)
        }
        view.addSubview(bottom_bar)
        let v = CustomTableView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - bottom_bar.bounds.height), content: categories_words)
        self.view.addSubview(v)
        views.append(v)
        
        self.tableView = UITableView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - bottom_bar.bounds.height))
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "archiveCell")
        self.tableView.backgroundColor = UIColor.clear
        tableView.delegate = self
        tableView.dataSource = self
        views.append(tableView)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return archive.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "archiveCell", for: indexPath)
        cell.textLabel?.text = archive[indexPath.row].english + " - " + archive[indexPath.row].russian
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.textColor = UIColor.white
        cell.frame = cell.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        return cell
    }
    
    @objc func switchView(gesture: UITapGestureRecognizer){
        let new_ind = gesture.view!.tag
        print(current_tab, new_ind)
        if(new_ind == current_tab){
            return
        }
        view.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.3, animations: {
            self.views[self.current_tab].alpha = 0
            for i in self.bottom_bar_btns{i.backgroundColor = UIColor.init(white: 1, alpha: 0.2)}
        }, completion: {(finished: Bool) in
            self.views[new_ind].alpha = 0
            self.view.addSubview(self.views[new_ind])
            self.views[self.current_tab].removeFromSuperview()
            UIView.animate(withDuration: 0.3, animations: {
                self.views[new_ind].alpha = 1
                self.bottom_bar_btns[self.current_tab].backgroundColor = UIColor.clear
                self.bottom_bar_btns[new_ind].backgroundColor = UIColor.init(white: 1, alpha: 0.4)
            }, completion: {(finished: Bool) in
                self.current_tab = new_ind
                self.view.isUserInteractionEnabled = true
            })
        })
    }
}
