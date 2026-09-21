const { test } = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");

const root = path.resolve(__dirname, "..");
const read = relative => fs.readFileSync(path.join(root, relative), "utf8");

test("manifest defines a zero-configuration replacement for omarchy.tray", () => {
  const manifest = JSON.parse(read("manifest.json"));
  const packageMetadata = JSON.parse(read("package.json"));

  assert.equal(manifest.id, "io.github.manateelazycat.tray-bar");
  assert.equal(manifest.version, packageMetadata.version);
  assert.equal(manifest.license, "GPL-3.0-only");
  assert.deepEqual(manifest.kinds, ["bar-widget"]);
  assert.equal(manifest.entryPoints.barWidget, "Tray.qml");
  assert.equal(manifest.omarchy.clonedFrom, "omarchy.tray");
  assert.equal(fs.existsSync(path.join(root, "Tray.qml")), true);
  assert.equal(fs.existsSync(path.join(root, "TrayModel.js")), true);
});

test("tray is permanently expanded without arrow or hover controls", () => {
  const source = read("Tray.qml");

  assert.match(source, /property bool expanded:\s*true/);
  assert.doesNotMatch(source, /HoverHandler\s*\{/);
  assert.doesNotMatch(source, /id:\s*expandIcon/);
  assert.doesNotMatch(source, /containmentMask:/);
});

test("horizontal tray uses the full drawer extent without empty arrow space", () => {
  const source = read("Tray.qml");

  assert.match(source, /drawerBlockWidth:\s*root\.drawerCount > 0 \? root\.drawerExtent : 0/);
  assert.match(source, /id:\s*trayClip\s*\n\s*x:\s*0/);
});

test("vertical tray uses the full drawer extent without empty arrow space", () => {
  const source = read("Tray.qml");

  assert.match(source, /drawerBlockHeight:\s*root\.drawerCount > 0 \? root\.drawerExtent : 0/);
  assert.match(source, /id:\s*trayClip\s*\n\s*y:\s*0/);
});

test("drawer areas only exist when drawer items are present", () => {
  const matches = read("Tray.qml").match(/visible:\s*root\.drawerCount > 0/g) || [];
  assert.equal(matches.length, 2);
});

test("README documents one-command installation and upstream credit", () => {
  const source = read("README.md");

  assert.match(source, /omarchy plugin add https:\/\/github\.com\/manateelazycat\/omarchy-tray-bar\.git --enable --yes/);
  assert.match(source, /No manual edits/);
  assert.match(source, /github\.com\/omacom\/omarchy/);
  assert.match(source, /GNU General Public License v3\.0 only/);
  assert.equal(fs.existsSync(path.join(root, "licenses/OMARCHY-LICENSE")), true);
});
