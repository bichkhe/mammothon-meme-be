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
    event MetadataUpdated(string newMetadataURI);
    event Buy(address indexed buyer, uint256 amountETH, uint256 amountToken);
    event Sell(address indexed seller, uint256 amountETH, uint256 amoumtToken);

    constructor(
        string memory name_,
        string memory symbol_,
        string memory metadataURI_
    ) ERC20(name_, symbol_) Ownable(msg.sender) {
        metadataURI = metadataURI_;
    }

    // Function to update metadata (only owner can call)
    function updateMetadata(string memory newMetadataURI) external onlyOwner {
        metadataURI = newMetadataURI;
        emit MetadataUpdated(newMetadataURI);
    }

    // return current price of token
    function getCurrentPrice() public view returns (uint256) {
        return (totalTokenSupply + c);
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
        uint256 curentPrice = getCurrentPrice();
        // Công thức: n = (-a + sqrt(a^2 + 2*b*amount)) / b
        uint256 discriminant = curentPrice * curentPrice + (2 * amount);
        uint256 sqrtDiscriminant = sqrt(discriminant);
        uint256 n = (sqrtDiscriminant - curentPrice) / b;
        return n;
    }
    function calculateTokenSell(uint256 amount) public view returns (uint256) {
        uint256 currentPrice = totalTokenSupply;
        uint256 value = (amount * (2 * currentPrice - amount + 1)) / 2;
        return value;
    }
    // buy token with amount, transfer token to sender and redundant
    function buy() public payable {
        uint256 n = calculateToken(msg.value);
        require(n > 0, "Amount is too small");
        uint256 finalPrice = (n + totalTokenSupply);
        uint256 price = (((finalPrice + totalTokenSupply - 1) * n) / 2);
        _mint(msg.sender, n);
        // update balance of sender
        totalTokenSupply += n;
        // refund redundant money
        if (msg.value > price) {
            (bool success, ) = msg.sender.call{value: msg.value - price}("");
            require(success, "Refund failed");
        }
        emit Buy(msg.sender, msg.value, n);
    }

    // sell token with amount, transfer money to sender
    function sell(uint256 amount) public {
        require(amount > 0, "Amount too small");
        uint256 value = calculateTokenSell(amount);
        require(
            address(this).balance >= value,
            "Not enough balance in contract"
        );

        totalTokenSupply -= amount;
        _burn(msg.sender, amount);

        (bool success, ) = msg.sender.call{value: value}("");
        require(success, "Transfer failed");
        emit Sell(msg.sender, amount, value);
    }

    receive() external payable {} // Allow contract to receive ETH

    function decimals() public pure override returns (uint8) {
        return 0;
    }
    // add to contract
}
