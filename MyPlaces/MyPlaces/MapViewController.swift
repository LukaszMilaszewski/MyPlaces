import UIKit
import GoogleMaps
import RealmSwift

class MapViewController: UIViewController {
  
  var realm = try! Realm()
  var places: Results<Place>!
  @IBOutlet fileprivate weak var mapView: GMSMapView!
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    mapView.clear()
    places = realm.objects(Place.self)
    if !places.isEmpty {
      for place in places {
        if place.hasPosition() {
          let camera = GMSCameraPosition.camera(withLatitude: place.latitude, longitude: place.longitude, zoom: 6.0)
          mapView.camera = camera
          let marker = GMSMarker()
          marker.position = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
          marker.userData = place
          marker.map = mapView
        }
      }
    }
  }
}

extension MapViewController: GMSMapViewDelegate {
  
  func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
    let markerView = MarkerView.loadNiB()
    let place = marker.userData as! Place
    markerView.initMarkerView(place: place)
    
    return markerView
  }
}
