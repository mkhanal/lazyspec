// Shared plumbing for the married tests. Not a test file: the runner
// takes *.lazyspec.test.js only.
const { spawnSync } = require('node:child_process');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');

const ROOT = path.resolve(__dirname, '..');

function tmp() {
  return fs.mkdtempSync(path.join(os.tmpdir(), 'lazyspec-'));
}

function write(dir, rel, body) {
  const p = path.join(dir, rel);
  fs.mkdirSync(path.dirname(p), { recursive: true });
  fs.writeFileSync(p, body);
  return p;
}

// Run the hook the way a coding agent does: the call as JSON on stdin,
// from a working directory that is not this repository, so the window
// this repository may have open cannot answer for it.
function guard(payload, { cwd = tmp() } = {}) {
  const r = spawnSync('sh', [path.join(ROOT, 'lazyspec-guard')], {
    cwd,
    input: JSON.stringify(payload),
    encoding: 'utf8',
  });
  return { status: r.status, stdout: r.stdout, stderr: r.stderr };
}

const edit = (file) => ({
  tool_name: 'Edit',
  tool_input: { file_path: file, old_string: 'a', new_string: 'b' },
});

const bash = (command) => ({ tool_name: 'Bash', tool_input: { command } });

// A structured tool names the file it writes to; the rest of the call is
// content, however much of it reads like a path.
const writeCall = (file, content) => ({
  tool_name: 'Write',
  tool_input: { file_path: file, content },
});

const notebookCall = (file, source) => ({
  tool_name: 'NotebookEdit',
  tool_input: { notebook_path: file, new_source: source },
});

const read = (rel) => fs.readFileSync(path.join(ROOT, rel), 'utf8');

module.exports = { ROOT, tmp, write, guard, edit, bash, writeCall, notebookCall, read };
