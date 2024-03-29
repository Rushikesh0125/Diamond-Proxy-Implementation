// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

library StakingStorage {
    bytes32 private constant _STAKING_STORAGE_SLOT = keccak256("diamond.standard.staking_contract.storage");

    struct Stake {
        uint256 amount;
        uint256 stakedOn;
    }

    struct Layout {
        // Amount of tokens in contract
        uint256 totalStakedSTK;
        uint256 minCapStake;
        //Number of token per ETH
        uint256 aprRate;
        //lock
        bool lock;
        //STK token
        IERC20 stk;
        //record of buyed amount by user
        mapping (address => Stake) stakeByUser;
    }

    function registerStake(uint256 _amount, address user) internal {
        Stake memory stake = Stake({
            amount : _amount,
            stakedOn: block.timestamp
        });
        StakingStorage.layout().stakeByUser[user] = stake;
        StakingStorage.layout().totalStakedSTK += _amount;
    }

    function calculateRewards(uint256 _amount, uint256 timePeriod) internal view returns(uint256){
        require(timePeriod > 1 days, "StakingLib: Stake for atleast one day");
        uint256 stakedForDays = timePeriod/ 1 days;
        uint256 rewardPerDay = StakingStorage.layout().aprRate*_amount*1000/365;
        return (rewardPerDay*stakedForDays)/100000;
    }

    function layout() internal pure returns (Layout storage l) {
        bytes32 position = _STAKING_STORAGE_SLOT;
        assembly {
            l.slot := position
        }
    }
}