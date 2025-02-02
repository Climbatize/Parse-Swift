//: [Previous](@previous)

//: If you are using Xcode 13+, ignore the comments below:
//: For this page, make sure your build target is set to ParseSwift (iOS) and targeting
//: an iPhone, iPod, or iPad. Also be sure your `Playground Settings`
//: in the `File Inspector` is `Platform = iOS`. This is because
//: SwiftUI in macOS Playgrounds doesn't seem to build correctly
//: Be sure to switch your target and `Playground Settings` back to
//: macOS after leaving this page.

import PlaygroundSupport
import Foundation
import ParseSwift
import SwiftUI

PlaygroundPage.current.needsIndefiniteExecution = true

initializeParse()

//: Create your own value typed ParseObject.
struct GameScore: ParseObject {
    //: These are required by `ParseObject`.
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?

    //: Your own properties.
    var points: Int? = 0
    var location: ParseGeoPoint?
    var name: String?

    //: Implement your own version of merge
    func merge(with object: Self) throws -> Self {
        var updated = try mergeParse(with: object)
        if updated.shouldRestoreKey(\.points,
                                     original: object) {
            updated.points = object.points
        }
        if updated.shouldRestoreKey(\.name,
                                     original: object) {
            updated.name = object.name
        }
        if updated.shouldRestoreKey(\.location,
                                     original: object) {
            updated.location = object.location
        }
        return updated
    }
}

//: It's recommended to place custom initializers in an extension
//: to preserve the convenience initializer.
extension GameScore {
    //: Custom initializer.
    init(name: String, points: Int) {
        self.name = name
        self.points = points
    }
}

//: Be sure you have LiveQuery enabled on your server.

//: Create a query just as you normally would.
var query = GameScore.query("points" < 11)

//: To use subscriptions inside of SwiftUI
struct ContentView: View {

    //: A LiveQuery subscription can be used as a view model in SwiftUI
    @ObservedObject var subscription = query.subscribe!

    var body: some View {
        VStack {

            if subscription.subscribed != nil {
                Text("Subscribed to query!")
            } else if subscription.unsubscribed != nil {
                Text("Unsubscribed from query!")
            } else if let event = subscription.event {

                //: This is how you register to receive notifications of events related to your LiveQuery.
                switch event.event {

                case .entered(let object):
                    Text("Entered with points: \(String(describing: object.points))")
                case .left(let object):
                    Text("Left with points: \(String(describing: object.points))")
                case .created(let object):
                    Text("Created with points: \(String(describing: object.points))")
                case .updated(let object):
                    Text("Updated with points: \(String(describing: object.points))")
                case .deleted(let object):
                    Text("Deleted with points: \(String(describing: object.points))")
                }
            } else {
                Text("Not subscribed to a query")
            }

            Text("Update GameScore in Parse Dashboard to see changes here:")

            Button(action: {
                try? query.unsubscribe()
            }, label: {
                Text("Unsubscribe")
                    .font(.headline)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .padding()
                    .cornerRadius(20.0)
            })
            Spacer()
        }
    }
}

PlaygroundPage.current.setLiveView(ContentView())

PlaygroundPage.current.finishExecution()
//: [Next](@next)
