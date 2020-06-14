/*
    libfakechroot -- fake chroot environment
    Copyright (c) 2010-2015 Piotr Roszatycki <dexter@debian.org>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
*/


#include <config.h>

#if defined(HAVE_STAT64) && (!defined(HAVE___XSTAT64) || defined(__XSTAT_CALL_STAT))

#define _BSD_SOURCE
#define _LARGEFILE64_SOURCE
#define _DEFAULT_SOURCE
#include <sys/stat.h>
#include <limits.h>
#include <stdlib.h>

#include "libfakechroot.h"

typedef struct stat64 fakechroot_stat64_t;

#ifdef stat64
#undef stat64
#endif


wrapper(stat64, int, (const char * file_name, fakechroot_stat64_t * buf))
{
    char fakechroot_abspath[FAKECHROOT_PATH_MAX];
    char fakechroot_buf[FAKECHROOT_PATH_MAX];
    debug("stat64(\"%s\", &buf)", file_name);
    expand_chroot_path(file_name);
    return nextcall(stat64)(file_name, buf);
}

#else
typedef int empty_translation_unit;
#endif
