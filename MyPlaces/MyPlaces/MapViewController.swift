import UIKit
import GoogleMaps
import RealmSwift

class MapViewController: UIViewController {
  
  var realm : Realm!
  var places: Results<Place>!
  @IBOutlet fileprivate weak var mapView: GMSMapView!
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    mapView.clear()
    realm = try! Realm()
    places = realm.objects(Place.self)
    if places.count > 0 {
      let initLatitude = places[places.count - 1].latitude
      let initLongitude = places[places.count - 1].longitude
      
      let camera = GMSCameraPosition.camera(withLatitude: initLatitude, longitude: initLongitude, zoom: 6.0)
      mapView.camera = camera
      
      for place in places {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
        marker.userData = place
        marker.map = mapView
      }
    }
  }
}

extension MapViewController: GMSMapViewDelegate{
  
  func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
    let markerView = MarkerView.loadNiB()
    let place = marker.userData as! Place
    markerView.initMarkerView(place: place)
    
    return markerView
  }
}
