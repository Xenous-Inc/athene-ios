//
//  ArchiveViewController.swift
//  testing
//
//  Created by Vadim on 17/03/2019.
//  Copyright © 2019 Vadim Zaripov. All rights reserved.
//

import UIKit

class ArchiveViewController: UITableViewController{

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView = UITableView(frame: self.view.frame)
        if(frame != nil){
            view.frame = frame!
        }
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "archiveCell")
        self.tableView.backgroundColor = UIColor.clear
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return archive.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "archiveCell", for: indexPath)
        cell.textLabel?.text = archive[indexPath.row].english + " - " + archive[indexPath.row].russian
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.textColor = UIColor.white
        cell.frame = cell.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        return cell
    }

    @IBAction func Back(_ sender: Any) {
        performSegue(withIdentifier: "back_from_archive", sender: self)
    }
}
