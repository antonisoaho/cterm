#!/usr/bin/env bash
# Claude Code statusline — reads session JSON from stdin (piped by Claude Code)
# Shows: model figure | tokens/ctx | 5h rate limit bar | vim mode | caveman mode

input=$(cat)

# ── Pure-bash JSON extraction ──────────────────────────────────────────────────
json_val() {
    echo "$input" | grep -o "\"$1\"[[:space:]]*:[[:space:]]*[^,}]*" | head -1 \
        | sed 's/.*:[[:space:]]*//' | tr -d '"[:space:]'
}

MODEL=$(json_val "display_name")
MODEL_ID=$(json_val "id")
PCT=$(json_val "used_percentage")
CTX_SIZE=$(json_val "context_window_size")
IN_TOKENS=$(json_val "total_input_tokens")
OUT_TOKENS=$(json_val "total_output_tokens")
VIM_MODE=$(json_val "mode")

FIVE_H_PCT=$(echo "$input" | grep -o '"five_hour"[^}]*}' \
    | grep -o '"used_percentage"[[:space:]]*:[[:space:]]*[0-9.]*' \
    | sed 's/.*:[[:space:]]*//')
FIVE_H_RESETS=$(echo "$input" | grep -o '"five_hour"[^}]*}' \
    | grep -o '"resets_at"[[:space:]]*:[[:space:]]*[0-9]*' \
    | sed 's/.*:[[:space:]]*//')

# ── Defaults ───────────────────────────────────────────────────────────────────
MODEL=${MODEL:-unknown}
PCT=${PCT:-0};       PCT=${PCT%%.*}
CTX_SIZE=${CTX_SIZE:-200000}
IN_TOKENS=${IN_TOKENS:-0}
OUT_TOKENS=${OUT_TOKENS:-0}

# ── ANSI colours ───────────────────────────────────────────────────────────────
CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
BOLD='\033[1m'
DIM='\033[2m'
ORANGE='\033[38;5;172m'
NC='\033[0m'

# ── Progress bar ───────────────────────────────────────────────────────────────
build_bar() {
    local pct=$1 width=15 filled empty bar=""
    filled=$(( pct * width / 100 ))
    empty=$(( width - filled ))
    for (( i=0; i<filled; i++ )); do bar+="█"; done
    for (( i=0; i<empty;  i++ )); do bar+="░"; done
    echo "$bar"
}

# ── Format helpers ─────────────────────────────────────────────────────────────
fmt_ctx() {
    if   [[ $1 -ge 1000000 ]]; then echo "$(( $1 / 1000000 ))M"
    elif [[ $1 -ge 1000    ]]; then echo "$(( $1 / 1000 ))K"
    else echo "$1"; fi
}

fmt_tok() {
    [[ $1 -ge 10000 ]] && echo "$(( $1 / 1000 ))K" || echo "$1"
}

# ── Model figure ───────────────────────────────────────────────────────────────
MODEL_LOWER=$(echo "$MODEL_ID" | tr '[:upper:]' '[:lower:]')
if echo "$MODEL_LOWER" | grep -q "opus"; then
    FIGURE="(ง'̀-'́)ง"
elif echo "$MODEL_LOWER" | grep -q "sonnet"; then
    FIGURE="(^_^)"
else
    FIGURE="(•ᴗ•)"
fi

MODEL_NUM=$(echo "$MODEL" | grep -oE '[0-9]+(\.[0-9]+)+' | head -1)
MODEL_NUM=${MODEL_NUM:-$MODEL}

# ── Assemble ───────────────────────────────────────────────────────────────────
LINE="${CYAN}${BOLD}${FIGURE} ${MODEL_NUM}${NC}"
LINE+=" ${DIM}|${NC} ${DIM}out:${NC}$(fmt_tok "$OUT_TOKENS")${DIM}/$(fmt_ctx "$CTX_SIZE")${NC}"

# 5-hour rate limit
if [[ -n "$FIVE_H_PCT" && "$FIVE_H_PCT" != "null" ]]; then
    FIVE_H_INT=${FIVE_H_PCT%%.*}
    BAR_COLOR=$GREEN
    [[ $FIVE_H_INT -ge 75 ]] && BAR_COLOR=$RED
    [[ $FIVE_H_INT -ge 50 && $FIVE_H_INT -lt 75 ]] && BAR_COLOR=$YELLOW
    FIVE_BAR=$(build_bar "$FIVE_H_INT")

    RESET_STR=""
    if [[ -n "$FIVE_H_RESETS" && "$FIVE_H_RESETS" != "null" && "$FIVE_H_RESETS" -gt 0 ]]; then
        NOW=$(date +%s)
        SECS_LEFT=$(( FIVE_H_RESETS - NOW ))
        if [[ $SECS_LEFT -le 0 ]]; then
            RESET_STR="now"
        else
            HRS=$(( SECS_LEFT / 3600 ))
            MINS=$(( (SECS_LEFT % 3600) / 60 ))
            [[ $HRS -gt 0 ]] && RESET_STR="${HRS}h${MINS}m" || RESET_STR="${MINS}m"
        fi
    fi

    LINE+=" ${DIM}|${NC} ${BAR_COLOR}[${FIVE_BAR}]${NC} ${BOLD}${FIVE_H_INT}%${NC}"
    [[ -n "$RESET_STR" ]] && LINE+=" ${DIM}resets in ${RESET_STR}${NC}"
fi

# Vim mode
if [[ -n "$VIM_MODE" && "$VIM_MODE" != "null" ]]; then
    if [[ "$VIM_MODE" == "INSERT" ]]; then
        LINE+=" ${DIM}|${NC} ${YELLOW}${BOLD}INSERT${NC}"
    else
        LINE+=" ${DIM}|${NC} ${CYAN}${VIM_MODE}${NC}"
    fi
fi

# Caveman mode (only if caveman plugin is active)
CAVEMAN_FLAG="$HOME/.claude/.caveman-active"
if [[ -f "$CAVEMAN_FLAG" ]]; then
    CAVEMAN_MODE=$(cat "$CAVEMAN_FLAG" 2>/dev/null | tr -d '[:space:]')
    if [[ "$CAVEMAN_MODE" == "full" || -z "$CAVEMAN_MODE" ]]; then
        LINE+=" ${DIM}|${NC} ${ORANGE}${BOLD}[CAVEMAN]${NC}"
    else
        CAVEMAN_SUFFIX=$(echo "$CAVEMAN_MODE" | tr '[:lower:]' '[:upper:]')
        LINE+=" ${DIM}|${NC} ${ORANGE}${BOLD}[CAVEMAN:${CAVEMAN_SUFFIX}]${NC}"
    fi
fi

echo -e "$LINE"
