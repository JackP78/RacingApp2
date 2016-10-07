//
//  ChatInitialControllerViewController.swift
//  ListowelRaces
//
//  Created by Jack McAuliffe on 22/09/2016.
//  Copyright © 2016 Jack McAuliffe. All rights reserved.
//

import UIKit

class ChatInitialViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    
    var objectContext = ObjectContext()
    var senderId : String?
    var displayName : String?
    
    var userId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.senderId = nil
        self.displayName = nil
        objectContext.ensureLoggedInWithCompletion(self) { (user) in
            self.senderId = user.uid
            self.displayName = user.displayName
            self.performSegue(withIdentifier: "childViewController", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "childViewController" {
            return senderId != nil;
        }
        else {
            return true;
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let destinationScene = segue.destination as? ChatViewController {
            destinationScene.senderId = self.senderId
            destinationScene.senderDisplayName = self.displayName
        }
    }
 

}
