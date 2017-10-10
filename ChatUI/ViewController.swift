//
//  ViewController.swift
//  ChatUI
//
//  Created by apple on 09/10/17.
//  Copyright © 2017 SK. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var bottomSpace: NSLayoutConstraint!
    @IBOutlet weak var bottomMargin: NSLayoutConstraint!
    var messages:[Messages]?
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchmessages()
        
        // Add observer for get the height of the keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
    }
    
    // MARK: - Oberver Registered method
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            if let window = self.view.window?.frame {
                let getSpace = window.origin.y + window.height - keyboardHeight
                bottomSpace.constant = keyboardHeight + (getSpace - keyboardHeight)
            }
        }
        
    }
    
    // MARK: - Fetch messages
    func fetchmessages() {
        messages = appDelegate.fetchMessages()
        tableView.reloadData()
        if let messages = messages {
            if messages.count > 1 {
                tableView.scrollToRow(at: IndexPath(item: messages.count - 1, section: 0), at: .bottom, animated: false)
            }
        }
    }
    
    // MARK: - Send Messages
    @IBAction func didPressedSendButton(_ sender: Any) {
        
        if let text = messageTextField.text {
            
            if text.isEmpty {return}
            appDelegate.saveMessage(body:text , isOutgoing: true)
            appDelegate.saveMessage(body:text , isOutgoing: false)
            messageTextField.text = ""
            fetchmessages()
        }
    }
    
}

extension ViewController:UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages == nil ? 0 : messages!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MessageTableViewCell
        let message = messages![indexPath.row]
        cell.messageContentTextView.text = message.body
        if message.outgoing {
            cell.messageContentTextView.textAlignment = .right
        }
        else {
            cell.messageContentTextView.textAlignment = .left
        }
        return cell
    }
}

let padding:CGFloat = 20.0;
extension ViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let dict = messages![indexPath.row]
        let msg = dict.body
        
        let size: CGSize = msg!.size(withAttributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14.0)])
        let height = size.height < 50 ? 50 : size.height + (padding*2.0)
        return CGFloat(height);
    }
}



