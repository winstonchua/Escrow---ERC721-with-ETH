//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract TestERC721 is ERC721("Test721", "TST721") {
    
    function mint(uint256 _mintAmount) public {
        _safeMint(msg.sender, _mintAmount);
    }

}
