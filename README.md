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
    1. Diamond Proxy - 
        - This contract is central proxy of delegating calls to respective facet
        - It utilized 'LIbDiamond.sol' as storage 
        - Saves record of implementations for each function selector
        - DiamondProxy.sol
    2. Diamond loupe contract 
        - This is standard getter function to get facet addresses and other facet related data from 'LibDiamond.sol'
        - DiamondLoupeFacet.sol
    3. Diamond Cut contract 
        - DiamondCutFacet.sol
    4. STK token 
        - STKBase.Sol
        - STKTokenFacet.sol
    5. Staking contract
        - Staking Facet
    6. Buy STK token 
        - BuyStkFacet.sol
    7. Ownership
        - OwnerFacet.sol
    8. Storage contracts 
        - LibDiamond
        - LibBuyStk
        - LibSTKToken
        - LibStaking
    9. Interfaces 
        - IDiamondCut.sol
        - IDiamondLoupe.sol
        - IERC165.sol
        - IERC172.sol
