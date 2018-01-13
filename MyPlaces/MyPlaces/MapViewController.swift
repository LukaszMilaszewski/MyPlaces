import UIKit
import GoogleMaps
import RealmSwift

class MapViewController: UIViewController, PlaceDetailViewControllerDelegate {
  
  var realm = try! Realm()
  var places: Results<Place>!
  
  @IBOutlet fileprivate weak var mapView: GMSMapView!
  
  //MARK: - prepare view
  
  override func viewDidLoad() {
    super.viewDidLoad()
    hideNavBar()
    obtainPlaces()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setMarkers()
  }
  
  func obtainPlaces() {
    places = realm.objects(Place.self)
  }
  
  func setMarkers() {
    mapView.clear()
   
    guard !places.isEmpty else { return }
    
    for place in places where place.hasPosition() {
      let camera = GMSCameraPosition.camera(withLatitude: place.latitude, longitude: place.longitude, zoom: 6.0)
      mapView.camera = camera
      let marker = GMSMarker()
      marker.position = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
      marker.userData = place
      marker.map = mapView
    }
  }
  
  func hideNavBar() {
    self.navigationController?.setNavigationBarHidden(true, animated: true)
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "AddPin" {
      let navigationController = segue.destination as! UINavigationController
      let controller = navigationController.topViewController as! PlaceDetailViewController
      controller.delegate = self
      controller.placeFromMap = sender as? Place
    }
  }
  
  //MARK: - PlaceDetailViewControllerDelegate
  
  func placeDetailViewControllerDidCancel(_ controller: PlaceDetailViewController) {
    dismiss(animated: true, completion: nil)
  }
  
  func placeDetailViewController(_ controller: PlaceDetailViewController, didFinishAdding place: Place) {
    place.save(realm: realm)
    dismiss(animated: true, completion: nil)
  }
  
  func placeDetailViewController(_ controller: PlaceDetailViewController, didFinishEditing place: Place, editedPlace: Place) {}
}

extension MapViewController: GMSMapViewDelegate {
  
  func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
    let place = Place()
    place.latitude = coordinate.latitude
    place.longitude = coordinate.longitude
    
    performSegue(withIdentifier: "AddPin", sender: place)
  }
  
  func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
    let markerView = MarkerView.loadNiB()
    let place = marker.userData as! Place
    markerView.initMarkerView(place: place)
    
    return markerView
  }
}
