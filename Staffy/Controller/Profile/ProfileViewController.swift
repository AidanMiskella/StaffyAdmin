//
//  ProfileViewController.swift
//  Staffy
//
//  Created by Aidan Miskella on 05/08/2019.
//  Copyright © 2019 Aidan Miskella. All rights reserved.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func logoutTapped(_ sender: UIBarButtonItem) {
        
        do {
            
            try Auth.auth().signOut()
        } catch let signoutError as NSError {
            
            debugPrint("Error signing out: \(signoutError)")
        }
    }
}
