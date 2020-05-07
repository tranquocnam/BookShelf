//
//  CoredataAction.swift
//  BookShelf
//
//  Created by 西田 on 20/01/23.
//  Copyright © 2020 Nishida. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CoredataAtion {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let fetchReauest:NSFetchRequest<Books> = Books.fetchRequest()
    
    func saveAction(title: String, author: String, content: String, url: URL){
        let book = Books(context: context)
        let fetchData = try! context.fetch(fetchReauest)
            if let lastId = fetchData.first?.id{
                let incrementId = lastId + 1
            
                book.id = incrementId
                book.title = title
                book.author = author
                book.content = content
                book.bookImage = url
        
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
        }
    }
    
    func sortAction() {
        
        let sort = NSSortDescriptor(key: "id", ascending: false)
        fetchReauest.sortDescriptors = [sort]
        fetchReauest.fetchLimit = 1
    }
}
