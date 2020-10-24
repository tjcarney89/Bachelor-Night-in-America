//
//  AdminViewController.swift
//  Bachelor Night in America
//
//  Created by TJ Carney on 7/21/20.
//  Copyright © 2020 TJ Carney. All rights reserved.
//

import UIKit

class AdminViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var userTableView: UITableView!
    
    var users: [BNIAUser] = []
    var contestants: [Contestant] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userTableView.delegate = self
        self.userTableView.dataSource = self
        self.userTableView.tableFooterView = UIView()
        FirebaseClient.fetchUsers { (users) in
            self.users = users.sorted(by: { (user1, user2) -> Bool in
                user1.name < user2.name
            }).sorted(by: { (user1, user2) -> Bool in
                user1.currentPick != nil
            })
            DispatchQueue.main.async {
                self.userTableView.reloadData()
            }
        }
        FirebaseClient.fetchContestants { (contestants) in
            self.contestants = contestants
            DispatchQueue.main.async {
                self.userTableView.reloadData()
            }
        }

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.users.count
        case 1:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserTableViewCell
            let currentUser = users[indexPath.row]
            cell.selectionStyle = .none
            cell.nameLabel.text = currentUser.name
            if currentUser.currentPick != nil {
                var currentPick = ""
                for contestant in contestants {
                    if contestant.id == currentUser.currentPick! {
                        currentPick = contestant.name
                    }
                }
                cell.currentPickLabel.text = "Current Pick: \(currentPick)"
                cell.currentPickLabel.textColor = AppColors.green
            } else {
                cell.currentPickLabel.text = "Pick Not Entered"
                cell.currentPickLabel.textColor = AppColors.red
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "resetPicksCell", for: indexPath) as! ResetPicksTableViewCell
            cell.selectionStyle = .none
            cell.users = self.users
            cell.callerVC = self
            cell.separatorInset = UIEdgeInsets(top: 0, left: 10000, bottom: 0, right: 0)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    

    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userDetailSegue" {
            if let detailVC = segue.destination as? UserDetailViewController {
                detailVC.contestants = self.contestants
                detailVC.user = self.users[userTableView.indexPathForSelectedRow!.row]
                let currentPick = self.users[userTableView.indexPathForSelectedRow!.row].currentPick
                if currentPick != nil {
                    detailVC.currentPick = self.contestants[currentPick!]
                } else {
                    detailVC.currentPick = nil
                }
            }
        }
    }

}
