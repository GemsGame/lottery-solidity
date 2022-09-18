// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;
import "./Lottery.sol";
import "./CrowdSale.sol";

contract CryptoLottery is Lottery, CrowdSale {
    uint private _cap = 100000 * 10 ** 18;
    uint private _price = 100000 * 10 ** 15;
    uint private _interval = 86400;
    uint private _t_price = 1 * 10 ** 15;
    uint private _f = 10;
    address payable private _ico_owner = payable(msg.sender);

    constructor() Lottery(_interval, _t_price, _f) CrowdSale(_cap, _price, _ico_owner) {}
} 
