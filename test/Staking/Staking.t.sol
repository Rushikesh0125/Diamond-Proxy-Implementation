// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { StdCheats, StdUtils, Test } from "forge-std/Test.sol";
import {DiamondCutFacet} from "../../src/Facets/DiamondCutFacet.sol";
import {DiamondLoupeFacet} from "../../src/Facets/DiamondLoupeFacet.sol";
import {Diamond} from "../../src/DiamondProxy.sol";
import {IDiamondCut} from "../../src/interfaces/IDiamondCut.sol";
import {STKTokenFacet} from "../../src/Facets/STKToken/STKTokenFacet.sol";
import {BaseDiamondTest} from "../DiamondCut/BaseDiamond.t.sol";
import {StakingFacet} from "../../src/Facets/Staking/StakingFacet.sol";

contract BuyStkTest is BaseDiamondTest {

    StakingFacet stakingFacet;
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

        stakingFacet = new StakingFacet();

        /// add STK Token facet cut to diamond
        bytes4[] memory stakingSelectors = new bytes4[](6);
        stakingSelectors[0] = stakingFacet.stakeSTK.selector;
        stakingSelectors[1] = stakingFacet.unstakeSTK.selector;
        stakingSelectors[2] = stakingFacet.addLiquidityForRewards.selector;
        stakingSelectors[3] = stakingFacet.getStakeByUser.selector;
        stakingSelectors[4] = stakingFacet.setAprRate.selector;
        stakingSelectors[5] = stakingFacet.setStkToken.selector;

        IDiamondCut.FacetCut[] memory stakingFacetCut = new IDiamondCut.FacetCut[](1);
        stakingFacetCut[0] = IDiamondCut.FacetCut({
            facetAddress:address(stakingFacet),
            action:IDiamondCut.FacetCutAction.Add,
            functionSelectors:stakingSelectors
        });

        dCut.diamondCut(
            stakingFacetCut, 
            address(0), 
            ""
        );

        StakingFacet stkingFct = StakingFacet(address(diamondProxy));
        stkingFct.setAprRate(5000); //50 percent
        stkingFct.setStkToken(address(stkFacet));
    }


}
