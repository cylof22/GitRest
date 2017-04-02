//
//  MasterViewController.swift
//  GistsRest
//
//  Created by 曹元乐 on 2017/3/11.
//  Copyright © 2017年 曹元乐. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var gists = [Gist]()
    var nextPageURLString : String?
    var isLoading = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        loadGists(urlToLoad: nextPageURLString)
        //GitHubAPIManager.sharedInstance.getStarredGistWithBasicAuth()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(_ sender: Any) {
        let alert = UIAlertController(title : "Not implemented", message : "Can't create a new gists yet, will implment later", preferredStyle : UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title : "Ok", style : UIAlertActionStyle.default, handler : nil))
        self.present(alert, animated : true, completion : nil)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let gist = gists[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = gist
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gists.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let gist = gists[indexPath.row]
        cell.textLabel!.text = gist.m_description
        cell.detailTextLabel!.text = gist.m_ownerLogin
        if let url = gist.m_ownerAvatorURL {
            GitHubAPIManager.sharedInstance.imageFromURLString(imageURLString: url, completionHandler: {
                (image, requestError) in
                if let error = requestError {
                    print(error)
                }
                
                if let cellUpdate = self.tableView?.cellForRow(at: indexPath) {
                    cellUpdate.imageView?.image = image
                    cellUpdate.setNeedsLayout()
                }
                
            })
        }
        else {
            cell.imageView?.image = nil
        }
        
        let rowsToLoadFromBotton = 5;
        let rowsLoaded = gists.count
        if let nextPage = nextPageURLString {
            if (!isLoading && (indexPath.row >= (rowsLoaded - rowsToLoadFromBotton))) {
                self.loadGists(urlToLoad: nextPage)
            }
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            gists.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }

    func loadGists(urlToLoad : String?)
    {
        self.isLoading = true;
        GitHubAPIManager.sharedInstance.getPublicGists(pageToLoad: urlToLoad) { (result, nextPage) in
            self.nextPageURLString = nextPage
            self.isLoading = false
            
            guard result.error == nil else
            {
                print(result.error!)
                return
            }
            
            if let fetchedGists = result.value {
                if self.nextPageURLString == nil {
                    self.gists = fetchedGists
                } else {
                    self.gists += fetchedGists
                }
            }
            
            self.tableView.reloadData()
            
        }
        
    }

}

