import UIKit
import RealmSwift

class PlacesListViewController: UITableViewController, PlaceDetailViewControllerDelegate {

  var realm : Realm!
  var places: Results<Place> { get { return realm.objects(Place.self) }}
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    realm = try! Realm()
    
    let nibCellName = UINib(nibName: "PlaceCell", bundle: nil)
    tableView.register(nibCellName, forCellReuseIdentifier: "PlaceCell")
  }
  
  @IBAction func addPlace() {
    let place = Place(photo: "noimage.png", descript: "blabla", address: "slupsk")
    
    try! self.realm.write({
      self.realm.add(place)
      self.tableView.insertRows(at: [IndexPath.init(row: self.places.count-1, section: 0)], with: .automatic)
    })
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "AddPlace" {
      let navigationController = segue.destination as! UINavigationController
      let controller = navigationController.topViewController as! PlaceDetailViewController
      controller.delegate = self
    } else if segue.identifier == "EditPlace" {
      let navigationController = segue.destination as! UINavigationController
      let controller = navigationController.topViewController as! PlaceDetailViewController
      controller.delegate = self
      
      if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
        controller.placeToEdit = places[indexPath.row]
      }
    }
  }
  
  // MARK: - TableView
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return places.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath) as! PlaceCell
    cell.initPlaceCell(place: places[indexPath.item])
    
    let place = places[indexPath.item]
    cell.descriptionLabel.text = place.descript
    cell.addressLabel.text = place.address
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 100
  }
  
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if (editingStyle == .delete){
      let place = places[indexPath.row]
      try! self.realm.write({
        self.realm.delete(place)
      })
      tableView.deleteRows(at:[indexPath], with: .automatic)
    }
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let cell = tableView.cellForRow(at: indexPath) {
      performSegue(withIdentifier: "EditPlace", sender: cell)
    }
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
  // MARK: - PlaceDetailViewControllerDelegate
  
  func placeDetailViewControllerDidCancel(_ controller: PlaceDetailViewController) {
    dismiss(animated: true, completion: nil)
  }
  
  func placeDetailViewController(_ controller: PlaceDetailViewController,
                                didFinishAdding place: Place) {
    try! self.realm.write({
      self.realm.add(place)
      self.tableView.insertRows(at: [IndexPath.init(row: self.places.count-1, section: 0)], with: .automatic)
    })
    
    dismiss(animated: true, completion: nil)
  }
  
  func placeDetailViewController(_ controller: PlaceDetailViewController,
                                 didFinishEditing place: Place, editedPlace: Place) {
    try! self.realm.write({
      place.descript = editedPlace.descript
    })
    tableView.reloadData()
    dismiss(animated: true, completion: nil)
  }
}
