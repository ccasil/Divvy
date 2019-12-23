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
    
    var itemData = [Item]()
    
    var total: Double = 0.0
    var percent: Double = 15
    
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAllItems()
        percentTextField.text = "15"
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
        percentTextField.text = String(percent)
    }
    
    @IBAction func calculateButtonPressed(_ sender: Any) {
        fetchAllItems()
        total = 0.00
        if itemData.count > 0 {
            for item in itemData {
                total += item.price
            }
            let subtotal: Double = total
            print("SUBTOTAL", subtotal)
            if let unwrappedmembers = Double(memberTextField.text ?? "1") {
                let members = unwrappedmembers
                print("MEMBERS", members)
                subtotalLabel.text = String(subtotal / members)
                if let unwrappedtax = Double(taxTextField.text ?? "1") {
                    let totaltax = Double(subtotal) * (unwrappedtax * 0.01)
                    print("TAX", totaltax)
                    taxLabel.text = String(totaltax / members)
                    let totaltip = (percent * 0.01) * subtotal
                    print("TIP", totaltip)
                    tipLabel.text = String(totaltip / members)
                    totalLabel.text = String((subtotal + totaltax + totaltip) / members)
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
