//
//  TodoListViewController.swift
//  TodoApp
//
//  Created by Jonathan Hernandez on 12/18/17.
//  Copyright © 2017 Jonathan Hdez. All rights reserved.
//

import UIKit
import CoreData
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    var numberOfRows = 0
    var selectedCategory: Category? {
        
        didSet{
            managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            loadItems()
        }
    }
    
    var managedObjectContext : NSManagedObjectContext?
    var fetchedResultsController : NSFetchedResultsController<Item>!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Local data File path
        //print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let colorHex  = selectedCategory?.color {
            title = selectedCategory?.name
            updateNavigationBar(with: colorHex)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateNavigationBar(with: UIColor.flatSkyBlue.hexValue())
    }
    
    private func updateNavigationBar(with colorHex: String) {
        
        let color = UIColor(hexString: colorHex)
        let constrastColor = ContrastColorOf(color!, returnFlat: true)
        
        let navigationBar = navigationController?.navigationBar
        navigationBar?.barTintColor = color
        navigationBar?.tintColor = constrastColor
        navigationBar?.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : constrastColor]
        searchBar.barTintColor = color
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = fetchedResultsController.object(at: indexPath)
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        let color = UIColor(hexString: (selectedCategory?.color)!)
        let darkenColor = color?.darken(byPercentage: (CGFloat(indexPath.row) / CGFloat(numberOfRows)))
        cell.backgroundColor = darkenColor
        cell.textLabel?.textColor = ContrastColorOf(darkenColor!, returnFlat: true)
        
        cell.accessoryType  = item.done ? .checkmark : .none
        cell.textLabel?.text = item.title
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        numberOfRows = fetchedResultsController.sections?[section].numberOfObjects ?? 0
        return numberOfRows
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
        item.parentCategory = selectedCategory
        
        updateItem()
    }
    
    func updateItem(){
        
        do {
            try managedObjectContext?.save()
            loadItems()
        } catch {
            print("Error encoding item array, \(error)")
        }
    }
    
    func loadItems(with searchPredicate: NSPredicate? = nil) {
        
        let fetchRequest : NSFetchRequest = Item.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor (key: "title", ascending: true)]
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let predicate = searchPredicate {
            
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, predicate])
            
        }else{
            
            fetchRequest.predicate = categoryPredicate
            
        }
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        
            do {
                
                try fetchedResultsController.performFetch()
                
            } catch {
                print("Error decoding item array \(error)")
            }
        
        tableView.reloadData()
        
    }
    
    override func updateManagedObjectModel(at indexPath: IndexPath) {
        
        let categoryItem = self.fetchedResultsController.object(at: indexPath)
        
        self.managedObjectContext?.delete(categoryItem)
        
        loadItems()
    }
}

extension TodoListViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        loadItems(with: predicate)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
       
        if searchBar.text?.count == 0 {
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

