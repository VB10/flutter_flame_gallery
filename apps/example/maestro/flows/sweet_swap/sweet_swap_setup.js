// Sweet Swap Daily demo (seed 20261024, 8x8, 20 moves). The board is fixed,
// so these swaps and scores are exact. Cell centres are screen percentages
// for an iPhone 17 portrait screen; recompute them for other devices.
output.daily = {
    MOVES_START: '20',
    MOVES_AFTER_SWAP: '19',
    SCORE_START: '0',
    // Row 5, columns 5 <-> 6: a 3 level cascade worth 30 + 60 + 120.
    SCORE_AFTER_SWAP: '210',
    VALID_FROM: '67%, 65%',
    VALID_TO: '79%, 65%',
    // Row 7, columns 0 <-> 1: no match, must bounce back for free.
    INVALID_FROM: '10%, 76%',
    INVALID_TO: '21%, 76%',
    END_QUIT: 'quit',
}
