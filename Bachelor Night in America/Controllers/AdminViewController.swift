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
            self.users = users
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserTableViewCell
        let currentUser = users[indexPath.row]
        
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
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    

    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
