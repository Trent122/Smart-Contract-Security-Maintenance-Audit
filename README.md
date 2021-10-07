# Smart-Contract-Security-Maintenance
Research Papers focused on Smart-contracts security topics. As well as listing all the encountered smart-contracts defects with a summary description. 🛡️

1. Unchecked External Calls
REF: https://arxiv.org/pdf/1905.01467.pdf

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
