//
//  RecycleLogCollectionViewController.swift
//  FIT3175_assignment4
//
//  Created by Ishrat Kaur on 9/6/2023.
//

import UIKit
import CoreData

/**
 The class is responsible for displaying the the collection of cells containing images to the user. The class outlines the keys behaviours and properties of collection view customised to be displayed in a specific way for the app. The class also conforms to UIImagePickerControllerDelegate and UINavigationControllerDelegate
 */
class RecycleLogCollectionViewController: UICollectionViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    /**
     attributes
     */
    let CELL_IMAGE = "imageCell"
    var imageList = [UIImage]()
    var imagePathList = [String]()
    var selectedIndexPath: IndexPath? //
    var managedObjectContext: NSManagedObjectContext?
    
    /**
     The controls the display of elements of the collection view controller such as background colour of the collection view. The app is also responsible for tap gesture which will be used to delete images from collection view controller
     */
    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        managedObjectContext = appDelegate.persistentContainer?.viewContext

        collectionView.backgroundColor = .systemBackground
        collectionView.setCollectionViewLayout(generateLayout(), animated: false)

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
    
    /**
     the method is responsible for loading the screen to the user by ensuring that the data stored in teh core datat is correctly retrived.
     @param animanted which is a boolena value, true if changing should be animated, false otherwise
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

    /**
     method returns number of sections in the collection view. Ony one section is used
     @param: collectionView: collection view
     @return number of sections, which is 1
     */
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    /**
     The method returns Each collection stores as many cells as there are images
     @param: collectionView: collection view
     @return number images in the list of images
     */
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return imageList.count
    }

    /**
     The function is responsible for cell configuration.  It's responsibilities include dequeuing a reusable cell, configureing background color and updating index path
     @param: The collection view
     @param: indexPath: The index path of image whose cell is being configured
     @returns the configgured cell
     */
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

    /**
     function is responsible for taking a filename and attempting to load an image from file
     @param: filename which is a string which stores the name of image that is to be loaded
     @returns the UIImage after it is loaded
     */
    func loadImageData(filename: String) -> UIImage? {
        // get document directory
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        // add image file to directory path
        let imageURL = documentsDirectory.appendingPathComponent(filename)
        let image = UIImage(contentsOfFile: imageURL.path)
        return image
    }

    /**
     The method is responsible for configuring paramters for the layout of the collection view
     @returns UICollectionViewLayout, which is the general layout of the collection view
     */
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
    
    /**
     The method is responsible for checking the gesture is perfomed and once it is over, shows the delete akert to delete the photo upon which gesture action has been performed.
     @param: gestureRecognizer which recognises the gesture that has been performed by the user
     */
    @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        if gestureRecognizer.state == .ended {
            let tapLocation = gestureRecognizer.location(in: collectionView)
            if let indexPath = collectionView.indexPathForItem(at: tapLocation) {
                selectedIndexPath = indexPath
                showDeleteAlert()
            }
        }
    }

    /**
     the function is rsponisble for showing the delete alert following the gesture had been performed. Allows users to choose between Deleting and Saving a photo
     */
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

    /**
     The function is responsible for deleting an image from the collection view controller. The method also ensures that the image is also deleted from the core data
     */
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
}
