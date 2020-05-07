//
//  SearchBookViewController.swift
//  BookShelf
//
//  Created by 西田 on 20/01/06.
//  Copyright © 2020 Nishida. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage

class SearchBookViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var saveBtn: UIBarButtonItem!
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var bookImage: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var content: UITextView!
    var authors: [String] = []
    
    var coredataAction = CoredataAtion()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchTextField.delegate = self
        navigationController?.isNavigationBarHidden = false
        saveBtn.isEnabled = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.resignFirstResponder()
    }
    
    func found(keyword: String){
        
        let text = "https://www.googleapis.com/books/v1/volumes?q=\(keyword)"

        let url = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON { (response) in
                
            switch response.result{
            case.success:
                self.authors = []
                let json:JSON = JSON(response.data as Any)
                let title = json["items"][0]["volumeInfo"]["title"].string
                for i in 0...2{
                let author = json["items"][0]["volumeInfo"]["authors"][i].string
                    if author != nil{
                        self.authors.append(author!)
                    }
                }
                let content = json["items"][0]["volumeInfo"]["description"].string
                let imageURL = json["items"][0]["volumeInfo"]["imageLinks"]["thumbnail"].string
                
                self.label.text = title
                self.author.text = self.authors.joined(separator: ",")
                self.content.text = content
                self.bookImage.sd_setImage(with: URL(string: imageURL!), completed: nil)
                break
                
            case .failure(let error):
                print(error)
                break
            }
        }
    }
    
    @IBAction func search(_ sender: Any) {
        
        found(keyword: searchTextField.text!)
        searchTextField.resignFirstResponder()
        saveBtn.isEnabled = true
    }
    
    @IBAction func save(_ sender: Any) {
    
        coredataAction.sortAction()
        coredataAction.saveAction(title: label.text!, author: author.text!, content: content.text, url: bookImage.sd_imageURL!)
        
        self.navigationController?.popViewController(animated: true)
    }
}
