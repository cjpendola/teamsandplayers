//
//  DetailPlayerTableViewController.swift
//  TeamsMembers
//
//  Created by Carlos Javier Pendola on 4/28/19.
//  Copyright © 2019 Carlos Javier Pendola. All rights reserved.
//

import UIKit

class DetailPlayerTableViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var photoCell: ProfileTableViewCell!
    @IBOutlet weak var photoCellImage: RoundImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var heightText: UITextField!
    @IBOutlet weak var weightText: UITextField!
    @IBOutlet weak var foulsText: UITextField!
    @IBOutlet weak var Points: UITextField!
    
    var team:Team?
    var player:Player?
    
    override func viewDidLoad(){
        super.viewDidLoad()
        tableView.delegate = self
        updateViews()
        
        nameText.delegate = self
        heightText.delegate = self
        weightText.delegate = self
        foulsText.delegate = self
        Points.delegate = self
        
    }
    
    func updateViews(){
        guard let _ = team, let player = player else {
            print("team or player is nil");
            return
        }
        
        nameText?.text = player.name
        heightText?.text = player.height
        weightText?.text = player.weight
        foulsText?.text = player.fouls
        Points?.text = player.points
        UtilsController.shared.fetchImage(image: player.image) { (image) in
            if(image != nil){
                DispatchQueue.main.async {
                    self.photoCellImage.image = image
                }
            }
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
}
