#!/bin/bash

################################################################
# Sources for all libraries used in this script can be found at
# http://www2.mmm.ucar.edu/people/duda/files/mpas/sources/ 
# modified by Yue_Ma 
# 2018.10.25
# system ubuntu 18.04lts
# e-mail: mynorthmoon@gmail.com
################################################################

###########################################
# If it ia a new system, you should install
# build-essential gcc g++ gfortran
# make m4 gawk tcsh zlib libpng git
###########################################
#sudo apt-get install update upgrade
#sudo apt-get install build-essential gcc g++ gfortran
#sudo apt-get install tcsh make m4 gawk cmake git
#sudo apt-get install libpng-dev

################################## Begin ##################################

# Where to find sources for libraries
export PATH_FOR_MPAS=`pwd`
export LIBSRC=$PATH_FOR_MPAS/sources

# Where to install libraries
export LIBBASE=$PATH_FOR_MPAS/mpas-libs

# Compilers
export SERIAL_FC=gfortran
export SERIAL_F77=gfortran
export SERIAL_CC=gcc
export SERIAL_CXX=g++
export MPI_FC=mpifort
export MPI_F77=mpif77
export MPI_CC=mpicc
export MPI_CXX=mpicxx

# Download packages
wget -P ${LIBSRC} http://www2.mmm.ucar.edu/people/duda/files/mpas/sources/mpich-3.2.tar.gz    #mpich
wget -P ${LIBSRC} http://www2.mmm.ucar.edu/people/duda/files/mpas/sources/zlib-1.2.8.tar.gz   #zlib
wget -P ${LIBSRC} http://www2.mmm.ucar.edu/people/duda/files/mpas/sources/hdf5-1.8.19.tar.bz2 #hdf5
wget -P ${LIBSRC} http://www2.mmm.ucar.edu/people/duda/files/mpas/sources/parallel-netcdf-1.8.1.tar.gz  #pnetcdf
wget -P ${LIBSRC} http://www2.mmm.ucar.edu/people/duda/files/mpas/sources/netcdf-4.4.1.1.tar.gz #netcdf-c
wget -P ${LIBSRC} http://www2.mmm.ucar.edu/people/duda/files/mpas/sources/netcdf-fortran-4.4.4.tar.gz #netcdf-fortran
wget -P ${LIBSRC} http://www2.mmm.ucar.edu/people/duda/files/mpas/sources/cmake-3.4.0-rc3.tar.gz  #cmake

########################################
# MPICH
########################################
tar xzvf ${LIBSRC}/mpich-3.2.tar.gz
cd mpich-3.2
export CC=$SERIAL_CC
export CXX=$SERIAL_CXX
export F77=$SERIAL_F77
export FC=$SERIAL_FC
unset F90  # This seems to be set by default on NCAR's Cheyenne and is problematic
unset F90FLAGS
./configure --prefix=${LIBBASE} --disable-shared
make
make check
make install
export PATH=${LIBBASE}/bin:$PATH
cd ..
rm -rf mpich-3.2

########################################
# cmake
########################################
tar xzvf ${LIBSRC}/cmake-3.4.0-rc3.tar.gz
cd cmake-3.4.0-rc3
./bootstrap --prefix=${LIBBASE}
gmake
gmake install
export PATH=${LIBBASE}/bin:$PATH
cd ..
rm -rf cmake-3.4.0-rc3


########################################
# zlib
########################################
tar xzvf ${LIBSRC}/zlib-1.2.8.tar.gz
cd zlib-1.2.8
./configure --prefix=${LIBBASE} --static
make
make install
cd ..
rm -rf zlib-1.2.8

########################################
# HDF5
########################################
tar xjvf ${LIBSRC}/hdf5-1.8.19.tar.bz2
cd hdf5-1.8.19
export FC=$MPI_FC
export CC=$MPI_CC
export CXX=$MPI_CXX
./configure --prefix=${LIBBASE} --enable-parallel --with-zlib=${LIBBASE} --disable-shared
make
make check
make install
cd ..
rm -rf hdf5-1.8.19

########################################
# Parallel-netCDF
########################################
tar xzvf ${LIBSRC}/parallel-netcdf-1.8.1.tar.gz
cd parallel-netcdf-1.8.1
export CC=$SERIAL_CC
export CXX=$SERIAL_CXX
export F77=$SERIAL_F77
export FC=$SERIAL_FC
export MPICC=$MPI_CC
export MPICXX=$MPI_CXX
export MPIF77=$MPI_F77
export MPIF90=$MPI_FC
### Will also need gcc in path
./configure --prefix=${LIBBASE}
make
make testing
make install
export PNETCDF=${LIBBASE}
cd ..
rm -rf parallel-netcdf-1.8.1

########################################
# netCDF (C library)
########################################
tar xzvf ${LIBSRC}/netcdf-4.4.1.1.tar.gz
cd netcdf-4.4.1.1
export CPPFLAGS="-I${LIBBASE}/include"
export LDFLAGS="-L${LIBBASE}/lib"
export LIBS="-lhdf5_hl -lhdf5 -lz -ldl"
export CC=$MPI_CC
./configure --prefix=${LIBBASE} --disable-dap --enable-netcdf4 --enable-pnetcdf --enable-parallel-tests --disable-shared
make
make check
make install
export NETCDF=${LIBBASE}
cd ..
rm -rf netcdf-4.4.1.1

########################################
# netCDF (Fortran interface library)
########################################
tar xzvf ${LIBSRC}/netcdf-fortran-4.4.4.tar.gz
cd netcdf-fortran-4.4.4
export FC=$MPI_FC
export F77=$MPI_F77
export LIBS="-lnetcdf ${LIBS}"
./configure --prefix=${LIBBASE} --enable-parallel-tests --disable-shared
make
make check
make install
cd ..
rm -rf netcdf-fortran-4.4.4

########################################
# PIO
########################################
git clone https://github.com/NCAR/ParallelIO.git
cd ParallelIO
export PIOSRC=`pwd`
cd ..
mkdir pio
cd pio
export CC=mpicc
export FC=mpifort
cmake -DNetCDF_C_PATH=$NETCDF -DNetCDF_Fortran_PATH=$NETCDF -DPnetCDF_PATH=$PNETCDF -DCMAKE_INSTALL_PREFIX=$LIBBASE -DPIO_ENABLE_TIMING=OFF $PIOSRC
make
make install
cd ..
rm -rf pio ParallelIO-master
export PIO=$LIBBASE

########################################
# Other environment vars needed by MPAS
########################################
export MPAS_EXTERNAL_LIBS="-L${LIBBASE}/lib -lhdf5_hl -lhdf5 -ldl -lz"
export MPAS_EXTERNAL_INCLUDES="-I${LIBBASE}/include"

########################################
# MPAS
########################################
git clone https://github.com/MPAS-Dev/MPAS-Model.git
git clone https://github.com/MPAS-Dev/MPAS-Tools.git
cd MPAS-Model
make gfortran CORE=init_atmosphere USE_PIO2=true
make clean CORE=atmosphere
make gfortran CORE=atmosphere USE_PIO=2

########################################
# WPS(v3) geog static data
########################################
mkdir $LIBSRC/geog_source
cd $LIBSRC/geog_source
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/NUDAPT44_1km.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/albedo_ncep.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/bnu_soiltype_bot.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/bnu_soiltype_top.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/clayfrac_5m.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/crop.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/erod.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/greenfrac.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/greenfrac_fpar_modis.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/groundwater.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/hangl.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/hanis.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/hasynw.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/hasys.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/hasysw.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/hasyw.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/hcnvx.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/hlennw.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/hlens.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/hlensw.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/hlenw.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/hslop.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/hstdv.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/hzmax.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/islope.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/lai_modis_10m.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/lai_modis_30s.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/lake_depth.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/landuse_10m.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/landuse_5m.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/landuse_2m.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/landuse_30s.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/landuse_30s_with_lakes.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/maxsnowalb.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/modis_landuse_20class_30s.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/modis_landuse_20class_30s_with_lakes.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/modis_landuse_20class_15s.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/modis_landuse_21class_30s.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/nlcd2006_ll_30s.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/nlcd2006_ll_9s.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/nlcd2011_can_ll_9s.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/nlcd2011_imp_ll_9s.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/nlcd2011_ll_9s.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/orogwd_2deg.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/orogwd_1deg.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/orogwd_30m.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/orogwd_20m.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/orogwd_10m.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/sandfrac_5m.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/soiltemp_1deg.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/soiltype_bot_10m.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/soiltype_bot_5m.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/soiltype_bot_2m.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/soiltype_bot_30s.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/soiltype_top_10m.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/soiltype_top_5m.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/soiltype_top_2m.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/soiltype_top_30s.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/ssib_landuse_10m.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/ssib_landuse_5m.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/topo_10m.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/topo_5m.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/topo_2m.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/topo_30s.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/topo_gmted2010_30s.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/varsso_10m.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/varsso_5m.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/varsso_2m.tar.bz2
wget -P $LIBSRC/geog_source http://www2.mmm.ucar.edu/wrf/src/wps_files/varsso.tar.bz2

mkdir $LIB_PATH_FOR_MPAS/geog
for i in $(ls *.tar.bz2);do tar jxvf $i -C $LIB_PATH_FOR_MPAS/geog;done
cd $PATH_FOR_MPAS
########################################
# modified ~/.bashrc
########################################

cat >> ~/.bashrc << EOF
################################################
#          MODIFIED BY MPAS_INSTALL.sh         #
################################################
export PATH_FOR_MPAS=$LIB_PATH_FOR_MPAS
export LIBSRC=$LIB_PATH_FOR_MPAS/sources
export LIBBASE=$LIB_PATH_FOR_MPAS/mpas-libs
export PATH=\$PATH:${LIBBASE}/bin
export PNETCDF=${LIBBASE}
export NETCDF=${LIBBASE}
export PIO=$LIBBASE
export MPAS_EXTERNAL_LIBS="-L${LIBBASE}/lib -lhdf5_hl -lhdf5 -ldl -lz"
export MPAS_EXTERNAL_INCLUDES="-I${LIBBASE}/include"
################################################

EOF

################################## End ##################################
