// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "node_modules/@openzeppelin/contracts/utils/Counters.sol";

contract Property is ERC721URIStorage{
    using Counters for Counters.Counter;
    Counters.Counter private _idxTokens;

    address owner;

    event TokenId(uint256 token_id);
    
    constructor(address newOwner) ERC721("PropertyNFT", "PFT") {
        owner = newOwner;
    }

    function registerProperty(string memory tokenURI) public {
        _idxTokens.increment();
        uint256 newID = _idxTokens.current();

        _mint(msg.sender, newID);
        _setTokenURI(newID, tokenURI);
        approve(owner, newID);

        emit TokenId(newID);
    }

    function transferPropertyOwnerShip(
        address from,
        address to,
        uint256 tokenId) external onlyOwner {
        
        _transfer(from, to, tokenId);
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "Only owner can call this method!");
        _;
    }
}