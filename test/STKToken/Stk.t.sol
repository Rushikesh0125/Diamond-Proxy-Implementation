// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { StdCheats, StdUtils, Test } from "forge-std/Test.sol";
import {DiamondCutFacet} from "../../src/Facets/DiamondCutFacet.sol";
import {DiamondLoupeFacet} from "../../src/Facets/DiamondLoupeFacet.sol";
import {Diamond} from "../../src/DiamondProxy.sol";
import {IDiamondCut} from "../../src/interfaces/IDiamondCut.sol";
import {STKTokenFacet} from "../../src/Facets/STKToken/STKTokenFacet.sol";
import {BaseDiamondTest} from "../DiamondCut/BaseDiamond.t.sol";

contract StkTest is BaseDiamondTest {
    
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

    }

    function test_get_token_name() public{
        STKTokenFacet stkToken = STKTokenFacet(address(diamondProxy));
        assertEq(stkToken.name(), "STK Token");
    }

    function test_get_token_decimals() public{
        STKTokenFacet stkToken = STKTokenFacet(address(diamondProxy));
        assertEq(stkToken.decimals(), 18);
    }

    function test_mint() public{
        STKTokenFacet stkToken = STKTokenFacet(address(diamondProxy));
        address addr = makeAddr("addr");
        stkToken.mint(1000*1e18, addr);
        assertEq(stkToken.balanceOf(addr),1000*1e18);
    }

    function test_transfer() public{
        STKTokenFacet stkToken = STKTokenFacet(address(diamondProxy));
        address addr = makeAddr("addr");
        address addr2 = makeAddr("addr2");
        stkToken.mint(1000*1e18, addr);
        vm.startPrank(addr);
        stkToken.transfer(addr2, 100*1*18);
        assertEq(stkToken.balanceOf(addr2), 100*1*18);
    }

    function testFail_mint_non_owner() public{
        STKTokenFacet stkToken = STKTokenFacet(address(diamondProxy));
        address addr = makeAddr("addr");
        vm.startPrank(addr);
        stkToken.mint(1000*1e18, addr);
    }

}