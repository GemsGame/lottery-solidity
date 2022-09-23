// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;
import "./Lottery.sol";
import "./CrowdSale.sol";

contract CryptoLottery is CrowdSale {
    uint private _ico_price = 100000 * 10 ** 15;
    uint private _ico_soft_cap = 100000 * 10 ** 18;
    uint private _interval = 86400;
    uint private _ticket_p = 1 * 10 ** 15;
    uint private _f = 10;
    uint private _ico_time = 86400 * 90;
    
    constructor() CrowdSale(_ico_price, _interval, _ticket_p, _f, _ico_soft_cap, _ico_time) {}
} 
