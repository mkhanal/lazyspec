// The married test. Every describe is a requirement in
// specs/instruction.lazyspec.md, word for word.
const assert = require('node:assert');
const fs = require('node:fs');
const path = require('node:path');
const { describe, it } = require('node:test');
const { ROOT, read } = require('./support.js');

const skills = () =>
  fs
    .readdirSync(path.join(ROOT, 'skills'))
    .map((name) => path.join('skills', name, 'SKILL.md'))
    .filter((rel) => fs.existsSync(path.join(ROOT, rel)));

describe('The Standing Instruction Fits In Every Prompt', () => {
  it('stays under two thousand characters', () => {
    const instruction = read('INSTRUCTION.md');
    assert.ok(
      instruction.length < 2000,
      `INSTRUCTION.md is ${instruction.length} characters`,
    );
  });
});

// Any file an editor loads on every task. AGENTS.md is the one every
// agent reads; the rest are one-line shims for editors that insist on a
// name of their own.
const editorFiles = () =>
  fs
    .readdirSync(ROOT)
    .filter((f) => /^(AGENTS|CLAUDE|GEMINI|CONVENTIONS)\.md$/.test(f));

describe('This Repository Loads Its Own Instruction', () => {
  it('carries the body of INSTRUCTION.md word for word in AGENTS.md', () => {
    assert.ok(read('AGENTS.md').includes(read('INSTRUCTION.md').trim()));
  });

  it('points every other editor at AGENTS.md rather than repeating it', () => {
    const others = editorFiles().filter((f) => f !== 'AGENTS.md');
    assert.ok(others.length > 0, 'found no editor files to check');
    const repeated = others.filter((f) => !/^@AGENTS\.md$/m.test(read(f)));
    assert.deepEqual(repeated, []);
  });
});

describe('The Standing Instruction Names /lazyspec And /lazyspec-validate', () => {
  const instruction = read('INSTRUCTION.md');

  it('names /lazyspec as the way into a specification', () => {
    assert.match(instruction, /\/lazyspec\b/);
    // Naming it as a condition - "locked unless you are in /lazyspec" -
    // leaves an agent that has just learnt a requirement with nothing to
    // do. It has to be named as the action too.
    assert.match(instruction, /run `\/lazyspec`/);
  });

  it('names /lazyspec-validate as the way to check', () => {
    assert.match(instruction, /\/lazyspec-validate\b/);
  });
});

describe('The Procedures Live In The Skills Alone', () => {
  it('copies no line of any skill into the instruction', () => {
    const instruction = read('INSTRUCTION.md');
    const copied = skills().flatMap((rel) =>
      read(rel)
        .split('\n')
        .map((line) => line.trim())
        .filter((line) => line.length > 40 && instruction.includes(line))
        .map((line) => `${rel}: ${line}`),
    );
    assert.deepEqual(copied, []);
    // Guard the scan itself: an empty skills list would pass silently.
    assert.ok(skills().length > 0, 'found no skills to scan');
  });
});
