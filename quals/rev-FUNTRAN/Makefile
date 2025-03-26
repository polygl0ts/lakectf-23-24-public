FC=gfortran
FCFLAGS=-Wall -Wno-tabs -Wextra -Wunused -Wsurprising -Wpedantic -Wuse-without-only -Waliasing -Winteger-division -Wcharacter-truncation -Wimplicit-interface -Wimplicit-procedure -Wconversion -Wconversion-extra -Wrealloc-lhs-all -Wno-maybe-uninitialized -fimplicit-none

EVIL=0
STRIP=0
ifeq ($(EVIL), -1)  # debug
FCFLAGS+= -fcheck=all -fbacktrace -g -DDEBUG=1 -O0
else ifeq ($(EVIL), 0)  # easy
FCFLAGS+= -O1 #-g
else ifeq ($(EVIL), 1)  # medium
FCFLAGS+= -O2
else ifeq ($(EVIL), 2)
FCFLAGS+= -O3
STRIP=1
endif

DIR_BUILD=build
DIR_SRC=src

all: fortran

.phony: clean fortran

fortran: clean
	mkdir -p ${DIR_BUILD}
	${FC} ${FCFLAGS} -J${DIR_BUILD} -c ${DIR_SRC}/types.f90 -o ${DIR_BUILD}/types.o
	${FC} ${FCFLAGS} -J${DIR_BUILD} -c ${DIR_SRC}/arrayops.f90 -o ${DIR_BUILD}/arrayops.o
	${FC} ${FCFLAGS} -J${DIR_BUILD} -c ${DIR_SRC}/integrate.f90 -o ${DIR_BUILD}/integrate.o
	${FC} ${FCFLAGS} -J${DIR_BUILD} -c ${DIR_SRC}/main.F90 -o ${DIR_BUILD}/main.o
	${FC} ${FCFLAGS} -J${DIR_BUILD} -static ${DIR_BUILD}/types.o ${DIR_BUILD}/integrate.o ${DIR_BUILD}/arrayops.o ${DIR_BUILD}/main.o -o ${DIR_BUILD}/funtran

ifneq ($(STRIP), 0)
	strip -s ${DIR_BUILD}/funtran
endif

clean:
	rm -rf build
