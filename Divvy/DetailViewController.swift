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
    
    var itemData = [Item]()
    
    var total: Double = 0.0
    var grouptotal: Double = 0.0
    var percent: Double = 15
    
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAllItems()
        percentTextField.text = "15"
        taxTextField.text = "7.25"
        self.hideKeyboardWhenTappedAround()
        percentTextField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
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
        total = 0.00
        grouptotal = 0.00
        if itemData.count > 0 {
            for item in itemData {
                if item.group == true {
                    grouptotal += item.price
                    
                }
            }
            for item in itemData {
                total += item.price
            }
            let subtotal: Double = total
//            print("SUBTOTAL", subtotal)
            if let unwrappedmembers = Double(memberTextField.text ?? "1") {
                let members = unwrappedmembers
//                print("MEMBERS", members)
                subtotalLabel.text = String(format: "%.2f", subtotal / members)
                groupSubtotalLabel.text = String(format: "%.2f", grouptotal / members)
                allSubtotalLabel.text = String(format: "%.2f", subtotal)
                if let unwrappedtax = Double(taxTextField.text ?? "1") {
                    let totaltax = Double(subtotal) * (unwrappedtax * 0.01)
//                    print("TAX", totaltax)
                    taxLabel.text = String(format: "%.2f", totaltax / members)
                    groupTaxLabel.text = String(format: "%.2f", totaltax / members)
                    allTaxLabel.text = String(format: "%.2f", totaltax)
                    let totaltip = (percent * 0.01) * subtotal
//                    print("TIP", totaltip)
                    tipLabel.text = String(format: "%.2f", totaltip / members)
                    groupTipLabel.text = String(format: "%.2f", totaltip / members)
                    allTipLabel.text = String(format: "%.2f", totaltip)
                    totalLabel.text = String(format: "%.2f", (subtotal + totaltax + totaltip) / members)
                    groupTotalLabel.text = String(format: "%.2f", (grouptotal + totaltax + totaltip) / members)
                    allTotalLabel.text = String(format: "%.2f", subtotal + totaltax + totaltip)
                }
            } else {
                print("Missing members.")
            }
        }
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
    
    
    @IBAction func clearButtonPressed(_ sender: Any) {
        memberTextField.text = ""
        taxTextField.text = "7.25"
        percentTextField.text = "15"
        tipSlider.value = 15
        subtotalLabel.text = ""
        taxLabel.text = ""
        tipLabel.text = ""
        totalLabel.text = ""
        allSubtotalLabel.text = ""
        allTaxLabel.text = ""
        allTipLabel.text = ""
        allTotalLabel.text = ""
        self.deleteAllData(entity: "Item")
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
