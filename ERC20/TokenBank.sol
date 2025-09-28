// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

contract TokenBank {

    IERC20 public token;
    address public owner;
    

    // 映射  地址  - 数量
    mapping(address => uint256) public deposits;

    constructor(address _tokenAddress){
        owner = msg.sender;
        token = IERC20(_tokenAddress);
    }

    modifier onlyOwner {
        require(owner == msg.sender, "Illegal permission"); 
        _;
    }
    
    // 通知事件
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event OwnerWithdraw(address indexed admin, uint256 amount);
    
    // deposit() : 需要记录每个地址的存入数量；
    function deposit(uint256 amount) external returns (bool){
        // 参数鉴权
        require(amount > 0, "Amount must be greater than 0");
        require(token.balanceOf(msg.sender) >= amount, "Insufficient balance");
        // 查询授权额度
        uint256 allowedAmount = token.allowance(msg.sender, address(this));
        require(allowedAmount >= amount, "Insufficient authorization limit");

        // 进行转账
        token.transferFrom(msg.sender, address(this), amount);
        // 记录用户存款
        deposits[msg.sender] += amount;
        
        emit Deposit(msg.sender, amount);
        return true;
    }


    // withdraw（）: 用户可以提取自己的之前存入的 token。
    function withdraw(uint256 amount) external returns (bool){
        // 参数鉴权
        require(amount > 0, "Amount must be greater than 0");
        require(deposits[msg.sender] >= amount, "Insufficient balance");
        
        // 记录用户提取
        deposits[msg.sender] -= amount;

        // 进行转账 从合约转回给用户
        bool success = token.transfer(msg.sender, amount);
        require(success, "Token transfer failed");
        emit Withdraw(msg.sender, amount);
        return true;
    }


    // 管理员可以提取所有的Token (ownerWithdraw 方法)。
    function ownerWithdraw() external onlyOwner returns (bool){
        uint256 bankBalance = token.balanceOf(address(this));
        require(bankBalance > 0, "No tokens to withdraw");

         // 进行转账
        bool success = token.transfer(owner, bankBalance);
        require(success, "Token transfer failed");

        emit OwnerWithdraw(msg.sender, bankBalance);
        return true;
    }

    // 检查用户的授权额度
    function getAllowance(address user) external view returns (uint256) {
        return token.allowance(user, address(this));
    }
    
    // 检查用户存款
    function getDeposit(address user) external view returns (uint256) {
        return deposits[user];
    }
    
    // 检查银行总存款
    function getBankBalance() external view returns (uint256) {
        return token.balanceOf(address(this));
    }

    


}