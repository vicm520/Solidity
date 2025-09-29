// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../ERC20/TokenBank.sol";
import "./BaseERC20V2.sol";

contract TokenBankV2 is TokenBank,ITokenReceiver {

    BaseERC20V2  public expandToken;
    
    constructor(address _tokenAddress) TokenBank( _tokenAddress) {
        expandToken = BaseERC20V2 (_tokenAddress);
    }

    

    // 回调方法
    function tokensReceived(address from, uint256 amount) external override returns (bool){
        require(msg.sender == address(token), "Only accepted token can call this function");
        deposits[from] += amount;
        emit Deposit(from, amount);
        return true;
    }


}