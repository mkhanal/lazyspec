// The married test. Its name is the requirement, word for word.
const assert = require('node:assert');
const { describe, it } = require('node:test');
const { refund } = require('../src/refunds.js');

describe('Refunds Never Exceed What Was Captured', () => {
  it('refuses a refund beyond the captured amount', () => {
    assert.equal(refund({ captured: 100, refunded: 80 }, 30).ok, false);
  });

  it('allows the exact remaining balance', () => {
    assert.equal(refund({ captured: 100, refunded: 80 }, 20).ok, true);
  });
});
