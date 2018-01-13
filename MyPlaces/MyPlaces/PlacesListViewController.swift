import UIKit
import RealmSwift
import Dropdowns

class PlacesListViewController: UITableViewController, PlaceDetailViewControllerDelegate {

  var realm = try! Realm()
  var places: Results<Place>!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    obtainPlaces()
    setDropdownmenu()
    loadPlaceCell()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    tableView.reloadData()
  }
  
  func obtainPlaces() {
    places = realm.objects(Place.self)
  }
  
  func loadPlaceCell() {
    let nibCellName = UINib(nibName: "PlaceCell", bundle: nil)
    tableView.register(nibCellName, forCellReuseIdentifier: "PlaceCell")
  }
  
  func setDropdownmenu() {
    let items = ["By date", "By description", "By address"]
    
    let titleView = TitleView(navigationController: navigationController!, title: "My places", items: items)
    titleView?.action = { [weak self] index in
      let keys = ["date", "descript", "address"]
      self?.places = self?.realm.objects(Place.self).sorted(byKeyPath: keys[index])
      self?.tableView.reloadData()
    }
    navigationItem.titleView = titleView
  }
  
  // MARK: - segue
  
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
    if (editingStyle == .delete) {
      let place = places[indexPath.row]
      place.delete(realm: realm)
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
  
  func placeDetailViewController(_ controller: PlaceDetailViewController, didFinishAdding place: Place) {
    place.save(realm: realm)
    self.tableView.insertRows(at: [IndexPath.init(row: self.places.count-1, section: 0)], with: .automatic)
    dismiss(animated: true, completion: nil)
  }
  
  func placeDetailViewController(_ controller: PlaceDetailViewController, didFinishEditing place: Place, editedPlace: Place) {
    place.update(editedPlace: editedPlace, realm: realm)
    tableView.reloadData()
    dismiss(animated: true, completion: nil)
  }
}
