import UIKit
import Foundation
import Darwin

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Data model: These strings will be the data for the table view cells
    var messages: [Message]? = nil
    let db = WADBReader.main
    var chat: Chat? = nil
    var messageForSegue: Message? = nil
    
    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "cell"
    
    // don't forget to hook this up from the storyboard
    @IBOutlet var tableView: UITableView!
    
    func setChat(_ chat: Chat)
    {
        self.chat = chat
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register the table view cell class and its reuse id
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        
        // This view controller itself will provide the delegate methods and row data for the table view.
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Read DB asynchronously
        DispatchQueue.main.async {
            self.messages = self.db.getMessagesForChat(self.chat!)
            self.tableView.reloadData()
        }
    }
    
    @objc func addTapped()
    {
        messageForSegue = self.db.addMessage(for: self.chat!)
        
        performSegue(withIdentifier: "messageSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "messageSegue"
        {
            let vc = segue.destination as! MessageViewController
            vc.setMessage(messageForSegue!)
        }
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages?.count ?? 0
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create a new cell if needed or reuse an old one
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell!
        
        guard let message = self.messages?[indexPath.row] else {
            return cell
        }
        
        // set the text from the data model
        cell.textLabel?.text = message.content ?? ""
        
        // Color the background according to the sender.
        if (message.isFromMe)
        {
            cell.backgroundColor = UIColor.init(red: 220/255.0, green: 248/255.0, blue: 198/255.0, alpha: 1)
        }
        else
        {
            cell.backgroundColor = UIColor.init(red: 236/255.0, green: 229/255.0, blue: 221/255.0, alpha: 1)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        messageForSegue = messages![indexPath.row]
        self.performSegue(withIdentifier: "messageSegue", sender: self)
    }
}
