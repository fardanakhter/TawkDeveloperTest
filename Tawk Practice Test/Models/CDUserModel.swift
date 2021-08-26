//
//  UserModel.swift
//  Tawk Practice Test
//
//  Created by Fardan Akhter on 8/19/21.
//
import Foundation
import CoreData

// MARK: - CDUserModel
// Parses Json response + CoreData entry
class CDUserModel: CDModel{
    
    @NSManaged var login: String?
    @NSManaged var id: NSNumber?
    @NSManaged var avatarURL: String?
    @NSManaged var name: String?
    @NSManaged var company: String?
    @NSManaged var blog: String?
    @NSManaged var followers: NSNumber?
    @NSManaged var following: NSNumber?
    @NSManaged var hasNote: NSNumber?
    @NSManaged var note: String?

    enum CodingKeys: String, CodingKey {
        case login, id
        case avatarURL = "avatar_url"
        case name, company, blog
        case followers, following
        case hasNote, note
    }
    
    // MARK:- Init Entity
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {

        guard let _ = context,
              let user = NSEntityDescription.entity(forEntityName: CoreDataEntity.user.rawValue,
                                                          in: context!)
        else{
            fatalError("Failed to decode entity")
        }
        // creates new model and inserts into context
        super.init(entity: user, insertInto: context)
    }
    
    // MARK:- Decodable
    override func decode(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.login = try container.decodeIfPresent(String.self, forKey: .login)
        self.id = try container.decodeIfPresent(Int.self, forKey: .id) as NSNumber?
        self.avatarURL = try container.decodeIfPresent(String.self, forKey: .avatarURL) ?? ""
        self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        self.company = try container.decodeIfPresent(String.self, forKey: .company) ?? ""
        self.blog = try container.decodeIfPresent(String.self, forKey: .blog) ?? ""
        self.followers = try container.decodeIfPresent(Int.self, forKey: .followers) as NSNumber?
        self.following = try container.decodeIfPresent(Int.self, forKey: .following) as NSNumber?
        
        self.hasNote = false
        self.note = nil
    }
    
    // MARK: - Encodable
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id as? Int, forKey: .id)
        try container.encode(login, forKey: .login)
        try container.encode(avatarURL, forKey: .avatarURL)
        try container.encode(name, forKey: .name)
        try container.encode(company, forKey: .company)
        try container.encode(blog, forKey: .blog)
        try container.encode(followers as? Int, forKey: .followers)
        try container.encode(following as? Int, forKey: .following)
        
        try container.encode(hasNote as? Int, forKey: .hasNote)
        try container.encode(note, forKey: .note)
    }
    
    func printDescription(){
        print("**********",type(of: self),"**********")
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            print(child.label ?? "", child.value)
        }
        print("**********","**********","**********")
    }
    
    func clone(model: CDUserModel){
        self.login = model.login
        self.id = model.id
        self.avatarURL = model.avatarURL
        self.name = model.name
        self.company = model.company
        self.blog = model.blog
        self.followers = model.followers
        self.following = model.following
        
        //self.hasNote = model.hasNote
        //self.note = model.note
    }
}
