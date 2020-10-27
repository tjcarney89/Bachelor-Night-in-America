//
//  ViewController.swift
//  Bachelor Night in America
//
//  Created by TJ Carney on 6/23/20.
//  Copyright © 2020 TJ Carney. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseUI

class SurvivorPoolViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    @IBOutlet weak var contestantsCollectionView: UICollectionView!
    @IBOutlet weak var adminButton: UIButton!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var contestants: [Contestant] = []
    var handle: AuthStateDidChangeListenerHandle?
    var currentUser: BNIAUser?
    var loadCount = 0 {
        didSet {
            if loadCount == contestants.count {
                self.loadingView.isHidden = true
                self.loadingSpinner.stopAnimating()
            }
        }
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.contestantsCollectionView.delegate = self
        self.contestantsCollectionView.dataSource = self
//        Defaults.removeObject(key: Defaults.signedInKey)
//        Defaults.all().setValue(nil, forKey: Defaults.userIDKey)
        self.scheduleNotifications()
        FirebaseClient.fetchContestants { (contestants) in
            self.contestants = contestants
            DispatchQueue.main.async {
                self.contestantsCollectionView.reloadData()
            }
            
        }
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: Notification.Name("didMakePick"), object: nil)
        
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        if let userID = Defaults.all().string(forKey: Defaults.userIDKey) {
            FirebaseClient.fetchUser(id: userID) { (user) in
                self.appDelegate.currentUser = user
                //self.currentUser = user
                DispatchQueue.main.async {
                    self.contestantsCollectionView.reloadData()
                }
                
                FirebaseClient.setIsAdmin(userID: userID, completion: {
                    if Defaults.all().bool(forKey: Defaults.isAdminKey) == true {
                        self.adminButton.isHidden = false
                    } else {
                        self.adminButton.isHidden = true
                    }
                })
            }
            
        }
        
        self.loadingSpinner.startAnimating()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }
    
    @objc func reloadData() {
        self.contestantsCollectionView.reloadData()
    }
    
   
    
    func scheduleNotifications() {
        let manager = LocalNotificationManager()
        let pickNotification = LocalNotification(id: "pick-notification", title: "Survivor Pool", body: "Don't forget to submit your pick!", datetime: DateComponents(calendar: .current, timeZone: .current, hour: 18, minute: 00, weekday: 3))
        manager.notifications = [pickNotification]
        manager.schedule()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.contestants.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "contestantCell", for: indexPath) as! ContestantCollectionViewCell
        //guard let currentUser = self.currentUser else {return cell}
        let currentContestant = self.contestants[indexPath.row]
        let hasBeenPicked = Picks.store.allPicks.contains(currentContestant.id)
        let placeholder = UIImage(named: "female")
        let ref = FirebaseClient.storage.child("contestants/\(currentContestant.imagePath)")
        cell.imageView.sd_setImage(with: ref, placeholderImage: placeholder) { (image, error, cache, ref) in
            self.loadCount += 1
        }
        cell.nameLabel.text = currentContestant.name
        cell.overlayView.alpha = 0
        if currentContestant.status == .onShow && !hasBeenPicked {
            cell.nameLabel.textColor = .label
            cell.xImageView.isHidden = true
        } else if currentContestant.status == .onShow && hasBeenPicked {
            cell.cardView.layer.borderColor = AppColors.red?.cgColor
            cell.cardView.layer.borderWidth = 3
            cell.nameLabel.textColor = AppColors.red
            cell.xImageView.isHidden = true
        } else if currentContestant.status == .offShow && !hasBeenPicked {
            cell.xImageView.isHidden = false
            cell.overlayView.alpha = 0
            cell.nameLabel.textColor = .label
        } else if currentContestant.status == .offShow && hasBeenPicked {
            cell.cardView.layer.borderColor = AppColors.red?.cgColor
            cell.cardView.layer.borderWidth = 3
            cell.nameLabel.textColor = AppColors.red
            cell.xImageView.isHidden = false
        }
        
        if let currentPick = Picks.store.currentPick {
            if currentContestant.id ==  currentPick {
                cell.cardView.layer.borderColor = AppColors.green?.cgColor
                cell.cardView.layer.borderWidth = 3
                cell.nameLabel.textColor = AppColors.green
                cell.xImageView.isHidden = true
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing = 8
        let width = (Int(self.contestantsCollectionView.frame.width) - (spacing * 3))/4
        let height = (Int(self.contestantsCollectionView.frame.height) - (spacing * 6))/7
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailSegue" {
            if let detailVC = segue.destination as? ContestantDetailViewController {
                detailVC.selectedContestant = self.contestants[(self.contestantsCollectionView.indexPathsForSelectedItems?.first!.row)!]
                
            }
        }
    }
    
    @IBAction func adminButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let adminVC = storyboard.instantiateViewController(identifier: "admin") as! AdminViewController
        self.navigationController?.pushViewController(adminVC, animated: true)
    }
    
}

