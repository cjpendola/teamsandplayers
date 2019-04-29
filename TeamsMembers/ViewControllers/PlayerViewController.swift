//
//  CreatePlayerTableViewController.swift
//  TeamsMembers
//
//  Created by Carlos Javier Pendola on 4/27/19.
//  Copyright © 2019 Carlos Javier Pendola. All rights reserved.
//

import UIKit

class PlayerViewController: UITableViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var photoCell: ProfileTableViewCell!
    @IBOutlet weak var photoCellImage: RoundImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var heightText: UITextField!
    @IBOutlet weak var weightText: UITextField!
    @IBOutlet weak var foulsText: UITextField!
    @IBOutlet weak var Points: UITextField!
    
    
    // MARK: - Properties
    var team:Team?
    var player:Player?
    
    override func viewDidLoad(){
        super.viewDidLoad()
        tableView.delegate = self
        photoCell.delegate = self
        updateViews()
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
    
    // MARK: - IBAction
    @IBAction func saveTeamButtonTapped(_ sender: Any) {
        guard let team = team, let image = photoCellImage.image, let nameText = nameText.text ,let heightText = heightText.text ,let weightText = weightText.text ,let foulsText = foulsText.text ,let points = Points.text else {
            print("team or image nil");
            return
        }
        
        if let player = player {
            FirebaseManager.shared.updatePlayer(player:player,name:nameText, image: image, height: heightText , weight: weightText, fouls :foulsText, points: points ) { (success) in
                if(success) {
                    self.navigationController?.popViewController(animated: false)
                }
            }
        }
        else{
            FirebaseManager.shared.uploadPlayer(team:team,name:nameText, image: image, height: heightText , weight: weightText, fouls :foulsText, points: points ) { (success) in
                if(success) {
                    self.navigationController?.popViewController(animated: false)
                }
            }
        }
    }
}


extension PlayerViewController: ProfileTableViewCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func selectPhotoButton() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let actionSheet = UIAlertController(title: "Add Player Avatar", message: "Select a photo", preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (_) in
                imagePickerController.sourceType = UIImagePickerController.SourceType.camera
                self.present(imagePickerController, animated:  true, completion: nil)
            }))
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            actionSheet.addAction(UIAlertAction(title: "Photos", style: .default, handler: { (_) in
                imagePickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
                self.present(imagePickerController, animated: true , completion: nil)
            }))
        }
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let photo = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            photoCellImage.image = photo
        }
    }
    
    
}
