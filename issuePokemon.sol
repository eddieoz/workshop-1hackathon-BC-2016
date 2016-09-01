// Pokemon create template: 1,500,40,"at1",1,"at2",500
// owner 0xca35b7d915458ef540ade6068dfe2f44e8fa733c

contract tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData); }

contract IssuePokemon {
    /* Public variables of the token */

    
    string public standard = 'Pokemon 0.1';
    string public name = 'IssuePokemon';
    uint256 public totalSupply;
    
    Pokemon[] public pokemons;
    PokemonOwner[] public pokeOwners;

    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    mapping (uint256 => address) public pokemonMaster;
    mapping (address => uint256) public pokeOwnerIndex;

    struct Pokemon {
        uint pokeNumber;
        string pokeName;
        string pokeType;
        uint pokeCP;
        uint pokeHP;
        //string pokeAttack;
        //uint pokeAttackPower;
        //string pokeSpecial;
        //uint pokeSpecialPower;
        bytes32 pokemonHash;
        address pokeOwner;    
    }
    
    struct PokemonOwner {
        address pokeOwner;
        uint[] pokemons;
    }
    
    
    
    string[][] public pokemonNameTypes = [["Pokemon 0", "invalid"], ["Bulbassauro", "Grass/Poison"], ["Charmander", "Fire"], ["Squirtle","Water"], ["Pikachu","Eletric"]]; // nÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ£o aceita bytes

    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);
    event CreatePokemon(uint id, string name, uint cp, uint hp );
    event UpdateMasterPokemons(string message);
    event Log1(uint number);
	event Log2(string message);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function IssuePokemon( ) {
        newPokemonOwner(msg.sender); 						// Todos pokemons serao criados para este owner
        newPokemon(0,0,0); 									// Pokemon índice 0
		
		/* Criacao de pokemons iniciais */
		//newPokemon(3,500,40);
		//newPokemon(1,535,70);
		//newPokemon(0,546,80);
		//newPokemon(2,557,90);
		
        //balanceOf[msg.sender] = initialSupply;              // Give the creator all initial tokens
        //totalSupply = initialSupply;                        // Update total supply
        //msg.sender.send(msg.value);                         // Send back any ether sent accidentally
    }
    
	//function newPokemon(uint pokemonNumber, uint cp, uint hp, string attack, uint attackPower, string special, uint specialPower ) returns (bool success) { // cp e hp fornecidos por https://api.random.org/json-rpc/1/basic
    function newPokemon(uint pokemonNumber, uint cp, uint hp ) returns (bool success) { // cp e hp fornecidos por https://api.random.org/json-rpc/1/basic
        address owner = msg.sender;
        uint pokemonID = pokemons.length++;
        Pokemon p = pokemons[pokemonID];
        p.pokeNumber = pokemonNumber;
        p.pokeName = pokemonNameTypes[pokemonNumber][0];
        p.pokeType = pokemonNameTypes[pokemonNumber][1];
        p.pokeCP = cp;
        p.pokeHP = hp;
        //p.pokeAttack = attack;
        //p.pokeAttackPower = attackPower;
        //p.pokeSpecial = special;
        //p.pokeSpecialPower = specialPower;
        p.pokeOwner = owner;
        pokemonMaster[pokemonID] = owner;
        
        //p.pokemonHash = sha3(p.pokeNumber,p.pokeName,p.pokeType,p.pokeCP,p.pokeHP, p.pokeAttack, p.pokeAttackPower, p.pokeSpecial, p.pokeSpecialPower);
		p.pokemonHash = sha3(p.pokeNumber,p.pokeName,p.pokeType,p.pokeCP,p.pokeHP);
        
        updateMasterPokemons(owner, pokemonID, true);
        
        totalSupply += 1;
        CreatePokemon(pokemonID, p.pokeName, p.pokeCP, p.pokeHP);
        return true;
    }
    
    function newPokemonOwner(address pokeOwner) returns (bool success) {
        uint ownerID = pokeOwners.length++;
        PokemonOwner o = pokeOwners[ownerID];
        o.pokeOwner = pokeOwner;
        pokeOwnerIndex[pokeOwner] = ownerID;
        return true;
    }
    
    /* Send coins */
    function transfer(address _to, uint256 _pokemonID) {
        Pokemon p = pokemons[_pokemonID];
        if (p.pokeOwner != msg.sender) throw; // Checa se quem estÃ¡ solicitando a transferde proprietÃ¡rio do pokemon
        if (pokeOwnerIndex[_to] == 0 && _to != pokemonMaster[0] ) newPokemonOwner(_to);
        p.pokeOwner = _to;
        pokemonMaster[_pokemonID] = _to;
        updateMasterPokemons(msg.sender, _pokemonID, false);
        updateMasterPokemons(_to, _pokemonID, true);
        Transfer(msg.sender, _to, _pokemonID);                   // Avisa que a transferÃªncia de pokemon ocorreu
    }

    /* Allow another contract to spend some tokens in your behalf */
    function approve(address _spender, uint256 _value) returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    /* Approve and then comunicate the approved contract in a single tx */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }        

    /* A contract attempts to get the coins */
    function transferFrom(address _from, address _to, uint256 _pokemonID) returns (bool success) {
        Pokemon p = pokemons[_pokemonID];
        if (p.pokeOwner != _from) throw;
        // Construir controle de acesso somente para o owner
        p.pokeOwner = _to;
        pokemonMaster[_pokemonID] = _to;
        updateMasterPokemons(_from, _pokemonID, false);
        updateMasterPokemons(_to, _pokemonID, true);
        Transfer(_from, _to, _pokemonID);
        return true;
    }
    
    function updateMasterPokemons(address _pokemonOwner, uint256 _pokemonID, bool _add) returns (bool success) {
		uint ownerID = pokeOwnerIndex[_pokemonOwner];
        PokemonOwner o = pokeOwners[ownerID];
        uint[] pokeList = o.pokemons;
		uint newID = pokeList.length++;
		
        if (_add) {
			o.pokemons.push(_pokemonID);
			Log1(pokeList[newID]);
        } else {
            for (uint i=0; i < newID; i++){
				if (uint(pokeList[i]) == _pokemonID){
					delete pokeList[i];
					Log2("delete item");
					Log1(_pokemonID);
            	}
        	}
        }
        UpdateMasterPokemons("ok");
        return true;
    }

    /* This unnamed function is called whenever someone tries to send ether to it */
    function () {
        throw;     // Prevents accidental sending of ether
    }
}