//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DegenToken is ERC20, Ownable {
    event Redeem(address indexed from, uint256 itemId, uint256 quantity);

    // Struct to represent an item in the in-game store
    struct Item {
        uint256 price;
        uint256 quantity;
    }

    mapping(uint256 => Item) public storeItems;
    uint256 public itemCount;

    // Constructor to initialize the token with the name "Degen Gaming Token" and symbol "DGT"
    constructor() ERC20("Degen Token", "DGNT") {
    }

    // Function to mint new tokens (only the owner can do this)
    function mint(address to, uint256 value) external onlyOwner {
        require(to != address(0), "Invalid address");
        require(value > 0, "Invalid value");

        _mint(to, value);
        emit Transfer(address(0), to, value);
    }

    // Function to redeem tokens for items in the in-game store
    function redeem(uint256 itemId, uint256 quantity) external {
        require(itemId > 0 && itemId <= itemCount, "Invalid item ID");
        require(quantity > 0, "Quantity must be greater than zero");
        require(storeItems[itemId].quantity >= quantity, "Item not available");

        // Calculate the total cost of the items
        uint256 totalCost = storeItems[itemId].price * quantity;
        // Check if the player has enough tokens to redeem the items
        require(balanceOf(msg.sender) >= totalCost, "Insufficient balance");

        _transfer(msg.sender, owner(), totalCost);
        storeItems[itemId].quantity -= quantity;

        emit Redeem(msg.sender, itemId, quantity);
    }

    // Function to add items and their prices to the in-game store
    function addItem(uint256 price, uint256 initialQuantity) external onlyOwner {
        require(price > 0, "Invalid price");
        require(initialQuantity > 0, "Invalid quantity");

        itemCount++;
        storeItems[itemCount] = Item(price, initialQuantity);
    }

    // Function to burn tokens (anyone can do this)
    function burn(uint256 amount) external {
        require(amount > 0 && balanceOf(msg.sender) >= amount, "Insufficient balance");

        _burn(msg.sender, amount);
    }
}
