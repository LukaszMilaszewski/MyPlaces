import UIKit

class Place {
  var photo: UIImage!
  var description: String
  var address: String
  
  init(photo: UIImage, description: String, address: String) {
    self.photo = photo
    self.description = description
    self.address = address
  }
}
