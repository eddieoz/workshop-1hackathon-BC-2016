// Pokemon create template: 1,500,40,"at1",1,"at2",500
// owner "0xca35b7d915458ef540ade6068dfe2f44e8fa733c"

contract owned {
    address public owner;
    address public market;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _
    }
    
    modifier Market {
        if (msg.sender != market || msg.sender != owner) throw;
        _
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
    
    function updateMarket(address newMarket) onlyOwner {
        market = newMarket;
    }
}


contract IssuePokemon is owned {

    uint256 public totalPokemonSupply;
    address public marketAddress;
    
    Pokemon[] public pokemons;
    PokemonMaster[] public pokeMasters;


    mapping (uint256 => address) public pokemonToMaster;
    mapping (address => uint256) public pokeOwnerIndex;
    mapping (uint => uint256) public pokemonIndex;
    mapping (address => uint256) public totalPokemonsFromMaster;

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
    
    struct PokemonMaster {
        address pokeMaster;
        uint[] pokemons;
    }
    
    string[][] public pokemonNameTypes = [["Pokemon 0", "invalid"], ["Bulbassauro", "Grass/Poison"], ["Charmander", "Fire"], ["Squirtle","Water"], ["Pikachu","Eletric"]]; // nÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ£o aceita bytes

    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address from, address to, uint256 value);
    event CreatePokemon(uint id, string name, uint cp, uint hp );
    event UpdatePokemon(uint id, string name, uint cp, uint hp );
    event UpdateMasterPokemons(address owner, uint total);
    event Log1(uint number);
    event Log2(string message);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function IssuePokemon() {
        owner = msg.sender;
        newPokemonMaster(owner);                            // Todos pokemons serao criados para este owner
        newPokemon(0,0,0);                                  // Pokemon Índice 0
        totalPokemonSupply-=1;                              // Ajusta o total de pokemons porque o primeiro é fake
        
        /* Criacao de pokemons iniciais */
        newPokemon(3,500,40);
        newPokemon(1,535,70);
        newPokemon(4,546,80);
        newPokemon(2,557,90);

    }
    
    //function newPokemon(uint pokemonNumber, uint cp, uint hp, string attack, uint attackPower, string special, uint specialPower ) returns (bool success) { // cp e hp fornecidos por https://api.random.org/json-rpc/1/basic
    function newPokemon(uint pokemonNumber, uint cp, uint hp )  returns (bool success) { // cp e hp fornecidos por https://api.random.org/json-rpc/1/basic
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

        //p.pokemonHash = sha3(p.pokeNumber,p.pokeName,p.pokeType,p.pokeCP,p.pokeHP, p.pokeAttack, p.pokeAttackPower, p.pokeSpecial, p.pokeSpecialPower);
        p.pokemonHash = sha3(p.pokeNumber,p.pokeName,p.pokeType,p.pokeCP,p.pokeHP);
        p.pokeOwner = owner;
        pokemonIndex[pokemonNumber] = pokemonID;
        pokemonToMaster[pokemonID] = owner;
        addPokemonToMaster(owner, pokemonID);
        
        totalPokemonSupply += 1;
        CreatePokemon(pokemonID, p.pokeName, p.pokeCP, p.pokeHP);
        return true;
    }
    
    function updatePokemon(uint _pokemonNumber, uint _cp, uint _hp )  returns (bool success) {
        uint pokemonID = pokemonIndex[_pokemonNumber];
        Pokemon p = pokemons[pokemonID];
        p.pokeCP = _cp;
        p.pokeHP = _hp;
        //p.pokeAttack = attack;
        //p.pokeAttackPower = attackPower;
        //p.pokeSpecial = special;
        //p.pokeSpecialPower = specialPower;

        //p.pokemonHash = sha3(p.pokeNumber,p.pokeName,p.pokeType,p.pokeCP,p.pokeHP, p.pokeAttack, p.pokeAttackPower, p.pokeSpecial, p.pokeSpecialPower);
        p.pokemonHash = sha3(p.pokeNumber,p.pokeName,p.pokeType,p.pokeCP,p.pokeHP);

        UpdatePokemon(pokemonID, p.pokeName, p.pokeCP, p.pokeHP);
        return true;
        
    }    
    
    function newPokemonMaster(address pokemonMaster)  returns (bool success) {
        uint ownerID = pokeMasters.length++;
        PokemonMaster o = pokeMasters[ownerID];
        o.pokeMaster = pokemonMaster;
        pokeOwnerIndex[pokemonMaster] = ownerID;
        return true;
    }
    

    function transferPokemon(address _from, address _to, uint256 _pokemonID)   returns (uint pokemonID, address from, address to) {
        Pokemon p = pokemons[_pokemonID];
        if (p.pokeOwner != _from) throw;
        if (pokeOwnerIndex[_to] == 0 && _to != pokemonToMaster[0] ) newPokemonMaster(_to);
        // Construir controle de acesso somente para o owner
        p.pokeOwner = _to;
        pokemonToMaster[_pokemonID] = _to;
        delPokemonFromMaster(_from, _pokemonID);
        addPokemonToMaster(_to, _pokemonID);
        Transfer(_from, _to, _pokemonID);
        return (_pokemonID, _from, _to);
    }
    
    function addPokemonToMaster(address _pokemonOwner, uint256 _pokemonID)  returns (address pokeOwner, uint[] pokemons, uint pokemonsTotal) {
        uint ownerID = pokeOwnerIndex[_pokemonOwner];
        PokemonMaster o = pokeMasters[ownerID];
        uint[] pokeList = o.pokemons;
        
        // o.pokemons.push(_pokemonID);
        // usando .push ele adiciona 0,_pokemonID
        
        // Ao invés de simplesmente adicionar um pokemon ao final da lista,
        // verifica se há slot zerado no array, senao adiciona ao final
        bool slot;
        for (uint i=0; i < pokeList.length; i++){
            if (pokeList[i] == 0){
                slot = true;
                break;
            }
        }
        if (slot == true){
            o.pokemons[i] = _pokemonID;
        } else {
            uint j = pokeList.length++;
            o.pokemons[j] = _pokemonID;
        }    
        
        qtdePokemons(_pokemonOwner);
        UpdateMasterPokemons(_pokemonOwner, o.pokemons.length);
        return (_pokemonOwner, o.pokemons, o.pokemons.length);
    }
    
    function delPokemonFromMaster(address _pokemonOwner, uint256 _pokemonID)  returns (address pokeOwner, uint[] pokemons, uint pokemonsTotal) {
        uint ownerID = pokeOwnerIndex[_pokemonOwner];
        PokemonMaster o = pokeMasters[ownerID];
        uint[] pokeList = o.pokemons;

        for (uint i=0; i < pokeList.length; i++){
            if (pokeList[i] == _pokemonID){
                delete pokeList[i];
            }
        }
        
        // http://ethereum.stackexchange.com/questions/3373/how-to-clear-large-arrays-without-blowing-the-gas-limit
        o.pokemons=pokeList; // Se usar delete, usa a propria pokeList
        
        qtdePokemons(_pokemonOwner);
        UpdateMasterPokemons(_pokemonOwner, o.pokemons.length);
        return (_pokemonOwner, o.pokemons, o.pokemons.length);
    }
    
    function listPokemons( address _pokeOwner )  returns (address, uint[]){
        uint ownerID = pokeOwnerIndex[_pokeOwner];
        PokemonMaster o = pokeMasters[ownerID];
        return ( _pokeOwner, o.pokemons );
    }
    
    function qtdePokemons( address _pokeOwner)  returns (uint qtde){
        uint ownerID = pokeOwnerIndex[_pokeOwner];
        PokemonMaster o = pokeMasters[ownerID];
        uint[] pokeList = o.pokemons;
        uint count = 0;
        for (uint i=0; i < pokeList.length; i++){
            if ( pokeList[i] > 0 ){
                count++;
            }
        }
        totalPokemonsFromMaster[_pokeOwner] = count;
        return count;
    }

    /* Se tentarem enviar ether para o end desse contrato, ele rejeita */
    function () {
        throw; 
    }
}