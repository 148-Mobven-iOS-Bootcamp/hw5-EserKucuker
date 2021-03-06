//
//  MapViewController.swift
//  UIComponents
//
//  Created by Semih Emre ÜNLÜ on 9.01.2022.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkLocationPermission()
        addLongGestureRecognizer()
    }
    
    private var currentCoordinate: CLLocationCoordinate2D?
    private var destinationCoordinate: CLLocationCoordinate2D?
    private var routes : [MKPolyline] = []
    private var render : [MKPolylineRenderer] = []
    private var currentIndex = 0
    
    
    func addLongGestureRecognizer() {
        let longPressGesture = UILongPressGestureRecognizer(target: self,
                                                            action: #selector(handleLongPressGesture(_ :)))
        self.view.addGestureRecognizer(longPressGesture)
    }
    
    @objc func handleLongPressGesture(_ sender: UILongPressGestureRecognizer) {
        
        let overlays = mapView.overlays
        mapView.removeOverlays(overlays)
        
        let position = mapView.annotations
        mapView.removeAnnotations(position)
        
        let point = sender.location(in: mapView)
        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
        destinationCoordinate = coordinate
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Pinned"
        mapView.addAnnotation(annotation)
        self.routes = []
    }
    
    func checkLocationPermission() {
        switch self.locationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse, .authorized:
            locationManager.requestLocation()
        case .denied, .restricted:
            //popup gosterecegiz. go to settings butonuna basildiginda
            //kullaniciyi uygulamamizin settings sayfasina gonder
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            fatalError()
        }
    }
    
    @IBAction func showCurrentLocationTapped(_ sender: UIButton) {
        locationManager.requestLocation()
    }
    
    @IBAction func drawRouteButtonTapped(_ sender: UIButton) {
        guard let currentCoordinate = currentCoordinate,
              let destinationCoordinate = destinationCoordinate else {
                  // log
                  // alert
                  return
              }
        
        let sourcePlacemark = MKPlacemark(coordinate: currentCoordinate)
        let source = MKMapItem(placemark: sourcePlacemark)
        
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate)
        let destination = MKMapItem(placemark: destinationPlacemark)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = source
        directionRequest.destination = destination
        directionRequest.transportType = .automobile
        directionRequest.requestsAlternateRoutes = true
        
        let direction = MKDirections(request: directionRequest)
        
        direction.calculate { response, error in
            guard error == nil else {
                //log error
                //show error
                //print(error?.localizedDescription)
                return
            }
            
            
            guard let routeData = response else { return }
            let sortedRoutes = routeData.routes.sorted(by: { $0.distance > $1.distance })
            
            for route in sortedRoutes {
                self.routes.append(route.polyline)
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
            
            
        }
    }
    
    func setRoute(){
        
        
        for item in self.render {
            if self.render.firstIndex(of: item) == currentIndex {
                item.strokeColor = .blue
            }
            else{
                item.strokeColor = .gray
            }
            
        }
        
        
    }
    
    private var routeIndex = 0
    @IBAction func reverseBarButtonTapped(_ sender: UIBarButtonItem){
        
        if(self.currentIndex > 0){
            self.currentIndex -= 1
            
        }else{
            self.currentIndex = self.routes.count - 1
        }
        
        setRoute()
        
    }
    
    @IBAction func forwardBarButtonTapped(_ sender : UIBarButtonItem){
        
        if(self.currentIndex < self.routes.count - 1 ){
            self.currentIndex += 1
        }else{
            self.currentIndex = 0
        }
        setRoute()
    }
    
    private lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        return locationManager
    }()
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = locations.first?.coordinate else { return }
        currentCoordinate = coordinate
        print("latitude: \(coordinate.latitude)")
        print("longitude: \(coordinate.longitude)")
        
        mapView.setCenter(coordinate, animated: true)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationPermission()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polyline = overlay as! MKPolyline
        
        let renderer = MKPolylineRenderer(polyline: polyline)
        self.render.append(renderer)
                
        for item in self.render {
            if self.render.firstIndex(of: item) == currentIndex {
                item.strokeColor = .blue
            }
            else{
                item.strokeColor = .gray
            }
            
        }

        
        return renderer
    }
    
    
}
