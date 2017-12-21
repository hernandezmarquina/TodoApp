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

class CategoriesViewController: SwipeTableViewController {
    
    var managedObjectContext : NSManagedObjectContext?
    var fetchedResultsController : NSFetchedResultsController<Category>!
    var fetchRequest : NSFetchRequest<Category>!
    
    var selectedCategory: Category?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        fetchRequest = Category.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor (key: "name", ascending: true)]
        
        loadCategories()
        
        tableView.rowHeight = 80.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = fetchedResultsController.object(at: indexPath)
        
        let cell  = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = item.name
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    private func saveCategory(with name: String){
        
        let category = Category(context: managedObjectContext!)
        category.name = name
        
        updateManagedObjectContext()
    }
    
    private func updateManagedObjectContext(){
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        selectedCategory = fetchedResultsController.object(at: indexPath)
        
        performSegue(withIdentifier: "goToList", sender: self)
        
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToList" {
            let controller = segue.destination as! TodoListViewController
            
            controller.selectedCategory = selectedCategory
        }
    }
    
    override func updateManagedObjectModel(at indexPath: IndexPath) {
        
        let categoryItem = self.fetchedResultsController.object(at: indexPath)
        
        self.managedObjectContext?.delete(categoryItem)
        
        self.updateManagedObjectContext()
    }
    
}

