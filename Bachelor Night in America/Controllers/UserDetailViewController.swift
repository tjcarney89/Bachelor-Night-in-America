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

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var currentPickImageView: UIImageView!
    @IBOutlet weak var currentPickNameLabel: UILabel!
    @IBOutlet weak var currentPickLabel: UILabel!
    @IBOutlet weak var previousPicksTableView: UITableView!
    
    var contestants: [Contestant] = []
    var user: BNIAUser?
    var currentPick: Contestant?
    var previousPicks: [Contestant] = [] {
        didSet {
            self.previousPicksTableView.reloadData()
        }
    }
    
    var availablePicks: [Contestant] = [] {
        didSet {
            self.previousPicksTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        previousPicksTableView.delegate = self
        previousPicksTableView.dataSource = self
        userNameLabel.text = user?.name
        currentPickImageView.layer.cornerRadius = 20
        currentPickImageView.layer.masksToBounds = true
        currentPickImageView.layer.borderWidth = 3
        if user?.status == .eliminated {
            self.currentPickImageView.image = UIImage(named: "logo")
            self.currentPickNameLabel.text = "ELIMINATED"
            self.currentPickImageView.layer.borderColor = AppColors.red?.cgColor
            self.currentPickLabel.isHidden = true
        } else {
            if currentPick != nil {
                let placeholder = UIImage(named: "female")
                let ref = FirebaseClient.storage.child("contestants/\(self.currentPick!.imagePath)")
                self.currentPickImageView.sd_setImage(with: ref, placeholderImage: placeholder)
                self.currentPickNameLabel.text = self.currentPick!.name
                self.currentPickImageView.layer.borderColor = AppColors.green?.cgColor
                self.currentPickLabel.isHidden = false
            } else {
                self.currentPickImageView.image = UIImage(named: "logo")
                self.currentPickNameLabel.text = "No Pick Entered"
                self.currentPickImageView.layer.borderColor = AppColors.red?.cgColor
                self.currentPickLabel.isHidden = true
                
            }
        }
        guard let currentUser = user else {return}
        self.previousPicks = contestants.filter({ (contestant) -> Bool in
            currentUser.picks.contains(contestant.id) && currentUser.currentPick != contestant.id
        })
        self.availablePicks = contestants.filter({ (contestant) -> Bool in
            !currentUser.picks.contains(contestant.id) && contestant.status == .onShow
        }).sorted { $0.name < $1.name }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            if previousPicks.count == 0 {
                return nil
            } else {
                return "Previous Picks"
            }
        } else {
            return "Available Picks"
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return previousPicks.count
        } else {
            return availablePicks.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "previousPickCell", for: indexPath) as! PreviousPickTableViewCell
        cell.selectionStyle = .none
        if indexPath.section == 0 {
            let currentPreviousPick = previousPicks[indexPath.row]
            let placeholder = UIImage(named: "female")
            let ref = FirebaseClient.storage.child("contestants/\(currentPreviousPick.imagePath)")
            cell.previousPickImageView.sd_setImage(with: ref, placeholderImage: placeholder)
            cell.previousPickImageView.layer.borderColor = AppColors.red?.cgColor
            cell.previousPickImageView.layer.borderWidth = 3
            //cell.weekLabel.text = "Week \(indexPath.row + 1)"
            cell.weekLabel.isHidden = true
            cell.previousPickNameLabel.text = currentPreviousPick.name
        } else {
            let currentAvailablePick = availablePicks[indexPath.row]
            let placeholder = UIImage(named: "female")
            let ref = FirebaseClient.storage.child("contestants/\(currentAvailablePick.imagePath)")
            cell.previousPickImageView.sd_setImage(with: ref, placeholderImage: placeholder)
            cell.weekLabel.text = "Available"
            cell.previousPickNameLabel.text = currentAvailablePick.name
        }
        return cell
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
