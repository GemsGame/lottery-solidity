// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "./ERC20.sol";

contract CryptoLottery is ERC20 {
    uint256 public _round_interval;
    uint256 public _ticket_price;
    uint256 public _fee;
    uint256 public _fee_value;
    uint256 public _token_reward;
    uint256 public _purchased_tickets;
    uint256 public _purchased_free_tickets;
    uint256 public _all_eth_reward;
    uint256 private _secret_key;
    bool public __reward_2;

    address public _owner;

    enum RoundStatus {
        End,
        Start
    }

    mapping(uint256 => Ticket[]) private _tickets;
    mapping(address => TicketRef[]) private _tickets_ref;
    mapping(address => uint256) private _free_tickets;

    Round[] public _rounds;

    constructor(
        uint256 round_interval,
        uint256 ticket_price,
        uint256 fee
    ) ERC20("Crypto Lottery", "CL") {
        _round_interval = round_interval;
        _ticket_price = ticket_price;
        _fee = fee;
        _owner = msg.sender;
        __reward_2 = true;
    }

    struct Round {
        uint256 startTime;
        uint256 endTime;
        RoundStatus status;
        uint256[] win;
        uint256 number;
    }

    struct TicketRef {
        uint256 round;
        uint256 number;
    }

    struct Ticket {
        address owner;
        uint256[6] numbers;
        uint256 win_count;
        bool win_last_digit;
        uint256 eth_reward;
        uint256 token_reward;
        bool free_ticket;
        uint256 round;
        uint256 number;
        bool paid;
        uint256 time;
        uint256 tier;
    }

    function createRound() internal {
        if (
            _rounds.length > 0 &&
            _rounds[_rounds.length - 1].status != RoundStatus.End
        ) {
            revert("Error: the last round in progress");
        }

        uint256[] memory win;

        Round memory round = Round(
            block.timestamp,
            block.timestamp + _round_interval,
            RoundStatus.Start,
            win,
            _rounds.length
        );

        _rounds.push(round);

        _mint(msg.sender, 1000 * 10**18);

        _token_reward += 1000 * 10**18;
    }

    function buyTicket(uint256[6] memory _numbers) external payable {
        require(_ticket_price == msg.value, "not valid value");
        require(
            _rounds[_rounds.length - 1].status == RoundStatus.Start,
            "Error: the last round ended"
        );

        Ticket memory ticket = Ticket(
            msg.sender,
            _numbers,
            0,
            false,
            0,
            0,
            false,
            _rounds.length - 1,
            _tickets[_rounds.length - 1].length,
            false,
            block.timestamp,
            0
        );

        TicketRef memory ticket_ref = TicketRef(
            _rounds.length - 1,
            _tickets[_rounds.length - 1].length
        );

        _tickets[_rounds.length - 1].push(ticket);
        _tickets_ref[msg.sender].push(ticket_ref);

        _purchased_tickets += 1;
    }

    function buyFreeTicket(uint256[6] memory _numbers) external {
        require(_free_tickets[msg.sender] > 0, "You do not have a free ticket");
        require(
            _rounds[_rounds.length - 1].status == RoundStatus.Start,
            "Error: the last round ended"
        );

        Ticket memory ticket = Ticket(
            msg.sender,
            _numbers,
            0,
            false,
            0,
            0,
            false,
            _rounds.length - 1,
            _tickets[_rounds.length - 1].length,
            false,
            block.timestamp,
            0
        );

        TicketRef memory ticket_ref = TicketRef(
            _rounds.length - 1,
            _tickets[_rounds.length - 1].length
        );

        _tickets[_rounds.length - 1].push(ticket);
        _tickets_ref[msg.sender].push(ticket_ref);

        _free_tickets[msg.sender] -= 1;
        _purchased_free_tickets += 1;
    }

    function _random(uint256 key) internal view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        key,
                        block.difficulty,
                        block.timestamp,
                        _tickets[_rounds.length - 1].length,
                        block.coinbase
                    )
                )
            );
    }

    function lastCombination() internal {
        if (_rounds[_rounds.length - 1].win.length == 0) {
            uint256[6] memory _cache;
            uint256 _num;

            for (uint256 i = 0; i < 6; i++) {
                if (i < 5) {
                    _secret_key += 1;
                    uint256 _number = _random(_secret_key) % 69;
                    _cache[i] = _number + 1;
                } else {
                    _secret_key += 1;
                    uint256 _number = _random(_secret_key) % 26;
                    _cache[i] = _number + 1;
                }
            }

            for (uint256 i = 0; i < _cache.length; i++) {
                for (uint256 z = 0; z < _cache.length; z++) {
                    if (_cache[i] == _cache[z]) {
                        _num += 1;
                    }
                }
            }

            if (_num > 6) {
                lastCombination();
            } else {
                _rounds[_rounds.length - 1].win = _cache;
            }
        } else {
            revert("Error: the win combination already exist");
        }
    }

    function closeRound() internal {
        if (_rounds[_rounds.length - 1].status == RoundStatus.End) {
            revert("The round end");
        }

        if (block.timestamp < _rounds[_rounds.length - 1].endTime) {
            revert("The round can't closed");
        }

        _rounds[_rounds.length - 1].status = RoundStatus.End;

        lastCombination();
    }
    
    function claimPay(uint256 round, uint256 number) internal returns (uint) {
        require(
            msg.sender == _tickets[round][number].owner,
            "You are not an owner"
        );
        require(
            _rounds[round].status == RoundStatus.End,
            "The Round is in process"
        );

        require(_tickets[round][number].paid == false, "The Ticket was paid");

        _tickets[round][number].paid = true;

        if (_tickets[round][number].free_ticket == true) {
            _free_tickets[_tickets[round][number].owner] += 1;
        }
        if (_tickets[round][number].eth_reward > 0) {
            payable(_tickets[round][number].owner).transfer(
                _tickets[round][number].eth_reward
            );
        }

        if (_tickets[round][number].token_reward > 0) {
            _mint(
                _tickets[round][number].owner,
                _tickets[round][number].token_reward
            );
        }

        return _tickets[round][number].tier;
    }

    function getTicketWinNumbers(uint256 round, uint256 number) internal {
        
        require(_tickets[round][number].win_count == 0, "Win numbers already exist");

        uint256[] memory _numbers = _rounds[round].win;
        

        for (
            uint256 z = 0;
            z < _tickets[round][number].numbers.length;
            z++
        ) {
            for (uint256 y = 0; y < _numbers.length; y++) {
                if (_tickets[round][number].numbers[z] == _numbers[y]) {
                    _tickets[round][number].win_count += 1;

                    if (_numbers[y] == 6) {
                        _tickets[round][number].win_last_digit = true;
                    }
                }
            }
        }
    }

    function addTicketReward(uint round, uint number) internal {

      require(_tickets[round][number].token_reward == 0, "Token reward already exist");

      require(_tickets[round][number].eth_reward == 0, "Eth reward already exist");
        /* 
      0 - free ticket + 50 CL
      1 - free ticket + 100 CL
      
      0 + 1 - x2 + 2000 CL
      1 + 1 x2 + 2000 CL  
      2 - x2 + 2000 CL
      
      2 + 1 - x5 + 5000 CL
      3 - x10 + 10000 CL
      3 + 1 - x50  + 50000  CL
      4 + 0 - x100 + 100000 CL
       
      // jackpots
 
      4 + 1 - 2% of bank
      5 + 0 - 10% of bank
      5 + 1 - 30% of bank
 
     */

            if (_tickets[round][number].win_count == 0) {
                _tickets[round][number].token_reward = 50 * 10**18;
                _tickets[round][number].free_ticket = true;

                _token_reward += _tickets[round][number].token_reward;
                _tickets[round][number].tier = 1;
            }

            if (
                _tickets[round][number].win_count == 1 &&
                _tickets[round][number].win_last_digit == false &&
                __reward_2 == true
            ) {
                _tickets[round][number].free_ticket = true;
                _tickets[round][number].token_reward = 100 * 10**18;
                _token_reward += _tickets[round][number].token_reward;
                 _tickets[round][number].tier = 2;
            }

            if (
                _tickets[round][number].win_count == 1 &&
                _tickets[round][number].win_last_digit == true
            ) {
                _tickets[round][number].eth_reward = _ticket_price * 2;
                _tickets[round][number].token_reward = 2000 * 10**18;
                _token_reward += _tickets[round][number].token_reward;

                _fee_value += (_fee * (_ticket_price * 2)) / 100;

                _all_eth_reward += _tickets[round][number].eth_reward;

                _tickets[round][number].tier = 3;
            }

            if (
                _tickets[round][number].win_count == 2 &&
                _tickets[round][number].win_last_digit == false
            ) {
                _tickets[round][number].eth_reward = _ticket_price * 2;
                _tickets[round][number].token_reward = 2000 * 10**18;
                _token_reward += _tickets[round][number].token_reward;

                _fee_value += (_fee * (_ticket_price * 2)) / 100;

                _all_eth_reward += _tickets[round][number].eth_reward;

                _tickets[round][number].tier = 4;
            }

            if (
                _tickets[round][number].win_count == 2 &&
                _tickets[round][number].win_last_digit == true
            ) {
                _tickets[round][number].eth_reward = _ticket_price * 2;
                _tickets[round][number].token_reward = 2000 * 10**18;
                _token_reward += _tickets[round][number].token_reward;

                _fee_value += (_fee * (_ticket_price * 2)) / 100;

                _all_eth_reward += _tickets[round][number].eth_reward;

                _tickets[round][number].tier = 5;
            }

            if (
                _tickets[round][number].win_count == 3 &&
                _tickets[round][number].win_last_digit == true
            ) {
                _tickets[round][number].eth_reward = _ticket_price * 5;
                _tickets[round][number].token_reward = 5000 * 10**18;
                _token_reward += _tickets[round][number].token_reward;

                _fee_value += (_fee * (_ticket_price * 5)) / 100;

                _all_eth_reward += _tickets[round][number].eth_reward;

                _tickets[round][number].tier = 6;
            }

            if (
                _tickets[round][number].win_count == 3 &&
                _tickets[round][number].win_last_digit == false
            ) {
                _tickets[round][number].eth_reward = _ticket_price * 10;
                _tickets[round][number].token_reward = 10000 * 10**18;

                _token_reward += _tickets[round][number].token_reward;

                _fee_value += (_fee * (_ticket_price * 10)) / 100;

                _all_eth_reward += _tickets[round][number].eth_reward;

                _tickets[round][number].tier = 7;
            }

            if (
                _tickets[round][number].win_count == 4 &&
                _tickets[round][number].win_last_digit == true
            ) {
                _tickets[round][number].eth_reward = _ticket_price * 50;
                _tickets[round][number].token_reward = 50000 * 10**18;
                _token_reward += _tickets[round][number].token_reward;

                _fee_value += (_fee * (_ticket_price * 50)) / 100;

                _all_eth_reward += _tickets[round][number].eth_reward;

                _tickets[round][number].tier = 8;
            }

            if (
                _tickets[round][number].win_count == 4 &&
                _tickets[round][number].win_last_digit == false
            ) {
                _tickets[round][number].eth_reward =
                    _ticket_price *
                    100;
                _tickets[round][number].token_reward = 100000 * 10**18;

                _token_reward += _tickets[round][number].token_reward;

                _fee_value += ((_fee * (_ticket_price * 100)) / 100);

                _all_eth_reward += _tickets[round][number].eth_reward;

                _tickets[round][number].tier = 9;
            }

            if (
                _tickets[round][number].win_count == 5 &&
                _tickets[round][number].win_last_digit == true
            ) {
                _tickets[round][number].eth_reward =
                    (2 * address(this).balance) /
                    100;

                _fee_value +=
                    (_fee * _tickets[round][number].eth_reward) /
                    100;

                _all_eth_reward += _tickets[round][number].eth_reward;

                _tickets[round][number].tier = 10;
            }

            if (
                _tickets[round][number].win_count == 5 &&
                _tickets[round][number].win_last_digit == false
            ) {
                _tickets[round][number].eth_reward =
                    (10 * address(this).balance) /
                    100;

                _fee_value +=
                    (_fee * _tickets[round][number].eth_reward) /
                    100;

                _all_eth_reward += _tickets[round][number].eth_reward;

                _tickets[round][number].tier = 11;
            }

            if (
                _tickets[round][number].win_count == 6 &&
                _tickets[round][number].win_last_digit == true
            ) {
                _tickets[round][number].eth_reward =
                    (30 * address(this).balance) /
                    100;

                _fee_value +=
                    (_fee * _tickets[round][number].eth_reward) /
                    100;

                _all_eth_reward += _tickets[round][number].eth_reward;

                _tickets[round][number].tier = 12;
            }
        
    }

    function claimTicketReward (uint round, uint number) external returns(uint) {
        getTicketWinNumbers(round, number);
        addTicketReward(round, number);
        return claimPay(round, number);
    }

    function claimOwnerReward() external {
        require(_owner == msg.sender, "you are not an owner");

        payable(_owner).transfer(_fee_value);

        _mint(_owner, _token_reward);

        _fee_value = 0;
        _token_reward = 0;
    }

    function getRoundsCount() external view returns (uint256) {
        return _rounds.length;
    }

    function getLastTicketsCount() external view returns (uint256) {
        return _tickets[_rounds.length - 1].length;
    }

    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getTicketRef(address user)
        external
        view
        returns (TicketRef[] memory ref)
    {
        TicketRef[] memory ref_ = new TicketRef[](_tickets_ref[user].length);

        for (uint256 i = 0; i < _tickets_ref[user].length; i++) {
            ref_[i] = _tickets_ref[user][i];
        }

        return ref_;
    }

    function getRoundById(uint256 id)
        external
        view
        returns (Round[] memory _round)
    {
        Round[] memory round = new Round[](1);
        round[0] = _rounds[id];
        return round;
    }

    function getLastRound() external view returns (Round[] memory _round) {
        Round[] memory round = new Round[](1);
        round[0] = _rounds[_rounds.length - 1];
        return round;
    }

    function getLastRounds(uint256 cursor, uint256 howMany)
        external
        view
        returns (
            Round[] memory rounds,
            uint256 newCursor,
            uint256 total
        )
    {
        uint256 length = howMany;
        uint256 _total = _rounds.length;
        if (length > _rounds.length - cursor) {
            length = _rounds.length - cursor;
        }

        Round[] memory _rounds_array = new Round[](_total);
        Round[] memory __array = new Round[](length);

        uint256 j = 0;

        for (uint256 i = _total; i >= 1; i--) {
            _rounds_array[j] = _rounds[i - 1];
            j++;
        }

        for (uint256 i = 0; i < length; i++) {
            __array[i] = _rounds_array[cursor + i];
        }

        return (__array, cursor + length, _total);
    }

    function getLastTickets(uint256 cursor, uint256 howMany)
        external
        view
        returns (
            Ticket[] memory tickets,
            uint256 newCursor,
            uint256 total
        )
    {
        uint256 length = howMany;
        uint256 _total = _tickets[_rounds.length - 1].length;
        if (length > _tickets[_rounds.length - 1].length - cursor) {
            length = _tickets[_rounds.length - 1].length - cursor;
        }

        Ticket[] memory ticket_array = new Ticket[](_total);
        Ticket[] memory __array = new Ticket[](length);

        uint256 j = 0;

        for (uint256 i = _total; i >= 1; i--) {
            ticket_array[j] = _tickets[_rounds.length - 1][i - 1];
            j++;
        }

        for (uint256 i = 0; i < length; i++) {
            __array[i] = ticket_array[cursor + i];
        }

        return (__array, cursor + length, _total);
    }

    function getUserTickets(
        address user,
        uint256 cursor,
        uint256 howMany
    )
        external
        view
        returns (
            Ticket[] memory tickets,
            uint256 newCursor,
            uint256 total
        )
    {
        uint256 length = howMany;
        uint256 _total = _tickets_ref[user].length;
        if (length > _tickets_ref[user].length - cursor) {
            length = _tickets_ref[user].length - cursor;
        }

        Ticket[] memory ticket_array = new Ticket[](_total);
        Ticket[] memory __array = new Ticket[](length);

        uint256 j = 0;

        for (uint256 i = _tickets_ref[user].length; i >= 1; i--) {
            ticket_array[j] = _tickets[_tickets_ref[user][i - 1].round][
                _tickets_ref[user][i - 1].number
            ];
            j++;
        }

        for (uint256 i = 0; i < length; i++) {
            __array[i] = ticket_array[cursor + i];
        }

        return (__array, cursor + length, _total);
    }

    function getUserFreeTicketsCount(address user)
        external
        view
        returns (uint256)
    {
        return _free_tickets[user];
    }

    function _switch_free_token_bonus(bool status) external {
        require(msg.sender == _owner, "You are not an owner");
        __reward_2 = status;
    }

    function _change_round_interval(uint256 interval) external {
        require(msg.sender == _owner, "You are not an owner");
        require(interval >= 1000, "Too short");
        _round_interval = interval;
    }

    function _change_ticket_price(uint256 price) external {
        require(msg.sender == _owner, "You are not an owner");
        require(price >= 1000, "Too short");
        _ticket_price = price;
    }

    function nextGame() external {
        if (_rounds.length > 0) {
            closeRound();
        }

        createRound();
    }

    receive() external payable {}
}
