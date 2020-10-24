//
//  ContestantDetailViewController.swift
//  Bachelor Night in America
//
//  Created by TJ Carney on 7/16/20.
//  Copyright © 2020 TJ Carney. All rights reserved.
//

import UIKit
import FirebaseStorage

class ContestantDetailViewController: UIViewController {
    
    @IBOutlet weak var contestantImageView: UIImageView!
    @IBOutlet weak var nameAgeLabel: UILabel!
    @IBOutlet weak var occupationLabel: UILabel!
    @IBOutlet weak var hometownLabel: UILabel!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var funFactsTextView: UITextView!
    @IBOutlet weak var pickButton: UIButton!
    @IBOutlet weak var statusLabel: PaddingLabel!
    @IBOutlet weak var availabilityLabel: PaddingLabel!
    
    var selectedContestant: Contestant!
    //var currentUser: BNIAUser!
    var hasBeenPicked: Bool {
        Picks.store.allPicks.contains(selectedContestant.id)
    }
    
    var pickSubmitted: Bool {
        (Picks.store.currentPick != nil)
    }
    
    var currentPick: Int? {
        Picks.store.currentPick
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureUI()
    }
    
    func configureUI() {
        let placeholder = UIImage(named: "female")
        let ref = FirebaseClient.storage.child("contestants/\(selectedContestant.imagePath)")
        self.contestantImageView.sd_setImage(with: ref, placeholderImage: placeholder)
        self.nameAgeLabel.text = "\(selectedContestant.name), \(selectedContestant.age)"
        self.occupationLabel.text = selectedContestant.occupation
        self.hometownLabel.text = selectedContestant.hometown
        let bulletedFacts = selectedContestant.funFacts.map { return "🌹 " + $0}
        self.bioTextView.text = selectedContestant.bio
        self.funFactsTextView.text = bulletedFacts.joined(separator: "\n")
        self.bioTextView.textContainerInset = UIEdgeInsets.zero
        self.bioTextView.textContainer.lineFragmentPadding = 0
        self.setUpIndicatorLabels()
        self.setUpPickButton()
        
    }
    
    func setUpIndicatorLabels() {
        self.statusLabel.layer.cornerRadius = 10
        self.statusLabel.layer.masksToBounds = true
        self.availabilityLabel.layer.cornerRadius = 10
        self.availabilityLabel.layer.masksToBounds = true

        if selectedContestant.status == .onShow && !hasBeenPicked {
            self.statusLabel.backgroundColor = AppColors.green
            self.statusLabel.text = "On Show"
            self.availabilityLabel.backgroundColor = AppColors.green
            self.availabilityLabel.text = "Available"
        } else if selectedContestant.status == .onShow && hasBeenPicked {
            self.statusLabel.backgroundColor = AppColors.green
            self.statusLabel.text = "On Show"
            if currentPick == selectedContestant.id {
                self.availabilityLabel.backgroundColor = AppColors.green
                self.availabilityLabel.text = "Current Pick"
            } else {
                self.availabilityLabel.backgroundColor = AppColors.red
                self.availabilityLabel.text = "Previously Picked"
            }
        } else if selectedContestant.status == .offShow {
            self.statusLabel.backgroundColor = AppColors.red
            self.statusLabel.text = "Eliminated"
            self.availabilityLabel.backgroundColor = AppColors.red
            self.availabilityLabel.text = "Unavailable"
        }
        
        
    }
    
    func setUpPickButton() {
        self.pickButton.layer.cornerRadius = 15
        if pickSubmitted {
            if currentPick == selectedContestant.id {
                self.pickButton.setTitle("Remove Pick", for: .normal)
            } else {
                self.pickButton.setTitle("Change Pick", for: .normal)
            }
            
        } else {
            self.pickButton.setTitle("Pick", for: .normal)
        }
        
        if Picks.store.allPicks.contains(selectedContestant.id) {
            if currentPick == selectedContestant.id {
                self.pickButton.isEnabled = true
                self.pickButton.isHidden = false
            } else {
                self.pickButton.isEnabled = false
                self.pickButton.isHidden = true
            }
        } else if selectedContestant.status == .offShow {
            self.pickButton.isEnabled = false
            self.pickButton.isHidden = true
        } else {
            self.pickButton.isEnabled = true
            self.pickButton.isHidden = false
        }
    }
    
    @IBAction func pickButtonTapped(_ sender: Any) {
        if pickSubmitted {
            let previousPick = self.currentPick
            Picks.store.removePick(id: currentPick!)
            Picks.store.removeCurrentPick()
            if previousPick != selectedContestant.id {
                Picks.store.addPick(id: selectedContestant.id)
                self.pickButton.isEnabled = false
                self.pickButton.backgroundColor = .darkGray
                self.pickButton.setTitle("Pick Submitted", for: .disabled)
                self.availabilityLabel.backgroundColor = AppColors.green
                self.availabilityLabel.text = "Current Pick"
            } else {
                self.pickButton.isEnabled = true
                self.pickButton.backgroundColor = AppColors.red
                self.pickButton.setTitle("Pick", for: .normal)
                self.availabilityLabel.backgroundColor = AppColors.green
                self.availabilityLabel.text = "Available"
            }
        } else {
            Picks.store.addPick(id: selectedContestant.id)
            self.pickButton.isEnabled = false
            self.pickButton.backgroundColor = .darkGray
            self.pickButton.setTitle("Pick Submitted", for: .disabled)
            self.availabilityLabel.backgroundColor = AppColors.green
            self.availabilityLabel.text = "Current Pick"
        }
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
