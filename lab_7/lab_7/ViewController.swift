//
//  ViewController.swift
//  lab_7
//
//  Created by Gauhar Zhanuzak on 24.10.2026.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = "Maximilian Alexander von Habsburg"
        aboutLabel.text = "Building banking apps in Swift. I like clean architecture, coffee and long walks in the mountains around Almaty."
    }

}

