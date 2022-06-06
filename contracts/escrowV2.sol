//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Escrow is Ownable {
    
    struct tradeDetails{ //All the details in a single trait
        address seller;
        address buyer;
        address tokenAddress;
        uint256 tokenID;
        uint256 price;
    }

    mapping(uint256 => tradeDetails) public tradedetails;

    uint256 tradeID = 0;

    modifier onlySeller(uint256 _tradeID){
        require (msg.sender == (tradedetails[_tradeID]).seller);
        _;
    }

    modifier onlyBuyer(uint256 _tradeID){
        require (msg.sender == tradedetails[_tradeID].buyer);
        _;
    }

    function onERC721Received( address operator, address from, uint256 tokenId, bytes calldata data ) public returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function depositNFT(address _token, uint256 _tokenID, uint256 _price, address _buyer) public {
        require(msg.sender == IERC721(_token).ownerOf(_tokenID), "Seller does not own NFT");
        
        tradedetails[tradeID] = tradeDetails({
            seller: msg.sender,
            buyer: _buyer,
            tokenAddress: _token,
            tokenID: _tokenID,
            price: _price 
        });

        IERC721(tradedetails[tradeID].tokenAddress).safeTransferFrom(msg.sender,address(this), _tokenID);
        tradeID++;
    }

    function acceptTrade(uint256 _tradeID) public payable onlyBuyer(_tradeID){
        require(msg.value == tradedetails[_tradeID].price, "Incorrect amount paid");
        IERC721(tradedetails[_tradeID].tokenAddress).safeTransferFrom(address(this), msg.sender, tradedetails[_tradeID].tokenID);
    }

    function claimETH(uint256 _tradeID) public onlySeller(_tradeID){
        require(tradedetails[_tradeID].price > 0, "No ethereum to be withdrawn");
        (bool os, ) = payable(msg.sender).call{value: tradedetails[_tradeID].price}('');
        require(os);
        delete(tradedetails[_tradeID]);

    }

    function withdrawTrade(uint256 _tradeID) public onlySeller(_tradeID){
        require(address(this) == IERC721(tradedetails[_tradeID].tokenAddress).ownerOf(tradedetails[_tradeID].tokenID));
        IERC721(tradedetails[_tradeID].tokenAddress).safeTransferFrom(address(this), msg.sender, tradedetails[_tradeID].tokenID);
    }
    
    function tradeInfo(uint _tradeID) public view returns(tradeDetails memory){
        return (tradedetails[_tradeID]);
    }

}