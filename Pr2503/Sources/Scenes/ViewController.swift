import UIKit

class ViewController: UIViewController {
    
    // MARK: -  Properties
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var unlockPasswordLabel: UILabel!
    @IBOutlet weak var generatePasswordButton: UIButton!
    
    var isBlack: Bool = false {
        didSet {
            if isBlack {
                self.view.backgroundColor = .blue
            } else {
                self.view.backgroundColor = .white
            }
        }
    }
    
    private var currentPassword = ""
    var isStartHucking = false
    var isPasswordCracked = false
    
    // MARK: - Life Cicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        passwordTextField.placeholder = "Введите ваш пароль"
        unlockPasswordLabel.numberOfLines = 2
        unlockPasswordLabel.text = ""
        activityIndicator.isHidden = true
        passwordTextField.isSecureTextEntry = true
    }
    
    // MARK: - Methods
    
    @IBAction func generatePassword(_ sender: UIButton) {
        guard let userPassword = passwordTextField.text else { return }
        guard userPassword != "" else  {
            self.unlockPasswordLabel.text = "Введите свой пароль"
            return
        }
        isStartHucking.toggle()
        self.currentPassword = userPassword
        changeStateButtonAndActivity()
        if isStartHucking {
            let concurrentQueue = DispatchQueue(label: "myConcurrentQueue",
                                                qos: .default, attributes: .concurrent,
                                                autoreleaseFrequency: .inherit,
                                                target: nil)
            concurrentQueue.async {
                self.bruteForce(passwordToUnlock: self.currentPassword)
            }
        }
        if !isPasswordCracked {
            self.unlockPasswordLabel.text = "Пароль \(currentPassword) не взломан"
            print("Пароль не взломан")
        }
    }
    
    @IBAction func onBut(_ sender: Any) {
        isBlack.toggle()
    }
    
    func checkStatePasswordCracked(_ password: String) {
        if self.currentPassword == password {
            isPasswordCracked = true
            self.unlockPasswordLabel.text = "Пароль \(currentPassword) взломали "
            generatePasswordButton.setTitle("Начать подбор пароля", for: .normal)
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
            print("Пароль взломали")
        } else if isStartHucking {
            self.unlockPasswordLabel.text = "Идет взлом пароля... \(password)"
            changeStateButtonAndActivity()
        }
    }
    
    func changeStateButtonAndActivity() {
        if isStartHucking && !isPasswordCracked {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            generatePasswordButton.setTitle("Стоп", for: .normal)
        } else {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            generatePasswordButton.setTitle("Начать подбор пароля", for: .normal)
        }
    }
    
    func bruteForce(passwordToUnlock: String) {
        let ALLOWED_CHARACTERS:   [String] = String().printable.map { String($0) }
        
        var password: String = ""
        
        while password != passwordToUnlock && isStartHucking {
            password = generateBruteForce(password, fromArray: ALLOWED_CHARACTERS)
            
            print(password)
            // Your stuff here
            DispatchQueue.main.async {
                self.checkStatePasswordCracked(password)
            }
        }
        print(password)
    }
}

extension String {
    var digits:      String { return "0123456789" }
    var lowercase:   String { return "abcdefghijklmnopqrstuvwxyz" }
    var uppercase:   String { return "ABCDEFGHIJKLMNOPQRSTUVWXYZ" }
    var punctuation: String { return "!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~" }
    var letters:     String { return lowercase + uppercase }
    var printable:   String { return digits + letters + punctuation }
    
    mutating func replace(at index: Int, with character: Character) {
        var stringArray = Array(self)
        stringArray[index] = character
        self = String(stringArray)
    }
}

func indexOf(character: Character, _ array: [String]) -> Int {
    return array.firstIndex(of: String(character))!
}

func characterAt(index: Int, _ array: [String]) -> Character {
    return index < array.count ? Character(array[index])
    : Character("")
}

func generateBruteForce(_ string: String, fromArray array: [String]) -> String {
    var str: String = string
    
    if str.count <= 0 {
        str.append(characterAt(index: 0, array))
    }
    else {
        str.replace(at: str.count - 1,
                    with: characterAt(index: (indexOf(character: str.last!, array) + 1) % array.count, array))
        
        if indexOf(character: str.last!, array) == 0 {
            str = String(generateBruteForce(String(str.dropLast()), fromArray: array)) + String(str.last!)
        }
    }
    
    return str
}

