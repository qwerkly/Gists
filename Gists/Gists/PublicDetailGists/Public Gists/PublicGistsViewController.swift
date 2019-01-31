//
//  ViewController.swift
//  Gists
//
//  Created by Ivan Babich on 25/01/2019.
//  Copyright © 2019 Ivan Babich. All rights reserved.
//

import UIKit

class PublicGistsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topUsersCollectionView: UICollectionView!
    private var gistsModel = GistsModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        gistsModel.didNewGistsLoad = newGistsLoaded
        gistsModel.didNewGistsFail = newGistsFailed
        gistsModel.didTopUserChange = topUsersChanged
        gistsModel.didOwnerOrAvatarLoad = avatarOrNameDidLoaded
        gistsModel.downloadGists()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailGistSegue" {
            guard let destination = segue.destination as? DetailGistViewController, let gist = sender as? GistPlainModel else {
                return
            }
            destination.gist = gist
            destination.gistsModel = gistsModel
        } else if segue.identifier == "UserGistsSegue" {
            guard let destination = segue.destination as? UserPublicGistsTableViewController, let topUser = sender as? OwnerPlainModel else {
                return
            }
            destination.user = topUser
            destination.gistsModel = gistsModel
        }
    }
    
    // MARK: - Load Functions
    
    private func newGistsLoaded(with newIndexPathsToReload: [IndexPath]?) {
        guard let newIndexPathsToReload = newIndexPathsToReload else {
            tableView.reloadData()
            return
        }
        tableView.insertRows(at: newIndexPathsToReload, with: .automatic)
    }
    
    private func newGistsFailed(with error: APIError) {
        print("Ошибка при загрузке гистов: \(error)")
        let alert = UIAlertController(title: "Ошибка при загрузке данных", message: "Попытка загрузить слишком большие объемы данных, для этого нужно авторизоваться.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func topUsersChanged() {
        topUsersCollectionView.reloadData()
    }
    
    private func avatarOrNameDidLoaded(for row: Int) {
        self.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
    }
}

extension PublicGistsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gistsModel.gists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GistCell", for: indexPath) as! PublicGistsTableViewCell
        let gist = gistsModel.gists[indexPath.row]
        cell.descriptionLabel.text = gist.description
        if let avatarData = gist.owner.avatarData {
            cell.avatarImageView.image = UIImage(data: avatarData)
        }
        cell.nameLabel.text = gist.owner.name
        if indexPath.row == gistsModel.gists.count - 1 {
            gistsModel.downloadGists()
        }
        return cell
    }
}

extension PublicGistsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let gist = gistsModel.gists[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "DetailGistSegue", sender: gist)
    }
}

extension PublicGistsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gistsModel.topUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AvatarCell", for: indexPath) as! AvatarCollectionViewCell
        if let imageData = gistsModel.topUsers[indexPath.row].avatarData {
            cell.avatarImageView.image = UIImage(data: imageData)
            cell.avatarImageView.layer.cornerRadius = cell.avatarImageView.frame.height/2
            cell.avatarImageView.clipsToBounds = true
        }
        return cell
    }
}

extension PublicGistsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "UserGistsSegue", sender: gistsModel.topUsers[indexPath.row])
    }
}
