//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import {PoseidonT3} from "./Poseidon.sol"; //an existing library to perform Poseidon hash on solidity
import "./verifier.sol"; //inherits with the MerkleTreeInclusionProof verifier contract

contract MerkleTree is Verifier {
    uint256[] public hashes; // the Merkle tree in flattened array form
    uint256 public index = 0; // the current index of the first unfilled leaf
    uint256 public root; // the current Merkle root

    constructor() {
        // [assignment] initialize a Merkle tree of 8 with blank leaves

        for (uint256 i = 0; i < 8; i++) {
            hashes.push(0);
        }
        uint256 tracker = 0;
        for (uint256 i = 0; i < 7; i++) {
            hashes.push(
                PoseidonT3.poseidon([hashes[tracker], hashes[tracker + 1]])
            );
            tracker += 2;
        }

        root = hashes[14];
    }

    function insertLeaf(uint256 hashedLeaf) public returns (uint256) {
        // [assignment] insert a hashed leaf into the Merkle tree
        hashes[index] = hashedLeaf;
        uint256 start = 0;
        uint256 x = index;

        for (uint256 i = 1; i < 8; i *= 2) {
            uint256 c = start + x;
            x /= 2;
            x >> 1;
            start += 8 / i;
            uint256 c1 = start + x;

            if (c % 2 == 0) {
                hashes[c1] = PoseidonT3.poseidon([hashes[c], hashes[c + 1]]);
            } else {
                hashes[c1] = PoseidonT3.poseidon([hashes[c - 1], hashes[c]]);
            }
        }
        index++;
        root = hashes[hashes.length - 1];
        return root;
    }

    function verify(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[1] memory input
    ) public view returns (bool) {
        // [assignment] verify an inclusion proof and check that the proof root matches current root
        return (Verifier.verifyProof(a, b, c, input) && hashes[14] == root);
    }
}
