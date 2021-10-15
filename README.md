# Smart-Contract-Security-Maintenance
Research Papers focused on Smart-contracts security topics. As well as listing all the encountered smart-contracts defects with a summary description. 🛡️


![1_Sq3E9pFatJP0IRjvY3j3XQ](https://user-images.githubusercontent.com/59753390/136479198-dc493cc0-5de5-4014-baca-9424353be037.jpg)



1.) ```Unchecked External Calls```
```REF```: https://arxiv.org/pdf/1905.01467.pdf

```// Choose a member to be the winner
function getWinner() {
    /* Block Info Dependency */
     uint winnerID = uint(block.blockhash(block.number)) % participants.length;
     participants[winnerID].send(8 ether);
     participatorID = 0;
}
```
To transfer Ethers or call functions of other smart contracts, Solidity provides a series of external call functions for raw addresses, i.e., address.send(), address.call(), address.delegatecall(). Unfortunately, these methods may fail due to network errors or out-of-gas error, e.g., the 2300 gas limitation of fallback function introduced in Section 2. When errors happen, these methods will return a boolean value (False), but never throw an exception. If callers do not check return values of external calls, they cannot ensure whether code logic is correct.

```Example```

An example of this defect is given in Listing 1. In function getWinner (L23), the contract does not check the return value of send (L26), but the array participants is emptied by assigning participatorID to 0 (L25). In this case, if the send method failed, the winner will lose 8 Ethers.

```Possible Solution```

Using ```address.transfer()``` to instead ```address.send()``` and ```address.call.value()``` if possible, or Checking the return value of send and call. 

2.) ```Transaction State Dependency```
```REF```:https://arxiv.org/pdf/1905.01467.pdf

Contracts need to check whether the caller has permissions in some functions like suicide (L33 in Listing 1). The failure of permission checks can cause serious consequences. For example, if someone passes the permission check of suicide function, he/she can destroy the contract and stole all the Ethers. tx.origin can get the original address that kicked off the transaction, but this method is not reliable since the address returned by this method depends on the transaction state.

3.) ```DOS Under External Infuence```

```REF```:https://arxiv.org/pdf/1905.01467.pdf 

```// Send 0.1 ETH to all members as bonus
function giveBonus() returns (bool) {
    /** Unmatched Type Assignment */
    for (uint256 i = 0; i < members.length; i++) {
        if (this.balance > 0.1 ether) {
            /** DoS Under External Influence */
            members[i].transfer(0.1 ether);
        }
    }
    /** Missing Return Statement */
} ```

When an exception is detected, the smart contract will rollback the transaction. However, throwing exceptions inside a loop is dangerous.

```Example```

In ```line 33``` of Listing 1, the contract uses ```transfer``` to send Ethers. However, In Solidity, ```transfer``` and ```send``` will limit the gas of ```fallback function``` in callee contracts to 2,300 gas. This gas is not enough to write to storage, call functions or send Ethers. If one of ```member[i]``` is an attacker’s smart contract and the transfer function (L33) can trigger an out-of-gas exception due to the ```2,300 gas limitation```. Then, the contract state will rollback. Since the code cannot be modified, the contract can not remove the attacker from members list, which means that if the attacker does not stop attacking, no one can get bonus anymore.

```Possible Solution```
Avoid throwing exceptions in the body of a loop. We can return a boolean value instead of throwing an exception. For example, using ```if(msg.send(…​) == false) break;``` instead of using ```msg.transfer.```

```Research Papers```

```May,2021```

https://arxiv.org/pdf/2105.02881.pdf: Abstract—Ethereum Smart contracts use blockchain to transfer values among peers on networks without central agency. These programs are deployed on decentralized applications running on top of the blockchain consensus protocol to enable people make agreements in a transparent and conflict free environment. The security vulnerabilities within those smart contracts are a potential threat to the applications and have caused huge financial losses to their users. In this paper, we present a framework that combines static and dynamic analysis to detect Reentrancy vulnerabilities in Ethereum smart contracts. This framework generates an attacker contract based on the ABI specifications of smart contracts under test and analyzes the contract interaction to precisely report Reentrancy vulnerability. We conducted a preliminary evaluation of our proposed framework on 5 modified smart contracts from Etherscan and our framework was able to detect the Reentrancy vulnerability in all our modified contracts. Our framework analyzes smart contracts statically to identify potentially vulnerable functions and then uses dynamic analysis to precisely confirm Reentrancy vulnerability, thus achieving increased performance and reduced false positives.

```April,2020```
https://arxiv.org/pdf/1905.01467.pdf:Abstract—Smart contracts are programs running on a blockchain. They are immutable to change, and hence can not be patched for bugs once deployed. Thus it is critical to ensure they are bug-free and well-designed before deployment. A Contract defect is an error, flaw or fault in a smart contract that causes it to produce an incorrect or unexpected result, or to behave in unintended ways. The detection of contract defects is a method to avoid potential bugs and improve the design of existing code. Since smart contracts contain numerous distinctive features, such as the gas system. decentralized, it is important to find smart contract specified defects. To fill this gap, we collected smart-contract-related posts from Ethereum StackExchange, as well as real-world smart contracts. We manually analyzed these posts and contracts; using them to define 20 kinds of contract defects. We categorized them into indicating potential security, availability, performance, maintainability and reusability problems. To validate if practitioners consider these contract as harmful, we created an online survey and received 138 responses from 32 different countries. Feedback showed these contract defects are harmful and removing them would improve the quality and robustness of smart contracts. We manually identified our defined contract defects in 587 real world smart contract and publicly released our dataset. Finally, we summarized 5 impacts caused by contract defects. These help developers better understand the symptoms of the defects and removal priority.

```Famous Attacks```
1.) The DAO Attack
https://www.coindesk.com/learn/2016/06/25/understanding-the-dao-attack/

```Datasets```
https://github.com/Jiachi-Chen/TSE-ContractDefects 


```Not-So-Smart-Contracts```
https://github.com/Trent122/not-so-smart-contracts

```Blockchain Elements That Need Securing```

Layer 1 
The Underlying blockchain protocol itself 
(Bitcoin Core, GETH)

Layer 2 
An Overlaying network on top of layer one typically focused on scalability (Bitcoin lighting network)

Smart Contracts 
Automatically executing programs, deployments to the blockchain. (TokensmDApps,NFTs, etc.) 

Software Wallets
Custodial Vs. non-custodial

Hardware Wallet
Physical devices for storing private keys that are used to send and recevice funds.

Mining Software 
Programs used to run specialized hardware used to perform mining operations.

Centrilzied Exchanges 
Typically require KYC (Coinbase, Voyager, Binance, Kraken, etc.)

Decentralized exchanges 
"DEFI" exchanges typically built VIA smart contracts w/Web3 front-end)

People 
Social engineering. Rug pulls, asset protection.
