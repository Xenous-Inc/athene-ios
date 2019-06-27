//
//  ArchiveViewController.swift
//  testing
//
//  Created by Vadim on 17/03/2019.
//  Copyright © 2019 Vadim Zaripov. All rights reserved.
//

import UIKit

class ArchiveViewController: UITableViewController{

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.contentInset = UIEdgeInsets(top: 34,left: 0,bottom: 0,right: 0);
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return archive.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "archiveCell", for: indexPath)
        cell.textLabel?.text = archive[indexPath.row]
        return cell
    }

    @IBAction func Back(_ sender: Any) {
        performSegue(withIdentifier: "back_from_archive", sender: self)
    }
}
