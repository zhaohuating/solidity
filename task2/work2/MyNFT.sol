// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract MyNFT is ERC721, ERC721URIStorage,Ownable {
    uint256 private _tokenIdCounter;
    constructor() ERC721("MyNFT","ZHTNFT") Ownable(msg.sender) {
        _tokenIdCounter = 1;
    }

    function mintNFT(address addr,string memory _tokenURI) public onlyOwner  returns (uint256) {
        _safeMint(addr, _tokenIdCounter);
        _setTokenURI(_tokenIdCounter,_tokenURI);
        _tokenIdCounter++;
        return _tokenIdCounter;
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage)  virtual returns (string memory){
        return super.tokenURI(tokenId);
    }
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721URIStorage)  returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}