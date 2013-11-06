#!/bin/sh

# fakechroot
#
# Script which sets fake chroot environment
#
# (c) 2011, 2013 Piotr Roszatycki <dexter@debian.org>, LGPL


FAKECHROOT_VERSION=@VERSION@


die () {
    echo "$@" 1>&2
    exit 1
}


usage () {
    die "Usage:
    fakechroot [-l|--lib fakechrootlib] [-d|--elfloader ldso]
               [-s|--use-system-libs]
               [-e|--environment type] [-c|--config-dir directory]
               [--] [command]
    fakechroot -v|--version
    fakechroot -h|--help"
}


next_cmd_fakechroot () {
    if [ "$1" = "fakeroot" ]; then
        shift
        # skip the options
        while [ $# -gt 0 ]; do
            case "$1" in
                -h|-v)
                    break
                    ;;
                -u|--unknown-is-real)
                    shift
                    ;;
                -l|--lib|--faked|-s|-i|-b)
                    shift 2
                    ;;
                --)
                    shift
                    break
                    ;;
                *)
                    break
                    ;;
            esac
        done
    fi

    if [ -n "$1" -a "$1" != "-v" -a "$1" != "-h" ]; then
        environment=`basename -- "$1"`
    fi
}


if [ "$FAKECHROOT" = "true" ]; then
    die "fakechroot: nested operation is not supported"
fi


# Default settings
lib=libfakechroot.so
paths=@libpath@
sysconfdir=@sysconfdir@
confdir=
environment=

if [ "$paths" = "no" ]; then
    paths=
fi


# Get options
getopttest=`getopt --version`
case $getopttest in
    getopt*)
        # GNU getopt
        opts=`getopt -q -l lib: -l elfloader: -l use-system-libs -l config-dir: -l environment: -l version -l help -- +l:d:sc:e:vh "$@"`
        ;;
    *)
        # POSIX getopt ?
        opts=`getopt l:d:sc:e:vh "$@"`
        ;;
esac

if [ "$?" -ne 0 ]; then
    usage
fi

eval set -- "$opts"

while [ $# -gt 0 ]; do
    opt=$1
    shift
    case "$opt" in
        -h|--help)
            usage
            ;;
        -v|--version)
            echo "fakechroot version $FAKECHROOT_VERSION"
            exit 0
            ;;
        -l|--lib)
            lib=`eval echo "$1"`
            paths=
            shift
            ;;
        -d|--elfloader)
            FAKECHROOT_ELFLOADER=$1
            export FAKECHROOT_ELFLOADER
            shift
            ;;
        -s|--use-system-libs)
            paths="${paths:+$paths:}/usr/lib:/lib"
            ;;
        -c|--config-dir)
            confdir=$1
            shift
            ;;
        -e|--environment)
            environment=$1
            shift
            ;;
        --)
            break
            ;;
    esac
done

if [ -z "$environment" ]; then
    next_cmd_fakechroot "$@"
fi


# Autodetect if dynamic linker supports --argv0 option
if [ -n "$FAKECHROOT_ELFLOADER" ]; then
    detect=`$FAKECHROOT_ELFLOADER --argv0 echo @ECHO@ yes 2>&1`
    if [ "$detect" = yes ]; then
        FAKECHROOT_ELFLOADER_OPT_ARGV0="--argv0"
        export FAKECHROOT_ELFLOADER_OPT_ARGV0
    fi
fi


# Make sure the preload is available
paths="$paths${LD_LIBRARY_PATH:+${paths:+:}$LD_LIBRARY_PATH}"
lib="$lib${LD_PRELOAD:+ $LD_PRELOAD}"

detect=`LD_LIBRARY_PATH="$paths" LD_PRELOAD="$lib" FAKECHROOT_DETECT=1 @ECHO@ 2>&1`
case "$detect" in
    fakechroot*)
        libfound=yes
        ;;
    *)
        libfound=no
esac

if [ $libfound = no ]; then
    die "fakechroot: preload library not found, aborting."
fi


# Additional environment setting from configuration file
if [ "$environment" != "none" ]; then
    for e in "$environment" "${environment%.*}" default; do
        for d in "$confdir" "$HOME/.fakechroot" "$sysconfdir"; do
            f="$d/$e.env"
            if [ -f "$f" ]; then
                . "$f"
                break 2
            fi
        done
    done
fi


# Execute command
if [ -z "$*" ]; then
    LD_LIBRARY_PATH="$paths" LD_PRELOAD="$lib" ${SHELL:-/bin/sh}
    result=$?
else
    LD_LIBRARY_PATH="$paths" LD_PRELOAD="$lib" "$@"
    result=$?
fi

exit $result
