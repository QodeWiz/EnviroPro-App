//
//  AddItemViewController.swift
//  FIT3175_assignment4
//
//  Created by Ishrat Kaur on 9/6/2023.
//

import UIKit
import CoreData

class AddItemViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    var managedObjectContext: NSManagedObjectContext?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate; managedObjectContext = appDelegate.persistentContainer?.viewContext
        animateEffect()
    }
    
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
    
    // dispaly message function
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    // delegate function
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

    func animateEffect() {
        let layer = CAEmitterLayer()
        layer.emitterPosition = CGPointMake(view.center.x, -200)
        
        let cell = CAEmitterCell()
        cell.emissionRange = (22/7)*2
        cell.lifetime = 4
        cell.alphaSpeed = 8
        cell.contents = UIImage(named: "white")!.cgImage
        cell.velocity = 20
        cell.color = { UIColor.green }().cgColor
        
        view.layer.addSublayer(layer)
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
