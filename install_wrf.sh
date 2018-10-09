#!/bin/sh
set -x
DIR=$PWD

### set install zlib export
setenv CC gcc
setenv CXX g++
setenv FC pgf90
setenv FCFLAGS -m64
setenv F77 pgf77
setenv FFLAGS -m64

setenv LDFLAGS -L$DIR/env/lib
setenv CPPFLAGS -I$DIR/env/include

### install zlib
wget http://zlib.net/zlib-1.2.11.tar.gz

tar -zxvf zlib-1.2.11.tar.gz    
cd zlib-1.2.11
./configure --prefix=$DIR/env
make
make install
cd ..

### install libpng
wget http://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/libpng-1.2.50.tar.gz

tar -zxvf libpng-1.2.50.tar.gz     
cd libpng-1.2.50
./configure --prefix=$DIR/env
make
make install
cd ..

### install jasper
wget http://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/jasper-1.900.1.tar.gz

tar -zxvf jasper-1.900.1.tar.gz   
cd jasper-1.900.1
./configure --prefix=$DIR/env
make
make install
cd ..

### install wrf netcdf-4.1.3 env
wget http://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/netcdf-4.1.3.tar.gz

tar -zxvf netcdf-4.1.3.tar.gz
cd netcdf-4.1.3
./configure --prefix=$DIR/netcdf --disable-dap --disable-netcdf-4
make 
make install
cd ..

### install laps install netcdf-3.6.3 env 
### is must netcdf-3.6.3
#tar -zxvf netcdf-3.6.3.tar.gz     
#cd netcdf-3.6.3
#./configure --prefix=$DIR/netcdf --disable-dap --disable-netcdf-4
#make
#make install
#cd ..

### install hdf5
wget https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8/hdf5-1.8.13/src/hdf5-1.8.13.tar.gz

tar -zxvf hdf5-1.8.13.tar.gz     
cd hdf5-1.8.13
./configure --prefix=$DIR/hdf5 --with-zlib=$DIR/env --disable-shared --enable-fortran
make
make install
cd ..

### install mpich
wget http://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/mpich-3.0.4.tar.gz

tar -zxvf mpich-3.0.4.tar.gz   
cd mpich-3.0.4
./configure --prefix=$DIR/mpich
make
make install
cd ..

### install wrf3.8
wget http://www2.mmm.ucar.edu/wrf/src/WRFV3.8.TAR.gz

tar -zxvf WRFV3.8.TAR.gz
cd WRFV3

./configure 
./compile em_real &> 1.log
ll main/*.exe

cd ..
### install wps3.8
wget http://www2.mmm.ucar.edu/wrf/src/WPSV3.8.TAR.gz

tar -zxvf WPSV3.8.TAR.gz
cd WPS

./configure
./compile &> 1.log
ll *.exe

cd ..
























