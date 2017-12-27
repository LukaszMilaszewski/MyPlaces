import UIKit

class PlaceCell: UITableViewCell {

  @IBOutlet weak var photoView: UIImageView!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!

  override func awakeFromNib() {
    super.awakeFromNib()
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
  
  func initPlaceCell(place: Place) {
    photoView.image = UIImage(named: place.photo)
    descriptionLabel.text = place.description
    addressLabel.text = place.address
  }
}
