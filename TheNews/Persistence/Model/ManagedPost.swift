//
//  ManagedPost.swift
//  TheNews
//
//  Created by Luís Silva on 02/12/2020.
//

import Foundation
import CoreData

class ManagedPost: NSManagedObject {
    @NSManaged public var id: Int64
    @NSManaged public var createdAt: NSDate
    @NSManaged public var title: String
    @NSManaged public var url: String
    @NSManaged public var score: Int64
    @NSManaged public var comments: NSArray
    @NSManaged public var index: Int64
}

extension ManagedPost {
    static func fetchAll(in context: NSManagedObjectContext) -> [ManagedPost] {
        let request = NSFetchRequest<ManagedPost>(entityName: "Post")
        request.sortDescriptors = [NSSortDescriptor(key: "index", ascending: true)]
        let posts = try? context.fetch(request)
        return posts ?? []
    }
}

@objc(CommentsValueTransformer)
final class CommentsValueTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass {
        return NSArray.self
    }

    override class func allowsReverseTransformation() -> Bool {
        return true
    }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let array = value as? NSArray else { return nil }

        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: array, requiringSecureCoding: true)
            return data
        }
        catch {
            assertionFailure("Failed to convert Array to Data")
            return nil
        }
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? NSData else { return nil }

        do {
            let array = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: data as Data)
            return array
        }
        catch {
            assertionFailure("Failed to transform Data to Array")
            return nil
        }
    }
}

extension CommentsValueTransformer {
    static let name = NSValueTransformerName(String(describing: CommentsValueTransformer.self))

    static func register() {
        let transformer = CommentsValueTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}
