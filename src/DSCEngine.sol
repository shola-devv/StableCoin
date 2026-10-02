// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {DecentralisedStableCoin} from "./DecentralisedStableCoin.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/*
* @title DSCEngine
* @author olushola Emmanuel
*
* The system is designed to be as miniml aspossible, and its tokens maintain a 1 token == $1 peg
* This stable coin has the properties
* Exogeneous collateral
* our dsc system should be overcollaterised. value of collateral should always be > the amountof DSC
* ThiS contract is just the Erc20 implementation of our stable coin system
* It is similar to DAI if DAI had no governance, no fees, and was only backed by wETH  and wBTC
* @noticethis conract is the core of the DSC system.
* @notice this contract is loosley based on makerDAO (DAI) system.
*/

contract DSCEngine is ReentrancyGuard {
    error DSCEngine__NeedsMoreThanZero();
    error DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeTheSameLength();
    error DSCEngine__TokenNotAllowed();
    error DSCEngine__TransferFailed();

    mapping(address token => address priceFeed) private s_priceFeeds;
    DecentralisedStableCoin private immutable i_dsc;
    mapping(address user => mapping(address token => uin256 amount)) private s_collateralDeposited;
    mapping(address user => uint256 amountDscMinted) private s_DSCMinted;
    address[] private  s_collateralTokens;

    ////////////////////////////
    //////// Events ///////////
    ///////////////////////////
    event collateralDeposited(address indexed user, address indexed token, uint256 indexed amount);

    ////////////////////////////
    ////////Modifier ///////////
    ////////////////////////////

    modifier moreThanZero(uint256 amount) {
        if (amount == 0) {
            revert DSCEngine__NeedsMoreThanZero();
        }
        _;
    }

    modifier isAllowed(address token) {
        if (s_priceFeeds[token] == address(0)) {
            revert DSCEngine__TokenNotAllowed();
        }
        _;
    }


///////////////////////////
///functions//
///////////////
    constructor(address[] memory tokenAddresses, address[] memory priceFeedAddresses, address dscAddress) {
        if (tokenAddresses.length != priceFeedAddresses.length) {
            revert DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeTheSameLength();
        }

        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            s_priceFeeds[tokenAddresses[i]] = priceFeedAddresses[i];
            s_collateralTokens.push(tokenAddresses[i]);
        }

        i_    function depositCollateral(address tokenCollateralAddress, uint256 amountCollateral)
        external
        moreThanZero(amountCollateral)
        isAllowed(tokenCollateralAddress)
        nonReentrant
    {
        s_collateralDeposited[msg.sender][tokenCollateralAddress] += amountCollateral;
        emit CollateralDeposited(msg.sender, tokenCollateralAddress, amountCollateral);

        bool success = IERC20(tokenCollateralAddress).transferFrom(msg.sender, address(this), amountCollateral);
        if (!success) {
            revert DSCEngine__TransferFailed();
        }
    }

    function redeemCollateral() external {}

    function redeemCollateralForDSC() external {}

    
    /*
    * follows CEI
    * @param the amount of DSC to mint
    * @notice they must have the collateral value more than the minimum threshhold
    *
    */
    function mintDSC(uint256 amountDscToMint) external moreThanZero(tokenDscToMint) nonReentrant{
        s_DSCMinted[msg.sender] += amountDscToMint;
        _revertIfHealthFactorIsBroken(msg.sender);
    }

    function burnDSC() external {}

    function liquidate() external {}

    function getHealthFactor() external view returns (uint256) {}


    /////////////////////////////////////////
    //private and internal view functions////
    /////////////////////////////////////////

    function getAccountInformation(address user ) private view returns (uint256 totalDscminted, uint256 collateralValueUsd) {
     totalDscminted = s_DSCMinted[user;
     collateralValueUsd  = getAccountCollateralValue(user);
    }

    /*
    /* returns how close to liquidation a user is
    /* if  user gets to 0 they can get liquidated
    */

   function _healthFactor() private returns(uint256) {
         
   }

    function _revertIfhealthFactorIsBroken(address user) internal view  {

    }

    ////////////////////////////
    //pubblic and external functions///////
    //////////////////////// 
    function getAccountCollateralValue(address user) public view returns(uint256 ) {
        for(uint256 i  = 0; i <  s_collateralTokens.length; i++){
            address token = s_collateralTokens[i];
            uint256 amount = s_collateralDeposited[user][token];
            totalCollatralValueInUsd = 
        }

    } 

    function getUsdValue(address token, uint156 amount) public view returns(uint256) {
      
    }


}
