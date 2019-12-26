//
//  DetailViewController.swift
//  Divvy
//
//  Created by Cesar Kyle Casil on 12/22/19.
//  Copyright © 2019 Cesar Kyle Casil. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var memberTextField: UITextField!
    @IBOutlet weak var taxTextField: UITextField!
    @IBOutlet weak var tipSlider: UISlider!
    @IBOutlet weak var percentTextField: UITextField!
    
    var itemData = [Item]()
    let sections: [String] = ["Single Items Split:", "Group Items Only:", "Group + Single Items Split:", "All:"]
    var items = [
        [
            ["Subtotals:", ""],
            ["Tax:", ""],
            ["Tip:", ""],
            ["Single Totals:", ""]
        ],[
            ["Subtotal:", ""],
            ["Tax:", ""],
            ["Tip:", ""],
            ["Group Total:", ""]
        ],[
            ["Subtotals:", ""],
            ["Tax:", ""],
            ["Tip:", ""],
            ["Totals:", ""]
        ], [
            ["Subtotal:", ""],
            ["Tax:", ""],
            ["Tip:", ""],
            ["Total:", ""]
        ]
    ]
    var singletotal: [Double] = []
    var grouptotal: Double = 0.0
    var alltotal: Double = 0.0
    var percent: Double = 15
    
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAllItems()
        percentTextField.text = "15"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        self.hideKeyboardWhenTappedAround()
        percentTextField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
    }
    
    func fetchAllItems() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        do {
            let result = try managedObjectContext.fetch(request)
            itemData = result as! [Item]
        } catch {
            print (error)
        }
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        if let stringValue = percentTextField.text{
            if let intValue = Int(stringValue){
                tipSlider.value = Float(intValue)
                percent = Double(intValue)
            }
        }

    }
    
    @IBAction func percentSlider(_ sender: UISlider) {
        percent = Double(sender.value)
        percentTextField.text = String(format: "%.f", percent)
    }
    
    func clearTable() {
        items[0][0][1] = ""
        items[0][1][1] = ""
        items[0][2][1] = ""
        items[0][3][1] = ""
        items[1][0][1] = ""
        items[1][1][1] = ""
        items[1][2][1] = ""
        items[1][3][1] = ""
        items[2][0][1] = ""
        items[2][1][1] = ""
        items[2][2][1] = ""
        items[2][3][1] = ""
        items[3][0][1] = ""
        items[3][1][1] = ""
        items[3][2][1] = ""
        items[3][3][1] = ""
        tableView.reloadData()
    }
    
    @IBAction func calculateButtonPressed(_ sender: Any) {
        fetchAllItems()
        clearTable()
        alltotal = 0.00
        grouptotal = 0.00
        if itemData.count > 0 {
            for item in itemData {
                if item.group == true {
                    grouptotal += item.price
                } else if item.group == false {
                    singletotal.append(item.price)
                }
                alltotal += item.price
            }
            items[3][0][1] = String(alltotal)
            let singlesubtotal: [Double] = singletotal
            if let unwrappedmembers = Double(memberTextField.text ?? "1") {
                let members = unwrappedmembers
                items[1][0][1] = String(format: "%.2f", grouptotal / members)
                if let unwrappedtax = Double(taxTextField.text ?? "1") {
                    let totaltax = Double(alltotal) * (unwrappedtax * 0.01)
                    let totaltip = (percent * 0.01) * alltotal
                    items[0][1][1] = String(format: "%.2f", totaltax / members)
                    items[1][1][1] = String(format: "%.2f", totaltax / members)
                    items[2][1][1] = String(format: "%.2f", totaltax / members)
                    items[3][1][1] = String(format: "%.2f", totaltax)
                    items[0][2][1] = String(format: "%.2f", totaltip / members)
                    items[1][2][1] = String(format: "%.2f", totaltip / members)
                    items[2][2][1] = String(format: "%.2f", totaltip / members)
                    items[3][2][1] = String(format: "%.2f", totaltip)
                    for item in singlesubtotal {
                        items[0][0][1] += (String(item) + "\n")
                        items[0][3][1] += (String(format: "%.2f", item + (totaltax / members) + (totaltip / members)) + "\n")
                        items[2][0][1] += (String(format: "%.2f", item + (grouptotal / members)) + "\n")
                        items[2][3][1] += (String(format: "%.2f", (item + (grouptotal / members)) + (totaltax / members) + (totaltip / members)) + "\n")
                    }
                    items[1][3][1] = String(format: "%.2f", (grouptotal / members) + (totaltax / members) + (totaltip / members))
                    items[3][3][1] = String(format: "%.2f", alltotal + totaltax + totaltip)
                }
            } else {
                memberTextField.attributedPlaceholder = NSAttributedString(string: "Required", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red]);
            }
        }
    }

    
    @IBAction func clearButtonPressed(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let  deleteButton = UIAlertAction(title: "Delete App Data", style: .destructive, handler: { (action) -> Void in
            self.memberTextField.text = ""
            self.taxTextField.text = "7.25"
            self.percentTextField.text = "15"
            self.tipSlider.value = 15
            self.memberTextField.placeholder = ""
            self.clearTable()
        self.deleteAllData(entity: "Item")
        })
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
        })
        
        alertController.addAction(deleteButton)
        alertController.addAction(cancelButton)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func deleteAllData(entity: String) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        request.returnsObjectsAsFaults = false
        do {
            let result = try self.managedObjectContext.fetch(request)
            for managedObject in result {
                let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                self.managedObjectContext.delete(managedObjectData)
            }
        } catch {
            print (error)
        }
    }
    

}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AmountCell", for: indexPath)
        cell.textLabel?.text = items[indexPath.section][indexPath.row][0]
        cell.detailTextLabel?.text = items[indexPath.section][indexPath.row][1]
        return cell
    }
    
    
}
