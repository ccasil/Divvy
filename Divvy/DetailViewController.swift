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

    @IBOutlet weak var memberTextField: UITextField!
    @IBOutlet weak var taxTextField: UITextField!
    @IBOutlet weak var tipSlider: UISlider!
    @IBOutlet weak var percentTextField: UITextField!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var subtotalLabel: UILabel!
    @IBOutlet weak var taxLabel: UILabel!
    @IBOutlet weak var tipLabel: UILabel!
    
    @IBOutlet weak var allSubtotalLabel: UILabel!
    @IBOutlet weak var allTaxLabel: UILabel!
    @IBOutlet weak var allTipLabel: UILabel!
    @IBOutlet weak var allTotalLabel: UILabel!
    
    @IBOutlet weak var groupSubtotalLabel: UILabel!
    @IBOutlet weak var groupTaxLabel: UILabel!
    @IBOutlet weak var groupTipLabel: UILabel!
    @IBOutlet weak var groupTotalLabel: UILabel!
    
    @IBOutlet weak var outputLabel: UILabel!
    
    var itemData = [Item]()
    
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
        taxTextField.text = "7.25"
        outputLabel.text = ""
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
    
    @IBAction func calculateButtonPressed(_ sender: Any) {
        fetchAllItems()
        singletotal = []
        alltotal = 0.00
        grouptotal = 0.00
        subtotalLabel.text = ""
        totalLabel.text = ""
        if itemData.count > 0 {
            for item in itemData {
                if item.group == true {
                    grouptotal += item.price
                } else if item.group == false {
                    singletotal.append(item.price)
                }
                alltotal += item.price
            }
            let singlesubtotal: [Double] = singletotal
            let subtotal: Double = alltotal
            if let unwrappedmembers = Double(memberTextField.text ?? "1") {
                let members = unwrappedmembers
                for item in singlesubtotal {
                    print(item)
                    subtotalLabel.text! += (String(item) + "\n")
//                    subtotalLabel.text = String(format: "%.2f", singlesubtotal[item] / members)
                }
                groupSubtotalLabel.text = String(format: "%.2f", grouptotal / members)
                allSubtotalLabel.text = String(format: "%.2f", subtotal)
                if let unwrappedtax = Double(taxTextField.text ?? "1") {
                    let totaltax = Double(alltotal) * (unwrappedtax * 0.01)
                    let totaltip = (percent * 0.01) * alltotal
                    if subtotalLabel.text == "0.00" {
                        taxLabel.text = ""
                        tipLabel.text = ""
                        totalLabel.text = ""
                        subtotalLabel.text = ""
                    } else {
                        taxLabel.text = String(format: "%.2f", totaltax / members)
                        tipLabel.text = String(format: "%.2f", totaltip / members)
                        for item in singlesubtotal {
                            totalLabel.text! += (String(format: "%.2f", item + (totaltax / members) + (totaltip / members)) + "\n")
                        }
//                        totalLabel.text = String(format: "%.2f", (singlesubtotal + totaltax + totaltip) / members)
                    }
                    if groupSubtotalLabel.text == "0.00" {
                        groupTaxLabel.text = ""
                        groupTipLabel.text = ""
                        groupTotalLabel.text = ""
                        groupSubtotalLabel.text = ""
                    } else {
                        groupTaxLabel.text = String(format: "%.2f", totaltax / members)
                        groupTipLabel.text = String(format: "%.2f", totaltip / members)
                        groupTotalLabel.text = String(format: "%.2f", (grouptotal + totaltax + totaltip) / members)
                    }
                    allTaxLabel.text = String(format: "%.2f", totaltax)
                    allTipLabel.text = String(format: "%.2f", totaltip)
                    allTotalLabel.text = String(format: "%.2f", subtotal + totaltax + totaltip)
                }
            } else {
                memberTextField.attributedPlaceholder = NSAttributedString(string: "Required", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red]);                outputLabel.text = ""
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
            self.subtotalLabel.text = ""
            self.taxLabel.text = ""
            self.tipLabel.text = ""
            self.totalLabel.text = ""
            self.allSubtotalLabel.text = ""
            self.allTaxLabel.text = ""
            self.allTipLabel.text = ""
            self.allTotalLabel.text = ""
            self.groupSubtotalLabel.text = ""
            self.groupTaxLabel.text = ""
            self.groupTipLabel.text = ""
            self.groupTotalLabel.text = ""
            self.outputLabel.text = ""
            self.memberTextField.placeholder = ""
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
