//
//  TeamDetailTableViewController.swift
//  TeamsMembers
//
//  Created by Carlos Javier Pendola on 4/27/19.
//  Copyright © 2019 Carlos Javier Pendola. All rights reserved.
//

import UIKit

class PlayerListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Properties
    var team:Team?
    var player:Player?
    let searchController = UISearchController(searchResultsController: nil)
    var filteredPlayers = [Player]()
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        print("TeamDetail viewDidLoad")
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Players"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchBar.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        updateViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        dump("viewDidAppear")
        dump(FirebaseManager.shared.players)
        dump(filteredPlayers)
        super.viewDidAppear(true)
        self.player = nil
        self.tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        FirebaseManager.shared.listenerPlayers?.remove()
    }
    
    func updateViews(){
        guard let team = team else {
            print("team nil")
            return
        }
        FirebaseManager.shared.fetchPLayer(team: team) { (succes) in
            if(succes){
                self.tableView.reloadData()
            }
        }
    }
    
    
    //// MARK: - Segue
    override func prepare(for segue:UIStoryboardSegue ,sender:Any?  ){
        if segue.identifier == "addEditTeam"
        {
            if let destinationVC = segue.destination as? PlayerViewController{
                destinationVC.team = self.team
                destinationVC.player = self.player
            }
        }
        
        if segue.identifier == "showPlayerDetail"
        {
            if let indexPath = tableView.indexPathForSelectedRow {
                if let destinationVC = segue.destination as? DetailPlayerTableViewController{
                    var playerItem:Player
                    if isFiltering() {
                        playerItem = filteredPlayers[indexPath.row]
                    } else {
                        playerItem = FirebaseManager.shared.players[indexPath.row]
                    }
                    destinationVC.team = self.team
                    destinationVC.player = playerItem
                }
            }
        }
    }
    
    // MARK: - TableView Functions
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredPlayers.count
        }
        else{
            return FirebaseManager.shared.players.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "playerCell", for: indexPath) as? PlayerTableViewCell
            else {
                print("Unable to cast cell correctly.") ;
                return UITableViewCell()
        }
        
        var playerItem:Player
        if isFiltering() {
            playerItem = filteredPlayers[indexPath.row]
        } else {
            playerItem = FirebaseManager.shared.players[indexPath.row]
        }
        
        UtilsController.shared.fetchImage(image: playerItem.image) { (image) in
            DispatchQueue.main.async {
                cell.playerimageView?.image = image
            }
        }
        
        cell.player = playerItem
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            var playerItem:Player
            if self.isFiltering() {
                playerItem = self.filteredPlayers[indexPath.row]
            } else {
                playerItem = FirebaseManager.shared.players[indexPath.row]
            }
            
            FirebaseManager.shared.removePlayer(player: playerItem) { (success) in
                if(success){
                    if self.isFiltering() {
                        self.filteredPlayers.remove(at: indexPath.row)
                    }
                    self.tableView.reloadData()
                }
            }
        }
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
            
            if self.isFiltering() {
                self.player = self.filteredPlayers[indexPath.row]
            } else {
                self.player = FirebaseManager.shared.players[indexPath.row]
            }
            self.performSegue(withIdentifier: "addEditTeam", sender: nil)
        }
        
        edit.backgroundColor = UIColor.blue
        
        return [delete, edit]
    }
    
    
    // MARK: - Private instance methods
    func filterContentForSearchText(_ searchText: String) {
        print("filterContentForSearchText")
        filteredPlayers = FirebaseManager.shared.players.filter({ (player : Player) -> Bool in
            player.name.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
    
    
}



extension PlayerListViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!)
    }
}

extension PlayerListViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
