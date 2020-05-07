//
//  DetailsViewController.swift
//  BookShelf
//
//  Created by 西田 on 19/12/27.
//  Copyright © 2019 Nishida. All rights reserved.
//

import UIKit
import CoreData
import SDWebImage

class DetailsViewController: UIViewController {
    
     let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var count = Int()
    var book:[Books] = []
    
    @IBOutlet weak var bookDetailImage: UIImageView!
    @IBOutlet weak var bookDetailTitle: UILabel!
    @IBOutlet weak var bookDetailAuthor: UILabel!
    @IBOutlet weak var bookDetailContent: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = false
        
        getdata()
        
        bookDetailTitle.text = book[0].title
        bookDetailAuthor.text = book[0].author
        bookDetailContent.text = book[0].content
        bookDetailImage.sd_setImage(with: book[0].bookImage, completed: nil)
    }
    
    func getdata(){
        let request:NSFetchRequest<Books> = Books.fetchRequest()
        request.predicate = NSPredicate(format: "id = %d", count)
                
            do {
                book =  try context.fetch(request)
            } catch  {
                print("error")
            }
       }
    
    @IBAction func trash(_ sender: Any) {
       let deleteBook = book[0]
        context.delete(deleteBook)
        do {
            book = try context.fetch(Books.fetchRequest())
        } catch {
            print("Error")
        }
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        self.navigationController?.popViewController(animated: true)
    }
}
