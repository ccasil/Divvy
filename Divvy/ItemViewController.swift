//
//  ItemViewController.swift
//  Divvy
//
//  Created by Cesar Kyle Casil on 12/21/19.
//  Copyright © 2019 Cesar Kyle Casil. All rights reserved.
//

import UIKit
import CoreData

class ItemViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var groupSwitch: UISwitch!
    
    var tableData = [Item]()
    
    var price: String? = "0.00"
    var group: Bool = false
    
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        fetchAllItems()
        tableView.reloadData()
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchAllItems()
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    @IBAction func addItemButtonPressed(_ sender: Any) {
        
        if !priceTextField.text!.isEmpty {
            let item = NSEntityDescription.insertNewObject(forEntityName: "Item", into: managedObjectContext) as! Item
            if let unwrapped = Double(priceTextField.text ?? "0.00"){
                item.price = unwrapped
            } else {
                print("Needs to be a Double")
            }
            item.group = groupSwitch.isOn
            print(item.group)
            appDelegate.saveContext()
            fetchAllItems()
            tableView.reloadData()
            priceTextField.text = ""
            }
        }
    
    func fetchAllItems() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        do {
            tableData = try managedObjectContext.fetch(request) as! [Item]
        } catch {
            print (error)
        }
    }
}

extension ItemViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
        cell.textLabel?.text = String(tableData[indexPath.row].price )
        if tableData[indexPath.row].group == false {
            cell.detailTextLabel?.text = ""
        } else {
            cell.detailTextLabel?.text = "Group Item"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
        let item = self.tableData[indexPath.row]
        managedObjectContext.delete(item)
        appDelegate.saveContext()
        tableData.remove(at: indexPath.row)
        tableView.reloadData()
        }
    }
}
