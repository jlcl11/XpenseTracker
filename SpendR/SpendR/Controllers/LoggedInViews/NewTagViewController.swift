//
//  NewTagViewController.swift
//  SpendR
//
//  Created by José Luis Corral on 29/11/23.
//

import UIKit

class NewTagViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var nametextField: UITextField!
    @IBOutlet weak var colorWell: UIColorWell!
    @IBOutlet weak var colorLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        colorWell.addTarget(self, action: #selector(colorWellChangedColor(_:)), for: .valueChanged)

        imagePicker.delegate = self
        imagePicker.allowsEditing = false
    }

    @objc func colorWellChangedColor(_ sender: UIButton) {
        colorLabel.textColor = colorWell.selectedColor
    }
 
    @IBAction func pickImage(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    

    // MARK: - UIImagePickerControllerDelegate

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = pickedImage
        }

        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func saveTag(_ sender: Any) {
        // Aquí puedes agregar la lógica para guardar el nuevo tag con el nombre, color y la imagen seleccionada.
        // Puedes acceder a la imagen seleccionada a través de 'imageView.image'.
    }
}
