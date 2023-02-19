//
//  MuralLocation.swift
//  UserLocation
//
//  Created by Mohammed Abdullah Alotaibi on 11/12/2022.
//

import Foundation


// Example data for the Mural Locations
// artist = "Ben Eine";
// enabled = 1;
// id = 1;
// images =             (
//                     {
//         filename = "IMG_1065X.JPG";
//         id = 1;
//     }
// );
// info = "Overlooking a secure car park Ben Eine's 'I See The Sea' is a bright neon yellow mural which is just pure fun. Known for his use of different typefaces he will often paint statements big and bold on walls he is asked to paint. If he's anything like me, growing up away from the seaside then the excited childish cry of 'I see the sea' was a familiar one when, on family trips, we got near the coast.";
// lastModified = "2022-11-21 12:02:37";
// lat = "53.43881250167621";
// lon = "-3.0416222190640183";
// thumbnail = "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/nbm_thumbs/IMG_1065X.JPG";
// title = "I See The Sea";


class MuralLocation {
    var artist: String
    var enabled: Int
    var id: String
    var images: [String]
    var info: String
    var lastModified: String
    var lat: String
    var lon: String
    var thumbnail: String
    var title: String
    var imageData: Data?
    var favourite: Bool = false

    init(artist: String, enabled: Int, id: String, images: [String], info: String, lastModified: String, lat: String, lon: String, thumbnail: String, title: String) {
        self.artist = artist
        self.enabled = enabled
        self.id = id
        self.images = images
        self.info = info
        self.lastModified = lastModified
        self.lat = lat
        self.lon = lon
        self.thumbnail = thumbnail
        self.title = title
    }

    init() {
        self.artist = ""
        self.enabled = 0
        self.id = "0"
        self.images = []
        self.info = ""
        self.lastModified = ""
        self.lat = ""
        self.lon = ""
        self.thumbnail = ""
        self.title = ""
    }

    func printMuralLocation() {
        print("artist: \(artist)")
        print("enabled: \(enabled)")
        print("id: \(id)")
        print("images: \(images)")
        print("info: \(info)")
        print("lastModified: \(lastModified)")
        print("lat: \(lat)")
        print("lon: \(lon)")
        print("thumbnail: \(thumbnail)")
        print("title: \(title)")
        print("favourite: \(favourite)")
    }
}

