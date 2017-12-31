import UIKit

class MarkerView: UIView {
  
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var photoView: UIImageView!
  
  func initMarkerView(place: Place) {
    photoView.image = UIImage(data: place.photo!, scale: 1.0)
    descriptionLabel.text = place.descript
    addressLabel.text = place.address
  }
  
  class func loadNiB() -> MarkerView {
    let markerView = UINib(nibName: "MarkerView", bundle: nil).instantiate(withOwner: self, options: nil).first as! MarkerView
    return markerView
  }
}
