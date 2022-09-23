// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract Events {
  event ClaimTicketRewardEvent(uint tier, bool free_ticket, uint token_reward, uint eth_reward );
  event DepositEvent(uint value, uint tokens);
  event WithdrawEvent(uint amount);
  event CreateRoundEvent(uint round);
  event BuyTicketEvent(uint number);
  event BuyFreeTicketEvent(uint number);
  event BuyCLTicketEvent(uint number);
}