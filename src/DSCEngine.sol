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
* The system is designed to be as minimal as possible, and its tokens maintain a 1 token == $1 peg.
* This stable coin has the properties
* Exogeneous collateral
* our dsc system should be overcollateralised. value of collateral should always be > the amount of DSC
* ThiS contract is just the ERC20 implementation of our stable coin system
* It is similar to DAI if DAI had no governance, no fees, and was only backed by wETH and wBTC
* @notice this contract is the core of the DSC system.
* @notice this contract is loosely based on the MakerDAO (DAI) system.
*/

contract DSCEngine is ReentrancyGuard {
    error DSCEngine__NeedsMoreThanZero();
    error DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeTheSameLength();
    error DSCEngine__TokenNotAllowed();
    error DSCEngine__TransferFailed();

    mapping(address token => address priceFeed) private s_priceFeeds;
    DecentralisedStableCoin private immutable i_dsc;
    mapping(address user => mapping(address token => uint256 amount)) private s_collateralDeposited;
    mapping(address user => uint256 amountDscMinted) private s_DSCMinted;
    address[] private s_collateralTokens;

    event CollateralDeposited(address indexed user, address indexed token, uint256 indexed amount);

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

    constructor(address[] memory tokenAddresses, address[] memory priceFeedAddresses, address dscAddress) {
        if (tokenAddresses.length != priceFeedAddresses.length) {
            revert DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeTheSameLength();
        }

        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            s_priceFeeds[tokenAddresses[i]] = priceFeedAddresses[i];
            s_collateralTokens.push(tokenAddresses[i]);
        }

        i_dsc = DecentralisedStableCoin(dscAddress);
    }

    function depositCollateralAndMintDSC() external {}

    function depositCollateral(address tokenCollateralAddress, uint256 amountCollateral)
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

    function mintDSC(uint256 amountDscToMint) external moreThanZero(amountDscToMint) nonReentrant {
        s_DSCMinted[msg.sender] += amountDscToMint;
        _revertIfHealthFactorIsBroken(msg.sender);
    }

    function burnDSC() external {}

    function liquidate() external {}

    function getHealthFactor() external view returns (uint256) {
        return 1;
    }

    function getAccountInformation(address user)
        private
        view
        returns (uint256 totalDscMinted, uint256 collateralValueUsd)
    {
        totalDscMinted = s_DSCMinted[user];
        collateralValueUsd = getAccountCollateralValue(user);
    }

    function _healthFactor(address user) private view returns (uint256) {
        if (user == address(0)) {
            return 0;
        }
        return 1;
    }

    function _revertIfHealthFactorIsBroken(address user) internal view {
        if (_healthFactor(user) == 0) {
            revert DSCEngine__TokenNotAllowed();
        }
    }

    function getAccountCollateralValue(address user) public view returns (uint256) {
        uint256 totalCollateralValueInUsd = 0;
        for (uint256 i = 0; i < s_collateralTokens.length; i++) {
            address token = s_collateralTokens[i];
            uint256 amount = s_collateralDeposited[user][token];
            totalCollateralValueInUsd += getUsdValue(token, amount);
        }
        return totalCollateralValueInUsd;
    }

    function getUsdValue(address token, uint256 amount) public view returns (uint256) {
        address priceFeedAddress = s_priceFeeds[token];
        if (priceFeedAddress == address(0)) {
            revert DSCEngine__TokenNotAllowed();
        }

        AggregatorV3Interface priceFeed = AggregatorV3Interface(priceFeedAddress);
        (, int256 price,,,) = priceFeed.latestRoundData();
        return (uint256(price) * amount) / 1e8;
    }
}
