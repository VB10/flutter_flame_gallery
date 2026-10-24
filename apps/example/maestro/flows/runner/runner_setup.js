// Harabe Koşusu demo: 60s timer, 3 lives, easy.
output.runner = {
    // Distance chip label once the world has moved, e.g. "12 m".
    DISTANCE_MOVING: '[1-9][0-9]* m',
    // Without real dodging the round ends by lives or by the timer.
    END_NATURAL: 'outOfLives|timeUp',
    // Distance always earns points, so any finished run scores.
    SCORE_POSITIVE: '[1-9][0-9]*',
}
