//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Henry Lao on 3/19/21.
//

import UIKit
import Parse

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var TAG = "Feed"
    var posts = [PFObject]()
    var numberOfPosts: Int!
    let refreshFeed = UIRefreshControl()
    
    @IBOutlet weak var tableView: UITableView!
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
//        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        
        let post = posts[indexPath.row]
        let user = post["user"] as! PFUser
        cell.userLabel.text = user.username
        cell.descriptionLabel.text = post["description"] as? String

        let imageFile = post["image"] as! PFFileObject
        let urlString = imageFile.url!
        let url = URL(string: urlString)!
        cell.photoView.af.setImage(withURL: url)
//        cell.userLabel.text = "Hello World"
//        cell.descriptionLabel.text = "Goodbye World"
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // setup table view
        tableView.delegate = self
        tableView.dataSource = self
        
        // bind user action to a function call for loading more elements
        refreshFeed.addTarget(self, action: #selector(loadPosts), for: .valueChanged)
        tableView.refreshControl = refreshFeed
        self.tableView.rowHeight = UITableView.automaticDimension

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadPosts()
    }
    @objc func loadPosts(){
        let query = PFQuery(className: "Post")
        query.includeKey("user")
        query.limit = 20
        
        query.findObjectsInBackground{
            (posts, error) in
            if posts != nil {
//                posts = posts! as [PFObject]
//                self.posts.removeAll()
                self.posts=posts!
                self.tableView.reloadData()
                self.refreshFeed.endRefreshing()
            }
        }

    }
    
    // endless scroller
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if indexPath.row + 1 == posts.count{
//            print(TAG, "loading more posts")
////            self.loadMorePosts()
//        }
//    }
    
//
//    func loadMorePosts(){
//        numberOfPosts += 20
////        let payload = [
////            "count":numberOfTweets
////        ]
//        TwitterAPICaller.client?.getDictionariesRequest(url: self.timelineBaseUrl, parameters: payload, success: { (tweets : [NSDictionary]) in
//            self.tweetArray.removeAll()
//            for t in tweets{
//                self.tweetArray.append(t)
//            }
//            self.tableView.reloadData()
//            print(self.TAG, "successfully reloaded cell data")
//            self.refreshTweets.endRefreshing()
//            print(self.TAG,"successfully ended refreshing")
//
//        }, failure: {_  in
//            print(self.TAG,"failed to load more tweets")
//        })
//
//    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
