//
//  ViewController.swift
//  UserLocation
//
//  Created by Phil Jimmieson on 20/11/2022.
//

import UIKit
import MapKit
import CoreData

class ViewController: UIViewController,UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    
    
    // MARK: Map & Location related stuff
    
    @IBOutlet weak var myMap: MKMapView!

    // List of Mural Locations, start an empty array
    var muralLocations = [MuralLocation]()
    
    var locationManager = CLLocationManager()
    
    var firstRun = true
    var startTrackingTheUser = false
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationOfUser = locations[0] //this method returns an array of locations
        //generally we always want the first one (usually there's only 1 anyway)
        
        let latitude = locationOfUser.coordinate.latitude
        let longitude = locationOfUser.coordinate.longitude
        //get the users location (latitude & longitude)
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        if firstRun {
            firstRun = false
            let latDelta: CLLocationDegrees = 0.0025
            let lonDelta: CLLocationDegrees = 0.0025
            //a span defines how large an area is depicted on the map.
            let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
            
            //a region defines a centre and a size of area covered.
            let region = MKCoordinateRegion(center: location, span: span)
            
            //make the map show that region we just defined.
            self.myMap.setRegion(region, animated: true)
            
            //the following code is to prevent a bug which affects the zooming of the map to the user's location.
            //We have to leave a little time after our initial setting of the map's location and span,
            //before we can start centering on the user's location, otherwise the map never zooms in because the
            //intial zoom level and span are applied to the setCenter( ) method call, rather than our "requested" ones,
            //once they have taken effect on the map.
            
            //we setup a timer to set our boolean to true in 5 seconds.
            _ = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(startUserTracking), userInfo: nil, repeats: false)
        }
        
        if startTrackingTheUser == true {
            myMap.setCenter(location, animated: true)
        }

        
            theTable.reloadData()

    }
    
    //this method sets the startTrackingTheUser boolean class property to true. Once it's true, subsequent calls
    //to didUpdateLocations will cause the map to center on the user's location.
    @objc func startUserTracking() {
        startTrackingTheUser = true
    }

    // function will delete all the mural locations from the core data
    func deleteAllMuralLocations() {
        // Get the app delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        // Get the managed object context
        let context = appDelegate.coreDataStack.managedContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Murals")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print ("There was an error")
        }
    }

    
    
    
    //MARK: Table related stuff
    
    
    @IBOutlet weak var theTable: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return muralLocations.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 80
}
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! TableViewCell

        if (muralLocations.count == 0){
            cell.title.text = "Loading..."
            cell.subtitle.text = "Loading..."
            // hide thumbnail image, and star and starfilled
            cell.thumbnail.isHidden = true
            cell.starButton.isHidden = true
        }
        else{
            let mural = muralLocations[indexPath.row]
            cell.title.text = "Title: \(mural.title)"
            // Add distance from user
            let userLocation = locationManager.location
            let muralLat:Double = Double(mural.lat) ?? 0.0
            let muralLon:Double = Double(mural.lon) ?? 0.0
            
            let muralLocation = CLLocation(latitude: muralLat, longitude: muralLon)
            // Get distance in meters
            let distance = userLocation?.distance(from: muralLocation) ?? 0.0
            // Convert to kilometers
            let distanceInKm = distance / 1000
            // Round to 2 decimal places
            let distanceInKmRounded = String(format: "%.2f", distanceInKm)
            cell.subtitle.text = "Artist: \(mural.artist) - \(distanceInKmRounded) km"
            // Add thumbnail image
            if (mural.imageData != nil) {
                cell.thumbnail.image = UIImage(data: mural.imageData!)
            }
            else{
                let url = URL(string: muralLocations[indexPath.row].thumbnail)
                let task = URLSession.shared.dataTask(with: url!) { data, response, error in
                    guard let data = data, error == nil else { return }
                    DispatchQueue.main.async() {
                        cell.thumbnail.image = UIImage(data: data)
                        mural.imageData = data
                    }
                }
                task.resume()
            }

            cell.starButton.addTarget(self, action: #selector(toggleFavoriteMural), for: .touchUpInside)
            cell.starButton.tag = indexPath.row

            // Add star and starfilled
            if (mural.favourite == true){
                cell.starButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            }
            else{
                cell.starButton.setImage(UIImage(systemName: "star"), for: .normal)
            }
        }



        return cell
    }
    
    
    // MARK: View related Stuff

    // toggleFavoriteMural is called when the user clicks on the star icon
    @objc func toggleFavoriteMural(_ sender: UIButton) {
        let mural = muralLocations[sender.tag]
        mural.favourite = !mural.favourite
        // Save the muralLocations array to the database
        updateOneMuralData(mural: mural)
        // Reload the table
        theTable.reloadData()
    }

    
    
    fileprivate func saveCurrentDate() {
        // Save current date to user defaults
        let defaults = UserDefaults.standard
        // Get current date in the format "yyyy-mm-dd"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let currentDate = formatter.string(from: Date())
        defaults.set(currentDate, forKey: "lastUpdated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Make this view controller a delegate of the Location Managaer, so that it
        //is able to call functions provided in this view controller.
        locationManager.delegate = self as CLLocationManagerDelegate
        
        //set the level of accuracy for the user's location.
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        
        //Ask the location manager to request authorisation from the user. Note that this
        //only happens once if the user selects the "when in use" option. If the user
        //denies access, then your app will not be provided with details of the user's
        //location.
        locationManager.requestWhenInUseAuthorization()
        
        //Once the user's location is being provided then ask for udpates when the user
        //moves around.
        locationManager.startUpdatingLocation()
        
        //configure the map to show the user's location (with a blue dot).
        myMap.showsUserLocation = true

        // deleteAllMuralLocations()
        // UserDefaults.standard.removeObject(forKey: "isAppAlreadyLaunchedOnce")

        // new variable telling us if the app is launched for the first time
        let isAppAlreadyLaunched = UserDefaults.standard.string(forKey: "isAppAlreadyLaunchedOnce")
        if (isAppAlreadyLaunched != nil){
            print("App is launched more than once")
            // Read the last updated date from user defaults
            let defaults = UserDefaults.standard
            let lastUpdated = defaults.object(forKey: "lastUpdated") as! String
            loadAndMergeMuralData(lastUpdated: lastUpdated)
            deleteAllMuralLocations()
            insertMuralData()
            saveCurrentDate()
        }
        else{
            // Set the variable to true
            UserDefaults.standard.set("true", forKey: "isAppAlreadyLaunchedOnce")
            print("App is launched for the first time")
            // Get the mural data from the server
            loadMuralData(lastUpdated: "")
            insertMuralData()
            saveCurrentDate()
        }
    }

    // Function to load and merge the mural data from the server
    fileprivate func loadAndMergeMuralData(lastUpdated: String) {
        // Get the mural data from core data
        fetchMuralData()
        // Get the mural data from the server
        loadMuralData(lastUpdated: lastUpdated)
    }

    // Function to fetch the mural data from core data
    fileprivate func fetchMuralData() {
        // Get the app delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        // Get the managed object context
        let context = appDelegate.coreDataStack.managedContext
        // Create a fetch request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Murals")
        do {
            let results = try context.fetch(fetchRequest)
            for result in results as! [NSManagedObject] {
                let mural = MuralLocation()
                mural.artist = result.value(forKey: "artist") as! String
                mural.info = result.value(forKey: "info") as! String
                mural.lat = result.value(forKey: "lat") as! String
                mural.lon = result.value(forKey: "lon") as! String
                mural.thumbnail = result.value(forKey: "thumbnail") as! String
                mural.title = result.value(forKey: "title") as! String
                mural.favourite = result.value(forKey: "favorite") as! Bool
                mural.images = result.value(forKey: "images") as! [String]

                muralLocations.append(mural)

            }
            theTable.reloadData()
        } catch {
            print("Failed to fetch mural data from core data")
        }
    }

    // This function will save the mural data to core data
    fileprivate func insertMuralData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            for mural in self.muralLocations {
                // Get the app delegate
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                // Get the managed object context
                let context = appDelegate.coreDataStack.managedContext
                // Create a new managed object
                let newMural = NSEntityDescription.insertNewObject(forEntityName: "Murals", into: context)
                // Save the mural mural to core data
                newMural.setValue(mural.artist, forKey: "artist")
                newMural.setValue(mural.info, forKey: "info")
                newMural.setValue(mural.lat, forKey: "lat")
                newMural.setValue(mural.lon, forKey: "lon")
                newMural.setValue(mural.thumbnail, forKey: "thumbnail")
                newMural.setValue(mural.title, forKey: "title")
                newMural.setValue(mural.favourite, forKey: "favorite")
                // Add images to core data
                newMural.setValue(mural.images, forKey: "images")
                // newMural.setValue(mural.imageData, forKey: "imageData")
                // Save the managed object context
                do {
                    try context.save()
                } catch {
                    print("Failed saving")
                }
            }
        }
    }

    // Update one mural data in core data
    fileprivate func updateOneMuralData(mural: MuralLocation) {
        // Get the app delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        // Get the managed object context
        let context = appDelegate.coreDataStack.managedContext
        // Create a fetch request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Murals")
        fetchRequest.predicate = NSPredicate(format: "title = %@", mural.title)
        do {
            let results = try context.fetch(fetchRequest)
            for result in results as! [NSManagedObject] {
                result.setValue(mural.favourite, forKey: "favorite")
            }
            // Save the managed object context
            do {
                try context.save()
            } catch {
                print("Failed saving")
            }
        } catch {
            print("Failed to fetch mural data from core data")
        }
    }


    // This function is called before the view is displayed
    override func viewWillAppear(_ animated: Bool) {
        // Call the super class's implementation of this function
        super.viewWillAppear(animated)
        // Try to load the mural data from core data first
    }


    // add segue preparation code here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMural" {
            let destination = segue.destination as! InformationViewController
            let selectedRow = theTable.indexPathForSelectedRow!.row
            destination.mural = muralLocations[selectedRow]
        }
    }

    func mergeWithExistingMuralData(updatedMuralLocations: [MuralLocation]) {
        // Loop through the updated mural locations
        for updatedMural in updatedMuralLocations {
            // Loop through the existing mural locations
            var found = false
            for existingMural in muralLocations {
                // Check if the mural id's match
                if updatedMural.title == existingMural.title {
                    // Update the existing mural with the updated mural
                    existingMural.artist = updatedMural.artist
                    existingMural.info = updatedMural.info
                    existingMural.lat = updatedMural.lat
                    existingMural.lon = updatedMural.lon
                    existingMural.thumbnail = updatedMural.thumbnail
                    existingMural.title = updatedMural.title
                    existingMural.images = updatedMural.images

                    found = true
                }
            }
            // If the updated mural is not in the existing mural locations
            if !found {
                // Add the updated mural to the existing mural locations
                muralLocations.append(updatedMural)
            }
        }

    }

    fileprivate func loadMuralData(lastUpdated: String) {
        // Make a url string
        var urlString = ""
        if lastUpdated == "" {
            urlString = "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/nbm/data2.php?class=newbrighton_murals"
        } else {
            urlString = "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/nbm/data2.php?class=newbrighton_murals&lastModified=\(lastUpdated)"
        }
        // Make a rest call to get the mural locations
        let url = URL(string: urlString)
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print("ERROR")
            } else {
                if let content = data {
                    do {
                        let myJson = try JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                        
                        if let muralArray = myJson["newbrighton_murals"] as? NSArray {
                            // print the array length like this: "Array length: 3"
                            var updatedMuralLocations = [MuralLocation]()
                            // loop through the array
                            for mural in muralArray {
                                // cast the mural as a dictionary
                                if let muralDict = mural as? NSDictionary {
                                    // print the dictionary
                                    // create a new MuralLocation object
                                    let enabled = muralDict["enabled"] as! String
                                    if enabled == "1" {
                                        let newMural = MuralLocation()
                                        // set the properties of the new MuralLocation object
                                        // newMural.artist = muralDict["artist"] as! String
                                        if let artist = muralDict["artist"] as? String {
                                            newMural.artist = artist
                                        }
                                        let enabled = muralDict["enabled"] as! String
                                        if enabled == "1" {
                                            newMural.enabled = 1
                                        } else {
                                            newMural.enabled = 0
                                        }
                                        if let id = muralDict["id"] as? String {
                                            newMural.id = id
                                        }
                                        if let info = muralDict["info"] as? String {
                                            newMural.info = info
                                        }
                                        // newMural.lastModified = muralDict["lastModified"] as! String
                                        if let lastModified = muralDict["lastModified"] as? String {
                                            newMural.lastModified = lastModified
                                        }
                                        // newMural.lat = muralDict["lat"] as! String
                                        if let lat = muralDict["lat"] as? String {
                                            newMural.lat = lat
                                        }
                                        // newMural.lon = muralDict["lon"] as! String
                                        if let lon = muralDict["lon"] as? String {
                                            newMural.lon = lon
                                        }
                                        // newMural.thumbnail = muralDict["thumbnail"] as! String
                                        if let thumbnail = muralDict["thumbnail"] as? String {
                                            newMural.thumbnail = thumbnail
                                        }
                                        // newMural.title = muralDict["title"] as! String
                                        if let title = muralDict["title"] as? String {
                                            newMural.title = title
                                        }
                                        
                                        // get the images array from the dictionary
                                        if let imagesArray = muralDict["images"] as? NSArray {
                                            // loop through the images array
                                            for image in imagesArray {
                                                // cast the image as a dictionary
                                                if let imageDict = image as? NSDictionary {
                                                    if let filename = imageDict["filename"] as? String {
                                                        newMural.images.append(filename)
                                                    }
                                                }
                                            }
                                        }
                                        
                                        if (lastUpdated == ""){
                                            self.muralLocations.append(newMural)
                                        }
                                        else{
                                            updatedMuralLocations.append(newMural)
                                        }


                                    }
                                    else{
                                        print("Mural not enabled")
                                    }
                                }
                            }
                            
                            // Sort the muralLocations array by distance from the user's location, closest first. 
                            //Use lat and lon to create CLLocation objects, then use the distance function to calculate the 
                            //distance between the user's location and the mural location.
                            if (lastUpdated == ""){
                                self.muralLocations.sort(by: { (mural1, mural2) -> Bool in
                                    let mural1Location = CLLocation(latitude: Double(mural1.lat)!, longitude: Double(mural1.lon)!)
                                    let mural2Location = CLLocation(latitude: Double(mural2.lat)!, longitude: Double(mural2.lon)!)

                                    let uLocation = self.locationManager.location
                                    let distance1 = mural1Location.distance(from: uLocation!)
                                    let distance2 = mural2Location.distance(from: uLocation!)
                                    return distance1 < distance2
                                })
                            }
                            else {
                                self.mergeWithExistingMuralData(updatedMuralLocations: updatedMuralLocations)
                            }

                            // self.theTable.reloadData()
                        }
                    } catch {
                        print("ERROR")
                    }
                }
            }
        }
        task.resume()
    }


    // Do something before the loading of the view

    
    
    
}

