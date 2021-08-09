//
//  ViewController.swift
//  WhatFlower
//
//  Created by Daniel Ghebrat on 09/05/2021.
//

import UIKit
import CoreML
import Vision
import Alamofire
import SwiftyJSON
import SDWebImage

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let wikipediaURL = "https://en.wikipedia.org/w/api.php"
    let imagePickerController = UIImagePickerController()
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickerImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
           
            guard let convertedCIImage = CIImage(image: userPickerImage) else {
                fatalError("could not convert")
            }
            detect(image: convertedCIImage)
            imageView.image = userPickerImage
            
        }
        imagePickerController.dismiss(animated: true, completion: nil)
    }
    
    
    func detect (image : CIImage){
        guard let model = try? VNCoreMLModel(for: FlowerClassifier().model) else { fatalError("cannot import model") }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let classification = request.results?.first as? VNClassificationObservation else { print("could not classify image"); return }
//            let urlString = "\(self.wikipediaURL)\(classification.identifier.capitalized)"
//            let finalUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            self.requestInfo(flowerName: classification.identifier)
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        } catch  {
            fatalError("could not load")
        }
        
       
        
    }
    
//    func getData(completionHandler : @escaping (WikipediaAPIResponse) -> Void, url : String){
//        let url = URL(string: url)!
//        URLSession.shared.dataTask(with: url) { data, response, error in
//            guard let data = data else { return }
//            do {
//                let postsData = try JSONDecoder().decode(WikipediaAPIResponse.self, from: data)
//                completionHandler(postsData)
//            }catch{
//                let error = error
//                print(error.localizedDescription)
//            }
//        }.resume()
//    }
    
    func requestInfo (flowerName : String){
        
        let parameters : [String : String] = [
            "format" : "json",
            "action" : "query",
            "prop" : "extracts|pageimages",
            "exintro" : "",
            "explaintext" : "",
            "titles" : flowerName,
            "indexpageids" : "",
            "redirects" : "1",
            "pithumbsize" : "700"
        ]
        
        Alamofire.request(wikipediaURL, method: .get, parameters: parameters).responseJSON { response in
            if response.result.isSuccess {
                print("got wikipedia info")
                let flowerJSON : JSON = JSON(response.result.value!)
                let pageid = flowerJSON["query"]["pageids"][0].stringValue
                let flowerDescription = flowerJSON["query"]["pages"][pageid]["extract"].stringValue
                let flowerImageURL = flowerJSON["query"]["pages"][pageid]["thumbnail"]["source"].stringValue
                self.nameLabel.text = flowerDescription
                self.imageView.sd_setImage(with: URL(string: flowerImageURL), completed: nil)
                print(flowerDescription)
                
                
            }
        }
    }
    

    @IBAction func cameraPressed(_ sender: UIBarButtonItem) {
        
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
}

