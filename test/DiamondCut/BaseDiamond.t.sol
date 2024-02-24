// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { StdCheats, StdUtils, Test } from "forge-std/Test.sol";
import {DiamondCutFacet} from "../../src/Facets/DiamondCutFacet.sol";
import {DiamondLoupeFacet} from "../../src/Facets/DiamondLoupeFacet.sol";
import {Diamond} from "../../src/DiamondProxy.sol";
import {IDiamondCut} from "../../src/interfaces/IDiamondCut.sol";

contract BaseDiamondTest is Test{

    address owner;
    Diamond diamondProxy;
    DiamondCutFacet dCutFacet;
    DiamondLoupeFacet dLoupeFacet;

    function setUp() public virtual{
        owner = makeAddr("Owner");
        dCutFacet = new DiamondCutFacet();
        diamondProxy = new Diamond(owner, address(dCutFacet));

        vm.startPrank(owner);
        vm.deal(owner,100);

        ///deploying diamondloupeFacet instance
        dLoupeFacet = new DiamondLoupeFacet();
        bytes4[] memory selectors = new bytes4[](5);
        selectors[0] = dLoupeFacet.facets.selector;
        selectors[1] = dLoupeFacet.facetAddress.selector;
        selectors[2] = dLoupeFacet.facetAddresses.selector;
        selectors[3] = dLoupeFacet.facetFunctionSelectors.selector;
        selectors[4] = dLoupeFacet.supportsInterface.selector;
        IDiamondCut.FacetCut[] memory facets = new IDiamondCut.FacetCut[](1);
        facets[0] = IDiamondCut.FacetCut({
            facetAddress:address(dLoupeFacet),
            action:IDiamondCut.FacetCutAction.Add,
            functionSelectors:selectors
        });

        /// adding diamondloupeFacet cut to diamond
        DiamondCutFacet dCut = DiamondCutFacet(address(diamondProxy));
        dCut.diamondCut(facets, address(0), "");

        /// testing by invoking a function from diamondloupeFacet
        DiamondLoupeFacet dloup = DiamondLoupeFacet(address(diamondProxy));
        /// facetAddress for facets function from diamondloupeFacet should return address of diamondloupeFacet instance
        assertEq(dloup.facetAddress(dLoupeFacet.facets.selector), address(dLoupeFacet));
    }



}
