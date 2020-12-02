//
//  PostListViewController.swift
//  TheNews
//
//  Created by Luís Silva on 02/12/2020.
//

import UIKit
import SafariServices

class PostListViewController: UIViewController {
    lazy var tableView: UITableView = UITableView()

    let viewModel: PostListViewModel

    init(viewModel: PostListViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Hacker News"

        setupNavigationBar()
        setupViews()

        viewModel.delegate = self
    }

    private var isFirstAppearance: Bool = true
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if isFirstAppearance {
            isFirstAppearance = false

            if viewModel.posts.isEmpty {
                viewModel.fetchPosts()
            }
        }
    }

    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh(_:)))
    }

    private func setupViews() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        tableView.register(PostCell.self, forCellReuseIdentifier: PostCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc
    private func refresh(_ sender: Any) {
        viewModel.fetchPosts()
    }
}

// MARK: - PostListViewModelDelegate
extension PostListViewController: PostListViewModelDelegate {
    func postListViewModelDidLoadPosts(_ posts: [Network.Model.Post]) {
        tableView.reloadData()
    }

    func postListViewModelLoadFailed(_ error: HackerNewsAPIError) {

    }
}

// MARK: - UITableViewDataSource
extension PostListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PostCell = tableView.dequeueReusableCell(withIdentifier: PostCell.identifier, for: indexPath) as! PostCell

        PostCell.configureCell(cell, post: viewModel.posts[indexPath.row])

        return cell
    }
}

// MARK: - UITableViewDelegate
extension PostListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = viewModel.posts[indexPath.row]
        let safariViewController = SFSafariViewController(url: post.url)

        present(safariViewController, animated: true, completion: nil)

        tableView.deselectRow(at: indexPath, animated: false)
    }
}
