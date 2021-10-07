# Smart-Contract-Security-Maintenance
Research Papers focused on Smart-contracts security topics. As well as listing all the encountered smart-contracts defects with a summary description. 🛡️

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

3.) DOS Under External Infuence

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
