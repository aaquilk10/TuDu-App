//
//  AddTuDuViewController.swift
//  TuDu
//
//  Created by Aaquil Khan on 02/01/19.
//  Copyright © 2019 Aaquil Khan. All rights reserved.
//

import UIKit
import CoreData

class AddTuDuViewController: UIViewController {
    
    // MARK: Properties
    var tudu: TuDu?
    var managedContext: NSManagedObjectContext!
    
    // MARK: Outlets

    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(with:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        textView.becomeFirstResponder()
        
        if let tudu = tudu {
            
            textView.text = tudu.title
            textView.text = tudu.title
            segmentedControl.selectedSegmentIndex = Int(tudu.priority)
            
        }
        
    }
    
    // MARK: Actions
    
    @objc func keyboardWillShow(with notification: Notification) {
        
        let key = "UIKeyboardFrameEndUserInfoKey"
        guard let keyboardFrame = notification.userInfo?[key] as? NSValue else {return}
        
        let keyboardHeight = keyboardFrame.cgRectValue.height
        
        bottomConstraint.constant = keyboardHeight + 5
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    fileprivate func dismissAndResign() {
        dismiss(animated: true)
        
        textView.resignFirstResponder()
    }
    
    @IBAction func cancel(_ sender: Any) {
        
        dismissAndResign()
        
    }
    
    @IBAction func done(_ sender: Any) {
        
        guard let title = textView.text, !title.isEmpty else {
            return
        }
        
        if let tudu = self.tudu {
            tudu.title = title
            tudu.priority = Int16(segmentedControl.selectedSegmentIndex)
        }
        
        else {
            let tudu = TuDu(context: managedContext)
            tudu.title = title
            tudu.priority = Int16(segmentedControl.selectedSegmentIndex)
            //tudu.date = Date()
        }
        
        do { try managedContext.save()
            dismissAndResign()
        }
        catch { print("Error: \(error)") }
        
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

extension AddTuDuViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if doneButton.isHidden {
            
            if tudu != nil {
                textView.textColor = .white
            }
            
            else {
                textView.text.removeAll()
                textView.textColor = .white
            }
            
            doneButton.isHidden = false
            
            UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded()})
        }
        
    }
    
}
