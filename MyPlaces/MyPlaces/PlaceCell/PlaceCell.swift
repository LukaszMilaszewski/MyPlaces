import UIKit

class PlaceCell: UITableViewCell {

  @IBOutlet weak var photoView: UIImageView!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!

  override func awakeFromNib() {
    super.awakeFromNib()
    photoView.layer.cornerRadius = photoView.bounds.size.width / 2
    photoView.clipsToBounds = true
  }
  
  func initPlaceCell(place: Place) {
    photoView.image = thumbnail(for: place)
    descriptionLabel.text = place.description
    addressLabel.text = place.address
  }
  
  func thumbnail(for place: Place) -> UIImage {
    if place.hasPhoto, let imageData = place.photo {
      let image = UIImage(data: imageData, scale: 1.0)
      return image!
    }
    return UIImage(named: "noimage.png")!
  }
}
