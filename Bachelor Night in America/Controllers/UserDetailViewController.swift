//
//  UserDetailViewController.swift
//  Bachelor Night in America
//
//  Created by TJ Carney on 9/20/20.
//  Copyright © 2020 TJ Carney. All rights reserved.
//

import UIKit
import FirebaseStorage

class UserDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var currentPickImageView: UIImageView!
    @IBOutlet weak var currentPickNameLabel: UILabel!
    @IBOutlet weak var previousPicksTableView: UITableView!
    
    var contestants: [Contestant] = []
    var user: BNIAUser?
    var currentPick: Contestant?
    var previousPicks: [Contestant] = [] {
        didSet {
            self.previousPicksTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        previousPicksTableView.delegate = self
        previousPicksTableView.dataSource = self
        if currentPick != nil {
            let placeholder = UIImage(named: "female")
            let ref = FirebaseClient.storage.child("contestants/\(self.currentPick!.imagePath)")
            self.currentPickImageView.sd_setImage(with: ref, placeholderImage: placeholder)
            self.currentPickNameLabel.text = self.currentPick!.name
        } else {
            self.currentPickImageView.image = UIImage(named: "logo")
            self.currentPickNameLabel.text = "No Pick Entered"
        }
        guard let currentUser = user else {return}
        self.previousPicks = contestants.filter({ (contestant) -> Bool in
            currentUser.picks.contains(contestant.id) && currentUser.currentPick != contestant.id
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return previousPicks.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "previousPickCell", for: indexPath) as! PreviousPickTableViewCell
        let currentPreviousPick = previousPicks[indexPath.row]
        let placeholder = UIImage(named: "female")
        let ref = FirebaseClient.storage.child("contestants/\(currentPreviousPick.imagePath)")
        cell.previousPickImageView.sd_setImage(with: ref, placeholderImage: placeholder)
        cell.weekLabel.text = "Week \(indexPath.row + 1) Pick"
        cell.previousPickNameLabel.text = currentPreviousPick.name + " (\(currentPreviousPick.id))"
        return cell
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
