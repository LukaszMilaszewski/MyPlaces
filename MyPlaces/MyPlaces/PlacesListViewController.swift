import UIKit

class PlacesListViewController: UITableViewController {
  
  var places = [Place]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "My Places"
    
    let nibCellName = UINib(nibName: "PlaceCell", bundle: nil)
    tableView.register(nibCellName, forCellReuseIdentifier: "PlaceCell")
    
    places.append(Place(photo: UIImage(named: "noimage.png")!, description: "jeden", address: "1"))
    places.append(Place(photo: UIImage(named: "noimage.png")!, description: "dwa", address: "2"))
    places.append(Place(photo: UIImage(named: "noimage.png")!, description: "trzy", address: "3"))
    
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return places.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath) as! PlaceCell
    cell.initPlaceCell(place: places[indexPath.item])
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 100
  }
}
