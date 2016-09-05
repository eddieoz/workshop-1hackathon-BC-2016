# workshop-1hackathon-BC-2016
# Mercado Pokémon

Material didático para o Workshop no 1 Hackathon BC - 7-Set-2016

O conteúdo apresentado deve ser utilizado somente para fins didáticos. 
Este é um protótipo para estudo e aprendizado sobre o desenvolvimento de smart-contracts na plataforma Ethereum e não deve ser utilizado em produção.

## O que é o Mercado Pokémon
Mercado Pokémon é uma demonstração do funcionamento de criação de moedas e Pokémons na plataforma Ethereum, assim como a negociação dos mesmos entre contas distintas.

Também é apresentado o conceito de um ambiente sem infraestrutura, que usa o blockchain como repositório de dados e aplicações, acessado diretamente por um html standalone.

## Pré-requisitos:
- Ethereum em Testnet
- Mist

## Setup:

1. Abra o arquivo accounts-for-testing.txt
2. Carregue contracts/pokecoin.sol no Mist e utilize os Accounts do Player1 e Player2 para lançar o contrato.
  - Atualize o endereço PokeCoinAddress do arquivo accounts-for-testing.txt com o novo endereço.
3. Carregue contracts/pokecentral.sol no Mist e utilize os Accounts dos Players1 e Player2 para lançar o contrato.
  - Atualize o endereço PokeCentralAddress do arquivo accounts-for-testing.txt com o novo endereço.
4. Carregue contracts/pokemarket.sol no Mist e utilize os endereços PokeCoinAddress e PokeCentralAddress para lançar o contrato.
  - Atualize o endereço PokeMarketAddress do arquivo accounts-for-testing.txt com o novo endereço.
5. Atualize o PokeMarketAddress nos contratos PokeCoin e PokeCentral  
6. Atualize as variáveis PokeCoinAddress, PokeCentralAddress e PokeMarketAddress em mercadopokemon.js
7. Carregue player1.html e player2.html em janelas separadas

## Funcionamento: 

Assim que os contratos forem carregados, eles criarão as PokeCoins e Pokemons, e os distribuirão entre as contas Player1 e Player2.
Através dos arquivos html é possível colocar pokemons à venda e efetuar a compra.

## Observação:
É necessário que o account[0] esteja desbloqueado e possua fundos. Para isso, digite: personal.unlockAccount(eth.accounts[0]) no console.

Se as pokecoins forem transferidas para uma conta no Mist, é possível negociá-las no mercado secundário, desde que a wallet possua fundos em ether para pagar o gas da transação.

