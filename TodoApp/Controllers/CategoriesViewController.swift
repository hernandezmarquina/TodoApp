//
//  CategoriesViewController.swift
//  TodoApp
//
//  Created by Jonathan Hernandez on 12/20/17.
//  Copyright © 2017 Jonathan Hdez. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CategoriesViewController: UITableViewController {
    
    var managedObjectContext : NSManagedObjectContext?
    var fetchedResultsController : NSFetchedResultsController<Category>!
    var fetchRequest : NSFetchRequest<Category>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        fetchRequest = Category.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor (key: "name", ascending: true)]
        
        loadCategories()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell  = tableView.dequeueReusableCell(withIdentifier: "categoryItemCell", for: indexPath)
        let item = fetchedResultsController.object(at: indexPath)
        
        cell.textLabel?.text = item.name
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    private func saveCategory(with name: String){
        
        let category = Category(context: managedObjectContext!)
        category.name = name
        
        do {
            try managedObjectContext?.save()
            loadCategories()
        } catch {
            print("Error encoding item array, \(error)")
        }
    }
    
    private func loadCategories(){
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            
            try fetchedResultsController.performFetch()
            
        } catch {
            print("Error decoding category array \(error)")
        }
        
        tableView.reloadData()
        
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        let alertContoller = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        var textField = UITextField()
        
        alertContoller.addTextField { (alertTextField) in
            alertTextField.placeholder = "Category Name"
            textField = alertTextField
        }
        
        let action = UIAlertAction(title: "Save", style: .default) {(action) in
            
            self.saveCategory(with: textField.text ?? "New Category")
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {(action) in
            
        }
        
        alertContoller.addAction(action)
        alertContoller.addAction(cancelAction)
        
        present(alertContoller, animated: true, completion: nil)
    }
    
}
