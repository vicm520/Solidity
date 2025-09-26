//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IBank {
    function withdraw(uint256 amount) external;
    function depositRecord() external payable;
}

contract Bank {
    address public owner;
    // 记录每个地址的累计存款金额
    mapping (address => uint) public deposits;
    // 存储前 3 位存款用户
    address[3] public firstThreeDepositors;
    // 计数器
    uint8 public firstDepositorCount;
    

    constructor() {
        owner = msg.sender;
    }

    // 通过 Metamask 等钱包直接给银行合约地址
    receive() external payable {
        depositRecord();
    }
    fallback() external {

    }

    modifier onlyOwner {
        require(owner == msg.sender, "Illegal permission"); 
        _;
    }
    
    // 记录存款信息
    function depositRecord() public payable virtual { 
        
        // 累计到用户存储金额
        deposits[msg.sender] += msg.value;
        // 当该用户为第一次存款
        if (deposits[msg.sender] == 0 && firstDepositorCount < 3) {
            firstThreeDepositors[firstDepositorCount] = msg.sender;
            firstDepositorCount += 1;
        } 
    }


    // 取款方法
    function withdraw(uint256 amount) public onlyOwner{
        // 数据处理
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


contract BigBank is Bank {
    uint256 public constant MIN_DEPOSIT = 1000000000000000;

    modifier VerifyTheAmount{
        require(msg.value > MIN_DEPOSIT, "Amount must be > 0.001 ether"); 
        _;
    }

    // 限制支付最小金额
    function depositRecord() public payable override VerifyTheAmount {
        super.depositRecord();
    }

    // 转移管理员
    function transferOwner(address toAddress) public onlyOwner {
        require(toAddress != address(0), "cannot be an empty address"); 
        require(toAddress != owner, "Cannot be transferred to oneself"); 
        owner = toAddress;
    } 

}


