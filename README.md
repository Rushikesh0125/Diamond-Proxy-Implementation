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
