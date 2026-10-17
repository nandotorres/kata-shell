# shellcheck shell=bash
# Interactive-shell setup for the kata box (sourced from /root/.bashrc).
[[ $- == *i* ]] || return 0

# Ghostty (and other new terminals) set TERM to a name Ubuntu's ncurses does not ship.
# Compile the bundled description once; otherwise fall back so clear/less still work.
if [[ -n ${TERM:-} ]] && ! infocmp -x "$TERM" >/dev/null 2>&1; then
  src=/opt/kata/box/terminfo/${TERM}.ti
  if [[ -f $src ]]; then
    tic -x -o "$HOME/.terminfo" "$src" >/dev/null 2>&1 || true
  fi
  infocmp -x "$TERM" >/dev/null 2>&1 || export TERM=xterm-256color
fi

# Wrapper so `kata start` / `kata reset` can cd your shell into the lab dir.
kata() {
  KATA_WANT_CD=1 command kata "$@"
  local rc=$? f=$HOME/kata/.kata/cd d
  if [[ -s $f ]]; then d=$(<"$f"); rm -f "$f"; [[ -d $d ]] && { cd "$d" || return; }; fi
  return $rc
}

__kata_prompt() {
  local c
  c=$(cat "$HOME/kata/.kata/current" 2>/dev/null)
  KATA_PS1=${c:+[lab ${c%%-*}] }
}
PROMPT_COMMAND="__kata_prompt${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
PS1='\[\e[33m\]${KATA_PS1}\[\e[36m\]\u@\h\[\e[0m\]:\[\e[34m\]\w\[\e[0m\]\$ '

complete -W "list start next random show read state hint check solution reset stop progress cheat docs selftest help" kata

if [[ -z ${KATA_GREETED:-} ]]; then
  export KATA_GREETED=1
  printf '\n\e[1mshell-kata\e[0m · Ubuntu %s · systemd %s\n' \
    "$(. /etc/os-release && echo "$VERSION_ID")" "$(systemctl --version | awk 'NR==1{print $2}')"
  printf '  kata list · kata next · kata help · kata cheat split · kata docs trap\n\n'
  cur=$(cat "$HOME/kata/.kata/current" 2>/dev/null)
  if [[ -n $cur && -d $HOME/kata/$cur ]]; then cd "$HOME/kata/$cur" && printf 'Resuming %s (kata show)\n\n' "$cur"; fi
  unset cur
fi
