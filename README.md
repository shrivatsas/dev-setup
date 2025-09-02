# DevSetup

A fully declarative, cross‑OS developer setup using Nix flakes, Home Manager, and nix‑darwin. One repo drives both macOS and Ubuntu.

> Replace YOUR_USERNAME and YOUR_HOSTNAME where noted. Commit, then run the bootstrap script for your OS (below).

## Repo Layout

```
.
├─ flake.nix
├─ .gitignore
├─ README.md
├─ .envrc
├─ hosts/
│  ├─ macos/default.nix
│  └─ ubuntu/default.nix
├─ home/
│  ├─ common.nix
│  ├─ macos.nix
│  └─ linux.nix
├─ modules/
│  ├─ programs/
│  │  ├─ zsh.nix
│  │  ├─ git.nix
│  │  ├─ direnv.nix
│  │  └─ starship.nix
│  └─ services/
│     └─ gpg-agent.nix
└─ scripts/
   ├─ bootstrap_macos.sh
   └─ bootstrap_ubuntu.sh
```

## Usage

set userName and hostName

### Run on Mac
```
nix run nix-darwin -- switch --flake .#mac-m1
```

### Run on ubuntu
```
home-manager switch --flake .#ubuntu
```

```
home-manager switch --flake .#arch
```

## Python With `uv`

- Install: already provided via Nix as `unstable.uv` on macOS and Linux.
- New project: `uv init myproj` then `cd myproj && uv add requests`.
- Sync env: `uv sync` creates/updates `.venv` from `pyproject.toml`/`uv.lock`.
- Run code: `uv run python app.py` or `uv run pytest` (uses the project venv automatically).
- Requirements support: `uv pip install -r requirements.txt` or `uv pip compile requirements.in -o requirements.txt`.
- Global CLI tools (pipx replacement): `uv tool install ruff`, `uv tool list`, `uv tool upgrade --all`.
- Python versions (optional): `uv python install 3.12`, `uv python pin 3.12` to set per‑project interpreter.

Notes
- Our config also provides `python312`; prefer `uv` for new work and migrate existing projects over time.
- For Nix shells, you can still `nix develop` and let `uv` manage dependencies inside that shell.

### Fallback

Aim for “Nix-first”. Only fall back to Homebrew/Apt/Snap for stubborn GUI apps or things that are truly hard to package, and keep those fallbacks declarative and minimal.

Recommendations

Nix-first: centralize tools in your flake.nix so both macOS and Linux get the same inputs.
Prefer nixpkgs-unstable over external managers before giving up; add overlays if you need newer versions.
Package what’s missing: prebuilt binary wrappers and simple source builds are often <30 lines of Nix.
Fallbacks: use Homebrew (macOS) and, if you must, Snap (Ubuntu) for GUI-only or heavily OS-integrated apps. Keep the list tiny.
Nix-first playbook

Find it: nix search nixpkgs <name>, nix-index/nix-locate, check NUR.
Allow it: set nixpkgs.config.allowUnfree = true; for unfree packages.
Pin/patch it: add an overlay to override versions or small patches.
Wrap prebuilt binaries:
Linux: use stdenvNoCC, autoPatchelfHook, add required libs to buildInputs.
macOS: skip autoPatchelfHook; place the binary in $out/bin and ensure it runs.
Build from source:
Go: buildGoModule
Rust: buildRustPackage
Python: poetry2nix or uv2nix
Node: nodePackages or vendor a dist tarball
Last-resort shims:
AppImage: appimageTools.wrapType2
FHS needs: buildFHSUserEnv for legacy installers
GPU/OpenGL on Linux: nixGL if needed
Minimal examples

Overlay to add a local package:
In flake.nix, define overlays = [ (final: prev: { mytool = prev.callPackage ./pkgs/mytool { }; }) ];
Prebuilt binary wrapper (Linux/macOS friendly):
mkDerivation with src = fetchurl { ... }, nativeBuildInputs = lib.optionals stdenv.isLinux [ autoPatchelfHook ], installPhase = "install -Dm755 mytool $out/bin/mytool";, meta.platforms = [ "x86_64-linux" "aarch64-darwin" "aarch64-linux" "x86_64-darwin" ];
When to use Homebrew or Snap

Homebrew (macOS): GUI apps/casks, kernel extensions, apps requiring Apple entitlements, or when upstream only supports brew/cask. Avoid for CLI tools you can package.
Snap (Ubuntu): only if the app is snap-only and GUI-oriented. For CLI dev tools, prefer Nix (or apt if necessary) due to Snap’s sandboxing quirks and PATH/FS friction.
Keep fallbacks declarative

macOS via nix-darwin:
Enable Homebrew and declare casks/formulae so it’s reproducible:
homebrew.enable = true;
homebrew.brews = [ "mas" ];
homebrew.casks = [ "raycast" "orbstack" ];
homebrew.onActivation.cleanup = "zap";
Ubuntu via a tiny bootstrap:
Provide a bootstrap script in your repo that runs sudo snap install ... for the 1–2 GUI apps, and keep the list in version control.
Ensure your shell PATH prefers Nix (home-manager home.sessionPath) so Nix tools win over snap/apt/brew.
Risks of mixing and how to mitigate

Path shadowing: ensure Nix precedence in PATH.
Conflicting libraries: prefer Nix builds; avoid installing the same tool in two managers.
Update drift: keep all exceptions explicitly listed in your flake/darwin config and bootstrap script.

## Manual installs

Dropbox
Alfred5 (for macos)
mise
