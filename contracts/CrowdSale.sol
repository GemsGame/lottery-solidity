// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;
import "./Token.sol";
import "./Events.sol";
import "./Lottery.sol";

contract CrowdSale is Token, Events, Lottery {

   uint public tokenPrice;
   uint public softCap;
   uint public raisedAmount;
   uint public withdrawAmount;
   bool public inProgress;

   constructor(uint _tokenPrice, uint _interval, uint _t_price, uint _f, uint _ico_soft_cap) Lottery(_interval, _t_price, _f) {
     tokenPrice = _tokenPrice;
     inProgress = true;
     softCap = _ico_soft_cap;
   }

   function deposit () external payable {
     require(inProgress == true, 'Ico is over');

     raisedAmount += msg.value;

     uint tokens = msg.value / tokenPrice;
     _token_reward += tokens;

     _mint(msg.sender, tokens);
     emit DepositEvent(msg.value, tokens);
   }

   function winthdraw (uint amount) external {
     require(msg.sender == _owner, 'You are not an owner');
     require(withdrawAmount + amount <= raisedAmount, 'Contract is empty');
     
     withdrawAmount += amount;

     _owner.transfer(amount);

     emit WithdrawEvent(amount);
   }
   
   
}