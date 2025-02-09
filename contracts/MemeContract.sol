// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract MemeCoin is ERC20, Ownable {
    string private _name;
    string private _symbol;
    string public metadataURI;
    uint256 private constant PRECISION = 1e18; // Hệ số thập phân
    uint256 private constant b = 1; // Hằng số tuyến tính
    uint256 private constant c = 1; // Giá khởi điểm
    uint256 public totalTokenSupply; // Tổng số token đã phát hành
    // cu
    event MetadataUpdated(string newName, string newSymbol, string newMetadataURI);
    event Buy(address indexed buyer, uint256 amount, uint256 price);
    event Sell(address indexed seller, uint256 amount, uint256 value);

    constructor(string memory name_, string memory symbol_, string memory metadataURI_) ERC20(name_, symbol_) Ownable(msg.sender) {
        _name = name_;
        _symbol = symbol_;
        metadataURI = metadataURI_;
    }

     // Function to update metadata (only owner can call)
    function updateMetadata(string memory newName, string memory newSymbol, string memory newMetadataURI) external onlyOwner {
        _name = newName;
        _symbol = newSymbol;
        metadataURI = newMetadataURI;
        emit MetadataUpdated(newName, newSymbol, newMetadataURI);
    }
    function name() public view override returns (string memory) {
        return _name;
    }
    
    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    // return current price of token
    function getCurrentPrice() public view returns (uint256) {
        return (totalTokenSupply + c)/PRECISION ;
    }
    function sqrt(uint256 x) internal pure returns (uint256) {
        uint256 z = (x + 1) / 2;
        uint256 y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
        return y;
    }
    // return number token will return when buy with amount of money
    function calculateToken(uint256 amount) public view returns (uint256) {
        uint256 curentPrice = totalTokenSupply;
        // Công thức: n = (-a + sqrt(a^2 + 2*b*amount)) / b
        uint256 discriminant = curentPrice * curentPrice + (2 * amount * PRECISION);
        uint256 sqrtDiscriminant = sqrt(discriminant);
        uint256 n = (sqrtDiscriminant - curentPrice) / b;
        return n;
    }
    function calculateTokenSell(uint256 amount) public view returns (uint256) {
        uint256 currentPrice = totalTokenSupply ;
        uint256 value = (amount * (2 * currentPrice - amount + 1)) / 2;
        return value ;
    }

    // buy token with amount, transfer token to sender and redundant
    function buy(uint256 amount) public payable {
        uint256 n = calculateToken(amount);
        require(n > 0, "Amount is too small");
        uint256 finalPrice = (n + totalTokenSupply);
        uint256 price = ((finalPrice + totalTokenSupply - 1 ) * n / 2 )/ PRECISION;
        _mint(msg.sender, n );
        // update balance of sender
        totalTokenSupply += n ;
        if (price < amount) {
            payable(msg.sender).transfer(amount  - price);
        }
    }

    // sell token with amount, transfer money to sender
    function sell(uint256 amount) public {
        // check amout  > 0
        require(amount > 0, "Amount is too small");
        uint256 value = calculateTokenSell(amount);
        _burn(msg.sender, amount);
        // update balance of sender
        totalTokenSupply -= amount;
        payable(msg.sender).transfer(value/PRECISION);
    }
    function decimals() public pure override returns (uint8) {
    return 18;
    }
    // add to contract
}
