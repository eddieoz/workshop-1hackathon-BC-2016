contract tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData); }

contract owned {
    address public owner;
    address public pokeMarketAddress;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
    
    function updatePokeMarketAddress(address marketAddress) onlyOwner {
        pokeMarketAddress = marketAddress;
    }
    
}

contract Pokecoin is owned{
    /* Public variables of the token */
    string public standard = 'Pokecoin 0.1';
    string public name = 'Pokecoin';
    string public symbol = "pkc";
    uint256 public totalSupply;

    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function Pokecoin( uint256 initialSupply, address account1Demo, address account2Demo) {
        owner = msg.sender;
        
        balanceOf[msg.sender] = initialSupply;              // Give the creator all initial tokens
        totalSupply = initialSupply;                        // Update total supply
        if (account1Demo != 0 && account2Demo != 0){
            transfer(account1Demo, totalSupply/2);
            transfer(account2Demo, totalSupply/2);
        }
        //msg.sender.send(msg.value);                         // Send back any ether sent accidentally
    }

    /* Send coins */
    function transfer(address _to, uint256 _value) onlyOwner {
        if (balanceOf[msg.sender] < _value) throw;           // Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) throw; // Check for overflows
        balanceOf[msg.sender] -= _value;                     // Subtract from the sender
        balanceOf[_to] += _value;                            // Add the same to the recipient
        Transfer(msg.sender, _to, _value);                   // Notify anyone listening that this transfer took place
    }
    
    function issueNew(uint256 newSupply) onlyOwner{
        balanceOf[msg.sender] += newSupply;
        totalSupply += newSupply;
    }
    
    function vanishCoins(uint256 qtdCoinsToDelete) onlyOwner{
        balanceOf[msg.sender] -= qtdCoinsToDelete;
        totalSupply -= qtdCoinsToDelete;
    }

    /* A contract attempts to get the coins */
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (msg.sender != owner && msg.sender != pokeMarketAddress) throw;

        if (balanceOf[_from] < _value) throw;                 // Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) throw;  // Check for overflows
        balanceOf[_from] -= _value;                          // Subtract from the sender
        balanceOf[_to] += _value;                            // Add the same to the recipient
        Transfer(_from, _to, _value);
        return true;
    }

    /* This unnamed function is called whenever someone tries to send ether to it */
    function () {
        throw;     // Prevents accidental sending of ether
    }
}