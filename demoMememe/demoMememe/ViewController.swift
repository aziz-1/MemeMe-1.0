//
//  ViewController.swift
//  demoMememe
//
//  Created by Reem Aldughaither on 4/3/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit

class ViewController: UIViewController,  UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var navBar: UIToolbar!
    @IBOutlet weak var shareNavItem: UIBarButtonItem!
    
    
    struct Meme{
        let topText: String
        let bottomText: String
        let originalImage: UIImage
        let editedImage: UIImage
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        shareNavItem.isEnabled = false
        prepareTextField(textField: topText)
        prepareTextField(textField: bottomText)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        subscribeToKeyboardNotifications()
        subscribeToKeyboardNotificationsHide()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func generateMemedImage() -> UIImage {
        
        setHidden(hide: true)
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // TODO: Show toolbar and navbar
      setHidden(hide: false)
        
        return memedImage
    }

    @IBAction func sharedMeme(_ sender: Any) {
        let sharedMeme = generateMemedImage()
        
        let activityController = UIActivityViewController(activityItems: [sharedMeme], applicationActivities: nil)
       
        
   
        activityController.completionWithItemsHandler = {
            (activity, done, items, error) in
            if(done && error == nil){
                //Do Work
                self.save()
                activityController.dismiss(animated: true, completion: nil)
            }
         
        }
        
        present(activityController, animated: true, completion: nil)
        
    }
    
    func save() {
        // Create the meme
        let memedImage: UIImage = generateMemedImage()
        _ = Meme(topText: topText.text!, bottomText: bottomText.text!, originalImage: imagePickerView.image!, editedImage: memedImage)
        
        
    }
    
    
    @IBAction func pickImage(_ sender: UIBarButtonItem) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = (sender.tag == 0) ? .photoLibrary : .camera
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Image picker did cancel")
    }
    

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage? {
           view.layoutIfNeeded()
            
            imagePickerView.image = image
            self.dismiss(animated: true, completion: nil)
            topText.isHidden = false
            bottomText.isHidden = false
            shareNavItem.isEnabled=true
        }
    }
    
    
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }

    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    func subscribeToKeyboardNotificationsHide() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if bottomText.isEditing{
        view.frame.origin.y -= getKeyboardHeight(notification)
        }
        
    }
    
    
    
    @objc func keyboardWillHide(_ notification:Notification) {
        
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    // called when 'return' key pressed. return NO to ignore
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        return textField.resignFirstResponder() //
        
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        switch textField {
        case topText:
            topText.text = ""
        case bottomText:
            bottomText.text = ""
        default:
            topText.text = topText.text
            bottomText.text = bottomText.text
   
        }
    }
    
    func setHidden(hide: Bool){
    toolbar.isHidden = hide
    navBar.isHidden = hide
    }
    
    func prepareTextField(textField: UITextField) {
        let memeTextAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.strokeColor: UIColor.black,
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedString.Key.strokeWidth:  -2.0
            
            
            
        ]
        
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
        textField.delegate = self
        textField.autocapitalizationType = .allCharacters
        
        
        
        
    }
}

