// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;
import "./Token.sol";


contract CrowdSale is Token {

   event Invest(uint value, uint tokens);

   address payable ico_owner;
   uint public tokenPrice;
   uint public hardCap;
   uint public raisedAmount;

   constructor(uint _tokenPrice, uint _hardCap, address payable _ico_owner) {
     tokenPrice = _tokenPrice;
     hardCap = _hardCap;
     ico_owner = _ico_owner;
   }

   function invest () external payable {
     require(raisedAmount + msg.value <= hardCap, "We touched a hardCap");
     raisedAmount += msg.value;

     uint tokens = msg.value / tokenPrice;

     _mint(msg.sender, tokens);
     
     emit Invest(msg.value, tokens);
     
     ico_owner.transfer(msg.value);
   }
   
}