contract pokeCoinContract { mapping (address => uint256) public balanceOf; function transferFrom(address _from, address _to, uint256 _value){  } }
contract pokeCentralContract { mapping (uint256 => address) public pokemonToMaster; function transferPokemon(address _from, address _to, uint256 _pokemonID) {  } }

contract pokeMarket {
    pokeCoinContract public pokeCoin;
    pokeCentralContract public pokeCentral;
    uint public totalPokemonSales;
    
    PokeSale[] public pokeSales;

    mapping (uint => bool) public pokeSelling;
    mapping (address => uint[]) public pokeMasterSelling;
    mapping (uint => uint) public pokeSaleIndex;
    
    struct PokeSale{
        address pokeSeller;
        address pokeBuyer;
        uint pokeID;
        uint pokePrice;
        bool pokeSold;
        bool pokeSellActive;
    }
    
    event NewSale(address pokeSellerAddress, uint pokemonID, uint pokemonSalePrice);
    event StopSale(address pokeSellerAddress, uint pokemonID);
    event PokeTrade(address pokeBuyerAddress, address pokeSellerAddress, uint pokemonID );
    event Log1(bool status);
    
    function pokeMarket(pokeCoinContract pokeCoinAddress, pokeCentralContract pokeCentralAddress) {
        pokeCoin = pokeCoinContract(pokeCoinAddress);
        pokeCentral = pokeCentralContract(pokeCentralAddress);

        
    }
    
    function newSale(address pokeSellerAddress, uint pokemonID, uint pokemonSalePrice) returns (bool success){
        if (pokeSellerAddress != pokeCentral.pokemonToMaster(pokemonID)) throw;
        if (pokeSelling[pokemonID]) throw;
        uint pokeSalesID = pokeSales.length++;
        PokeSale p = pokeSales[pokeSalesID];
        if (p.pokeSellActive) throw;
        p.pokeSeller = pokeSellerAddress;
        p.pokeID = pokemonID;
        p.pokePrice = pokemonSalePrice;
        p.pokeSold = false;
        p.pokeSellActive = true;
        
        pokeSelling[pokemonID] = true;
        pokeSaleIndex[pokemonID] = pokeSalesID;
        
        addPokemonToSellingList(pokeSellerAddress, pokemonID);
        
        totalPokemonSales+=1;
        
        NewSale(pokeSellerAddress, pokemonID, pokemonSalePrice);
        return (true);
    }
    
    function stopSale(address pokeSellerAddress, uint pokemonID){
        if (pokeSellerAddress != pokeCentral.pokemonToMaster(pokemonID)) throw;
        if (!pokeSelling[pokemonID]) throw;
        
        uint pokeSalesID = pokeSaleIndex[pokemonID];
        PokeSale p = pokeSales[pokeSalesID];
        if (!p.pokeSellActive) throw;
        p.pokeSellActive = false;
        pokeSelling[pokemonID] = false;
        
        delPokemonFromSellingList(pokeSellerAddress, pokemonID);

        totalPokemonSales-=1;
        
        StopSale(pokeSellerAddress, pokemonID);
    }
    
    function buyPokemon(address pokeBuyerAddress, uint pokemonID){
        if (!pokeSelling[pokemonID]) throw;
        uint pokeSalesID = pokeSaleIndex[pokemonID];
        PokeSale p = pokeSales[pokeSalesID];
        if (!p.pokeSellActive) throw;
        if (pokeCoin.balanceOf(pokeBuyerAddress) < p.pokePrice) throw;
        
        pokeCoin.transferFrom(pokeBuyerAddress, p.pokeSeller, p.pokePrice);
        pokeCentral.transferPokemon(p.pokeSeller, pokeBuyerAddress, pokemonID);
        p.pokeBuyer = pokeBuyerAddress;
        p.pokeSold = true;
        
        stopSale(pokeBuyerAddress,pokemonID);
        
        PokeTrade(pokeBuyerAddress, p.pokeSeller, pokemonID );
        
    }
    
    function transferCoin(address _from, address _to, uint _value){
        pokeCoin.transferFrom(_from, _to, _value);
    }
    
    function transferPokemon(address _from, address _to, uint _pokemonID){
        pokeCentral.transferPokemon(_from, _to, _pokemonID);
    }
    
    function addPokemonToSellingList(address pokeSellerAddress, uint pokemonID) internal {
        uint[] tempList = pokeMasterSelling[pokeSellerAddress];
        tempList[tempList.length++] = pokemonID;
        
        pokeMasterSelling[pokeSellerAddress] = cleanArray(tempList);
    }
    
    
    function delPokemonFromSellingList(address pokeSellerAddress, uint pokemonID) internal {
        uint[] tempList = pokeMasterSelling[pokeSellerAddress];
        uint count = tempList.length;
        
        for (uint i=0; i<count; i++){
            if (tempList[i] == pokemonID) delete tempList[i];
        }
        
        pokeMasterSelling[pokeSellerAddress] = cleanArray(tempList);
    }
    
    
    /* Esta funcao elimina todos os itens com zero do array, ao custo de gas */
    function cleanArray(uint[] pokeList) internal returns (uint[]){
        uint[] memory tempList = new uint[](pokeList.length);
        uint j = 0;
        for (uint i=0; i < pokeList.length; i++){
            if ( pokeList[i] > 0 ){
                tempList[j] = pokeList[i];
                j++;
            }
        }
        uint[] memory tempList2 = new uint[](j);
        for (i=0; i< j; i++) tempList2[i] = tempList[i];
        return tempList2;
    }
    
    function (){
        throw;
    }
    
}

