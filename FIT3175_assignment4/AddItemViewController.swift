//
//  AddItemViewController.swift
//  FIT3175_assignment4
//
//  Created by Ishrat Kaur on 9/6/2023.
//

import UIKit
import CoreData

/**
 The class is responsible for allowing users to add more items to their recycling log. The class allows users to take the picture oif the itme they wish to log and asks if they successfully recycled they item they are logging in using a segmented control. The class conforms to UIImagePickerControllerDelegate and UINavigationControllerDelegate
 */
class AddItemViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    /**
     attributes
     */
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    var managedObjectContext: NSManagedObjectContext?
    
    /**
     The controls the display of elements of the view controller.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate; managedObjectContext = appDelegate.persistentContainer?.viewContext
        animateEffect()
    }
    
    /**
     Method is invoked when user decides to take a photo by using ImageUIPickerController . the method also provides with an action sheet which offers three different solutions to get photo from callery in case there is no access to camera or if user simply wishes to
     */
    @IBAction func takePhoto(_ sender: Any) {
        let controller = UIImagePickerController()
        controller.allowsEditing = false
        controller.delegate = self
        let actionSheet = UIAlertController(title: nil, message: "Select Option:", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { action in controller.sourceType = .camera
        self.present(controller, animated: true, completion: nil)
        }
        let libraryAction = UIAlertAction(title: "Photo Library", style: .default) { action in controller.sourceType = .photoLibrary
        self.present(controller, animated: true, completion: nil)
        }
        let albumAction = UIAlertAction(title: "Photo Album", style: .default) { action in controller.sourceType = .savedPhotosAlbum
        self.present(controller, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        if UIImagePickerController.isSourceTypeAvailable(.camera) { actionSheet.addAction(cameraAction)
        }
        actionSheet.addAction(libraryAction)
        actionSheet.addAction(albumAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    /**
     the method checks if user has a valid photo selected and attempts where made to use the segment control to isRecycled property from core data. However, the method successfully converts the image taken by user to image url file
     */
    @IBAction func savePhoto(_ sender: Any) {
        guard let image = imageView.image else {
            displayMessage(title: "Error", message: "Cannot save until an image has been selected!")
                    return
                }
        let timestamp = UInt(Date().timeIntervalSince1970)
        let filename = "\(timestamp).jpg"
        
        guard let data = image.jpegData(compressionQuality: 0.8) else {
                    displayMessage(title: "Error", message: "Image data could not be compressed")
                    return
                }
        
        let pathsList = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = pathsList[0]
        let imageFile = documentDirectory.appendingPathComponent(filename)
                
        do {
            try data.write(to: imageFile)
            let imageEntity = NSEntityDescription.insertNewObject(forEntityName: "ImageMetaData", into: managedObjectContext!) as! ImageMetaData
            imageEntity.filename = filename
                    
            // Set the isRecycled attribute based on the selected segment index
            imageEntity.isRecycled = segmentControl.selectedSegmentIndex == 0
                    
            try managedObjectContext?.save()
            navigationController?.popViewController(animated: true)
                }
        catch {
            displayMessage(title: "Error", message: "\(error)")
                }
    }
    
    /**
     display message acts as a helper function to other classes that want to display an error
     @param: title, which is the title of the error message
     @oaram String, which is the message body of the error
     */
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    /**
     delegate function is used to create
     @param: infomration of the selected image
     */
    func imagePickerController(_ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
        imageView.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    // delegate function
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
