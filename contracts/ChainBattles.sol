// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract ChainBattles is ERC721URIStorage  {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct stats{
        uint256 level;
        uint256 hp;
        uint256 strength;
        uint256 speed;
        string class;
        string name;
    }

    mapping(uint256 => stats) public tokenIdToLevels;

    constructor() ERC721 ("Chain Battles", "CBTLS"){
    }

    function generateCharacter(uint256 tokenId) public returns(string memory){

        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            '<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>',
            '<rect width="100%" height="100%" fill="black" />',
            '<text x="50%" y="30%" class="base" dominant-baseline="middle" text-anchor="middle">', "Class: ",getClass(tokenId),'</text>',
            '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">', "Name: ",getName(tokenId),'</text>',
            '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">', "Levels: ",getLevels(tokenId),'</text>',
            '<text x="50%" y="60%" class="base" dominant-baseline="middle" text-anchor="middle">', "HP: ",getHp(tokenId),'</text>',
            '<text x="50%" y="70%" class="base" dominant-baseline="middle" text-anchor="middle">', "Strength: ",getStrenght(tokenId),'</text>',
            '<text x="50%" y="80%" class="base" dominant-baseline="middle" text-anchor="middle">', "Speed: ",getSpeed(tokenId),'</text>',
            '</svg>'
        );
        return string(
            abi.encodePacked(
                "data:image/svg+xml;base64,",
                Base64.encode(svg)
            )    
        );
    }

    function getLevels(uint256 tokenId) public view returns (string memory) {
        uint256 levels = tokenIdToLevels[tokenId].level;
        return levels.toString();
    }
    function getName(uint256 tokenId) public view returns (string memory) {
        return tokenIdToLevels[tokenId].name;
    }
    function getClass(uint256 tokenId) public view returns (string memory) {
        return tokenIdToLevels[tokenId].class;
    }
    function getHp(uint256 tokenId) public view returns (string memory) {
        uint256 hp = tokenIdToLevels[tokenId].hp;
        return hp.toString();
    }
    function getStrenght(uint256 tokenId) public view returns (string memory) {
        uint256 strength = tokenIdToLevels[tokenId].strength;
        return strength.toString();
    }
    function getSpeed(uint256 tokenId) public view returns (string memory) {
        uint256 speed = tokenIdToLevels[tokenId].speed;
        return speed.toString();
    }

    function getTokenURI(uint256 tokenId) public returns (string memory){
        bytes memory dataURI = abi.encodePacked(
            '{',
                '"name": "Chain Battles #', tokenId.toString(), '",',
                '"description": "Battles on chain",',
                '"image": "', generateCharacter(tokenId), '"',
            '}'
        );
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(dataURI)
            )
        );
    }

    function mint(string memory name, string memory class) public {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        tokenIdToLevels[newItemId].level = 0;
        tokenIdToLevels[newItemId].class = class;
        tokenIdToLevels[newItemId].name = name;
        tokenIdToLevels[newItemId].hp = 100 + random(50);
        tokenIdToLevels[newItemId].strength = 20 + random(20);
        tokenIdToLevels[newItemId].speed = 20 + random(30);
        _setTokenURI(newItemId, getTokenURI(newItemId));
    }

    function train(uint256 tokenId) public {
        require(_exists(tokenId));
        require(ownerOf(tokenId) == msg.sender, "You must own this NFT to train it!");
        uint256 currentLevel = tokenIdToLevels[tokenId].level;
        uint256 currentHP = tokenIdToLevels[tokenId].hp;
        uint256 currentStrength = tokenIdToLevels[tokenId].strength;
        uint256 currentSpeed = tokenIdToLevels[tokenId].speed;
        tokenIdToLevels[tokenId].level = currentLevel + 1;
        tokenIdToLevels[tokenId].hp = currentHP + 20;
        tokenIdToLevels[tokenId].strength = currentStrength + 15;
        tokenIdToLevels[tokenId].speed = currentSpeed + 5;

        _setTokenURI(tokenId, getTokenURI(tokenId));
    }

    function random(uint number) public view returns(uint){
        return uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,  
        msg.sender))) % number;
    }
}

