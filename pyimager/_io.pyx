from cpython.object cimport PyObject_AsFileDescriptor
from libc.stdio cimport FILE, fclose, SEEK_SET
from libc.limits cimport INT_MIN, INT_MAX
import os
import io

cdef extern from "_io.h":
    ctypedef int pyi_off_t

    FILE *pyi_fdopen(int fd, const char * mode)
    pyi_off_t pyi_lseek(int fd, pyi_off_t offset, int whence)
    int pyi_fseek(FILE *stream, pyi_off_t offset, int whence)
    pyi_off_t pyi_ftell(FILE *stream)


cdef FILE * PyFile_Dup(object file, char* mode, pyi_off_t *orig_pos):
    cdef:
        int fd, fd2
        Py_ssize_t fd2_tmp
        pyi_off_t pos
        FILE *handle

    file.flush()

    fd = PyObject_AsFileDescriptor(file)
    if fd == -1:
        return NULL
    fd2_tmp = os.dup(fd)
    if fd2_tmp < INT_MIN or fd2_tmp > INT_MAX:
        raise IOError("Getting an 'int' from os.dup() failed")

    fd2 = <int> fd2_tmp
    handle = pyi_fdopen(fd2, mode)
    orig_pos[0] = pyi_ftell(handle)
    if orig_pos[0] == -1:
        if isinstance(file, io.RawIOBase):
            return handle
        else:
            raise IOError("obtaining file position failed")

    # raw handle to the Python-side position
    try:
        pos = file.tell()
    except Exception:
        fclose(handle)
    if pyi_fseek(handle, pos, SEEK_SET) == -1:
        fclose(handle)
        raise IOError("seeking file failed")
    return handle

cdef int PyFile_DupClose(object file, FILE* handle, pyi_off_t orig_pos):
    cdef:
        int fd
        pyi_off_t position = pyi_ftell(handle)
    fclose(handle)

    # Restore original file handle position,
    fd = PyObject_AsFileDescriptor(file)
    if fd == -1:
        return -1
    if pyi_lseek(fd, orig_pos, SEEK_SET) == -1:
        if isinstance(file, io.RawIOBase):
            return 0
        else:
            raise IOError("seeking file failed")
    if position == -1:
        raise IOError("obtaining file position failed")

    # Seek Python-side handle to the FILE* handle position
    file.seek(position)
    return 0
