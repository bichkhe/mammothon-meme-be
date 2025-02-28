// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "forge-std/console.sol";
contract MemeCoin is ERC20, Ownable {
    string private _name;
    string private _symbol;
    string public metadataURI;
    uint8 private constant PRECISION = 5; // Hệ số thập phân
    uint256 private constant b = 1; // Hằng số tuyến tính
    uint256 private initialPrice = 1; // Giá khởi điểm
    uint256 public feePercentage = 2;
    address public feeRecipient; // Address to collect fees
    
    event MetadataUpdated(string newMetadataURI);
    event Buy(address indexed buyer, uint256 amountETH, uint256 amountToken, uint256 price);
    event Sell(address indexed seller, uint256 amountETH, uint256 amoumtToken, uint256 price);
    bytes32[] public transactions;
    constructor(
        string memory name_,
        string memory symbol_,
        string memory metadataURI_,
        uint256 initialPrice_,
        address owner
    ) ERC20(name_, symbol_) Ownable(owner) {
        initialPrice = initialPrice_;
        metadataURI = metadataURI_;
        feeRecipient = owner;
    }

    function setFeeRecipient(address newRecipient) external onlyOwner {
        require(newRecipient != address(0), "Invalid recipient");
        feeRecipient = newRecipient;
    }

    // Function to update metadata (only owner can call)
    function updateMetadata(string memory newMetadataURI) external onlyOwner {
        metadataURI = newMetadataURI;
        emit MetadataUpdated(newMetadataURI);
    }

    // return current price of token
    function getCurrentPrice() public view returns (uint256) {
        return totalSupply() + initialPrice;
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
        require(amount > 0, "Amount must be greater than 0");
        uint256 curentPrice = getCurrentPrice();
        uint256 discriminant = curentPrice * curentPrice + (2 * amount);
        // Kiểm tra discriminant không bị tràn số
        require(discriminant >= curentPrice * curentPrice, "Invalid amount");
        uint256 sqrtDiscriminant = sqrt(discriminant);
        uint256 n = (sqrtDiscriminant - curentPrice) / b;
        // Kiểm tra n > 0
        require(n > 0, "Amount is too small to mint any token");
        return n;
    }
    // calculate amount of ether will return when sell amount token
    function calculateTokenSell(uint256 amount) public view returns (uint256) {
        uint256 currentPrice = getCurrentPrice();
        uint256 value = (amount * (2 * currentPrice - amount - 1 )) / 2;
        return value;
    }
    // buy token with amount, transfer token to sender and redundant
    function buy() public payable {
        uint256 n = calculateToken(msg.value);
        require(n > 0, "Amount is too small");
        uint256 currentPrice = getCurrentPrice();
        uint256 finalPrice = (n + currentPrice);
        uint256 price = (((finalPrice + currentPrice - 1) * n) / 2);
        console.log("Price:", price);
        console.log("token buy: ", n);
        _mint(msg.sender, n);
        // refund redundant money
        if (msg.value > price) {
            (bool success, ) = msg.sender.call{value: msg.value - price}("");
            require(success, "Refund failed");
        }
        emit Buy(msg.sender, msg.value, n, getCurrentPrice());
    }

    // sell token with amount, transfer money to sender
    function sell(uint256 amount) public {
        require(amount > 0, "Amount too small");
        require(amount <= totalSupply(),  "Amount is too big");
        uint256 value = calculateTokenSell(amount);
        uint256 fee = (value * feePercentage) / 100; // Calculate fee
        uint256 finalValue = value - fee; // Deduct fee
        console.log("Value:", value);
        console.log("Blance:", address(this).balance);
        require(
            address(this).balance >= finalValue,
            "Not enough balance in contract"
        );
        _burn(msg.sender, amount);
        (bool success, ) = msg.sender.call{value: finalValue}("");
        require(success, "Transfer failed");
        emit Sell(msg.sender,finalValue, amount , getCurrentPrice());
    }

    receive() external payable {} // Allow contract to receive ETH

    function decimals() public pure override returns (uint8) {
        return PRECISION;
    }
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
    function logTransaction(bytes32 transaction) public {
        transactions.push(transaction);
    }
    function getTransactions() public view returns (bytes32[] memory) {
        return transactions;
    }
    struct Transaction {
        address from;
        address to;
        uint256 amount;
        uint256 timestamp;
    }
}
