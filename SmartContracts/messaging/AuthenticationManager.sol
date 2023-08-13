// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract AuthenticationManager{

    mapping(string=>address) users;
    mapping(address => bool) _isAuthenticated;

    function authenticate(string calldata nullifier) public payable{
        require(!_isAuthenticated[msg.sender],"User Authenticated Before");
        require(users[nullifier] == address(0),"This nullifier is registered before");
        users[nullifier] = msg.sender;
        _isAuthenticated[msg.sender] = true;
    }

    function isAuthenticated() public view returns(bool){
        return _isAuthenticated[msg.sender];
    }
}