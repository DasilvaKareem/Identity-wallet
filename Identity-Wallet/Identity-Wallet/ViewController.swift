//
//  ViewController.swift
//  example
//
//

import UIKit
import Ssi

class ViewController: UIViewController {
    
    @IBOutlet weak var LittleConsole: UILabel!
    @IBAction func CreateDidTapped(_ sender: Any) {
        createDID();
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addLog(text: "App initialized.");
    }
    
    func createDID() {
        // dont think we need this
        // let supportedKeyTypes = IdentityGetSupportedKeyTypes();
        
        var error: NSError? = NSError()
        let did = SsiGenerateDIDKey("secp256k1", &error);
        
        if let unwrapped = did?.privateJSONWebKey {
            do {
                let json = try JSONSerialization.jsonObject(with: unwrapped);
                addLog(text: "Did creation successful. Did is: \(did!.didKey)");
                addLog(text: "Did JSON is: \(json)");
                storeUnsecureKey(Key: did!.didKey)
            } catch {
                addLog(text: "Error while parsing JSON: \(error)")
            }
        }
    }
    
    func storeUnsecureKey(Key:String){
        let userDefaults = UserDefaults.standard
        var array = userDefaults.object(forKey: "myKey") as? [String]
        array?.append(Key)
        userDefaults.set(array, forKey: "myKey")
        guard let arrayInfo = array?.formatted() else {
            
            print("No array found")
            let info = [Key]
            userDefaults.set(info, forKey: "myKey")
            return
            
        }
        print(arrayInfo)
        print("success")
    }
    // put private key in secure storage
    func storePrivateKey(key: String) throws {
        let tag = "com.tbd.example".data(using: .utf8)!
        let query: [String: Any] = [kSecClass as String: kSecClassKey,
                                       kSecAttrApplicationTag as String: tag,
                     kSecValueRef as String: key]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError.failure }
    }
    
    // utils
    func addLog(text: String) {
        let currentLogs = self.LittleConsole.text ?? "";
        self.LittleConsole.text = currentLogs + text + "\n\n";
        print(text);
    }
    
    enum KeychainError: Error {
          case failure
      }
}

