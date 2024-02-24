// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { StdCheats, StdUtils, Test } from "forge-std/Test.sol";
import { BaseDiamondTest} from "./BaseDiamond.t.sol";
import {DiamondLoupeFacet} from "../../src/Facets/DiamondLoupeFacet.sol";

contract DiamondLoupeTest is BaseDiamondTest{

    function setUp() public override{
        super.setUp();
    }

    /// test if correct facet selectors present
    function test_facet_selectors() public{
        DiamondLoupeFacet dloupe = DiamondLoupeFacet(address(diamondProxy));
        bytes4[] memory selectors = dloupe.facetFunctionSelectors(address(dLoupeFacet));
        assertEq(selectors[0], dLoupeFacet.facets.selector);
    }

    /// test number of facets
    function test_number_of_facets() public{
        dLoupeFacet = DiamondLoupeFacet(address(diamondProxy));
        assertEq(dLoupeFacet.facetAddresses().length, 2);
    }

}
