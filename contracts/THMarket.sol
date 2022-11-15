// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";



contract THMarket is ERC721URIStorage {
    using Counters for Counters.Counter; 
    Counters.Counter private _tokenIds; // Total number of items ever created.
    Counters.Counter private _itemsSold; // Total number of items ever sold.

    uint256 listingFee = 0.001 ether; // Payment for listing the NFT
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

    function getListingFee() public view returns(uint256) {
        return listingFee; // Returns the listing fee.
    }

    function updateListingFee(uint _listingFee) public payable {
        require(owner == msg.sender, "Only the marketplace owner can update the listing fee!")
        listingFee = _listingFee; //Updates the listing fee.
    }

    function createMarketItem(uint256 tokenId, uint256 price) private {
        require(price > 0, "Price must be greater than zero!")
        require(msg.value == listingFee, "Fee must be equal to listing fee!")

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

    // Mints a token and lists it in the marketplace.
    function createToken(string memory tokenURI, uint256 price) public payable returns(uint) {
        _tokenIds.increment(); // Increments the token Id
        uint256 newTokenId = _tokenIds.current(); // New token with teh current new tokenId.
        _mint(msg.sender, newTokenId); // Calling mint function in library.
        _setTokenURI(newTokenId. tokenURI): 
        createMarketItem(newTokenId, price); // Creates the marketItem.
        return newTokenId; // Returns the new tokenId.
    }

    // Createing the sale of a marketplace item.
    // Transfers ownership of the item as well as funding between parties

    function createMarketSale(uint256 tokenId) public payable {
        uint price = marketItemId[tokenId].price;
        address seller = marketItemId[tokenId].seller;

        require(msg.value == price, "Please submit the asking price in order to complete the purchase!");

        // Changing market item info
        marketItemId[tokenId].owner = payable(msg.sender); // This changes the owner.
        marketItemId[tokenId].sold = true;                  // Changes the status of the listing.
        marketItemId[tokenId].seller = payable(address(0)); // Empties address indicating there is no longer a seller.
        _itemsSold.increment();                             // Increments items sold.
        _transfer(address(this), msg.sender, tokenId);      // Calling transfer to move the token ownership from "this" contract to "msg.sender"
        payable(owner).transfer(listingFee);              // Transfers the listing fee to owner of smart contract. 
        payable(seller).transfer(msg.value);                // Transfers the funds to the seller.

    }

}