import RealmSwift

class Place: Object {
  @objc dynamic var photo = ""
  @objc dynamic var descript = ""
  @objc dynamic var address = ""

  convenience init(photo: String, descript: String, address: String) {
    self.init()
    self.photo = photo
    self.descript = descript
    self.address = address
  }
}
