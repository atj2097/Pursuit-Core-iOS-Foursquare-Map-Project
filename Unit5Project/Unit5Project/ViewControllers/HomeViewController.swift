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
    private let locationManager = CLLocationManager()
    var searchString: String = ""
    var venueData = [Venue]() {
        didSet {
            collectionView.reloadData()
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
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var venueSearch: UISearchBar!
    @IBOutlet weak var citySearch: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBAction func listButton(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        requestLocationAndAuthorizeIfNeeded()
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
extension HomeViewController: UISearchBarDelegate {
    
}
extension HomeViewController: UICollectionViewDelegate , UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return venueData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
    
}
