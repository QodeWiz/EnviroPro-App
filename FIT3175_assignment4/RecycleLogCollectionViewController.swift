//
//  RecycleLogCollectionViewController.swift
//  FIT3175_assignment4
//
//  Created by Ishrat Kaur on 9/6/2023.
//

import UIKit
import CoreData

// properties
let CELL_IMAGE = "imageCell"
var imageList = [UIImage]()
var imagePathList = [String]()
var selectedIndexPath: IndexPath? //
var managedObjectContext: NSManagedObjectContext?

class RecycleLogCollectionViewController: UICollectionViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        managedObjectContext = appDelegate.persistentContainer?.viewContext
        
        
        collectionView.backgroundColor = .systemBackground
        collectionView.setCollectionViewLayout(generateLayout(), animated: false)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        
        // Do any additional setup after loading the view.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        collectionView.addGestureRecognizer(tapGesture)

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        do {
            // Fetch all ImageMetaData from Core Data
            let fetchRequest: NSFetchRequest<ImageMetaData> = ImageMetaData.fetchRequest()
            let imageDataList = try managedObjectContext!.fetch(fetchRequest)
            
            for data in imageDataList {
                let filename = data.filename!
                
                if imagePathList.contains(filename) {
                    print("Image Already loaded. Skipping image")
                    continue
                }
                
                // Load image using loadImageData function
                if let image = loadImageData(filename: filename) {
                    imageList.append(image)
                    imagePathList.append(filename)
                    collectionView.reloadSections([0])
                }
            }
        } catch {
            print("Unable to fetch images")
        }
    }



    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        
        return imageList.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CELL_IMAGE, for: indexPath) as! ImageCollectionViewCell
        
        // Configure the cell
        cell.backgroundColor = selectedIndexPath == indexPath ? .systemRed : .secondarySystemFill
        cell.imageView.image = imageList[indexPath.item]
        
        // for selected photo
        selectedIndexPath = indexPath
        collectionView.reloadItems(at: [indexPath])
        return cell
    }

    // function is responsible for taking a filename and attempting to load an image from file
        func loadImageData(filename: String) -> UIImage? {
            // get document directory
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let documentsDirectory = paths[0]
            
            // add image file to directory path
            let imageURL = documentsDirectory.appendingPathComponent(filename)
            let image = UIImage(contentsOfFile: imageURL.path)
            return image
        }

    
    // generate layout
    func generateLayout() -> UICollectionViewLayout {
        
        let imageItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
        
        let imageItem = NSCollectionLayoutItem(layoutSize: imageItemSize)
        imageItem.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2,
            bottom: 2, trailing: 2)
        
        let imageGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(1/3))
        
        let imageGroup = NSCollectionLayoutGroup.horizontal(layoutSize: imageGroupSize, subitems: [imageItem])
        
        let imageSection = NSCollectionLayoutSection(group: imageGroup)
        
        return UICollectionViewCompositionalLayout(section: imageSection)
    }
    

    @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        if gestureRecognizer.state == .ended {
            let tapLocation = gestureRecognizer.location(in: collectionView)
            if let indexPath = collectionView.indexPathForItem(at: tapLocation) {
                selectedIndexPath = indexPath
                showDeleteAlert()
            }
        }
    }

    func showDeleteAlert() {
        let alert = UIAlertController(title: "Delete Photo", message: "Are you sure you want to delete this photo?", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteImage()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }

    func deleteImage() {
        guard let indexPath = selectedIndexPath else { return }
        
        // Delete the image from Core Data
        let filename = imagePathList[indexPath.item]
        
        let fetchRequest: NSFetchRequest<ImageMetaData> = ImageMetaData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "filename == %@", filename)
        
        do {
            let results = try managedObjectContext!.fetch(fetchRequest)
            if let imageMetaData = results.first {
                managedObjectContext!.delete(imageMetaData)
                try managedObjectContext!.save()
            }
        } catch {
            print("Unable to delete image from Core Data: \(error)")
        }
        
        // Delete the image file from the document directory
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imageURL = documentsDirectory.appendingPathComponent(filename)
        
        do {
            try fileManager.removeItem(at: imageURL)
        } catch {
            print("Unable to delete image file: \(error)")
        }
        
        // Remove the image from the data source
        imageList.remove(at: indexPath.item)
        imagePathList.remove(at: indexPath.item)
        
        // Reset the selected index path and reload the collection view
        selectedIndexPath = nil
        collectionView.reloadData()
    }

    
        
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
