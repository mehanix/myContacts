//
//  ViewController.swift
//  MyContacts
//
//  Created by user217567 on 4/28/22.
//

import UIKit
import CoreData
var contacts = [Contact]()
var selectedIndex:Int? = 0;

class MainVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var firstLoad = true;
    @IBOutlet var tableView: UITableView!;

    
    func getData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        let context : NSManagedObjectContext = appDelegate.persistentContainer.viewContext;
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Contact")
        
        do {
            let results:NSArray = try context.fetch(request) as NSArray
            
            for result in results {
                let contact = result as! Contact
                contacts.append(contact)
            }
        } catch {
            print("Fetch error")
        }
    }
    override func viewDidLoad() {
        if (firstLoad) {
            firstLoad = false;
            getData();
        }
        super.viewDidLoad()
        title = "My Contacts"
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.frame = view.bounds;
        // Do any additional setup after loading the view.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        let context : NSManagedObjectContext = appDelegate.persistentContainer.viewContext;
        
        if editingStyle == .delete {
            let toDelete = contacts[indexPath.row]
            contacts.remove(at: indexPath.row)
            context.delete(toDelete)
            do {
                try context.save()
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                print("cannot save, reason: \(error)");
            }
        }
      
       
      
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let contact = contacts[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath);
        
        
        cell.textLabel?.text = contact.firstName! + " " + contact.lastName!;
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row;
        let viewContact = self.storyboard?.instantiateViewController(withIdentifier: "ViewContact") as! ViewContactVC;
        
        viewContact.object = contacts[indexPath.row]
        self.navigationController?.pushViewController(viewContact, animated: true)
    }
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
        super.viewDidAppear(animated)
    }
}

