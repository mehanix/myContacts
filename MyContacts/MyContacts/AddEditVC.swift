import UIKit
import CoreData

class AddEditVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var saveButton: UIButton!;
    @IBOutlet var firstNameTextField: UITextField!;
    @IBOutlet var lastNameTextField: UITextField!;
    @IBOutlet var phoneNumberTextField: UITextField!;
    
    @IBOutlet var contactImage: UIImageView!
    @IBOutlet weak var birthDatePicker: UIDatePicker!
    var object:Contact?;
    override func viewDidLoad() {
        if(object != nil)
        {
            self.title = "Edit contact";
            firstNameTextField.text = object?.firstName;
            lastNameTextField.text = object?.lastName;
            phoneNumberTextField.text = object?.phoneNumber;
            birthDatePicker.date = object?.birthday ?? Date();
        } else {
            self.title = "Add new contact"
        }
        super.viewDidLoad()

        
    }
        	 	
    @IBAction func save(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        let context : NSManagedObjectContext = appDelegate.persistentContainer.viewContext;
        let entity = NSEntityDescription.entity(forEntityName: "Contact", in: context)

        if (firstNameTextField.text == "" || lastNameTextField.text == "" || phoneNumberTextField.text == "") {
            return;
        }
        
        if (object == nil) { // nil means new contact will be added
                Task {
               
                    var newContact = Contact(entity: entity!, insertInto: context)
                    newContact.firstName = firstNameTextField.text;
                    newContact.lastName = lastNameTextField.text;
                    newContact.phoneNumber = phoneNumberTextField.text;
                    if (contactImage.image != nil) {
                        newContact.photo = contactImage.image!.pngData();

                    } else {
                        let res = await loadPhotoUrl();
                        let imageData = await loadPhoto(apiUrl: res)
                        print("got: \(res)")
                    newContact.photo = imageData;
                    }
                    newContact.birthday = birthDatePicker.date;
                    
                    addNotif(contact: &newContact)
                  
                    
                  
                    do
                        {
                        try context.save();
                        contacts.append(newContact)
                        navigationController?.popViewController(animated:true)

                    } catch {
                        print("context save error")
                    }
                }
            
          
        } else { // contact edit
            object!.firstName = firstNameTextField.text;
            object!.lastName = lastNameTextField.text;
            object!.phoneNumber = phoneNumberTextField.text;
            object!.photo = contactImage.image?.pngData();
            object!.birthday = birthDatePicker.date;
            // sterg notificarea veche si pun una noua
            let notifId = object!.notif?.notificationId;
            let notificationCenter = UNUserNotificationCenter.current();
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [notifId!])
            addNotif(contact: &object!)
            do {
                try context.save()
                navigationController?.popToRootViewController(animated:true)	
            } catch {
                print("edit error")
            }
        }

    }
    @IBAction func addPhoto(_ sender: Any) {
        let picker = UIImagePickerController();
        picker.allowsEditing = true;
        picker.delegate = self;
        present(picker, animated: true)
        
    }
    
    func addNotif(contact:inout Contact) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;

        let context : NSManagedObjectContext = appDelegate.persistentContainer.viewContext;
        let notifEntity = NSEntityDescription.entity(forEntityName: "ContactBirthdayNotifications", in: context)

        let notificationCenter = UNUserNotificationCenter.current();
       
    
        let notif = UNMutableNotificationContent();
        notif.title = "It's " + contact.firstName! + " " + contact.lastName! + "'s birthday today!'"
        notif.body = "Don't forget to say Happy Birthday!"
            
        var dateComponents = DateComponents()
        dateComponents.hour = Calendar.current.component(.hour, from: contact.birthday!);
        dateComponents.minute = Calendar.current.component(.minute, from: contact.birthday!);
        		
        dateComponents.day = Calendar.current.component(.day, from: contact.birthday!);
        
        dateComponents.month = Calendar.current.component(.month, from: contact.birthday!);
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let newNotif = ContactBirthdayNotifications(entity: notifEntity!, insertInto: context);
        let uuidString = UUID().uuidString;

        newNotif.notificationId = uuidString; // saving the notification's uuid so that on edit i can cancel it and recreate it with the new birthday date
        newNotif.contact = contact;
        contact.notif = newNotif;
        notificationCenter.requestAuthorization(options:[.alert, .sound, .badge], completionHandler: {granted, error in
            if let error=error {
                print(error)
                return;
            } else {
                let request = UNNotificationRequest(identifier:uuidString, content: notif, trigger: trigger)
                
             
                
                print(request)
                notificationCenter.add(request) { (error) in
                    if error != nil {
                        print("error adding notification")
                    }
            }
            }
        })
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else {return}
        dismiss(animated:true)
        contactImage.image = image;
        
        
    }
    
    struct RandomContactPhoto: Codable {
        let message: String!;
        let status: String!;
    }
    
    func loadPhotoUrl() async -> String {
        let apiUrl = "https:dog.ceo/api/breeds/image/random";
        guard let url = URL(string:apiUrl) else {
            return String("")
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let decodedResponse = try? JSONDecoder().decode(RandomContactPhoto.self, from: data) {
                return decodedResponse.message
            }
        } catch {
            print("api error")
        }
        return String("")
    }
    
    func loadPhoto(apiUrl:String) async -> Data? {
        guard let url = URL(string:apiUrl) else {
            return nil
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return data

        } catch {
            print("api load error")
        }
        return nil
    }

//    func getRandomContactPhoto() {

//
//        let task = URLSession.shared.dataTask(with: url, completionHandler: <#T##(Data?, URLResponse?, Error?) -> Void#>) {
//            data, response, error in
//            guard let data = data, error == nil else {
//                return
//            }
//            var result:RandomContactPhoto?
//            do {
//                result = try JSONDecoder().decode(RandomContactPhoto.self, from: data)
//                
//                if (result!.status == "success") {
//                    let answer = self.getPhotoData(apiUrl: result!.message)
//                } else {
//                    print("error")
//                }
//            } catch {
//                print("failed to decode with \(error)")
//            }
//            guard let final = result else {
//                return
//            }
//            print("got \(final)")
//        }
//        task.resume()
//
//    }
//
}
