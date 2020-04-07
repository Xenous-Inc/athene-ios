//
//  ArchiveViewController.swift
//  testing
//
//  Created by Vadim on 17/03/2019.
//  Copyright © 2019 Vadim Zaripov. All rights reserved.
//

import UIKit

class ArchiveViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    var frame: CGRect? = nil
    var tableView: UITableView!
    
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
        let v = CustomTableView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height), content: ["Первый": [Word(eng: "nice", rus: "лол", ct: "", lvl: 0, ind: 0), Word(eng: "hello", rus: "привет", ct: "", lvl: 0, ind: 0)],
                                                             "Second": [Word(eng: "house", rus: "дом", ct: "", lvl: 0, ind: 0)],
                                                             "Third": [Word(eng: "perseverance", rus: "настойчивость", ct: "", lvl: 0, ind: 0), Word(eng: "doom", rus: "рок", ct: "", lvl: 0, ind: 0)]])
        self.view.addSubview(v)
        /*
        self.tableView = UITableView(frame: self.view.frame)
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "archiveCell")
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.frame = view.frame
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self*/
 
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
}
