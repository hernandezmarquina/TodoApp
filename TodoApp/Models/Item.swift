//
//  Item.swift
//  TodoApp
//
//  Created by Jonathan Hernandez on 12/20/17.
//  Copyright © 2017 Jonathan Hdez. All rights reserved.
//

import Foundation

class Item : Encodable, Decodable {
    
    var title : String = ""
    var done : Bool = false
    
}
