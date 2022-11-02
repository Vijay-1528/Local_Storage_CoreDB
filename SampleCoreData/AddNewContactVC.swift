//
//  AddNewContactVC.swift
//  SampleCoreData
//
//  Created by Mac-OBS-41 on 27/02/22.
//

import UIKit
import CoreData

class AddNewContactVC: UIViewController {
    
    //OUTLET PROPERTIES
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var saveBtnTapped: UIButton!
    @IBOutlet weak var nameTxtFld: UITextField!
    @IBOutlet weak var contactTxtFld: UITextField!
    
    //GLOBAL PROPERTIES
    var contact:NSManagedObject?
    var update = Bool()
    var indexValue = Int()
    var delegate: afterDataStoredDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameTxtFld.delegate = self
        self.contactTxtFld.delegate = self
        
        if update {
            self.nameTxtFld.text = "\(self.contact?.value(forKey: "name") ?? "")"
            self.contactTxtFld.text = "\(self.contact?.value(forKey: "contactNo") ?? "")"
        }
    }
    
    func updateDetails() {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = delegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ContactDetails")
        fetchRequest.predicate = NSPredicate(format: "name = %@ AND contactNo = %@", argumentArray: [contact?.value(forKey: "name") ?? "", contact?.value(forKey: "contactNo") ?? ""])
        do {
            let results = try context.fetch(fetchRequest) as? [NSManagedObject]
            if let tempResult = results, results?.count != 0 { // Atleast one was returned

                // In my case, I only updated the first item in results
                tempResult[0].setValue(self.nameTxtFld.text, forKey: "name")
                tempResult[0].setValue(self.contactTxtFld.text, forKey: "contactNo")
            }
        } catch {
            print("Fetch Failed: \(error)")
        }
        do {
            try context.save()
            self.delegate?.DataStoredOnDB()
           }
        catch {
            print("Saving Core Data Failed: \(error)")
        }

    }
    
    //MARK: - BUTTON ACTIONS
    @IBAction func cancelBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func saveBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
        guard !update else {
            self.updateDetails()
            return
        }
        
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        //Create the persistentContainer to access the CoreData
        let managedContext = delegate.persistentContainer.viewContext
        
        //Separate the Entity which one you need
        let entity = NSEntityDescription.entity(forEntityName: "ContactDetails", in: managedContext)!
        
        //Create the NSManagedObject to access the values of the attribute
        self.contact = NSManagedObject(entity: entity, insertInto: managedContext)
        
        //Insert the values on the NSManagedObject, to save it on the CoreData
        self.contact?.setValue(self.nameTxtFld.text, forKey: "name")
        self.contact?.setValue(self.contactTxtFld.text, forKey: "contactNo")
        
        //Once the work is done, save the values on the CoreData
        do {
            try managedContext.save()
            self.delegate?.DataStoredOnDB()
        } catch let error as NSError {
            print("errors details \(error.localizedDescription) and \(error.userInfo)")
        }
    }
    
}

extension AddNewContactVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == self.nameTxtFld {
            // Get invalid characters
            let invalidChars = NSCharacterSet.alphanumerics.inverted
            
            // Attempt to find the range of invalid characters in the input string. This returns an optional.
            let range = string.rangeOfCharacter(from: invalidChars)
            if range != nil {
                // We have found an invalid character, don't allow the change
                return false
            } else {
                // No invalid character, allow the change
                return true
            }
        }else{
            let invalidChars = NSCharacterSet.decimalDigits.inverted
            let range = string.rangeOfCharacter(from: invalidChars)
            if range != nil {
                // We have found an invalid character, don't allow the change
                return false
            } else {
                // No invalid character, allow the change
                return true
            }
        }
    }
}
