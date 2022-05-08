import UIKit
import Contacts

class ViewContactVC: UIViewController {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var birthDateLabel: UILabel!
    @IBOutlet weak var funFactLabel: UILabel!
    @IBOutlet weak var funFactIntroLabel: UILabel!
    var object:Contact?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (object != nil && (object!.photo) != nil) {
            photoImageView.image = UIImage(data:object!.photo!)
        }
        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "dd/MM/yyyy";
        firstNameLabel.text = object!.firstName;
        lastNameLabel.text = object!.lastName;
        phoneNumberLabel.text = object!.phoneNumber;
        if (object?.birthday != nil) {
            
            birthDateLabel.text = dateFormatter.string(from:(object?.birthday)!);
           
            let dateFormatter = DateFormatter();
            dateFormatter.dateFormat = "MM";
            let month = dateFormatter.string(from: (object?.birthday!)!)
            
            dateFormatter.dateFormat = "dd";
            let day = dateFormatter.string(from: (object?.birthday!)!)
            print(day,month)
            let url = URL(string: "https://history.muffinlabs.com/date/\(day)/\(month)")!
            let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                guard let data = data else { return }
                do {
                    if let decodedResponse = try JSONDecoder().decode(ThisDayInHistory?.self, from: data) {
                        let event =  decodedResponse.data.Events.randomElement();
                        print(event!.year)
                        DispatchQueue.main.async {
                            self.funFactIntroLabel.text = "On their birth date, in " + (event?.year ?? "")  + ", the following happened:"
                            self.funFactLabel.text = event!.text;
                        }
                      
                    }
                } catch {
                    print("api error")
                }
                print(String(data: data, encoding: .utf8)!)
            }

            task.resume()
        } else {
            birthDateLabel.text = "Not set"
        }
       
        
    }
    
    func call(phoneNumber:String) {

      if let phoneCallURL = URL(string: "tel://\(phoneNumber)") {

        let application:UIApplication = UIApplication.shared
        if (application.canOpenURL(phoneCallURL)) {
            application.open(phoneCallURL, options: [:], completionHandler: nil)
        }
      }
    }
    @IBAction func callButtonPress(_ sender: Any) {
        let number = phoneNumberLabel.text;
        guard let numberonly = number?.replacingOccurrences(of: " ", with: "") else { return  }
        call(phoneNumber:numberonly)
    }
    @IBAction func shareButtonPress(_ sender: Any) {
        let toShare=[ object?.firstName!, object?.lastName!, object?.phoneNumber!]
    
        let activityViewController = UIActivityViewController(activityItems: toShare as [Any], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        
        self.present(activityViewController, animated: true)
        
    }
    @IBAction func editButtonPress(_ sender: Any) {

        let editContact = self.storyboard?.instantiateViewController(withIdentifier: "AddEditContact") as! AddEditVC;
        editContact.object = object;
        
        self.navigationController?.pushViewController(editContact, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (self.isMovingFromParent) {
            object = nil;
            print("object is nil")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
}
