import RealmSwift

class Place: Object {
  @objc dynamic var photo: Data?
  @objc dynamic var descript = ""
  @objc dynamic var address = ""
  @objc dynamic var longitude = 0.0
  @objc dynamic var latitude = 0.0
  @objc dynamic var date = NSDate()
  
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
      address = editedPlace.address
      photo = editedPlace.photo
    })
  }
}
