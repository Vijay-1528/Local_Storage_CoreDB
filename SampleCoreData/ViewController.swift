//
//  ViewController.swift
//  SampleCoreData
//
//  Created by Mac-OBS-41 on 20/02/22.
//

import UIKit
import CoreData

protocol afterDataStoredDelegate{
    func DataStoredOnDB()
}

class ViewController: UIViewController {
    
    //OUTLET PROPERTIES
    @IBOutlet weak var contactsDetails: UITableView!
    
    //GLOBAL PROPERTIES
    var contact: [NSManagedObject] = []
    var delegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        registerCell()
        fetchData()
    }
    
    // Get the details from the local data base.
    func fetchData() {
        let manage = delegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ContactDetails")
        do {
            let value = try manage.fetch(fetchRequest)
            if value.count != 0 {
                self.contact.removeAll()
                self.contact = value
            }
            DispatchQueue.main.async {
                self.contactsDetails.reloadData()
            }
        } catch {
            print("error : \(error.localizedDescription)")
        }
    }
    
    //MARK: - CELL REGISTRATION
    func registerCell() {
        contactsDetails.register(UINib(nibName: "DetailsCell", bundle: nil), forCellReuseIdentifier: "DetailsCell")
    }
    
    //MARK: - BUTTON ACTIONS
    @IBAction func addButtonTapped(_ sender: Any) {
        let pageObj = AddNewContactVC()
        pageObj.delegate = self
        self.present(pageObj, animated: true, completion: nil)
    }
}

//MARK: - TABLEVIEW DELEGATE AND DATASOURCE
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contact.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailsCell", for: indexPath) as! DetailsCell
        cell.nameLbl.text = self.contact[indexPath.row].value(forKey: "name") as? String
        cell.contactNoLbl.text = self.contact[indexPath.row].value(forKey: "contactNo") as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            self.deleteTheSelectedEntry(indexValue: indexPath.row)
        }
        deleteAction.backgroundColor = .red
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { _, _, _ in
            self.updateTheSelectedEntry(indexValue: indexPath.row, details: self.contact[indexPath.row])
        }
        editAction.backgroundColor = .orange
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
}


extension ViewController: afterDataStoredDelegate {
    func DataStoredOnDB() {
        fetchData()
    }
    
    func deleteTheSelectedEntry(indexValue:Int) {
        let manageObject = self.contact[indexValue]
        self.contact.remove(at: indexValue)
        self.contactsDetails.reloadData()
        //Create the persistentContainer to access the CoreData
        let managedContext = delegate.persistentContainer.viewContext
        
        managedContext.delete(manageObject)
        
        //Once the work is done, save the values on the CoreData
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("errors details \(error.localizedDescription) and \(error.userInfo)")
        }
    }
    
    func updateTheSelectedEntry(indexValue: Int, details: NSManagedObject) {
        let pageObj = AddNewContactVC()
        pageObj.delegate = self
        pageObj.update = true
        pageObj.indexValue = indexValue
        pageObj.contact = details
        self.present(pageObj, animated: true, completion: nil)
    }
}
