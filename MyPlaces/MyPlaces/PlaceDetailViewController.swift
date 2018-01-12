import UIKit
import RealmSwift
import CoreLocation

protocol PlaceDetailViewControllerDelegate: class {
  func placeDetailViewControllerDidCancel(_ controller: PlaceDetailViewController)
  func placeDetailViewController(_ controller: PlaceDetailViewController, didFinishAdding place: Place)
  func placeDetailViewController(_ controller: PlaceDetailViewController, didFinishEditing place: Place, editedPlace: Place)
}

class PlaceDetailViewController: UITableViewController, CLLocationManagerDelegate, UITextViewDelegate {
  
  @IBOutlet weak var descriptionTextView: UITextView!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var photoLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var doneButton: UIBarButtonItem!
  
  weak var delegate: PlaceDetailViewControllerDelegate?
  var placeToEdit: Place?

  let locationManager = CLLocationManager()
  lazy var geocoder = CLGeocoder()

  var longitude = 0.0
  var latitude = 0.0
  var address = ""
  var date = NSDate()
  
  func textViewDidChange(_ textView: UITextView) { //Handle the text changes here
    if textView.text.isEmpty {
      doneButton.isEnabled = false
    } else {
      doneButton.isEnabled = true
    }
  }
  
  func findLocation() {
    addressLabel.text = "searching for location ... "
    locationManager.requestAlwaysAuthorization()
    if CLLocationManager.locationServicesEnabled() {
      locationManager.delegate = self
      locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
      locationManager.requestLocation()
    }
  }
  
  func show(image: UIImage) {
    imageView.image = image
    imageView.isHidden = false
    imageView.frame = CGRect(x: 10, y: 10, width: 260, height: 260)
    photoLabel.isHidden = true
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
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {}
  
  func getDate(date: NSDate) -> String {
    let dateformatter = DateFormatter()
    dateformatter.dateStyle = DateFormatter.Style.medium
    return dateformatter.string(from: date as Date)
  }
  func configureView() {
    if let place = placeToEdit {
      title = "Edit Place"
      descriptionTextView.text = place.descript
      addressLabel.text = place.address
      dateLabel.text = getDate(date: place.date)
      doneButton.isEnabled = true
      
      if let photo = place.photo {
        show(image: UIImage(data: photo, scale: 1.0)!)
      }
    } else {
      title = "Add Place"
      dateLabel.text = getDate(date: date)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    findLocation()
    configureView()
    
    let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
    gestureRecognizer.cancelsTouchesInView = false
    tableView.addGestureRecognizer(gestureRecognizer)
  }
  
  @objc func hideKeyboard(_ gestureRecognizer: UIGestureRecognizer) {
    let point = gestureRecognizer.location(in: tableView)
    let indexPath = tableView.indexPathForRow(at: point)
    
    if indexPath != nil && indexPath!.section == 0 && indexPath!.row == 0 {
      return
    }
    
    descriptionTextView.resignFirstResponder()
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
    place.descript = descriptionTextView.text!
    place.longitude = longitude
    place.latitude = latitude
    place.date = date
    place.address = address
    if let image = imageView.image {
      place.photo = UIImagePNGRepresentation(image) as Data?
    } else {
      place.photo = UIImagePNGRepresentation(UIImage(named: "noimage")!) as Data?
    }
  }
  // MARK: - TableView
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    switch (indexPath.section, indexPath.row) {
    case (0, 0):
      return 88
    case (1, _):
      return 84
    case (2, _):
      return imageView.isHidden ? 44 : 280
    default:
      return 44
    }
  }
  
  override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    return (indexPath.section == 0 || indexPath.section == 2) ? indexPath : nil
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.section == 0 && indexPath.row == 0 {
      descriptionTextView.becomeFirstResponder()
    }
    if indexPath.section == 2 && indexPath.row == 0 {
      pickPhoto()
      tableView.deselectRow(at: indexPath, animated: true)
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
    let image = info[UIImagePickerControllerEditedImage] as? UIImage
    
    if let theImage = image {
      show(image: theImage)
    }
    
    tableView.reloadData()
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
