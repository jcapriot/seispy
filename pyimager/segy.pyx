from libc.stdio cimport FILE, fopen, fclose
from libc.stdlib cimport malloc, free
cimport cython
from .par cimport initargs

import numpy as np

# This needs to be here for file-based io to work
# it initializes the xargc and xargv parameters
# (to nothing because this package handles everything)
cdef char* argv_placeholder = ''
initargs(1, &argv_placeholder)

@cython.final
cdef class SEGYTrace:

    def __cinit__(self):
        self.trace_owner = False

    def __dealloc__(self):
        # De-allocate if not null and flag is set
        if self.trace.data is not NULL and self.trace_owner:
            free(self.trace.data)
            self.trace.data = NULL

    @staticmethod
    cdef SEGYTrace from_trace(segy trace, bint trace_owner=False):
        cdef SEGYTrace cy_trace = SEGYTrace.__new__(SEGYTrace)
        cy_trace.trace = trace
        cy_trace.trace_owner = trace_owner
        return cy_trace

    @staticmethod
    cdef SEGYTrace from_file_descriptor(FILE *fd):
        cdef SEGYTrace cy_trace = SEGYTrace.__new__(SEGYTrace)
        cy_trace.trace_owner = True
        cdef int getter_success = fvgettr(fd, &cy_trace.trace)
        if not getter_success:
            raise EOFError("Reached end of fd file.")
        return cy_trace

    def __init__(
        self,
        data,
        unsigned short dt,
        int tracl=0,
        int tracr=0,
        int fldr=0,
        int tracf=0,
        int ep=0,
        int cdp=0,
        int cdpt=0,
        short trid=0,
        short nvs=1,
        short nhs=1,
        short duse=2,
        short offset=0,
        int gelev=0,
        int selev=0,
        int sdepth=0,
        int gdel=0,
        int sdel=0,
        int swdep=0,
        int gwdep=0,
        int scalel=1,
        int scalco=1,
        int sx=0,
        int sy=0,
        int gx=0,
        int gy=0,
        short counit=1,
        short wevel=1,
        short swevel=1,
        short sut=0,
        short gut=0,
        short sstat=0,
        short gstat=0,
        short tstat=0,
        short laga=0,
        short lagb=0,
        short delrt=0,
        short muts=-1,
        short mute=-1,
        short gain=1,
        short igc=1,
        short igi=1,
        short corr=1,
        short sfs=1,
        short sfe=120,
        short slen=10_000,
        short styp=3,
        short stas=0,
        short stae=10_000,
        short tatyp=1,
        short afilf=0,
        short afils=1,
        short nofilf=0,
        short nofils=1,
        short lcf=0,
        short hcf=0,
        short lcs=1,
        short hcs=1,
        short year=1970,
        short day=0,
        short hour=0,
        short minute=0,
        short sec=0,
        short timbas=0,
        short trwf=0,
        short grnors=0,
        short grnofr=0,
        short grnlof=0,
        short gaps=0,
        short otrav=0,
        float d1=1,
        float f1=0,
        float d2=1,
        float f2=0,
        float ungpow=0,
        float unscale=1,
        int ntr=1,
        short mark=0,
        short shortpad=0,
    ):
        self.trace_data = np.require(data, dtype=np.float32, requirements='C')

        self.trace.tracl = tracl
        self.trace.tracr = tracr
        self.trace.fldr = fldr
        self.trace.tracf = tracf
        self.trace.ep = ep
        self.trace.cdp = cdp
        self.trace.cdpt = cdpt
        self.trace.trid = trid
        self.trace.nvs = nvs
        self.trace.nhs = nhs
        self.trace.duse = duse
        self.trace.offset = offset
        self.trace.gelev = gelev
        self.trace.selev = selev
        self.trace.sdepth = sdepth
        self.trace.gdel = gdel
        self.trace.sdel = sdel
        self.trace.swdep = swdep
        self.trace.gwdep = gwdep
        self.trace.scalel = scalel
        self.trace.scalco = scalco
        self.trace.sx = sx
        self.trace.sy = sy
        self.trace.gx = gx
        self.trace.gy = gy
        self.trace.counit = counit
        self.trace.wevel = wevel
        self.trace.swevel = swevel
        self.trace.sut = sut
        self.trace.gut = gut
        self.trace.sstat = sstat
        self.trace.gstat = gstat
        self.trace.tstat = tstat
        self.trace.laga = laga
        self.trace.lagb = lagb
        self.trace.delrt = delrt
        self.trace.muts = muts
        self.trace.mute = mute
        self.trace.ns = self.trace_data.shape[0]
        self.trace.dt = dt
        self.trace.gain = gain
        self.trace.igc = igc
        self.trace.igi = igi
        self.trace.corr = corr
        self.trace.sfs = sfs
        self.trace.sfe = sfe
        self.trace.slen = slen
        self.trace.styp = styp
        self.trace.stas = stas
        self.trace.stae = stae
        self.trace.tatyp = tatyp
        self.trace.afilf = afilf
        self.trace.afils = afils
        self.trace.nofilf = nofilf
        self.trace.nofils = nofils
        self.trace.lcf = lcf
        self.trace.hcf = hcf
        self.trace.lcs = lcs
        self.trace.hcs = hcs
        self.trace.year = year
        self.trace.day = day
        self.trace.hour = hour
        self.trace.minute = minute
        self.trace.sec = sec
        self.trace.timbas = timbas
        self.trace.trwf = trwf
        self.trace.grnors = grnors
        self.trace.grnofr = grnofr
        self.trace.grnlof = grnlof
        self.trace.gaps = gaps
        self.trace.otrav = otrav
        self.trace.d1 = d1
        self.trace.f1 = f1
        self.trace.d2 = d2
        self.trace.f2 = f2
        self.trace.ungpow = ungpow
        self.trace.unscale = unscale
        self.trace.ntr = ntr
        self.trace.mark = mark
        self.trace.shortpad = shortpad

        self.trace.data = &self.trace_data[0]

    @property
    def ntr(self):
        return self.trace.ntr

    @property
    def ns(self):
        return self.trace.ns

    @property
    def dt(self):
        return self.trace.dt

    @property
    def data(self):
        return np.asarray(<float[:self.trace.ns]> self.trace.data)

cdef class SEGY:
    def __cinit__(self):
        self.file_name = ''
        self.traces = None
        self.iterator = None

    def __init__(self, trace_data, dt, **kwargs):
        n_tr = len(trace_data)
        traces = []
        for trace in trace_data:
            traces.append(SEGYTrace(trace, dt=dt, ntr=n_tr, **kwargs))
        self.traces = traces

    @property
    def n_trace(self):
        return self.ntr

    @classmethod
    def from_file(cls, file_name):

        cdef SEGY new_segy = SEGY.__new__(SEGY)
        new_segy.file_name = file_name

        cdef:
            SEGYTrace trace
            FILE *fd
        # get the first trace to set some parameters
        fd = fopen(file_name.encode(), "rb")
        try:
            trace = SEGYTrace.from_file_descriptor(fd)
            new_segy.ntr = trace.trace.ntr
            new_segy.dt = trace.trace.dt
            new_segy.ns = trace.trace.ns
        finally:
            fclose(fd)
        return new_segy

    @staticmethod
    cdef SEGY from_trace_iterator(TraceIterator iterator):
        cdef SEGY new_segy = SEGY.__new__(SEGY)
        new_segy.iterator = iterator
        new_segy.ntr = iterator.handle.ntr
        new_segy.ns = iterator.handle.ns
        new_segy.dt = iterator.handle.dt
        return new_segy

    @property
    def on_disk(self):
        return self.file_name is not ''

    @property
    def is_iterator(self):
        return self.iterator is not None

    @property
    def in_memory(self):
        return self.traces is not None

    def __iter__(self):
        if self.on_disk:
            return _FileTraceIterator(self)
        elif self.in_memory:
            return TraceIterator(self)
        elif self.is_iterator:
            return self.iterator
        else:
            raise TypeError('Undefined')

    @property
    def iter_index(self):
        return self.i

    def to_memory(self):
        if self.in_memory:
            return self
        else:
            self.traces = [trace for trace in self]
            self.iterator = None
            self.file_name = ""
            return self

    def to_file(self, str file_name):
        if self.on_disk:
            return self
        cdef:
            SEGYTrace trace
            FILE *fd
        try:
            fd = fopen(file_name.encode(), 'wb')
            for trace in self:
                fvputtr(fd, &trace.trace)

            self.file_name = file_name
            self.iterator = None
            self.traces = None
        finally:
            fclose(fd)
        return self

cdef class TraceIterator:

    def __init__(self, SEGY handle):
        self.handle = handle
        self.i = 0

    cdef SEGYTrace next_trace(self):
        if self.i == self.handle.ntr:
            raise StopIteration()
        out = self.handle.traces[self.i]
        self.i += 1
        return out

    def __next__(self):
        return self.next_trace()

cdef class _FileTraceIterator(TraceIterator):
    cdef:
        FILE *fd

    def __dealloc__(self):
        # Ensure the file is close on deallocation
        if self.fd is not NULL:
            fclose(self.fd)
            self.fd = NULL

    def __init__(self, SEGY handle):
        super().__init__(handle=handle)
        self.fd = fopen(handle.file_name.encode(), 'rb')

    cdef SEGYTrace next_trace(self):
        try:
            out = SEGYTrace.from_file_descriptor(self.fd)
        except EOFError:
            if self.i < self.handle.ntr:
                print("Reached end of file unexpectedly")
            raise StopIteration()
        if self.i == self.handle.ntr:
            raise StopIteration()
        self.i += 1
        return out


