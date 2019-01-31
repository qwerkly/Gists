//
//  UserPublicGistsTableViewController.swift
//  Gists
//
//  Created by Ivan Babich on 30/01/2019.
//  Copyright © 2019 Ivan Babich. All rights reserved.
//

import UIKit

class UserPublicGistsTableViewController: UITableViewController {
    
    var gistsModel: GistsModel!
    var user: OwnerPlainModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserGists()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        gistsModel.userGists.removeAll()
    }
    
    private func loadUserGists() {
        var gistsURLString = user.gistsURL
        if gistsURLString.contains("{") {
            while gistsURLString.last != "{" {
                gistsURLString.removeLast()
            }
            gistsURLString.removeLast()
        }
        gistsModel.downloadGists(for: URL(string: gistsURLString)!) { [weak self] (result) in
            switch result {
            case .success(_):
                self?.tableView.reloadData()
                break
            case .failure(_):
                let alert = UIAlertController(title: "Ошибка при загрузке данных", message: "Попытка загрузить слишком большие объемы данных, для этого нужно авторизоваться.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
                break
            }
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gistsModel.userGists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GistCell", for: indexPath)
        if gistsModel.userGists[indexPath.row].description != "" {
            cell.textLabel?.text = gistsModel.userGists[indexPath.row].description
        } else {
            cell.textLabel?.text = "Название отсутствует"
        }
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
