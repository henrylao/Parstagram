//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Henry Lao on 3/19/21.
//

import UIKit
import Parse
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {
    var TAG = "FeedView"
    var isMorePostsToLoad = true
    var posts = [PFObject]()
    var showsCommentBar = false
    var selectedPost: PFObject!
    
    
    let refreshFeed = UIRefreshControl()
    let commentBar = MessageInputBar()
    
    override var inputAccessoryView: UIView?{
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool{
        return showsCommentBar
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func onLogout(_ sender: Any) {
        print(TAG, "onLogout")
        PFUser.logOut()
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
        let delegate = self.view.window?.windowScene?.delegate as! SceneDelegate
        
        delegate.window?.rootViewController = loginViewController
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.section]
        
        let comments = (post["comment"] as?  [PFObject]) ?? []
        if indexPath.row == comments.count + 1 {
            showsCommentBar = true
            becomeFirstResponder()
            
            commentBar.inputTextView.becomeFirstResponder()
            selectedPost = post
        }

        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return posts.count
        let post = posts[section]
        let comments = ( post["comment"] as? [PFObject]) ?? []
        return 2 + comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.section]
        let comments = (post["comment"] as? [PFObject]) ?? []
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
            
            let user = post["user"] as! PFUser
            cell.userLabel.text = user.username
            cell.descriptionLabel.text = post["description"] as? String

            let imageFile = post["image"] as! PFFileObject
            let urlString = imageFile.url!
            let url = URL(string: urlString)!
            cell.photoView.af.setImage(withURL: url)
            return cell
        }
        // assuming existence of 1 comment
        // then 0 is post, 1 is comment ==> indexpath.row = 2
        else if indexPath.row <= comments.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            let comment = comments[indexPath.row - 1]
            let user = comment["user"] as! PFUser
            
            cell.nameLabel.text = user.username
            cell.commentLabel.text = comment["text"] as? String
            return cell
        }
        // if indexPath.row > comments.count
        else  {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            return cell
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // setup table view
        tableView.delegate = self
        tableView.dataSource = self
        // setup comment bar to pop up from bottom
        tableView.keyboardDismissMode = .interactive
        commentBar.inputTextView.placeholder = "Add a comment..."
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self
        // bind user action to a function call for loading more elements
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        refreshFeed.addTarget(self, action: #selector(loadPosts), for: .valueChanged)
        tableView.refreshControl = refreshFeed
        self.tableView.rowHeight = UITableView.automaticDimension

        // Do any additional setup after loading the view.
        
    }
    
    @objc func keyboardWillBeHidden(note: Notification){
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        // Create the comment
        let comment = PFObject(className: "Comment")
        comment["text"] = text
        comment["post"] = selectedPost
        comment["user"] = PFUser.current()!

        selectedPost.add(comment, forKey: "comment")

        selectedPost.saveInBackground {
            (success, error) in
            if (success) {
                print(self.TAG, "random comment saved")
            }
            else {
                print(self.TAG, "random comment no saved")
            }
        }
        tableView.reloadData()
        // Clear and dismiss the input bar
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // initial feed setup
        loadPosts()
    }
    
    @objc func loadPosts(){
        let query = PFQuery(className: "Post")
        query.includeKeys(["user","comment", "comment.user"])
        query.order(byDescending: "createdAt")

        query.limit = 20
        
        query.findObjectsInBackground{
            (posts, error) in
            if posts != nil {
                self.posts=posts!
                self.tableView.reloadData()
                self.refreshFeed.endRefreshing()
            }
        }

    }
    
    // endless scroller
    // table signal to load more posts
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section + 1 == posts.count && isMorePostsToLoad{
            print(TAG, "Endless Scroller: Attempting to load more posts")
            self.loadMorePosts(lastIndex: indexPath.section)
        }
    }
    
    // endless scroller query handler
    func loadMorePosts(lastIndex: Int){
        let query = PFQuery(className: "Post")
        query.includeKeys(["user", "comment"])
        query.order(byDescending: "createdAt")
        query.skip = posts.count
        query.limit = 20
        
        query.findObjectsInBackground{
            (posts, error) in
            if posts != nil && posts!.count > 0{
//                posts = posts! as [PFObject]
//                self.posts.removeAll()
                self.posts.append(contentsOf: posts!)
                self.tableView.reloadData()
                self.refreshFeed.endRefreshing()
            }
            else {
                self.isMorePostsToLoad = false
                print(self.TAG, "Load More: No more posts available in database to load!")
            }
        }


    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
