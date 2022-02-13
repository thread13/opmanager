#!/bin/bash

:<<\true

Takes probe/probename content and merges it with the support code from the "shell library" :

 1. cat mylib/include.bash
 2. cat probename, removing .|source ../mylib/include.bash, the shebang line (if any), and the probe function invocation at the end (if any)
 3. invoke report() function to format the report )

true

export INCLUDEME='mylib/include.bash'

fail() {
    echo "error: $*" >&2
    exit 2
}


#
# run the script from its directory ...
#

oldcwd=`pwd`
trap "cd ${oldcwd}" 0
## trap "popd >/dev/null" 0

newcwd=$(dirname $0)
## pushd "$newcwd" >/dev/null
cd "$newcwd"



#
# running prerequisite checks ..
#


if [ "x$1" = 'x' ]; then
    fail "argument expected -- the probe file name"
fi

probefile="$1"

PROBEFILE=''
for n in "${probefile}" "probe/${probefile}" ; do
    # please use .bash extension for bash-specific / non-portable scripts )
    for s in '' '.bash' ; do 
        if [ -f "${n}${s}" ] ; then 
            PROBEFILE="${n}${s}"; 
            SCRIPTNAME=$(basename "$PROBEFILE") ;
            break
        fi
    done
    if [ -n "$PROBEFILE" ]; then
        break
    fi
done

if [ "x$PROBEFILE" = 'x' ] ; then
    fail "file '$probefile[.bash]' or 'probe/$probefile[.bash]' not found at '$newcwd'"
fi


if [ -f "${INCLUDEME}" ] ; then : ; else
    fail "file '${INCLUDEME}' is missing"'!'
fi


#
# main() )
#

FILENAME="monitor-${SCRIPTNAME}"

separator() {
  cat - <<\EOF

# --------------------------------------------------------------------- 
EOF
}

{ cat "${INCLUDEME}" ;

  ESCAPED=$(echo ${INCLUDEME} | sed 's@/@[/]@g')
  separator
  sed -E -e '1{/^\#\!/d}'                          \
         -e "/^\s*[.]\s+[.][.][/]${ESCAPED}/d"     \
         -e "/^\s*source\s+[.][.][/]${ESCAPED}/d"  \
         -e '/^\s*probe\s*([#].*)?$/d'             \
  "${PROBEFILE}" ;

  separator
  echo '# main()'
  echo ''
  echo report  

} >"${FILENAME}"

