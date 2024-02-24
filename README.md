## Wasserstoff-Task-2

**Proxy Contract for Load Balancing and Function Delegation [Diamond Proxy Pattern eip-2535].**

## Project Structure ->
    |-lib
    |-script
    |-src
      |_ Facets
        |_ contains all Facet "*Implementation*" contracts
      |_ Interface
        |_ contains all Facet "*Interface*" contracts
      |_ Libraries
        |_ contains all Facet "*Storage*" contracts
      |_ UpgradeInit
        |_ Upgrade contract - "supported interface checks"
      |_ utils
       |_ DiamondProxy.sol
    |_ test
      |_ Contains all Unit tests

## Commands
### To install dependencies
> make install

### To build contracts
> forge build

### To test contracts
> forge test

## Design considerations

### Project Contains following contracts

Contracts & purpose - 
1. Diamond Proxy - **DiamondProxy.sol**
    - This contract is central proxy of delegating calls to respective facet
    - It utilized **LIbDiamond.sol** as storage 
    - Saves record of implementations for each function selector
      
2. Diamond loupe contract **DiamondLoupeFacet.sol**
    - This is standard getter function to get facet addresses and other facet related data from **LibDiamond.sol**
    - Returns
          _ facet addresses
          _ facet for particular selector
          _ selctors present in particular facet
3. Diamond Cut contract
    - This contract is implementation of adding, removing, replacing facets and selectors
    - DiamondCutFacet.sol
5. STK token 
    - STKBase.Sol
    - STKTokenFacet.sol
6. Staking contract
    - Staking Facet
7. Buy STK token 
    - BuyStkFacet.sol
8. Ownership
    - OwnerFacet.sol
9. Storage contracts 
    - LibDiamond
    - LibBuyStk
    - LibSTKToken
    - LibStaking
10. Interfaces 
    - IDiamondCut.sol
    - IDiamondLoupe.sol
    - IERC165.sol
    - IERC172.sol
