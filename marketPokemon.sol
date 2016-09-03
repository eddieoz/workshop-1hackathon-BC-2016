/*
    Contract Address: "0x2ba25711fa1f94998d875bf80acbc2cccdf9abbb"

    PokeCoinAddress:"0x037D274575fE52239BfeB4911A09Cc5cfCe0C9FD"
    PokemonsAdress:"0x13EccD104f4012F857a9cD32C1E4877275f78Cec"
    "0x037D274575fE52239BfeB4911A09Cc5cfCe0C9FD","0x13EccD104f4012F857a9cD32C1E4877275f78Cec"
    
    PokeSeller Address: "0xfFAe2A502A6142a00DBB54361E244ED55461C7Aa"
    PokeBuyer Address: "0xf09c7cbD8B7D27ac12e82b8bC6d8fe7EEfC9E7C8"
    Main Wallet: "0x6A5b342ec71DEF8aAc337b82969D9dDd811023C9"
    
*/


contract pokeCoin { mapping (address => uint256) public balanceOf; function transferFrom(address _from, address _to, uint256 _value){  } }
contract pokemon { mapping (uint256 => address) public pokemonToMaster; function transferPokemon(address _from, address _to, uint256 _pokemonID) {  } }

contract MarketPokemon {
    pokeCoin public pokeCoinDapp;
    pokemon public pokemonDapp;
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
    
    function MarketPokemon(pokeCoin pokeCoinAddress, pokemon pokeRepositoryAddress) {
        pokeCoinDapp = pokeCoin(pokeCoinAddress);
        pokemonDapp = pokemon(pokeRepositoryAddress);
        
    }
    
    function newSale(address pokeSellerAddress, uint pokemonID, uint pokemonSalePrice) returns (bool success){
        if (pokeSellerAddress != pokemonDapp.pokemonToMaster(pokemonID)) throw;
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
        //if (pokeSellerAddress != pokemonDapp.pokemonToMaster(pokemonID)) throw;
        //if (!pokeSelling[pokemonID]) throw;
        
        uint pokeSalesID = pokeSaleIndex[pokemonID];
        PokeSale p = pokeSales[pokeSalesID];
        //if (!p.pokeSellActive) throw;
        p.pokeSellActive = false;
        pokeSelling[pokemonID] = false;
        
        delPokemonFromSellingList(pokeSellerAddress, pokemonID);

        totalPokemonSales-=1;
        
        StopSale(pokeSellerAddress, pokemonID);
    }
    
    function buyPokemon(address pokeBuyerAddress, uint pokemonID){
        //if (!pokeSelling[pokemonID]) throw;
        uint pokeSalesID = pokeSaleIndex[pokemonID];
        PokeSale p = pokeSales[pokeSalesID];
        //if (!p.pokeSellActive) throw;
        //if (pokeCoinDapp.balanceOf(pokeBuyerAddress) < p.pokePrice) throw;
        
        pokeCoinDapp.transferFrom(pokeBuyerAddress, p.pokeSeller, p.pokePrice);
        pokemonDapp.transferPokemon(p.pokeSeller, pokeBuyerAddress, pokemonID);
        p.pokeBuyer = pokeBuyerAddress;
        p.pokeSold = true;
        stopSale(p.pokeSeller,pokemonID);
        
        PokeTrade(pokeBuyerAddress, p.pokeSeller, pokemonID );
        
    }
    
    function transferCoin(address _from, address _to, uint _value){
        pokeCoinDapp.transferFrom(_from, _to, _value);
    }
    
    function transferPokemon(address _from, address _to, uint _pokemonID){
        pokemonDapp.transferPokemon(_from, _to, _pokemonID);
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

