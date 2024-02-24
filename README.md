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
      - facet addresses
      - facet for particular selector
      - selctors present in particular facet
    
3. Diamond Cut contract **DiamondCutFacet.sol**
    - This contract is Facet of adding, removing, replacing facets and selectors

4. STK token **STKBase.Sol & STKTokenFacet.sol**
    - Facet for ERC20 token used in project
    - Consists of standard ERC20 function
    
5. Staking contract **StakingFacet.sol**
    - This contract is facet for staking functions
    - Contains following functions
      - Stake STK tokens
      - Unstake STK tokens
      - Calculate rewards
      - Add reward token liquidity
      
6. Buy STK token **BuyStkFacet.sol**
    - This contract is facet for buying STK tokens
    - Contains following functions
      - Buy stk tokens
      - withdraw funds - (only owner)
      - addLiquidity of tokens
      - Other utils for setting stk token, caps, etc

7. Ownership **OwnerFacet.sol**
    - This contract is facet for ownable implementation
    - Consists transfering ownership and getOwner functions
    - Retrives owner address from **LibDiamond.sol**
   
10. Storage contracts 
    - LibDiamond - Storage structure for diamond contract
    - LibBuyStk - storage structure for Buy stk token contract
    - LibSTKToken - storage structure for STK token contract
    - LibStaking - storage structure for staking contract
      
11. Interfaces 
    - IDiamondCut.sol
    - IDiamondLoupe.sol
    - IERC165.sol
    - IERC172.sol
