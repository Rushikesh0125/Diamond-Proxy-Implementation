// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { STKTokenStorage } from "../../libraries/LibSTKToken.sol";
import {LibDiamond} from "../../libraries/LibDiamond.sol";

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

event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);

abstract contract STKBase  {
    function __ERC20_init(string memory name_, string memory symbol_, uint8 decimals_) internal {
        STKTokenStorage.layout().name = name_;
        STKTokenStorage.layout().symbol = symbol_;
        STKTokenStorage.layout().decimals = decimals_;
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual returns (bool) {
        if (owner == address(0)) revert ERC20_ApproveFromZeroAddress();
        if (spender == address(0)) revert ERC20_ApproveToZeroAddress();

        STKTokenStorage.layout().allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);
        return true;
    }

    /**
     * @notice Decrease spend amount granted by from to spender.
     * @param from address on whose behalf tokens to spend.
     * @param spender address whose allowance to decrease.
     * @param amount quantity by which to decrease allowance.
     */
    function _spendAllowance(address from, address spender, uint256 amount) internal {
        uint256 currentAllowance = _allowance(from, spender);

        if (amount > currentAllowance) revert ERC20_InsufficientAllowance();
        unchecked {
            _approve(from, spender, currentAllowance - amount);
        }
    }

    /**
     * @notice Mint tokens for given account.
     * @param account recipient of minted tokens.
     * @param amount quantity of tokens minted.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(msg.sender == LibDiamond.diamondStorage().contractOwner, "STK: Only owner can mint");
        if (account == address(0)) revert ERC20_MintToZeroAddress();

        _beforeTokenTransfer(address(0), account, amount);

        STKTokenStorage.layout().totalSupply += amount;
        STKTokenStorage.layout().balances[account] += amount;

        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @notice Burn tokens held by given account.
     * @param account from of burned tokens.
     * @param amount quantity of tokens burned.
     */
    function _burn(address account, uint256 amount) internal virtual {
        if (account == address(0)) revert ERC20_BurnFromZeroAddress();

        _beforeTokenTransfer(account, address(0), amount);

        uint256 balance = _balanceOf(account);
        if (amount > balance) revert ERC20_BurnExceedsBalance();
        unchecked {
            STKTokenStorage.layout().balances[account] = balance - amount;
        }
        STKTokenStorage.layout().totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _transfer(address from, address to, uint256 amount) internal virtual returns (bool) {
        if (from == address(0)) revert ERC20_TransferFromZeroAddress();
        if (to == address(0)) revert ERC20_TransferToZeroAddress();
        if (from == to) revert ERC20_TransferToSelf();

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balanceOf(from);
        if (amount > fromBalance) revert ERC20_TransferExceedsBalance();
        unchecked {
            STKTokenStorage.layout().balances[from] = fromBalance - amount;
        }
        STKTokenStorage.layout().balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
        return true;
    }

    function _transferFrom(address from, address to, uint256 amount) internal virtual returns (bool) {
        _spendAllowance(from, msg.sender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @notice Hook that is called before any transfer of tokens including mint and burn.
     * @param from sender of tokens.
     * @param to receiver of tokens.
     * @param amount quantity of tokens transferred.
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {
        // solhint-disable-previous-line no-empty-blocks
    }

    /**
     * @dev Hook that is called after any transfer of tokens including mint and burn.
     * @param from sender of tokens.
     * @param to receiver of tokens.
     * @param amount quantity of tokens transferred.
     */
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {
        // solhint-disable-previous-line no-empty-blocks
    }

    function _name() internal view virtual returns (string memory) {
        return STKTokenStorage.layout().name;
    }

    function _symbol() internal view virtual returns (string memory) {
        return STKTokenStorage.layout().symbol;
    }

    function _decimals() internal view virtual returns (uint8) {
        return STKTokenStorage.layout().decimals;
    }

    function _totalSupply() internal view virtual returns (uint256) {
        return STKTokenStorage.layout().totalSupply;
    }

    function _balanceOf(address account) internal view virtual returns (uint256) {
        return STKTokenStorage.layout().balances[account];
    }

    function _allowance(address from, address spender) internal view virtual returns (uint256) {
        return STKTokenStorage.layout().allowances[from][spender];
    }
}