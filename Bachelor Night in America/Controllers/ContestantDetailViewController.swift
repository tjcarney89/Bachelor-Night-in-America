//
//  ContestantDetailViewController.swift
//  Bachelor Night in America
//
//  Created by TJ Carney on 7/16/20.
//  Copyright © 2020 TJ Carney. All rights reserved.
//

import UIKit
import FirebaseStorage

class ContestantDetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var contestantImageView: UIImageView!
    @IBOutlet weak var nameAgeLabel: UILabel!
    @IBOutlet weak var occupationLabel: UILabel!
    @IBOutlet weak var hometownLabel: UILabel!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var funFactsTextView: UITextView!
    @IBOutlet weak var pickButton: UIButton!
    @IBOutlet weak var statusLabel: PaddingLabel!
    @IBOutlet weak var availabilityLabel: PaddingLabel!
    
    
    @IBOutlet weak var contestantDetailCollectionView: UICollectionView!
    var contestants: [Contestant] = []
    var selectedContestant: Contestant!
    var collectionWidth: CGFloat {
        return self.contestantDetailCollectionView.frame.width
    }
    var firstTime = true
    var pickSubmitted: Bool {
        (Picks.store.currentPick != nil)
    }
    
    var currentPick: Int? {
        Picks.store.currentPick
    }
    var isEliminated: Bool {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.currentUser?.status == .eliminated
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.contestantDetailCollectionView.delegate = self
        self.contestantDetailCollectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillLayoutSubviews() {
        let selectedContestantIndex = self.contestants.firstIndex { (contestant) -> Bool in
            contestant.id == self.selectedContestant.id
        }
        let offsetWidth = self.collectionWidth * CGFloat(selectedContestantIndex!)
        if self.firstTime == true {
            self.contestantDetailCollectionView.setContentOffset(CGPoint(x: offsetWidth, y: 0), animated: false)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.firstTime = false
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.contestants.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "detailCell", for: indexPath) as! ContestantDetailCollectionViewCell
        let currentContestant = self.contestants[indexPath.row]
        let hasBeenPicked = Picks.store.allPicks.contains(currentContestant.id)
        cell.pickButton.tag = indexPath.row
        cell.pickButton.addTarget(self, action: #selector(pickButtonTapped(_:)), for: .touchUpInside)
        let placeholder = UIImage(named: "female")
        let ref = FirebaseClient.storage.child("contestants/\(currentContestant.imagePath)")
        cell.contestantImageView.sd_setImage(with: ref, placeholderImage: placeholder)
        cell.nameAgeLabel.text = "\(currentContestant.name), \(currentContestant.age)"
        cell.occupationLabel.text = currentContestant.occupation
        cell.hometownLabel.text = currentContestant.hometown
        let bulletedFacts = currentContestant.funFacts.map { return "🌹 " + $0}
        cell.bioTextView.text = currentContestant.bio
        cell.funFactsTextView.text = bulletedFacts.joined(separator: "\n")
        cell.setUpIndicatorLabels(currentContestant: currentContestant, hasBeenPicked: hasBeenPicked, currentPick: currentPick, isEliminated: isEliminated)
        cell.setUpPickButton(currentContestant: currentContestant, currentPick: currentPick, pickSubmitted: pickSubmitted, isEliminated: isEliminated)
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        let height = collectionView.frame.height
        return CGSize(width: width, height: height)
    }
    
    @objc func pickButtonTapped(_ sender: UIButton) {
        let pickedContestant = contestants[sender.tag]
        let cell = sender.superview?.superview as! ContestantDetailCollectionViewCell
        if pickSubmitted {
            let previousPick = self.currentPick
            Picks.store.removePick(id: currentPick!)
            Picks.store.removeCurrentPick()
            if previousPick != pickedContestant.id {
                Picks.store.addPick(id: pickedContestant.id)
                cell.pickButton.isEnabled = false
                cell.pickButton.backgroundColor = .darkGray
                cell.pickButton.setTitle("Pick Submitted", for: .disabled)
                cell.availabilityLabel.backgroundColor = AppColors.green
                cell.availabilityLabel.text = "Current Pick"
            } else {
                cell.pickButton.isEnabled = true
                cell.pickButton.backgroundColor = AppColors.red
                cell.pickButton.setTitle("Pick", for: .normal)
                cell.availabilityLabel.backgroundColor = AppColors.green
                cell.availabilityLabel.text = "Available"
            }
        } else {
            Picks.store.addPick(id: pickedContestant.id)
            cell.pickButton.isEnabled = false
            cell.pickButton.backgroundColor = .darkGray
            cell.pickButton.setTitle("Pick Submitted", for: .disabled)
            cell.availabilityLabel.backgroundColor = AppColors.green
            cell.availabilityLabel.text = "Current Pick"
        }
        self.contestantDetailCollectionView.reloadData()
        NotificationCenter.default.post(name: Notification.Name("didMakePick"), object: nil)
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
