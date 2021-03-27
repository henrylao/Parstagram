//
//  CameraViewController.swift
//  Parstagram
//
//  Created by Henry Lao on 3/19/21.
//
import AlamofireImage
import UIKit
import Parse

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var TAG = "CameraView"

    @IBOutlet weak var descriptionField: UITextField!
   
    @IBOutlet weak var imageCaptureView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onSubmit(_ sender: Any) {
        print(self.TAG, "Submit button clicked!")
        let post = PFObject(className: "Post")
        
        post["description"] = descriptionField.text
        post["user"] = PFUser.current()
        
        let imageData = imageCaptureView.image!.pngData()
        let file = PFFileObject(data: imageData!)
        
        post["image"] = file
        
        post.saveInBackground {(success,error) in
            if success {
                print(self.TAG, "Successfully posted!")
                self.dismiss(animated: true, completion: nil)
                
            } else {
                
            }
        }
    }
    @IBAction func onCameraTapGesture(_ sender: Any) {
        let picker = UIImagePickerController()
        // when user is done taking photo let the picker be called on a function that contains the photo
        picker.delegate = self
        // present second screen to user after image capture completion
        picker.allowsEditing = true
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }
        
        // show the photo album
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        let size = CGSize(width: 300, height: 300)
        let scaledImage = image.af.imageAspectScaled(toFill: size)
        imageCaptureView.image = scaledImage
        dismiss(animated: true, completion: nil)
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
