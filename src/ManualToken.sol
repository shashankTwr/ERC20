// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract ManualToken {
    // my_address -> 10 tokens
    mapping (address => uint256) private s_balances;
    string public name = "Manual token";

    // function nameToken() public pure returns (string memory){
    //     return "Manual token";
    // }

    function totalSupply() public pure returns (uint256){
    
        return 100 ether; // 100 ETH
    }

    function decimals() public pure returns (uint8){
        return 18;
    }

    function symbol() public pure returns (string memory){
        return "MTK";
    }

    function balanceOf(address _owner) public view returns (uint256){
        return s_balances[_owner]; // 100 ETH
    }

    function transfer(address _to, uint256 _amount) public {
        uint256 previousBalances = balanceOf(msg.sender) + balanceOf(_to);
        s_balances[msg.sender] -= _amount;
        s_balances[_to] += _amount;
        require(balanceOf(msg.sender) + balanceOf(_to) == previousBalances);
    }

}