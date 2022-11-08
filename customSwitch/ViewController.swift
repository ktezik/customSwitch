//
//  ViewController.swift
//  customSwitch
//
//  Created by Иван Гришин on 08.11.2022.
//

import UIKit

class ViewController: UIViewController {
    
    private lazy var nsfwSwitch: ImageSwitch = {
        let imageSwitch = ImageSwitch(frame: .zero)
        imageSwitch.onThumbImage = UIImage(named: "pepperIcon")
        imageSwitch.offThumbImage = UIImage(named: "sunnyIcon")
        imageSwitch.onTintColors = [UIColor.blue.cgColor, UIColor.yellow.cgColor]
        imageSwitch.offTintColor = UIColor(named: "switchOffColor")!
        imageSwitch.thumbRadiusPadding = 4
        imageSwitch.isStretchEnable = false
        imageSwitch.alpha = 1
        return imageSwitch
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(nsfwSwitch)
        nsfwSwitch.translatesAutoresizingMaskIntoConstraints = false
        nsfwSwitch.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        nsfwSwitch.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

}
