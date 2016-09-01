contract owned {
    address public owner;

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
}


contract Pokecoin is owned { 
    /* Public variables of the pokecoin */
    string public name;
    string public symbol;
    //uint8 public decimals;
	
	uint256 public totalIssued;
	
	address public pokecoinRulesAddress;


    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint)) public allowance;
    mapping (address => mapping (address => uint)) public spentAllowance;
	
	
	/* Pokecoin upgrade index */
	mapping (uint => address) public accountIndex;
	mapping (address => bool) public hasAccountIndex;
	uint public accountCount;
	
    IssueLog[] public issuedLog;
	
	struct IssueLog {
        uint date;
		string operation;
        uint256 ammount;

    }
	uint256 logCount;
	//mapping (address => bool) public approvedAccount; 
	
	
	address public newPokecoinAddress;
    
    event ApprovedFunds(address target, bool approved);

    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);
	

    /* Initializes contract with initial supply pokecoins to the creator of the contract */
    function Pokecoin(uint256 initialSupply, string pokecoinName, string pokecoinSymbol, address centralMinter, address rulesAddress) {    
        if(centralMinter != 0 ) owner = centralMinter;
		pokecoinRulesAddress = rulesAddress;
        balanceOf[owner] = initialSupply; // Give the creator all initial pokecoins                    
		totalIssued = initialSupply;
		issuedLog[issuedLog.length++] = IssueLog({ date: now, operation: '+', ammount: initialSupply });
		logCount++;
        name = pokecoinName;                                   // Set the name for display purposes     
        symbol = pokecoinSymbol;                               // Set the symbol for display purposes    
        //decimals = decimalUnits;                            // Amount of decimals for display purposes        
		
		/* Initialize index for upgrade */
		accountIndex[accountCount] = owner;
		hasAccountIndex[owner] = true;
		accountCount++;
		
    }
	
    
    function issueNew( uint256 issueQty ) onlyOwner {
        balanceOf[owner] += issueQty;
		totalIssued += issueQty;
		issuedLog[issuedLog.length++] = IssueLog({ date: now, operation: '+', ammount: issueQty });
		logCount++;
		Transfer(msg.sender, owner, issueQty); 
    }
	
	function vanishPokecoin( uint256 vanishQty ) onlyOwner {
		if (vanishQty > balanceOf[owner]) throw;
        balanceOf[owner] -= vanishQty;
		totalIssued -= vanishQty;
		issuedLog[issuedLog.length++] = IssueLog({ date: now, operation: '-', ammount: vanishQty });
		logCount++;
		Transfer(msg.sender, owner, vanishQty); 
    }
    
    function NewPokecoinUpgrade(address _newPokecoinAddress) onlyOwner {
        newPokecoinAddress = _newPokecoinAddress;
    }
		
	function changePokecoinRulesAddress(address rulesAddress){
		pokecoinRulesAddress = rulesAddress;
	}

    
    
    /* Send coins */
    function transfer(address _to, uint256 _value) {
		
		// address nameReg = pokecoinRulesAddress;
		if (pokecoinRulesAddress != 0) {
			if (!pokecoinRulesAddress.call(bytes4(sha3("validRun(address,address)")),msg.sender,_to)) throw;
		} else {
			throw;
		}	
		//if (!nameReg.call(bytes4(sha3("validRun(address,address)")),msg.sender,_to)) throw;
		
        if (balanceOf[msg.sender] < _value) throw;           // Check if the sender has enough   
        if (balanceOf[_to] + _value < balanceOf[_to]) throw; // Check for overflows
        balanceOf[msg.sender] -= _value;                     // Subtract from the sender
        balanceOf[_to] += _value;                            // Add the same to the recipient            
        Transfer(msg.sender, _to, _value);                   // Notify anyone listening that this transfer took place
		
		/* Update index for pokecoin upgrade */
		if ( !hasAccountIndex[_to] ){
			accountIndex[accountCount] = _to;
			hasAccountIndex[_to] = true;
			accountCount++;
		}
		
    }
		
	function () {
        throw;     // Prevents accidental sending of ether
    } 
	
	
    /* Allow another contract to spend some pokecoins in your behalf */
    
    function approve(address _spender, uint256 _value) returns (bool success) {
        allowance[msg.sender][_spender] = _value;          
    }
    
    /* A contract attempts to get the coins */

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        // In case of whitelist instead of blacklist, change all frozen/freeze to approve
        
        //if (!approvedAccount[msg.sender]) throw;
        //if (!approvedAccount[_to]) throw;
        
        //if (frozenAccount[msg.sender]) throw;
        if (balanceOf[_from] < _value) throw;                 // Check if the sender has enough   
        if (balanceOf[_to] + _value < balanceOf[_to]) throw;  // Check for overflows
        if (spentAllowance[_from][msg.sender] + _value > allowance[_from][msg.sender]) throw;   // Check allowance
        
        balanceOf[_from] -= _value;                          // Subtract from the sender
        balanceOf[_to] += _value;                            // Add the same to the recipient            
        spentAllowance[_from][msg.sender] += _value;
        Transfer(msg.sender, _to, _value); 
    } 
    
    /* This unnamed function is called whenever someone tries to send ether to it */
           
}   