// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

library BuySTKStorage {
    bytes32 private constant _BUY_STK_STORAGE_SLOT = keccak256("diamond.standard.buy_stk_contract.storage");

    struct Layout {
        // Amount of tokens in contract
        uint256 liquidity;
        //Number of token per ETH
        uint256 exchangeRate;
        //max cap of buy
        uint256 maxBuyCap;
        //min cap of buy
        uint256 minBuyCap;
        //STK token
        IERC20 stk;
        //lock
        bool lock;
        //record of buyed amount by user
        mapping (address => uint) amountBoughtBy;
    }

    function calculatePayout(uint256 _ethAmount) internal view returns(uint256){
        uint exRate = BuySTKStorage.layout().exchangeRate;
        return _ethAmount*exRate;
    }

    function layout() internal pure returns (Layout storage l) {
        bytes32 position = _BUY_STK_STORAGE_SLOT;
        assembly {
            l.slot := position
        }
    }

}