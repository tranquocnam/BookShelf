//
//  ViewController.swift
//  BookShelf
//
//  Created by 西田 on 19/12/25.
//  Copyright © 2019 Nishida. All rights reserved.
//

import UIKit
import CoreData
import SDWebImage
import Alamofire

class ViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UISearchBarDelegate{

    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var searchBarField: UISearchBar!
    
    var books:[Books] = []
    
   let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let fetchRequest:NSFetchRequest<Books> = Books.fetchRequest()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBarField.delegate = self
        searchBarField.enablesReturnKeyAutomatically = false
        
        collection.delegate = self
        collection.dataSource = self
        collection.register(UINib(nibName: "CustomCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        let layout = UICollectionViewFlowLayout()
        
        collection.collectionViewLayout = layout
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
        
        getdata()
        collection.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return books.count
       }
       
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CustomCell
        let book = books[indexPath.row]
        cell.bookImage.sd_setImage(with: book.bookImage, completed: nil)
        return cell
       }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let horizontalSpace: CGFloat = 20
        let cellWidth: CGFloat = self.view.bounds.width/4 - horizontalSpace
        let cellHight: CGFloat = self.view.bounds.height/5 - horizontalSpace
        return CGSize(width: cellWidth, height: cellHight)
    }
    
    func getdata(){
        
        let sort = NSSortDescriptor(key: "id", ascending: false)
        fetchRequest.sortDescriptors = [sort]

        do {
            books = try context.fetch(fetchRequest)
        } catch {
            print("Error")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let indexNumber = books[indexPath.row].id
        let detailsVC = storyboard?.instantiateViewController(identifier: "details") as! DetailsViewController
        detailsVC.count = Int(indexNumber)
        navigationController?.pushViewController(detailsVC, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBarField.endEditing(true)
        books.removeAll()
        
        if searchBarField.text != "" {
            fetchRequest.predicate = NSPredicate(format: "title CONTAINS %@", searchBarField.text!)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: false, selector: #selector(NSString.localizedStandardCompare(_:)))]
            
        } else {
            fetchRequest.predicate = NSPredicate(format: "title != %@", "a")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        }
        do {
            books =  try context.fetch(fetchRequest)
        } catch  {
            print("error")
        }
        collection.reloadData()
    }
    
    @IBAction func barcodeNext(_ sender: Any) {
        performSegue(withIdentifier: "barcode", sender: nil)
    }
    @IBAction func magniNext(_ sender: Any) {
        performSegue(withIdentifier: "magni", sender: nil)
    }
}

