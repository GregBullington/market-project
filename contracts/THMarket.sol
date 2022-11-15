// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";



contract THMarket is ERC721URIStorage {
    using Counters for Counters.Counter; 
    Counters.Counter private _tokenIds; // Total number of items ever created.
    Counters.Counter private _itemsSold; // Total number of items ever sold.

    uint256 listingPrice = 0.001 ether; // Payment for listing the NFT
    address payable owner; // Owner of the smart contract.

    constructor() ERC721("The Market Token", "TMT")
    {
        owner = payable(msg.sender);
    }

    mapping (uint256 => MarketItem) private marketItemId;

    struct MarketItem {
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }

    event MarketItemCreated {
        uint256 tokenId;
        address seller;
        address owner;
        uint256 pr;ice
        bool sold;
    };

    function getListingPrice() public view returns(uint256) {
        return listingPrice; // Returns the listing price.
    }

    function updateListingPrice(uint _listingPrice) public payable {
        require(owner == msg.sender, "Only the marketplace owner can update the listing price!")
        listingPrice = _listingPrice; //Updates the listing price.
    }

    function createMarketItem(uint256 tokenId, uint256 price) private {
        require(price > 0, "Price must be greater than zero!")
        require(msg.value == listingPrice, "Price must be equal to listing price!")

        marketItemId[tokenId] = MarketItem(
            tokenId,
            payable(msg.sender), // Seller
            payable(address(this)), // Owner
            price,
            false
        );

        _transfer(msg.sender, address(this), tokenId);
        emit MarketItemCreated(tokenId, msg.sender, address(this), price, false);

    }

}