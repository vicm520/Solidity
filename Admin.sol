//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./Bank.sol";
// 编写一个 Admin 合约， Admin 合约有自己的 Owner ，同时有一个取款函数 adminWithdraw(IBank bank) , 
//adminWithdraw 中会调用 IBank 接口的 withdraw 方法从而把 bank 合约内的资金转移到 Admin 合约地址。
// BigBank 和 Admin 合约 部署后，把 BigBank 的管理员转移给 Admin 合约地址，模拟几个用户的存款，然后
// Admin 合约的Owner地址调用 adminWithdraw(IBank bank) 把 BigBank 的资金转移到 Admin 地址。

contract Admin {
    address public owner;

    constructor(){
        owner = msg.sender;
    }

    receive() external payable {}
    fallback() external payable {}

    modifier onlyOwner {
        require(owner == msg.sender, "Illegal permission"); 
        _;
    }

    function adminWithdraw(IBank bank,uint256 amount) public onlyOwner {
        try bank.withdraw(amount) {
        } catch Error(string memory reason) {
            // 处理明确的错误信息（包括权限错误 "Illegal permission"）
            if (keccak256(abi.encodePacked(reason)) == keccak256(abi.encodePacked("Illegal permission"))) {
                revert("Admin is not the owner of this bank");
            } else {
                revert(string(abi.encodePacked("Withdraw failed: ", reason)));
            }
        } catch  {
            revert("a pile error");
        } 
    }

    function withdraw(uint256 amount) public onlyOwner{
        require(amount > 0, "The amount is illegal");
        require(address(this).balance >= amount, "Insufficient balance");
        (bool success, ) = msg.sender.call{value:  amount}("");
        require(success, "Failed to send Ether");
    }



}