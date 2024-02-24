// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {STKBase} from "./STKBase.sol";

error ERC20_ApproveFromZeroAddress();
error ERC20_ApproveToZeroAddress();
error ERC20_BurnExceedsBalance();
error ERC20_BurnFromZeroAddress();
error ERC20_InsufficientAllowance();
error ERC20_MintToZeroAddress();
error ERC20_TransferExceedsBalance();
error ERC20_TransferFromZeroAddress();
error ERC20_TransferToZeroAddress();
error ERC20_TransferToSelf();


contract STKTokenFacet is Initializable, STKBase {

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function ERC20_init() external initializer {
        __ERC20_init("STK Token", "STK", 18);
    }

    
    function name() external view returns (string memory) {
        return _name();
    }

    
    function symbol() external view returns (string memory) {
        return _symbol();
    }

 
    function decimals() external view returns (uint8) {
        return _decimals();
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        return _transfer(msg.sender, to, amount);
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        return _approve(msg.sender, spender, amount);
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        return _transferFrom(from, to, amount);
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowance(owner, spender);
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply();
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balanceOf(account);
    }

    function mint(uint256 amount, address to) external {
        _mint(to, amount);
    }
}