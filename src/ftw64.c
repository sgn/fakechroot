/* File tree walker functions.  LFS version.
   Copyright (C) 1996, 1997, 1998, 2001, 2006 Free Software Foundation, Inc.
   This file is part of the GNU C Library.
   Contributed by Ulrich Drepper <drepper@cygnus.com>, 1996.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
   02111-1307 USA.  */

#include <config.h>
#define _GNU_SOURCE
#include <sys/stat.h>

#define __FTW64_C
#define FTW_NAME ftw64
#define NFTW_NAME nftw64
#define NFTW_OLD_NAME __old_nftw64
#define NFTW_NEW_NAME __new_nftw64
#define INO_T ino64_t
#define STAT stat64
#define LXSTAT __lxstat64
#define XSTAT __xstat64
#define FXSTATAT __fxstatat64
#define FTW_FUNC_T __ftw64_func_t
#define NFTW_FUNC_T __nftw64_func_t

#ifdef HAVE___FXSTATAT64
int __fxstatat64(int ver, int fd, const char *filename, struct stat64 *buf, int flags);
#endif
#ifdef HAVE___LXSTAT64
int __lxstat64(int ver, const char *filename, struct stat64 *buf);
#endif
#ifdef HAVE___XSTAT64
int __xstat64(int ver, const char *filename, struct stat64 *buf);
#endif

#include "ftw.c"
