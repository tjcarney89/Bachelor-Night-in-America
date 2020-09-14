//
//  SignInViewController.swift
//  Bachelor Night in America
//
//  Created by TJ Carney on 6/30/20.
//  Copyright © 2020 TJ Carney. All rights reserved.
//

import UIKit
import FirebaseUI

class SignInViewController: FUIAuthPickerViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        addLogo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Bachelor Night in America"
    }
    
    func addLogo() {
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        let imageViewBackground = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        imageViewBackground.image = UIImage(named: "logo")
        imageViewBackground.contentMode = .scaleAspectFit
        self.view.addSubview(imageViewBackground)
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
