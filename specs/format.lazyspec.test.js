// The married test. Every describe is a requirement in
// specs/format.lazyspec.md, word for word.
const assert = require('node:assert');
const fs = require('node:fs');
const path = require('node:path');
const { describe, it } = require('node:test');
const { ROOT, read } = require('./support.js');

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

// The files where a project writes down where its requirements live. A
// `## ` in one of these is the failure this test exists to catch: it
// would read as a requirement, and nothing would ever prove it.
const WHERE = ['lazyspec.md', 'lazyspec.example.md'];

describe('A Requirement Is A Level Two Heading', () => {
  it('marks a requirement in every project, and nothing written moves it', () => {
    const found = WHERE.filter((rel) => fs.existsSync(path.join(ROOT, rel)));
    assert.deepEqual(found, WHERE, 'a file describing the areas is missing');
    const stray = found.flatMap((rel) =>
      read(rel)
        .split('\n')
        .map((line, i) => [line, i + 1])
        .filter(([line]) => line.startsWith('## '))
        .map(([, n]) => `${rel}:${n}`),
    );
    assert.deepEqual(stray, []);
  });

  it('names ## in the standing instruction and in every header', () => {
    assert.match(read('INSTRUCTION.md'), /`## ` heading/);
    const silent = specs().filter((rel) => !/`##`/.test(header(rel)));
    assert.deepEqual(silent, []);
  });

  it('uses ## for nothing else, so every heading is repeated by a test', () => {
    const unmarried = specs().flatMap((rel) => {
      const married = read(rel.replace(/\.md$/, '.test.js'));
      return read(rel)
        .split('\n')
        .filter((l) => l.startsWith('## ') && !l.includes('no-test'))
        .map((l) => l.slice(3).trim())
        .filter((h) => !married.includes(h))
        .map((h) => `${rel}: ${h}`);
    });
    assert.deepEqual(unmarried, []);
  });
});

// The name, reduced to what the match actually looks at. Java cannot put
// a dot in a class name and Python cannot import one, so the token is
// what travels — never the punctuation around it.
const plain = (name) => name.toLowerCase().replace(/[._-]/g, '');

describe('Every Married Test Names Its Specification And lazyspec', () => {
  it("carries the specification's stem and the word lazyspec", () => {
    const wrong = specs().filter((rel) => {
      const stem = path.basename(rel).replace(/\.lazyspec\.md$/, '');
      const name = plain(path.basename(rel).replace(/\.md$/, '.test.js'));
      return !name.includes(plain(stem)) || !name.includes('lazyspec');
    });
    assert.deepEqual(wrong, []);
  });

  it('is matched with capitals and separators removed', () => {
    const spellings = [
      'billing.lazyspec.test.ts',
      'test_billing_lazyspec.py',
      'billing_lazyspec_test.go',
      'BillingLazyspecTest.java',
    ];
    const unreadable = spellings.filter(
      (n) => !plain(n).includes('lazyspec') || !plain(n).includes('billing'),
    );
    assert.deepEqual(unreadable, []);
    const shown = read('README.md');
    assert.deepEqual(spellings.filter((n) => !shown.includes(n)), []);
  });

  it('leaves an orphan where the specification is gone', () => {
    const orphans = fs
      .readdirSync(path.join(ROOT, 'specs'))
      .filter((f) => plain(f).includes('lazyspec') && !f.endsWith('.lazyspec.md'))
      .filter((f) => !fs.existsSync(path.join(ROOT, 'specs', f.replace(/\.test\.js$/, '.md'))));
    assert.deepEqual(orphans, []);
  });
});
