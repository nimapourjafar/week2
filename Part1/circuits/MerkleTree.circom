pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/mux1.circom";

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**n];
    signal output root;
    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves
    signal hashOutputs[2**n-1];
    component hash[2**n-1];
    var x = 2**n-1;

    for(var i=2**n-1;i>0;i--){
        hash[i] = Poseidon(2);   
        if(x>0){
            hash[i].inputs[1] <== leaves[x];
            x--;
            hash[i].inputs[0] <== leaves[x];
            x--;
            hashOutputs[i] <== hash[i].out;
        } 
        else {
            hash[i].inputs[0] <== hashOutputs[2*i];
            hash[i].inputs[1] <== hashOutputs[2*i+1];
            hashOutputs[i] <== hash[i].out;
        }
    }

    root <== hashOutputs[1];
    
}

template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    //[assignment] insert your code here to compute the root from a leaf and elements along the path
    component poseidon[n];
    component mux1[n];
    component mux2[n];
    signal hashOutputs[2*n+1];
    hashOutputs[0] <== leaf;

    for(var i=0;i<n;i++){
        poseidon[i] = Poseidon(2);
        mux1[i] = Mux1();
        mux2[i] = Mux1();

        mux1[i].c[0] <== path_elements[i];
        mux1[i].c[1] <== hashOutputs[i];
        mux1[i].s <== path_index[i];
        poseidon[i].inputs[0] <== mux1[i].out;
        mux2[i].c[0] <== hashOutputs[i];
        mux2[i].c[1] <== path_elements[i];
        mux2[i].s <== path_index[i];
        poseidon[i].inputs[1] <== mux2[i].out;
        hashOutputs[i+1] <== poseidon[i].out;
    }
    root <== hashOutputs[n];




}