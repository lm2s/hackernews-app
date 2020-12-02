//
//  AppDelegate.swift
//  TheNews
//
//  Created by Luís Silva on 02/12/2020.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let persistenceController = PersistenceController()
        let networkService = NetworkService(baseURL: URL(string: "https://hacker-news.firebaseio.com/v0")!)
        let hackerNewsAPI = HackerNewsAPI(networkService: networkService, persistenceController: persistenceController)

        let postsViewController = PostListViewController(viewModel: PostListViewModel(hackerNewsAPI: hackerNewsAPI))

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController(rootViewController: postsViewController)
        window?.makeKeyAndVisible()

        return true
    }
}

