import RealmSwift

class Place: Object {
  @objc dynamic var photo: Data?
  @objc dynamic var descript = ""
  @objc dynamic var address = ""

  convenience init(photo: Data, descript: String, address: String) {
    self.init()
    self.photo = photo
    self.descript = descript
    self.address = address
  }
  
  var hasPhoto: Bool {
    return photo != nil
  }
  
  func delete(realm: Realm) {
    try! realm.write({ realm.delete(self) })
  }
  
  func save(realm: Realm) {
    try! realm.write({ realm.add(self) })
  }
  
  func update(editedPlace: Place, realm: Realm) {
    try! realm.write({
      descript = editedPlace.descript
      photo = editedPlace.photo
    })
  }
}
