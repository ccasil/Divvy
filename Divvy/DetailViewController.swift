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
    
    var singletotal: Double = 0.0
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
        singletotal = 0.00
        alltotal = 0.00
        grouptotal = 0.00
        if itemData.count > 0 {
            for item in itemData {
                if item.group == true {
                    grouptotal += item.price
                } else if item.group == false {
                    singletotal += item.price
                }
                alltotal += item.price
            }
            let singlesubtotal: Double = singletotal
            let subtotal: Double = alltotal
            if let unwrappedmembers = Double(memberTextField.text ?? "1") {
                let members = unwrappedmembers
                subtotalLabel.text = String(format: "%.2f", singlesubtotal / members)
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
                        totalLabel.text = String(format: "%.2f", (singlesubtotal + totaltax + totaltip) / members)
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
        groupSubtotalLabel.text = ""
        groupTaxLabel.text = ""
        groupTipLabel.text = ""
        groupTotalLabel.text = ""
        outputLabel.text = ""
        memberTextField.placeholder = ""
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
