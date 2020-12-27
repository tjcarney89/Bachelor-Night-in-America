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
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    @IBOutlet weak var loadingMessageLabel: UILabel!
    @IBOutlet weak var checkmarkImageView: UIImageView!
    
    var users: [BNIAUser] = []
    var contestants: [Contestant] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userTableView.delegate = self
        self.userTableView.dataSource = self
        self.userTableView.tableFooterView = UIView()
        self.loadingView.layer.cornerRadius = 15
        self.loadingView.alpha = 0
        fetchUsers()
        FirebaseClient.fetchContestants { (contestants) in
            self.contestants = contestants
            DispatchQueue.main.async {
                self.userTableView.reloadData()
            }
        }

    }
    
    func fetchUsers() {
        FirebaseClient.fetchUsers { (users) in
            let picksIn = users.filter {$0.currentPick != nil}.sorted {$0.name < $1.name}
            let picksNotIn = users.filter {$0.currentPick == nil}.sorted {$0.name < $1.name}
            self.users = picksIn + picksNotIn

            DispatchQueue.main.async {
                self.userTableView.reloadData()
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserTableViewCell
        let currentUser = users[indexPath.row]
        cell.selectionStyle = .none
        cell.nameLabel.text = currentUser.name
        if currentUser.status == .eliminated {
            cell.currentPickLabel.text = "ELIMINATED"
            cell.currentPickLabel.textColor = AppColors.red
        } else {
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
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 100
        case 1:
            return 150
        default:
            return 100
        }
    }
    
    func setSurvivorStatus(completion: () -> ()) {
        self.startLoading(message: "Updating Statuses...")
        for user in self.users {
            if user.status == .active {
                let availablePicks = self.contestants.filter({ (contestant) -> Bool in
                    !user.picks.contains(contestant.id) && contestant.status == .onShow
                })
                if availablePicks.count == 0 {
                    FirebaseClient.updateSurvivorStatus(user: user, status: "Eliminated")
                    break
                }
                for contestant in self.contestants {
                    if user.currentPick == contestant.id {
                        if contestant.status == .offShow {
                            FirebaseClient.updateSurvivorStatus(user: user, status: "Eliminated")
                            break
                        } else {
                            FirebaseClient.updateSurvivorStatus(user: user, status: "Active")
                            break
                        }
                    }
                }
            }
        }
        completion()
        self.stopLoading(message: "Statuses Updated")
    }
    
    func resetPicks() {
        
        let alert = UIAlertController(title: "Picks Reset", message: "Are you sure you want to reset the picks for this week?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { (action) in
            self.startLoading(message: "Resetting Picks...")
            FirebaseClient.resetAllPicks(users: self.users) {
                self.fetchUsers()
                Picks.store.removeCurrentPick()
                NotificationCenter.default.post(name: Notification.Name("didClearPicks"), object: nil)
                self.stopLoading(message: "Picks Reset")
            }
        }
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alert.addAction(yesAction)
        alert.addAction(noAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func startLoading(message: String) {
        self.userTableView.isUserInteractionEnabled = false
        self.loadingMessageLabel.text = message
        self.loadingSpinner.startAnimating()
        UIView.animate(withDuration: 0.25) {
            self.loadingView.alpha = 0.4
        }
        
        //self.loadingView.isHidden = false
    }
    
    func stopLoading(message: String) {
        self.loadingSpinner.stopAnimating()
        self.loadingSpinner.isHidden = true
        self.checkmarkImageView.isHidden = false
        self.loadingMessageLabel.text = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.userTableView.isUserInteractionEnabled = true
            UIView.animate(withDuration: 1.0) {
                self.loadingView.alpha = 0
                //self.loadingView.isHidden = true
            }
            
        }
        
    }
    

    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func menuButtonTapped(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Admin", message: nil, preferredStyle: .actionSheet)
        let resetAction = UIAlertAction(title: "Reset All Picks", style: .destructive) { (action) in
            self.resetPicks()
        }
        let eliminateAction = UIAlertAction(title: "Update Elimination Statuses", style: .default) { (action) in
            self.setSurvivorStatus {
                self.fetchUsers()
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(resetAction)
        actionSheet.addAction(eliminateAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion: nil)
        
        
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
