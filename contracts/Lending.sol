// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;
import "./Events.sol";

contract Lending is Events {
    mapping(address => uint256) private _lending;
    mapping(address => uint256) private _lending_timestamp;
    LendingStatus public _lending_status = LendingStatus.Online;
    address _lending_owner = msg.sender;

    modifier _onlyOwner() {
        require(msg.sender == _lending_owner, "You are not an owner");
        _;
    }

    enum LendingStatus {
        Offline,
        Online
    }

    uint256 public _lending_all;

    uint256 private percentDay = 40; //0.04%

    function addLending() external payable {
        require(_lending[msg.sender] == 0, "No Zero funds");
        require(_lending_timestamp[msg.sender] == 0, "No Zero time");
        require(_lending_status == LendingStatus.Online, "Lending is offline");

        _lending[msg.sender] += msg.value;
        _lending_timestamp[msg.sender] = block.timestamp;
        _lending_all += msg.value;

        emit AddLengindEvent(msg.sender, msg.value, block.timestamp);
    }

    function removeLending() external {
        require(_lending[msg.sender] > 0, "Zero funds");
        require(_lending_timestamp[msg.sender] > 0, "Zero time");

        uint256 _amount = _lending[msg.sender];
        uint256 __time = _lending_timestamp[msg.sender];

        _lending[msg.sender] = 0;
        _lending_timestamp[msg.sender] = 0;
        _lending_all -= _amount;

        uint256 _time = block.timestamp - __time;
        uint256 _days = _time / 86400;
        uint256 _reward_percent = percentDay * _days; // 0.08% total
        uint256 _reward = (_amount * _reward_percent) / 10000;

        payable(msg.sender).transfer(_amount);
        payable(msg.sender).transfer(_reward);

        emit RemoveLengindEvent(
            msg.sender,
            _amount,
            _reward,
            _reward_percent,
            _days,
            block.timestamp
        );
    }

    function lendOff(bool status) external _onlyOwner {
        if (status == true) {
            _lending_status = LendingStatus.Offline;
        } else {
            _lending_status = LendingStatus.Online;
        }
    }

    function changePercentDay (uint _percentDay) external _onlyOwner {
        require(_percentDay < 100, "Too much");
        percentDay = _percentDay;
    }
}
