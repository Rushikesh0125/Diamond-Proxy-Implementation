// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {BuySTKStorage} from "../../libraries/LibBuySTK.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {LibDiamond} from "../../libraries/LibDiamond.sol";

event BoughtSTK(address user, uint256 amount);

error NoLiquidity();
error MaxBuyCapReached();

contract BuyStkFacet is Initializable{

    modifier ReEntrantLock {
        require(BuySTKStorage.layout().lock == false);
        BuySTKStorage.layout().lock = true;
        _;
        BuySTKStorage.layout().lock = false;
    }

    function setExRate(uint256 _exRate) public{
        require(msg.sender == LibDiamond.contractOwner(),"Only owner");
        BuySTKStorage.layout().exchangeRate = _exRate;
    }

    function setMaxBuyCap(uint256 _cap) public{
        require(msg.sender == LibDiamond.contractOwner(),"Only owner");
        BuySTKStorage.layout().maxBuyCap = _cap;
    }

    function setMinBuyCap(uint256 _cap) public{
        require(msg.sender == LibDiamond.contractOwner(),"Only owner");
        BuySTKStorage.layout().minBuyCap = _cap;
    }

    function setStkToken(address stkToken) external {
        require(msg.sender == LibDiamond.contractOwner(),"Only owner");
        BuySTKStorage.layout().stk = IERC20(stkToken);
    }

    function addLiquidity(uint256 _amount) external ReEntrantLock{
        require(_amount != 0, "BuySTKBase: Invalid _amount");
        require(msg.sender == LibDiamond.contractOwner(),"Only owner");
        uint256 balanceBefore = BuySTKStorage.layout().stk.balanceOf(address(this));
        BuySTKStorage.layout().stk.transferFrom(msg.sender, address(this), _amount);
        uint256 balanceAfter = BuySTKStorage.layout().stk.balanceOf(address(this));
        require(balanceAfter - balanceBefore == _amount);
    }

    function buySTK() external payable ReEntrantLock{
        require(msg.value > 0, "BuySTKBase: No value passed");
        require(msg.value > BuySTKStorage.layout().minBuyCap, "BuySTKBase: less than min cap");
        require(msg.value < BuySTKStorage.layout().maxBuyCap, "BuySTKBase: more than max cap");

        uint256 amountToSend = BuySTKStorage.calculatePayout(msg.value);
        uint256 balanceBefore = BuySTKStorage.layout().stk.balanceOf(msg.sender);
        BuySTKStorage.layout().stk.transfer(msg.sender, amountToSend);
        uint256 balanceAfter = BuySTKStorage.layout().stk.balanceOf(msg.sender);

        require(balanceAfter - balanceBefore == amountToSend);
    }

    function withdrawFunds() external ReEntrantLock{
        require(msg.sender == LibDiamond.contractOwner(),"Only owner");
        require(address(this).balance > 0, "No Funds");
        (bool success, ) = payable(msg.sender).call{value:address(this).balance}("");
        require(success);
    }


}