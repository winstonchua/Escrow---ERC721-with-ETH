//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Escrow is Ownable {
    address[] token;
    uint256[] tokenId;
    uint256 tradeId = 0;
    address[] buyer;
    address[] seller;
    uint256[] price;

    modifier onlySeller(uint256 _tradeId){
        require (msg.sender == seller[_tradeId]);
        _;
    }

    function onERC721Received( address operator, address from, uint256 tokenId, bytes calldata data ) public returns (bytes4) {
        return this.onERC721Received.selector;
    }
   
    function depositNFT(address _token, uint256 _tokenID, uint256 _price, address _buyer) public {
        require(msg.sender == IERC721(_token).ownerOf(_tokenID), "Seller does not own NFT");
        buyer.push(_buyer);
        seller.push(msg.sender);
        price.push(_price);
        token.push(_token);
        tokenId.push(_tokenID);
        IERC721(token[tradeId]).safeTransferFrom(msg.sender,address(this), _tokenID);
        tradeId++;
    }

    function acceptTrade(uint256 _tradeId) public payable {
        require(msg.sender == buyer[_tradeId], "Not the buyer");
        require(msg.value == price[_tradeId], "Incorrect amount paid");
        IERC721(token[_tradeId]).safeTransferFrom(address(this), msg.sender, tokenId[_tradeId]);
    }

    function claimETH(uint256 _tradeId) public onlySeller(_tradeId){
        (bool os, ) = payable(msg.sender).call{value: price[_tradeId]}('');
        require(os);
        delete(seller[_tradeId]);

    }


    function sellerDetails(uint256 _tradeId) public view returns(address){
        return seller[_tradeId];
    }

    function nftDeposited(uint _tradeId) public view returns(address,uint256){
        return (token[_tradeId],tokenId[_tradeId]);
    }
    
    function buyerDetails(uint256 _tradeId) public view returns(address){
        return buyer[_tradeId];
    }

    function priceDetails(uint256 _tradeId) public view returns(uint256){
        return price[_tradeId];
    }

    function tradeDetails(uint _tradeId) public view returns(
        address, //seller address
        address, //buyer address
        address, //token address
        uint256, //token id
        uint256  //price
    ){
        return (seller[_tradeId], buyer[_tradeId], token[_tradeId], tokenId[_tradeId], price[_tradeId]);
    }

    function currentTradeID()public view returns(uint256){
        return tradeId;
    }
}

//2nd account addy:0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2