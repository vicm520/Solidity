//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

contract Bank {
    address public immutable owner;
    // 记录每个地址的累计存款金额
    mapping (address => uint) public deposits;
    // 存储前 3 位存款用户
    address[3] public firstThreeDepositors;
    // 记录一个地址是否曾经存款过（用于唯一性判断）
    mapping(address => bool) private hasDepositedBefore;
    // 计数器
    uint8 public firstDepositorCount;
    

    constructor() {
        owner = msg.sender;
    }

    // 通过 Metamask 等钱包直接给银行合约地址
    receive() external payable {
        depositRecord(msg.sender,msg.value);
    }
    
    // 记录存款信息
    function depositRecord(address from, uint256 amount) internal { 
        
        // 累计到用户存储金额
        deposits[from] += amount;
        // 当该用户为第一次存款
        if (!hasDepositedBefore[from] && firstDepositorCount < 3) {
            hasDepositedBefore[from] = true;
            firstThreeDepositors[firstDepositorCount] = from;
            firstDepositorCount += 1;
        } else if (!hasDepositedBefore[from]) {
            // 即使超过前三名，也标记为已出现，避免重复判断
            hasDepositedBefore[from] = true;
        }
    }


    // 取款方法
    function withdraw(uint256 amount) public {
        // 数据处理
        require(owner == msg.sender, "Illegal permission"); 
        require(amount > 0, "The amount is illegal");
        require(address(this).balance >= amount, "Insufficient balance");
        (bool success, ) = msg.sender.call{value:  amount}("");
        require(success, "Failed to send Ether");
    }



    // 查询指定地址在银行合约中的存款余额
    function balanceOf(address user) external view returns (uint) {
        return deposits[user];
    }

    // 查询前三位用户列表
    function getFirstThreeDepositors() external view returns (address[3] memory) {
        return firstThreeDepositors;
    }
    

}