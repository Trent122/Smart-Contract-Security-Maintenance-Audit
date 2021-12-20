pragma solidity ^0.8.2;

contract Intake {
    /// @dev Mapping of ether shares of the contract.
    mapping(address => uint) shares;

    /// Withdraw your share.
    function withdraw() public {
        uint share = shares[msg.sender];
        shares[msg.sender] = 0;
        (bool success,)=msg.sender.call{value: share}("");
    }
}
