// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {StakingStorage} from "../../libraries/LibStaking.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {LibDiamond} from "../../libraries/LibDiamond.sol";

contract StakingFacet is Initializable {

    struct Stake {
        uint256 amount;
        uint256 stakedOn;
    }

    modifier ReEntrantLock {
        require(StakingStorage.layout().lock == false);
        StakingStorage.layout().lock = true;
        _;
        StakingStorage.layout().lock = false;
    }

    function setStkToken(address _stk) external {
        require(msg.sender == LibDiamond.contractOwner(),"Only owner");
        StakingStorage.layout().stk = IERC20(_stk);
    }


    function setAprRate(uint256 _aprRate) external {
        require(msg.sender == LibDiamond.contractOwner(),"Only owner");
        StakingStorage.layout().aprRate = _aprRate;
    }

    function stakeSTK(uint256 _amount) external ReEntrantLock{

        StakingStorage.registerStake(_amount, msg.sender);

        uint256 balanceBefore = StakingStorage.layout().stk.balanceOf(address(this));
        StakingStorage.layout().stk.transferFrom(msg.sender, address(this), _amount);
        uint256 balanceAfter = StakingStorage.layout().stk.balanceOf(address(this));

        require(balanceBefore - balanceAfter == _amount);
    }

    function unstakeSTK() external ReEntrantLock{
        uint256 amountStake = StakingStorage.layout().stakeByUser[msg.sender].amount;
        require(amountStake > 0, "StakingFacet: No Stake Found");
        uint256 stakedOn = StakingStorage.layout().stakeByUser[msg.sender].stakedOn;
        uint256 rewardsToPayout = StakingStorage.calculateRewards(amountStake, block.timestamp - stakedOn);

        delete StakingStorage.layout().stakeByUser[msg.sender];

        uint256 balanceBefore = StakingStorage.layout().stk.balanceOf(msg.sender);
        StakingStorage.layout().stk.transferFrom(address(this), msg.sender, rewardsToPayout);
        uint256 balanceAfter = StakingStorage.layout().stk.balanceOf(msg.sender);
        require(balanceAfter - balanceBefore == rewardsToPayout);
    }

    function getStakeByUser(address user) external view returns(uint256){
        return StakingStorage.layout().stakeByUser[user].amount;
    }

    function addLiquidityForRewards(uint256 _amount) external ReEntrantLock{
        require(msg.sender == LibDiamond.contractOwner(),"Only owner");
        uint256 balanceBefore = StakingStorage.layout().stk.balanceOf(address(this));
        StakingStorage.layout().stk.transferFrom(msg.sender, address(this), _amount);
        uint256 balanceAfter = StakingStorage.layout().stk.balanceOf(address(this));
        require(balanceAfter - balanceBefore == _amount);
    }
}