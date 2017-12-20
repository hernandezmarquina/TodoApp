//
//  ViewController.swift
//  TodoApp
//
//  Created by Jonathan Hernandez on 12/18/17.
//  Copyright © 2017 Jonathan Hdez. All rights reserved.
//

import UIKit
import CoreData

class CategoriesViewController: UITableViewController {
    
    var managedObjectContext : NSManagedObjectContext?
    var fetchedResultsController : NSFetchedResultsController<Item>!
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Local data File path
        //print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        loadItems()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell  = tableView.dequeueReusableCell(withIdentifier: "toDoItemCell", for: indexPath)
        let item = fetchedResultsController.object(at: indexPath)
        
        cell.accessoryType  = item.done ? .checkmark : .none
        cell.textLabel?.text = item.title
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let tableCell = tableView.cellForRow(at: indexPath)
        let item = fetchedResultsController.object(at: indexPath)
        
        item.done = !item.done
        tableCell?.accessoryType  = item.done ? .checkmark : .none
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        updateItem()
        
    }
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        let alertContoller = UIAlertController(title: "Add New Todo Item", message: "", preferredStyle: .alert)
        
        var textField = UITextField()
        
        alertContoller.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        let action = UIAlertAction(title: "Add Item", style: .default) {(action) in
            
            self.saveItem(title: textField.text ?? "New Item")
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {(action) in
            
        }
        
        alertContoller.addAction(action)
        alertContoller.addAction(cancelAction)
        
        present(alertContoller, animated: true, completion: nil)
        
    }
    
    func saveItem(title: String){
       
        let item = Item(context: managedObjectContext!)
        item.title = title
        item.done = false
        
        do {
          try managedObjectContext?.save()
        } catch {
            print("Error encoding item array, \(error)")
        }
        
        loadItems()
    }
    
    func updateItem(){
        
        do {
            try managedObjectContext?.save()
        } catch {
            print("Error encoding item array, \(error)")
        }
        
        loadItems()
    }
    
    func loadItems(){
        
        
        let fetchRequest : NSFetchRequest<Item> = Item.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor (key: "title", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        
            do {
                
                try fetchedResultsController.performFetch()
                
            } catch {
                print("Error decoding item array \(error)")
            }
        
        tableView.reloadData()
        
    }
    

}

