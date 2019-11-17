//
//  ViewController.swift
//  Unit5Project
//
//  Created by God on 11/16/19.
//  Copyright © 2019 God. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class HomeViewController: UIViewController {
    
    //MARK: Variables
    private let locationManager = CLLocationManager()
    var searchString: String = ""
   var venueData = [Venue]() {
        didSet {
            imageArray = []
            loadImageData(venue: self.venueData)
            
            for i in self.venueData {
                let annotation = MKPointAnnotation()
                annotation.title = i.name
                if let data = i.location {
                    annotation.coordinate = CLLocationCoordinate2D(latitude: data.lat, longitude: data.lng)
                    annotation.subtitle = i.id
                    self.mapView.addAnnotation(annotation)
                }
            }
        }
    }
    
    var imageArray:[UIImage] = [] {
        didSet {
            guard self.imageArray.count == venueData.count else {return}
            navigationItem.rightBarButtonItem?.isEnabled = true
            collectionView.reloadData()
        }
    }
    var searchCoordinates:String? = nil {
        didSet {
            guard let search = self.searchCoordinates else {return}
            loadLatLongData(cityNameOrZipCode: search)
        }
    }
    var searchStringQuery:String = "" {
        didSet  {
            guard self.searchStringQuery != ""  else {return}
            loadVenueData(query: self.searchStringQuery)
        }
    }
    let searchRadius: CLLocationDistance = 1000
    
    var coordinate:CLLocationCoordinate2D? = CLLocationCoordinate2D() {
        didSet {
            let coordinateRegion = MKCoordinateRegion(center: self.coordinate ?? CLLocationCoordinate2D(), latitudinalMeters: 2 * searchRadius, longitudinalMeters: 2 * searchRadius)
            mapView.setRegion(coordinateRegion, animated: true)
            guard searchStringQuery != "" else {return}
            loadVenueData(query: searchStringQuery)
        }
    }
    //MARK: @IB Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var venueSearch: UISearchBar!
    @IBOutlet weak var citySearch: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBAction func listButton(_ sender: Any) {
    }
    //MARK: Life Cycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        requestLocationAndAuthorizeIfNeeded()
        venueSearch.delegate = self
        citySearch.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self 
        venueSearch.placeholder = "Search Venues"
        citySearch.placeholder = "Search City"
        
    }
    //MARK: Private Functions
    private func requestLocationAndAuthorizeIfNeeded() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        default:
            locationManager.requestWhenInUseAuthorization()
        }
    }
    private func loadVenueData(query:String) {
        guard searchCoordinates != "" else {return}
        guard let lat = coordinate?.latitude, let long = coordinate?.longitude else {return}
        
        MapAPIClient.client.getMapData(query: query, latLong: "\(lat),\(long)") { (result) in
            switch result {
                
            case .success(let data):
                self.venueData = data
                
            case .failure(let error):
                print(error)
            }
        }
    }
    private func loadLatLongData(cityNameOrZipCode:String) {
        ZipCodeHelper.getLatLong(fromZipCode: cityNameOrZipCode) { [weak self] (results) in
            switch results {
                
            case .success(let coordinateData):
                
                self?.coordinate = coordinateData
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func loadImageData(venue:[Venue]) {
        navigationItem.rightBarButtonItem?.isEnabled = false
        for i in venue {
            MapPictureAPIClient.manager.getFourSquarePictureData(venueID:i.id ) { (results) in
                switch results {
                case .failure(let error):
                    print(error)
                    self.imageArray.append(UIImage(systemName: "photo")!)
                case .success(let item):
                    // print("got something from pictureAPI")
                    if item.count > 0 {
                        ImageHelper.shared.getImage(urlStr: item[0].returnPictureURL()) {   (results) in
                            
                            switch results {
                            case .failure(let error):
                                print("picture error \(error)")
                                self.imageArray.append(UIImage(systemName: "photo")!)
                            case .success(let imageData):
                                
                                DispatchQueue.main.async {
                                    
                                    self.imageArray.append(imageData)
                                    print("test Load PHoto function")
                                }
                            }
                        }
                    } else {
                        self.imageArray.append(UIImage(systemName: "photo")!)
                    }
                }
            }
        }
    }
    
    
    
    
    
}
//MARK: Extensions
extension HomeViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            self.mapView.setRegion(region, animated: true)
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("An error occurred: \(error)")
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("Authorization status changed to \(status.rawValue)")
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        default:
            break
        }
    }
}
//MARK: Search Bar Extensions
extension HomeViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
           switch searchBar.tag {
           case 0:
               venueSearch.showsCancelButton = true
               venueSearch.setImage(UIImage(systemName: "magnifyingglass.circle.fill"), for: .search, state: .normal)
           case 1:
               citySearch.showsCancelButton = true
               citySearch.setImage(UIImage(systemName: "magnifyingglass.circle.fill"), for: .search, state: .normal)
           default:
               break
           }
           
           return true
       }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        switch searchBar.tag {
        case 0:
            venueSearch.setImage(UIImage(systemName: "magnifyingglass.circle"), for: .search, state: .normal)
        case 1:
            citySearch.setImage(UIImage(systemName: "magnifyingglass.circle"), for: .search, state: .normal)
        default:
            break
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        switch searchBar.tag {
        case 0:
            venueSearch.showsCancelButton = false
            searchStringQuery = ""
            searchBar.placeholder = ""
            venueSearch.resignFirstResponder()
            
        case 1:
            citySearch.showsCancelButton = false
            citySearch.resignFirstResponder()
            
        default:
            break
            
        }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let annotations = self.mapView.annotations
        
        switch searchBar.tag {
        case 0:
            self.mapView.removeAnnotations(annotations)
            guard let search = venueSearch.text else {return}
            guard search != "" else {return}
            searchStringQuery = search.capitalized
            venueSearch.placeholder = venueSearch.text?.capitalized
            
            searchBar.resignFirstResponder()
            
        case 1:
            if venueSearch.alpha != 1.0 {
                UIView.animate(withDuration: 2.5, delay: 0.0, options: [.transitionCrossDissolve], animations: {
                    self.venueSearch.alpha = 1.0
                }, completion: nil)
            }
            venueSearch.isUserInteractionEnabled = true

            guard let search = citySearch.text else {return}
            navigationItem.title = search.capitalized
            searchCoordinates = search
            citySearch.placeholder = search.capitalized
            self.mapView.removeAnnotations(annotations)
            resignFirstResponder()
        default:
            break
        }
        
    }
    
    
}
extension HomeViewController: UICollectionViewDelegate , UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return venueData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VenueCell", for: indexPath) as! VenueCollectionViewCell
        cell.imageVenue.image = imageArray[indexPath.row]
        return cell
    }
    
    
}
