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

class SurvivorPoolViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    @IBOutlet weak var contestantsCollectionView: UICollectionView!
    @IBOutlet weak var adminButton: UIButton!
    
    var contestants: [Contestant] = []
    var handle: AuthStateDidChangeListenerHandle?
    var currentUser: User?
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
        
        
        print("PICKS: \(Picks.store.allPicks)")
        FirebaseClient.fetchContestants { (contestants) in
            self.contestants = contestants
            DispatchQueue.main.async {
                self.contestantsCollectionView.reloadData()
            }
            
        }
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: Notification.Name("didMakePick"), object: nil)
        //FOR CLEARING CURRENT PICK EACH WEEK
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy/MM/dd HH:mm"
//        guard let date = formatter.date(from: "2020/07/17 7:30") else { return }
//        let timer = Timer(fireAt: date, interval: 0, target: self, selector: #selector(testTimer), userInfo: nil, repeats: false)
//        RunLoop.main.add(timer, forMode: .common)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        handle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            if let user = user {
                self.currentUser = user
                FirebaseClient.setIsAdmin {
                    if Defaults.all().bool(forKey: Defaults.isAdminKey) == true {
                        self.adminButton.isHidden = false
                    } else {
                        self.adminButton.isHidden = true
                    }
                }
            }
        })
        self.loadingSpinner.startAnimating()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)

    }
    
    @objc func reloadData() {
        self.contestantsCollectionView.reloadData()
    }
    
    @objc func testTimer() {
        Picks.store.removeCurrentPick()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.contestants.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "contestantCell", for: indexPath) as! ContestantCollectionViewCell
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
            cell.nameLabel.textColor = .black
            cell.xImageView.isHidden = true
        } else if currentContestant.status == .onShow && hasBeenPicked {
            cell.cardView.layer.borderColor = AppColors.red?.cgColor
            cell.cardView.layer.borderWidth = 3
            cell.nameLabel.textColor = AppColors.red
            cell.xImageView.isHidden = true
        } else if currentContestant.status == .offShow && !hasBeenPicked {
            cell.xImageView.isHidden = false
            cell.overlayView.alpha = 0
            cell.nameLabel.textColor = .black
        } else if currentContestant.status == .offShow && hasBeenPicked {
            cell.cardView.layer.borderColor = AppColors.red?.cgColor
            cell.cardView.layer.borderWidth = 3
            cell.nameLabel.textColor = AppColors.red
            cell.xImageView.isHidden = false
        }
        
        if let currentPick = Defaults.all().value(forKey: Defaults.currentPickKey) as? Int {
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

