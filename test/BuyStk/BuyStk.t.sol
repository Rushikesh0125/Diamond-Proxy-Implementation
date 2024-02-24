// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { StdCheats, StdUtils, Test } from "forge-std/Test.sol";
import {DiamondCutFacet} from "../../src/Facets/DiamondCutFacet.sol";
import {DiamondLoupeFacet} from "../../src/Facets/DiamondLoupeFacet.sol";
import {Diamond} from "../../src/DiamondProxy.sol";
import {IDiamondCut} from "../../src/interfaces/IDiamondCut.sol";
import {STKTokenFacet} from "../../src/Facets/STKToken/STKTokenFacet.sol";
import {BaseDiamondTest} from "../DiamondCut/BaseDiamond.t.sol";
import {BuyStkFacet} from "../../src/Facets/BuyStk/BuySTKFacet.sol";

contract BuyStkTest is BaseDiamondTest {
    
    BuyStkFacet buyStkFacet;
    STKTokenFacet stkFacet;

    function setUp() public override{
        super.setUp();

        dCutFacet = new DiamondCutFacet();
        diamondProxy = new Diamond(owner, address(dCutFacet));

        DiamondCutFacet dCut = DiamondCutFacet(address(diamondProxy));

        stkFacet = new STKTokenFacet();

        /// add STK Token facet cut to diamond
        bytes4[] memory stkSelectors = new bytes4[](10);
        stkSelectors[0] = STKTokenFacet.transfer.selector;
        stkSelectors[1] = STKTokenFacet.allowance.selector;
        stkSelectors[2] = STKTokenFacet.approve.selector;
        stkSelectors[3] = STKTokenFacet.balanceOf.selector;
        stkSelectors[4] = STKTokenFacet.decimals.selector;
        stkSelectors[5] = STKTokenFacet.name.selector;
        stkSelectors[6] = STKTokenFacet.symbol.selector;
        stkSelectors[7] = STKTokenFacet.totalSupply.selector;
        stkSelectors[8] = STKTokenFacet.transferFrom.selector;
        stkSelectors[9] = STKTokenFacet.mint.selector;

        IDiamondCut.FacetCut[] memory stkFacets = new IDiamondCut.FacetCut[](1);
        stkFacets[0] = IDiamondCut.FacetCut({
            facetAddress:address(stkFacet),
            action:IDiamondCut.FacetCutAction.Add,
            functionSelectors:stkSelectors
        });

        dCut.diamondCut(
            stkFacets, 
            address(stkFacet), 
            abi.encodeWithSelector(
                STKTokenFacet.ERC20_init.selector
            )
        );

        buyStkFacet = new BuyStkFacet();

        
        bytes4[] memory buyStkSelectors = new bytes4[](7);
        buyStkSelectors[0] = BuyStkFacet.addLiquidity.selector;
        buyStkSelectors[1] = BuyStkFacet.buySTK.selector;
        buyStkSelectors[2] = BuyStkFacet.withdrawFunds.selector;
        buyStkSelectors[3] = BuyStkFacet.setStkToken.selector;
        buyStkSelectors[4] = BuyStkFacet.setExRate.selector;
        buyStkSelectors[5] = BuyStkFacet.setMaxBuyCap.selector;
        buyStkSelectors[6] = BuyStkFacet.setMinBuyCap.selector;

        IDiamondCut.FacetCut[] memory buyStkFacets = new IDiamondCut.FacetCut[](1);
        buyStkFacets[0] = IDiamondCut.FacetCut({
            facetAddress:address(buyStkFacet),
            action:IDiamondCut.FacetCutAction.Add,
            functionSelectors:buyStkSelectors
        });

        dCut.diamondCut(
            buyStkFacets, 
            address(0), 
            ""
        );

        BuyStkFacet buyStkFct = BuyStkFacet(address(diamondProxy));
        buyStkFct.setStkToken(address(diamondProxy));
        buyStkFct.setExRate(2000);
        buyStkFct.setMaxBuyCap(2 ether);
        buyStkFct.setMinBuyCap(0.5 ether);
    }

    function test_add_liquidity() public{
        BuyStkFacet buyStk = BuyStkFacet(address(diamondProxy));
        STKTokenFacet stkFct = STKTokenFacet(address(diamondProxy));
        stkFct.mint(5000000*1 ether, owner);
        stkFct.approve(address(diamondProxy), 500000*1 ether);
        buyStk.addLiquidity(500000*1 ether);
        assertEq(stkFct.balanceOf(address(diamondProxy)), 500000*1 ether);
    }

    function test_buy_stk() public{
        BuyStkFacet buyStk = BuyStkFacet(address(diamondProxy));
        STKTokenFacet stkFct = STKTokenFacet(address(diamondProxy));
        stkFct.mint(5000000*1 ether, owner);
        stkFct.approve(address(diamondProxy), 500000*1 ether);
        buyStk.addLiquidity(500000*1 ether);
        address user = makeAddr("user");
        vm.startPrank(user);
        vm.deal(user, 5 ether);
        buyStk.buySTK{value:1 ether}();
        assertEq(stkFct.balanceOf(user),2000*1 ether);
    }

    function test_withdraw_funds() public{
        BuyStkFacet buyStk = BuyStkFacet(address(diamondProxy));
        STKTokenFacet stkFct = STKTokenFacet(address(diamondProxy));
        stkFct.mint(5000000*1 ether, owner);
        stkFct.approve(address(diamondProxy), 500000*1 ether);
        buyStk.addLiquidity(500000*1 ether);

        address user = makeAddr("user");
        vm.startPrank(user);
        vm.deal(user, 5 ether);
        buyStk.buySTK{value:1 ether}();
        assertEq(stkFct.balanceOf(user),2000*1 ether);

        vm.startPrank(owner);
        uint ownerAdressBefore = owner.balance;
        buyStk.withdrawFunds();
        uint ownerAdressAfter = owner.balance;
        assertEq(ownerAdressAfter > ownerAdressBefore, true);
    }

    function testFail_withdraw_funds_non_owner() public{
        BuyStkFacet buyStk = BuyStkFacet(address(diamondProxy));
        STKTokenFacet stkFct = STKTokenFacet(address(diamondProxy));
        stkFct.mint(5000000*1 ether, owner);
        stkFct.approve(address(diamondProxy), 500000*1 ether);
        buyStk.addLiquidity(500000*1 ether);

        address user = makeAddr("user");
        vm.startPrank(user);
        vm.deal(user, 5 ether);
        buyStk.buySTK{value:1 ether}();
        assertEq(stkFct.balanceOf(user),2000*1 ether);

        //vm.startPrank(owner); Not starting owner context
        uint ownerAdressBefore = owner.balance;
        buyStk.withdrawFunds();
        uint ownerAdressAfter = owner.balance;
        assertEq(ownerAdressAfter > ownerAdressBefore, true);
    }

}