import UIKit
import Foundation
import Darwin

class MessageViewController: UIViewController {
    let db = WADBReader.main
    var message: Message? = nil
    var dateFromView: Date? = nil
    let dateFormatter = DateFormatter()
    
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var sideSelectionView: UISegmentedControl!
    @IBOutlet weak var statusSelectionView: UISegmentedControl!
    @IBOutlet weak var dateTextView: UITextField!
    

    @IBAction func dateFieldEditing(_ sender: UITextView) {
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePicker.Mode.dateAndTime
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(MessageViewController.datePickerValueChanged), for: UIControl.Event.valueChanged)
        
        if (message?.date != nil)
        {
            datePickerView.date = (message?.date)!
        }
    }
    
    func setMessage(_ message: Message)
    {
        self.message = message
    }
    
    @objc func datePickerValueChanged(sender:UIDatePicker) {
        setDateView(date: sender.date)
    }
    
    func setDateView(date: Date)
    {
        dateTextView.text = dateFormatter.string(from: date)
        self.dateFromView = date
    }
    
    @IBAction func didClickDone(_ sender: Any) {
        // Update the message fields.
        updateMessageFromUI()
        self.db.updateMessage(self.message!)
        self.navigationController?.popViewController(animated: true)
    }
    
    // Updates the message model from the values in the UI.
    func updateMessageFromUI()
    {
        self.message?.content = self.messageTextView.text
        self.message?.date = dateFromView
        self.message?.isFromMe = sideSelectionView.selectedSegmentIndex == 0 ? true : false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.short
        
        messageTextView.text = message!.content
        sideSelectionView.selectedSegmentIndex = message!.isFromMe ? 0 : 1
        if (message?.date != nil) { setDateView(date: message!.date!) }
        
        switch message!.status {
        case .Sent:
            statusSelectionView.selectedSegmentIndex = 0
            break
        case .Delivered:
            statusSelectionView.selectedSegmentIndex = 1
            break
        case .Read:
            statusSelectionView.selectedSegmentIndex = 2
            break
        }
    }
}
