#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -W 2>/dev/null || cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEFAULT_FONT="JetBrainsMono Nerd Font"
DEFAULT_FONT_SIZE=11
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"

# ── Prompt helpers ─────────────────────────────────────────────────────────────

ask() {
  local -n _var="$1"
  local prompt="$2" default="$3"
  shift 3
  local choices=("$@")
  local suffix=""
  [ ${#choices[@]} -gt 0 ] && suffix=" [$(IFS='/'; echo "${choices[*]}")]"
  [ -n "$default" ] && suffix+=" (default: $default)"
  while true; do
    printf '%s%s: ' "$prompt" "$suffix"
    read -r ans
    [ -z "$ans" ] && ans="$default"
    if [ ${#choices[@]} -gt 0 ]; then
      local ok=0
      for c in "${choices[@]}"; do [ "$ans" = "$c" ] && ok=1 && break; done
      [ $ok -eq 0 ] && echo "  pick one of: ${choices[*]}" && continue
    fi
    [ -n "$ans" ] && { _var="$ans"; return; }
  done
}

ask_yn() {
  local -n _yn="$1"
  ask _yn "$2" "${3:-n}" y n
}

# ── Font detection + install ───────────────────────────────────────────────────

font_installed() {
  if command -v fc-list >/dev/null 2>&1; then
    fc-list 2>/dev/null | grep -qi "JetBrains" && return 0
  fi
  ls "$HOME/Library/Fonts/" 2>/dev/null | grep -qi "JetBrains" && return 0
  ls /Library/Fonts/ 2>/dev/null | grep -qi "JetBrains" && return 0
  return 1
}

install_font_macos() {
  echo "  Installing via Homebrew..."
  brew install --cask font-jetbrains-mono-nerd-font
}

install_font_linux() {
  local dest="$HOME/.local/share/fonts/JetBrainsMono"
  local tmp
  tmp="$(mktemp -d)"
  echo "  Downloading JetBrainsMono Nerd Font..."
  curl -fsSL "$FONT_URL" -o "$tmp/JetBrainsMono.zip"
  mkdir -p "$dest"
  unzip -o "$tmp/JetBrainsMono.zip" -d "$dest" >/dev/null
  rm -rf "$tmp"
  fc-cache -fv "$dest" >/dev/null 2>&1
  echo "  Installed to $dest"
}

maybe_install_font() {
  local chosen_font="$1"
  [ "$chosen_font" != "$DEFAULT_FONT" ] && return 0
  font_installed && { echo "  JetBrainsMono Nerd Font already installed."; return 0; }

  local do_install
  ask_yn do_install "JetBrainsMono Nerd Font not found — install it now?" n
  [ "$do_install" = "y" ] || return 0

  if [[ "${OSTYPE:-}" == darwin* ]]; then
    install_font_macos
  else
    install_font_linux
  fi
}

# ── Settings JSON helpers via node ─────────────────────────────────────────────

_node_merge_settings() {
  local path="$1" js="$2"
  node -e "
const fs=require('fs');
const p=process.argv[1];
let s={};
if(fs.existsSync(p)){try{s=JSON.parse(fs.readFileSync(p,'utf8'));}catch(e){
  process.stderr.write('warning: '+p+' is not valid JSON; skipping\n');process.exit(0);
}}
$js
fs.mkdirSync(require('path').dirname(p),{recursive:true});
fs.writeFileSync(p,JSON.stringify(s,null,2)+'\n');
" "$path"
}

enable_statusline() {
  local settings="$HOME/.claude/settings.json"
  local sl_cmd="bash \"$REPO/scripts/statusline.sh\""
  node -e "
const fs=require('fs');
const p=process.argv[1],cmd=process.argv[2];
let s={};
if(fs.existsSync(p)){try{s=JSON.parse(fs.readFileSync(p,'utf8'));}catch(e){process.exit(0);}}
s.statusLine={type:'command',command:cmd,refreshInterval:5};
fs.mkdirSync(require('path').dirname(p),{recursive:true});
fs.writeFileSync(p,JSON.stringify(s,null,2)+'\n');
" "$settings" "$sl_cmd"
  echo "  Updated $settings"
}

enable_caveman() {
  local cfg_dir
  if [ -n "${XDG_CONFIG_HOME:-}" ]; then
    cfg_dir="$XDG_CONFIG_HOME/caveman"
  else
    cfg_dir="$HOME/.config/caveman"
  fi
  mkdir -p "$cfg_dir"
  printf '{"defaultMode":"ultra"}\n' > "$cfg_dir/config.json"
  echo "  Wrote $cfg_dir/config.json"

  local settings="$HOME/.claude/settings.json"
  node -e "
const fs=require('fs');
const p=process.argv[1];
let s={};
if(fs.existsSync(p)){try{s=JSON.parse(fs.readFileSync(p,'utf8'));}catch(e){process.exit(0);}}
s.extraKnownMarketplaces=s.extraKnownMarketplaces||{};
s.extraKnownMarketplaces.caveman={source:{source:'github',repo:'JuliusBrussee/caveman'}};
s.enabledPlugins=s.enabledPlugins||{};
s.enabledPlugins['caveman@caveman']=true;
fs.mkdirSync(require('path').dirname(p),{recursive:true});
fs.writeFileSync(p,JSON.stringify(s,null,2)+'\n');
" "$settings"
  echo "  Updated $settings"
  echo "  caveman plugin will install on next claude session."
}

# ── Main ───────────────────────────────────────────────────────────────────────

main() {
  echo "cterm setup"
  echo "-----------"

  local agent font size use_nvim
  ask agent "Default agent CLI" "claude" claude copilot codex gemini
  ask font  "Font name" "$DEFAULT_FONT"
  ask size  "Font size" "$DEFAULT_FONT_SIZE"
  [[ "$size" =~ ^[0-9]+$ ]] || { echo "  invalid size, using $DEFAULT_FONT_SIZE"; size=$DEFAULT_FONT_SIZE; }

  ask_yn use_nvim "Use your own nvim config (instead of bundled)?" n

  local inst_sl=n inst_cav=n
  if [ "$agent" = "claude" ]; then
    ask_yn inst_sl "Install statusline globally (model + cwd in claude sessions)?" y
    ask_yn inst_cav "Install caveman plugin (terse output, default mode: ultra)?" n
  fi

  local use_nvim_val
  [ "$use_nvim" = "y" ] && use_nvim_val=1 || use_nvim_val=0

  # Write cterm.local (bash)
  {
    echo "# Generated by scripts/setup.sh — edit freely or rerun: cterm --setup"
    echo "CTERM_DEFAULT_AGENT=$agent"
    echo "CTERM_FONT=\"$font\""
    echo "CTERM_FONT_SIZE=$size"
    echo "CTERM_USE_USER_NVIM=$use_nvim_val"
  } > "$REPO/cterm.local"

  # Write cterm.local.cmd (batch, CRLF)
  printf '@echo off\r\nrem Generated by scripts/setup.sh - edit freely or rerun: cterm --setup\r\nset "CTERM_DEFAULT_AGENT=%s"\r\nset "CTERM_FONT=%s"\r\nset "CTERM_FONT_SIZE=%s"\r\nset "CTERM_USE_USER_NVIM=%s"\r\n' \
    "$agent" "$font" "$size" "$use_nvim_val" > "$REPO/cterm.local.cmd"

  echo ""
  echo "Wrote $REPO/cterm.local"
  echo "Wrote $REPO/cterm.local.cmd"

  if [ "$inst_sl" = "y" ]; then
    echo ""
    echo "Configuring statusline globally..."
    enable_statusline
  fi

  if [ "$inst_cav" = "y" ]; then
    echo ""
    echo "Enabling caveman globally..."
    enable_caveman
  fi

  echo ""
  maybe_install_font "$font"

  echo ""
  echo "Done. Run 'cterm' to launch."
}

main "$@"
