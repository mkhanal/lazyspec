// The married test. Every describe is a requirement in
// specs/format.lazyspec.md, word for word.
const assert = require('node:assert');
const fs = require('node:fs');
const path = require('node:path');
const { describe, it } = require('node:test');
const { ROOT } = require('./support.js');

const specs = () =>
  fs
    .readdirSync(path.join(ROOT, 'specs'))
    .filter((f) => f.endsWith('.lazyspec.md'))
    .map((f) => path.join('specs', f));

// The header is everything above the title, so a specification can be
// read from the top by something that has never heard of lazyspec.
const header = (rel) =>
  fs.readFileSync(path.join(ROOT, rel), 'utf8').split(/^# /m)[0];

describe('Every Specification Says It Is Locked', () => {
  it('opens every specification with a header naming /lazyspec', () => {
    const found = specs();
    assert.ok(found.length > 0, 'found no specifications to check');
    const silent = found.filter((rel) => !/\/lazyspec/.test(header(rel)));
    assert.deepEqual(silent, []);
  });

  it('binds agents and leaves people alone', () => {
    const vague = specs().filter((rel) => {
      const h = header(rel);
      return !/agents?/i.test(h) || !/humans?/i.test(h);
    });
    assert.deepEqual(vague, []);
  });

  it('says what a requirement is and how to find its test', () => {
    const silent = specs().filter((rel) => {
      const h = header(rel);
      return !/heading is one requirement/i.test(h) || !/search the tests/i.test(h);
    });
    assert.deepEqual(silent, []);
  });
});
