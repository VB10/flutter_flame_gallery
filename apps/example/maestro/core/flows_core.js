// Shared timeouts (ms) for every flow.
output.config = {
    defaultTimeout: 10000,
    // Cold start after clearState; Android debug builds need the most.
    longTimeout: 60000,
    // Longest natural round (60s runner demo) plus slow Android lookups.
    roundTimeout: 90000,
}
