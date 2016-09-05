var Web3 = require('web3');
var web3 = new Web3();
var eth = web3.eth;
	
var txutils = lightwallet.txutils;
var signing = lightwallet.signing;
var encryption = lightwallet.encryption;

// ABI dos três Dapps
var abiPokeCoin = [{"constant":true,"inputs":[],"name":"name","outputs":[{"name":"","type":"string"}],"type":"function"},{"constant":true,"inputs":[],"name":"totalSupply","outputs":[{"name":"","type":"uint256"}],"type":"function"},{"constant":false,"inputs":[{"name":"marketAddress","type":"address"}],"name":"updatePokeMarketAddress","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"_from","type":"address"},{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transferFrom","outputs":[{"name":"success","type":"bool"}],"type":"function"},{"constant":true,"inputs":[],"name":"standard","outputs":[{"name":"","type":"string"}],"type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"}],"name":"balanceOf","outputs":[{"name":"","type":"uint256"}],"type":"function"},{"constant":true,"inputs":[],"name":"pokeMarketAddress","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":false,"inputs":[{"name":"qtdCoinsToDelete","type":"uint256"}],"name":"vanishCoins","outputs":[],"type":"function"},{"constant":true,"inputs":[],"name":"symbol","outputs":[{"name":"","type":"string"}],"type":"function"},{"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transfer","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"newSupply","type":"uint256"}],"name":"issueNew","outputs":[],"type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"},{"name":"","type":"address"}],"name":"allowance","outputs":[{"name":"","type":"uint256"}],"type":"function"},{"constant":false,"inputs":[{"name":"newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"type":"function"},{"inputs":[{"name":"initialSupply","type":"uint256"},{"name":"account1Demo","type":"address"},{"name":"account2Demo","type":"address"}],"type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"name":"from","type":"address"},{"indexed":true,"name":"to","type":"address"},{"indexed":false,"name":"value","type":"uint256"}],"name":"Transfer","type":"event"}];
var abiPokeCentral = [{"constant":true,"inputs":[{"name":"","type":"address"},{"name":"","type":"uint256"}],"name":"balanceOf","outputs":[{"name":"","type":"uint256"}],"type":"function"},{"constant":false,"inputs":[{"name":"marketAddress","type":"address"}],"name":"updatePokeMarketAddress","outputs":[],"type":"function"},{"constant":true,"inputs":[],"name":"totalPokemonSupply","outputs":[{"name":"","type":"uint256"}],"type":"function"},{"constant":true,"inputs":[{"name":"","type":"uint256"}],"name":"pokemonIndex","outputs":[{"name":"","type":"uint256"}],"type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"}],"name":"pokeOwnerIndex","outputs":[{"name":"","type":"uint256"}],"type":"function"},{"constant":true,"inputs":[{"name":"","type":"uint256"}],"name":"pokeMasters","outputs":[{"name":"pokeMaster","type":"address"}],"type":"function"},{"constant":true,"inputs":[],"name":"pokeMarketAddress","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":true,"inputs":[{"name":"","type":"uint256"}],"name":"pokemonToMaster","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":true,"inputs":[{"name":"","type":"uint256"}],"name":"pokemons","outputs":[{"name":"pokeNumber","type":"uint256"},{"name":"pokeName","type":"string"},{"name":"pokeType","type":"string"},{"name":"pokeCP","type":"uint256"},{"name":"pokeHP","type":"uint256"},{"name":"pokemonHash","type":"bytes32"},{"name":"pokeOwner","type":"address"}],"type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":false,"inputs":[{"name":"_pokemonNumber","type":"uint256"},{"name":"_cp","type":"uint256"},{"name":"_hp","type":"uint256"}],"name":"updatePokemon","outputs":[{"name":"success","type":"bool"}],"type":"function"},{"constant":false,"inputs":[{"name":"pokemonNumber","type":"uint256"},{"name":"cp","type":"uint256"},{"name":"hp","type":"uint256"}],"name":"newPokemon","outputs":[{"name":"success","type":"bool"}],"type":"function"},{"constant":false,"inputs":[{"name":"_from","type":"address"},{"name":"_to","type":"address"},{"name":"_pokemonID","type":"uint256"}],"name":"transferPokemon","outputs":[{"name":"pokemonID","type":"uint256"},{"name":"from","type":"address"},{"name":"to","type":"address"}],"type":"function"},{"constant":true,"inputs":[{"name":"","type":"uint256"},{"name":"","type":"uint256"}],"name":"pokemonNameTypes","outputs":[{"name":"","type":"string"}],"type":"function"},{"constant":false,"inputs":[{"name":"pokemonMaster","type":"address"}],"name":"newPokemonMaster","outputs":[{"name":"success","type":"bool"}],"type":"function"},{"constant":false,"inputs":[{"name":"_pokeOwner","type":"address"}],"name":"listPokemons","outputs":[{"name":"","type":"address"},{"name":"","type":"uint256[]"}],"type":"function"},{"constant":false,"inputs":[{"name":"newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"}],"name":"totalPokemonsFromMaster","outputs":[{"name":"","type":"uint256"}],"type":"function"},{"inputs":[{"name":"account1Demo","type":"address"},{"name":"account2Demo","type":"address"}],"type":"constructor"},{"anonymous":false,"inputs":[{"indexed":false,"name":"from","type":"address"},{"indexed":false,"name":"to","type":"address"},{"indexed":false,"name":"value","type":"uint256"}],"name":"Transfer","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"id","type":"uint256"},{"indexed":false,"name":"name","type":"string"},{"indexed":false,"name":"cp","type":"uint256"},{"indexed":false,"name":"hp","type":"uint256"}],"name":"CreatePokemon","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"id","type":"uint256"},{"indexed":false,"name":"name","type":"string"},{"indexed":false,"name":"cp","type":"uint256"},{"indexed":false,"name":"hp","type":"uint256"}],"name":"UpdatePokemon","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"owner","type":"address"},{"indexed":false,"name":"total","type":"uint256"}],"name":"UpdateMasterPokemons","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"number","type":"uint256"}],"name":"Log1","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"message","type":"string"}],"name":"Log2","type":"event"}];
var abiPokeMarket = [{"constant":true,"inputs":[{"name":"","type":"uint256"}],"name":"pokeSales","outputs":[{"name":"pokeSeller","type":"address"},{"name":"pokeBuyer","type":"address"},{"name":"pokeID","type":"uint256"},{"name":"pokePrice","type":"uint256"},{"name":"pokeSold","type":"bool"},{"name":"pokeSellActive","type":"bool"}],"type":"function"},{"constant":false,"inputs":[{"name":"newPokecoinAddress","type":"address"},{"name":"newPokecentralAddress","type":"address"}],"name":"updatePokecoinAndPokemarketAddresses","outputs":[],"type":"function"},{"constant":true,"inputs":[{"name":"","type":"uint256"}],"name":"pokeSaleIndex","outputs":[{"name":"","type":"uint256"}],"type":"function"},{"constant":true,"inputs":[{"name":"","type":"uint256"}],"name":"pokeSelling","outputs":[{"name":"","type":"bool"}],"type":"function"},{"constant":false,"inputs":[{"name":"pokeSellerAddress","type":"address"},{"name":"pokemonID","type":"uint256"},{"name":"pokemonSalePrice","type":"uint256"}],"name":"newSale","outputs":[{"name":"success","type":"bool"}],"type":"function"},{"constant":true,"inputs":[],"name":"totalPokemonSales","outputs":[{"name":"","type":"uint256"}],"type":"function"},{"constant":true,"inputs":[],"name":"pokeCoin","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":false,"inputs":[{"name":"pokeSellerAddress","type":"address"},{"name":"pokemonID","type":"uint256"}],"name":"stopSale","outputs":[],"type":"function"},{"constant":true,"inputs":[],"name":"pokeCentral","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":false,"inputs":[{"name":"pokeBuyerAddress","type":"address"},{"name":"pokemonID","type":"uint256"}],"name":"buyPokemon","outputs":[],"type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"},{"name":"","type":"uint256"}],"name":"pokeMasterSelling","outputs":[{"name":"","type":"uint256"}],"type":"function"},{"constant":false,"inputs":[{"name":"newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"type":"function"},{"inputs":[{"name":"pokeCoinAddress","type":"address"},{"name":"pokeCentralAddress","type":"address"}],"type":"constructor"},{"anonymous":false,"inputs":[{"indexed":false,"name":"pokeSellerAddress","type":"address"},{"indexed":false,"name":"pokemonID","type":"uint256"},{"indexed":false,"name":"pokemonSalePrice","type":"uint256"}],"name":"NewSale","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"pokeSellerAddress","type":"address"},{"indexed":false,"name":"pokemonID","type":"uint256"}],"name":"StopSale","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"pokeBuyerAddress","type":"address"},{"indexed":false,"name":"pokeSellerAddress","type":"address"},{"indexed":false,"name":"pokemonID","type":"uint256"}],"name":"PokeTrade","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"status","type":"bool"}],"name":"Log1","type":"event"}];

// Endereços dos Dapps
var pokeCoinAddress = '0x13EccD104f4012F857a9cD32C1E4877275f78Cec';
var pokeCentralAddress = '0xe46A592b722EAD6cEC7E0Eb736dEB59dbb325CAb';
var pokeMarketAddress = '0x0fd5c4D42e5E46aEe2A78bf8919ec60B03e4a80d';

// Carregamento dos Contratos
var MyPokeCoinContract = web3.eth.contract(abiPokeCoin);
var pokeCoin = MyPokeCoinContract.at(pokeCoinAddress);

var MyPokeCentralContract = web3.eth.contract(abiPokeCentral);
var pokeCentral = MyPokeCentralContract.at(pokeCentralAddress);

var MyPokeMarketContract = web3.eth.contract(abiPokeMarket);
var pokeMarket = MyPokeMarketContract.at(pokeMarketAddress);

var keystore;

		var accountAddress = "xxx";
var password = 'mercadopokemon';

// Inicializa conexão com o node local
web3.setProvider(new web3.providers.HttpProvider());	

function setWeb3Provider(keystore) {
    var web3Provider = new HookedWeb3Provider({
      host: "http://localhost:8545",
      transaction_signer: keystore
    });

    web3.setProvider(web3Provider);
};

// Criação do account
lightwallet.keystore.deriveKeyFromPassword(password, function(err, pwDerivedKey) {

	//var extraEntropy = 'mercadopokemon129387612348917236';
	//seed = lightwallet.keystore.generateRandomSeed(extraEntropy);
	keystore = new lightwallet.keystore(seed, pwDerivedKey);
	keystore.generateNewAddress(pwDerivedKey, 1);

	accountAddress = keystore.getAddresses()[0];

	document.getElementById("accountAddress").innerText = "Account Address: " + accountAddress;
	document.getElementById("seed").innerText = "Seed: " + seed;

	//console.log("Seed: " + seed);
		
	web3.eth.defaultAccount = eth.accounts[0];

});	

function showStatus(){
	var currentBalance = pokeCoin.balanceOf('0x'+accountAddress).toNumber();
	var qtdePokemons = pokeCentral.totalPokemonsFromMaster('0x'+accountAddress);
	document.getElementById("currbalance").innerText = 'Balance: ' + currentBalance + ' pkc'; 
	document.getElementById("totalPokemons").innerText = 'Qtde : ' + qtdePokemons + ' pokemon(s)'; 			
	
	var html = '<table>';
	html += '<tr><td>ID</td><td>Pokemon</td><td>Tipo</td><td>CP</CP><td>HP</td></tr>'
	for (i=0; i<qtdePokemons; i++){
		html += '<tr>'
		var pokeID = pokeCentral.balanceOf('0x'+accountAddress, i);
		html += '<td>' + pokeID + '</td>'
		for (j=1; j<5; j++){
			html += '<td>' + pokeCentral.pokemons(pokeID)[j] + '</td>';
		}
		html += '</tr>';
	}
	html+='</table>'
	
	document.getElementById("pokemonList").innerHTML = html;

	// Mostra vendas ativas
	var html2 = '';
	html2 = '<table>'
	html2 += '<tr><td>ID</td><td>Pokemon</td><td>Tipo</td><td>CP</CP><td>HP</td><td>Valor</td><td>Proprietario</td></tr>';
	for (i=0;;i++){
		if (pokeMarket.pokeSales(i)[0] == '0x') break;
		if (pokeMarket.pokeSales(i)[5]){ 
			html2 += '<tr>';
			saleID = pokeMarket.pokeSales(i)[2].toNumber();
			html2 += '<td>' + saleID + '</td>'
			for (j=1; j<5; j++){
				html2 += '<td>' + pokeCentral.pokemons(saleID)[j] + '</td>';
			}
			html2 += '<td>' + pokeMarket.pokeSales(i)[3].toNumber() + ' pkc</td>';
			html2 += '<td>' + pokeMarket.pokeSales(i)[0] + '</td>';
			html2 += '</tr>';
		}		
	}
	document.getElementById("pokeSells").innerHTML = html2;
	//console.log(pokemonList);
};

function setSell(){
	var pokeIDSell = document.getElementById("pokeIDSell").value;
	var pokePriceSell = document.getElementById("pokePriceSell").value;
	pokeMarket.newSale('0x'+accountAddress, pokeIDSell, pokePriceSell, {value: 0, gas: 290654, gasPrice: 20000000000}, function(err, hash) {
		if (!err){
			console.log("Transacao enviada: " + hash);
			document.getElementById("msgVenda").innerText = hash;
		} else {
			console.log("Erro no envio: " + err);
			document.getElementById("msgVenda").innerText = err;
		};
	});
	var pokeIDSell = document.getElementById("pokeIDSell").value = '';
	var pokePriceSell = document.getElementById("pokePriceSell").value = '';
}

function setBuy(){
	var pokeIDBuy = document.getElementById("pokeIDBuy").value;
	pokeMarket.buyPokemon('0x'+accountAddress, pokeIDBuy, {value: 0, gas: 428638, gasPrice: 20000000000}, function(err, hash) {
		if (!err){
			console.log("Transacao enviada: " + hash);
			document.getElementById("msgCompra").innerText = hash;
		} else {
			console.log("Erro no envio: " + err);
			document.getElementById("msgCompra").innerText = err;
		};
	});
	pokeIDBuy = document.getElementById("pokeIDBuy").value = '';
}


var filter = web3.eth.filter('latest');
filter.watch(function(error, result) {
	if (!error) {
		showStatus()
	}
});