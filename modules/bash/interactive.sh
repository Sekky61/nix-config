MANPAGER="sh -c 'col -bx | bat -l man -p'"
MANROFFOPT="-c"

#man pages
MANPATH=/usr/share/man

c_test () {
    T='gYw'   # The test text
    echo -e "\n                 40m     41m     42m     43m     44m     45m     46m     47m";
    for FGs in '    m' '   1m' '  30m' '1;30m' '  31m' '1;31m' '  32m' '1;32m' '  33m' '1;33m' '  34m' '1;34m' '  35m' '1;35m' '  36m' '1;36m' '  37m' '1;37m';
    do FG=${FGs// /}
    echo -en " $FGs \033[$FG  $T  "
    for BG in 40m 41m 42m 43m 44m 45m 46m 47m;
        do echo -en "$EINS \033[$FG\033[$BG  $T \033[0m\033[$BG \033[0m";
    done
    echo;
    done
    echo ''
}

eval "$(zoxide init bash)"

if command -v direnv &> /dev/null; then
    eval "$(direnv hook bash)"
fi

# Source API keys if the file exists
if [ -f ~/.secrets.sh ]; then
  source ~/.secrets.sh
fi


motd

