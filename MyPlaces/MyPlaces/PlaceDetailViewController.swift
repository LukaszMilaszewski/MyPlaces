import UIKit
import RealmSwift
import CoreLocation

protocol PlaceDetailViewControllerDelegate: class {
  func placeDetailViewControllerDidCancel(_ controller: PlaceDetailViewController)
  func placeDetailViewController(_ controller: PlaceDetailViewController, didFinishAdding place: Place)
  func placeDetailViewController(_ controller: PlaceDetailViewController, didFinishEditing place: Place, editedPlace: Place)
}

class PlaceDetailViewController: UIViewController, CLLocationManagerDelegate {
  
  @IBOutlet weak var descriptionTextField: UITextField!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var addressLabel: UILabel!
  
  weak var delegate: PlaceDetailViewControllerDelegate?
  var placeToEdit: Place?
  var image: UIImage?
  let locationManager = CLLocationManager()
  lazy var geocoder = CLGeocoder()
  var longitude = 0.0
  var latitude = 0.0
  var address = ""
  
  @IBAction func findLocation() {
    addressLabel.text = "searching for location ... "
    if CLLocationManager.locationServicesEnabled() {
      locationManager.delegate = self
      locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
      locationManager.requestLocation()
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.first {
      print(location.coordinate)
      longitude = location.coordinate.longitude
      latitude = location.coordinate.latitude
      
      geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
        if let placemarks = placemarks, let placemark = placemarks.first {
          self.addressLabel.text = placemark.compactAddress
          self.address = placemark.compactAddress!
        }
      }
    }
  }
  
  func locationManager(_ manager: CLLocationManager,
                       didFailWithError error: Error) {}
  
  @IBAction func addPhoto() {
    pickPhoto()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    locationManager.requestAlwaysAuthorization()
    addressLabel.text = ""
    if let place = placeToEdit {
      title = "Edit Place"
      descriptionTextField.text = place.descript
      addressLabel.text = place.address
      imageView.image = UIImage(data: place.photo!, scale: 1.0)
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
      setupPlace(place: newPlace)
      delegate?.placeDetailViewController(self, didFinishEditing: place, editedPlace: newPlace)
    } else {
      let place = Place()
      setupPlace(place: place)
      delegate?.placeDetailViewController(self, didFinishAdding: place)
    }
  }
  
  func setupPlace(place: Place) {
    place.descript = descriptionTextField.text!
    place.longitude = longitude
    place.latitude = latitude
    place.date = NSDate()
    place.address = address
    if let image = imageView.image {
      place.photo = UIImagePNGRepresentation(image) as Data?
    } else {
      place.photo = UIImagePNGRepresentation(UIImage(named: "noimage")!) as Data?
    }
  }
}

extension PlaceDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func pickPhoto() {
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      showPhotoMenu()
    } else {
      choosePhotoFromLibrary()
    }
  }
  
  func showPhotoMenu() {
    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    alertController.addAction(cancelAction)
    let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default, handler: { _ in self.takePhotoWithCamera() })
    alertController.addAction(takePhotoAction)
    let chooseFromLibraryAction = UIAlertAction(title: "Choose From Library", style: .default, handler: { _ in self.choosePhotoFromLibrary() })
    alertController.addAction(chooseFromLibraryAction)
    present(alertController, animated: true, completion: nil)
  }
  
  func takePhotoWithCamera() {
    let imagePicker = MyImagePickerController()
    imagePicker.sourceType = .camera
    imagePicker.delegate = self
    imagePicker.allowsEditing = true
    imagePicker.view.tintColor = view.tintColor
    present(imagePicker, animated: true, completion: nil)
  }
  
  func choosePhotoFromLibrary() {
    let imagePicker = MyImagePickerController()
    imagePicker.sourceType = .photoLibrary
    imagePicker.delegate = self
    imagePicker.allowsEditing = true
    imagePicker.view.tintColor = view.tintColor
    present(imagePicker, animated: true, completion: nil)
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    image = info[UIImagePickerControllerEditedImage] as? UIImage
    
    if let theImage = image {
      imageView.image = theImage
    }
    dismiss(animated: true, completion: nil)
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true, completion: nil)
  }
}

class MyImagePickerController: UIImagePickerController {
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
}

extension CLPlacemark {
  
  var compactAddress: String? {
    if let name = name {
      var result = name
      if let city = locality { result += ", \(city)" }
      if let country = country { result += ", \(country)" }
      
      return result
    }
    return nil
  }
}
