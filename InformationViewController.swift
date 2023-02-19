//
//  InformationViewController.swift
//  UserLocation
//
//  Created by Mohammed Abdullah Alotaibi on 12/12/2022.
//

import UIKit

class InformationViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var topTitle: UILabel!
    @IBOutlet weak var topArtist: UILabel!
    @IBOutlet weak var topInfo: UILabel!
    // @IBOutlet weak var topImages: UIStackView!
    
    // Mural
     var mural: MuralLocation?

    override func viewDidLoad() {
        super.viewDidLoad()
        topTitle.text = "Title: \(mural?.title ?? "No Title")"
        topArtist.text = "Artist: \(mural?.artist ?? "No Artist")"
        topInfo.text = "Info: \(mural?.info ?? "No Info")"
        
        
        let screenSize = UIScreen.main.bounds.size
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height

        // Do any additional setup after loading the view, typically from a nib
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        // layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
        let size = Int((collectionView.bounds.width))
        layout.itemSize = CGSize(width: size, height: size)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView!.collectionViewLayout = layout
        // set high score stack corner radius
        // collectionView.layer.cornerRadius = 10
        
        
        collectionView.dataSource = self
        // Do any additional setup after loading the view.
    }

    // func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

    //     let noOfCellsInRow = 1

    //     let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout

    //     let totalSpace = flowLayout.sectionInset.left
    //         + flowLayout.sectionInset.right
    //         + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))

    //     let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))

    //     return CGSize(width: size, height: size)
    // }

    // collection view stuff
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mural!.images.count
    }
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout:
    UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout:
    UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    // func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout:
    // UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    //     let theSize = CGSize(width: 10.0, height: 15.0)
    //     return theSize
    // }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell", for: indexPath) as! MyCellCollectionViewCell
        let image = mural!.images[indexPath.row]

        let url = URL(string: "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/nbm_images/" + image)
        // Load the image asynchronosly
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                cell.theImage.image = UIImage(data: data)
            }
        }
        task.resume()

        return cell
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
