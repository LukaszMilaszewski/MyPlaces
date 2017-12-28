import UIKit
import RealmSwift

protocol PlaceDetailViewControllerDelegate: class {
  func placeDetailViewControllerDidCancel(_ controller: PlaceDetailViewController)
  
  func placeDetailViewController(_ controller: PlaceDetailViewController,
                                didFinishAdding place: Place)
  
  func placeDetailViewController(_ controller: PlaceDetailViewController,
                                 didFinishEditing place: Place, editedPlace: Place)
}

class PlaceDetailViewController: UIViewController {
 
  @IBOutlet weak var descriptionTextField: UITextField!
  
  weak var delegate: PlaceDetailViewControllerDelegate?
  var placeToEdit: Place?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let place = placeToEdit {
      title = "Edit Place"
      descriptionTextField.text = place.descript
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  @IBAction func cancel() {
    delegate?.placeDetailViewControllerDidCancel(self)
  }
  
  @IBAction func done() {
    if let place = placeToEdit {
      let newPlace = Place()
      newPlace.descript = descriptionTextField.text!
      
      delegate?.placeDetailViewController(self, didFinishEditing: place, editedPlace: newPlace)
    } else {
      let place = Place()
      place.descript = descriptionTextField.text!
      delegate?.placeDetailViewController(self, didFinishAdding: place)
    }
  }
}
