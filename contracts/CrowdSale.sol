// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;
import "./Token.sol";


contract CrowdSale is Token {

   event Invest(uint value, uint tokens);
   event Withdraw(uint amount);
   event InProgress(bool value);

   address payable _owner;
   uint public tokenPrice;
   uint public raisedAmount;
   uint public withdrawAmount;
   bool public inProgress;

   constructor(uint _tokenPrice) {
     tokenPrice = _tokenPrice;
     _owner = payable(msg.sender);
     inProgress = true;
   }

   function invest () external payable {
     require(inProgress == true, 'Presale is over');

     raisedAmount += msg.value;

     uint tokens = msg.value / tokenPrice;

     _mint(msg.sender, tokens);
     
     emit Invest(msg.value, tokens);
   }

   function winthdraw (uint amount) external {
     require(msg.sender == _owner, 'You are not an owner');
     require(withdrawAmount + amount <= raisedAmount, 'Contract is empty');
     
     withdrawAmount += amount;

     _owner.transfer(amount);

     emit Withdraw(amount);
   }
   

   function setInProgress (bool value) external {
     require(msg.sender == _owner, 'You are not an owner');
     inProgress = value;
     emit InProgress(value);
   }
   
}