/*
    Contract Address: "0x2ba25711fa1f94998d875bf80acbc2cccdf9abbb"

    PokeCoinAddress:"0xCB672E5A5493571fA94a95628244BE3e923D8F6E"
    PokemonsAdress:"0x61288A28A873216C25B788E1fFA29c1AC21b92f3"
    "0xCB672E5A5493571fA94a95628244BE3e923D8F6E","0x61288A28A873216C25B788E1fFA29c1AC21b92f3"
    
    PokeSeller Address: "0xfFAe2A502A6142a00DBB54361E244ED55461C7Aa"
    
*/


contract pokeCoin { function transfer(address receiver, uint amount){  } }
contract pokemon { mapping (uint256 => address) public pokemonToMaster; function transferPokemon(address _from, address _to, uint256 _pokemonID) {  } }

contract MarketPokemon {
    pokeCoin public coinAddress;
    pokemon public pokemonAddress;
    PokeSale[] public pokeSales;
    uint public totalPokemonSales;
    
    mapping (uint => bool) public pokeSelling;
    mapping (address => uint[]) public pokeMasterSelling;
    mapping (uint => uint) public pokeSaleIndex;
    
    struct PokeSale{
        address pokeSeller;
        uint pokeID;
        uint pokePrice;
        bool pokeSold;
        bool pokeSellActive;
    }
    
    event NewSale(address pokeSellerAddress, uint pokemonID, uint pokemonSalePrice);
    
    function MarketPokemon(pokeCoin pokeCoinAddress, pokemon pokeRepositoryAddress) {
        coinAddress = pokeCoin(pokeCoinAddress);
        pokemonAddress = pokemon(pokeRepositoryAddress);
    }
    
    function newSale(address pokeSellerAddress, uint pokemonID, uint pokemonSalePrice) returns (bool success){
        if (pokeSellerAddress != pokemonAddress.pokemonToMaster(pokemonID)) throw;
        if (pokeSelling[pokemonID]) throw;
        uint pokeSalesID = pokeSales.length++;
        PokeSale p = pokeSales[pokeSalesID];
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
    }
    
    function addPokemonToSellingList(address pokeSellerAddress, uint pokemonID) internal {
        uint[] pokeSaleList = pokeMasterSelling[pokeSellerAddress];
        pokeSaleList[pokeSaleList.length++] = pokemonID;
        pokeMasterSelling[pokeSellerAddress] = cleanArray(pokeSaleList);
    }
    
    /* Esta funcao elimina todos os itens com zero do array, ao custo de gas */
    function cleanArray(uint[] pokeList) internal returns (uint[]){
        uint[] memory tempArray = new uint[](pokeList.length);
        uint j = 0;
        for (uint i=0; i < pokeList.length; i++){
            if ( pokeList[i] > 0 ){
                tempArray[j] = pokeList[i];
                j++;
            }
        }
        uint[] memory tempArray2 = new uint[](j);
        for (i=0; i< j; i++) tempArray2[i] = tempArray[i];
        return tempArray2;
    }
    
    function (){
        throw;
    }
    
}

