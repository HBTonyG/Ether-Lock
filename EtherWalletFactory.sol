// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;


import {EtherWallet} from "./etherWallet.sol";
// This is good practice. It imports the specific contract from the file.

event EtherWalletCreation(
        address indexed owner, address newEtherWalletContractAddress
    );

contract etherWalletFactory {

    address newEtherWalletContractAddress; 
    uint256 amountToLock; 
    EtherWallet[] public listOfEtherWalletContracts;

    function createEtherWallet() external payable { 
    require (msg.sender == tx.origin, "Only EOA"); 
  // Makes sure that a only real user can create
    EtherWallet newEtherWalletContract = new EtherWallet(msg.sender);
    //creates the contract
    newEtherWalletContractAddress = address(newEtherWalletContract);
    // assigns the address of the new contract to the variable
    listOfEtherWalletContracts.push(newEtherWalletContract); 
    //pushes the new contract address into the array
    emit EtherWalletCreation (msg.sender, newEtherWalletContractAddress);
    // emits the owner and the CA of the new contract, may be useful in the website design
    }
}