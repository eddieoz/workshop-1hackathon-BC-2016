contract oldRules {  
	
    bool public locked;
		
    mapping (address => bool) public frozenAccount;
	
	/* Rules upgrade index */
	mapping (uint => address) public accountIndex;
	mapping (address => bool) public hasAccountIndex;
	uint public accountCount;
	    
	mapping (address => bool) public approvedAccount;

	function resetOldRules( address target );
}


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


contract PokecoinRules is owned { 
    
    bool public locked;
		
    mapping (address => bool) public frozenAccount;
	
	/* Rules upgrade index */
	mapping (uint => address) public accountIndex;
	mapping (address => bool) public hasAccountIndex;
	uint256 public accountCount;
	
	oldRules public oldRulesInfo;
	    
	mapping (address => bool) public approvedAccount; 
    event ApprovedAccess(address target, bool approved);
	
    event FrozenFunds(address target, bool frozen);


    /* Initializes contract with initial supply pokecoins to the creator of the contract */	
	function PokecoinRules(address oldRulesAddress) {
		owner = msg.sender;
		
		/* Initialize index for upgrade */
		accountIndex[accountCount] = owner;
		hasAccountIndex[owner] = true;
		accountCount++;
		if (oldRulesAddress != 0){
			importOldRules(oldRulesAddress);
		}
		
	}
			
	/* Pokecoin Rules */
	function freezeAccount(address target, bool freeze) onlyOwner {
        frozenAccount[target] = freeze;
        FrozenFunds(target, freeze);
		
		/* Update account index for upgrading rules */
		updateAccountIndex(target);
    }
    
    
    function lock( bool lock ) onlyOwner {
        locked = lock;
    }
	
	/* Allow another contract to access this contract */
    function approveAccountToAccess(address _accountAddress, bool allowed) onlyOwner {
		approvedAccount[_accountAddress] = allowed;
		
		/* Update account index for upgrading rules */		
		updateAccountIndex(_accountAddress);
    }

	function updateAccountIndex(address _to){
		/* Update index for rules upgrade */
		if ( !hasAccountIndex[_to] && _to != 0x0){
			accountIndex[accountCount] = _to;
			hasAccountIndex[_to] = true;
			accountCount++;
		}
	}
	
	/* External Access Functions */ 
	function validRun(address _from, address _to) {
		if (!approvedAccount[msg.sender]) throw;
		if (locked) throw;
		if (frozenAccount[_from]) throw;
		if (frozenAccount[_to]) throw;
	}
	
	/* Import old rules */
	function importOldRules( address oldRulesAddress) onlyOwner {

		oldRulesInfo = oldRules(oldRulesAddress);

		locked = oldRulesInfo.locked();
		uint256 accountCount1 = oldRulesInfo.accountCount();
	
		for (uint256 i = 0; i < accountCount1; i++){
			address oldRulesAccount = oldRulesInfo.accountIndex(i);
			frozenAccount[oldRulesAccount] = oldRulesInfo.frozenAccount(oldRulesAccount);
			approvedAccount[oldRulesAccount] = oldRulesInfo.approvedAccount(oldRulesAccount);
			
			/* Update account index for upgrading rules */		
			updateAccountIndex(oldRulesAccount);
		}
	}
	
	/* Allow new rules to reset this old pokecoin rules */
	function resetOldTRules( address target){
		if (!approvedAccount[msg.sender]) throw;
		
		
	}

		
	function () {
        throw;     // Prevents accidental sending of ether
    } 

           
}   