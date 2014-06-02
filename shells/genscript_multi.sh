#!/bin/bash
#
#
STORM_NAME=$1
WORKDIR=$2
#
cd $WORKDIR
sdat1=`awk '{printf "%s", $1} ' ${STORM_NAME}.datesin `
sdat2=`awk '{printf "%s", $2} ' ${STORM_NAME}.datesin `
edat1=`awk '{printf "%s", $3} ' ${STORM_NAME}.datesin `
edat2=`awk '{printf "%s", $4} ' ${STORM_NAME}.datesin `

str=`echo $sdat1 | cut -c1-6 `
stc=`echo $sdat1 | cut -c7-8 `
st1=`echo $sdat2 | cut -c1-2 `
ste=`echo $sdat2 | cut -c3-6 `
st2=`echo $((st1+1)) `
st3=`echo $((stc+1)) `
if [ $st2 -lt "10" ]
  then
  stc="0"$st2
else
  stc=$st2
fi
if [ $st3 -lt "10" ]
  then
  sto="0"$st3
else
  sto=$st3
fi
startf=$stc$ste
start1=$str$sto

#
cat > ww3_multi.inp << EOF
 -------------------------------------------------------------------- $
$ WAVEWATCH III multi-grid model driver input file                     $
$ -------------------------------------------------------------------- $
$
$ *******************************************************************
$ *** NOTE : This is an example file from the mww3_test_05 script ***
$ ***        Unlilke other input example files this one CANNOT    ***
$ ***        be run as an independent interactive run             ***
$ *******************************************************************
$
$ The first input line sets up the general multi-grid model definition
$ by defining the follwing six parameters :
$
$   1) Number of wave model grids.i                         ( NRGRD )
$   2) Number of grids definint input fields.               ( NRINP )
$   3) Flag for using unified point output file.           ( UNIPTS )
$   4) Output server type as in ww3_shel.inp
$   5) Flag for dedicated process for iunified point output.
$   6) Flag for grids sharing dedicated output processes.
$
  4 2 F 1 F F
$
 'inp_basin' F F T F F F F
 'inp_westc' F F T F F F F
$
$ -------------------------------------------------------------------- $
$ Now each actual wave model grid is defined using 13 parameters to be
$ read fom a single line in the file. Each line contains the following
$ parameters
$     1)   Define the grid with the extension of the mod_def file.
$    2-8)  Define the inputs used by the grids with 8 keywords
$          corresponding to the 8 flags defining the input in the
$          input files. Valid keywords are:
$            'no'      : This input is not used.
$            'native'  : This grid has its own input files, e.g. grid
$                        grdX (mod_def.grdX) uses ice.grdX.
$            'MODID'   : Take input from the grid identified by
$                        MODID. In the example below, all grids get
$                        their wind from wind.input (mod_def.input).
$     9)   Rank number of grid (internally sorted and reassigned).
$    10)   Group number (internally reassigned so that different
$          ranks result in different group numbers.
$   11-12) Define fraction of cumminicator (processes) used for this
$          grid.
$    13)   Flag identifying dumping of boundary data used by this
$          grid. If true, the file nest.MODID is generated.
$
  'basin_l1'  'no' 'no' 'inp_basin' 'no' 'no' 'no' 'no'   1  1  0.00 1.00  F
  'westc_l2'  'no' 'no' 'inp_westc' 'no' 'no' 'no' 'no'   2  1  0.00 1.00  F
  'westc_l3'  'no' 'no' 'inp_westc' 'no' 'no' 'no' 'no'   3  1  0.00 1.00  F
  'cali_l4'  'no' 'no' 'native' 'no' 'no' 'no' 'no'   4  2  0.00 1.00  F  
$  'grd5'  'no' 'no' 'input' 'no' 'no' 'no' 'no'   5  3  0.00 1.00  F
$  'grd6'  'no' 'no' 'input' 'no' 'no' 'no' 'no'   6  4  0.00 1.00  F
$ 'grd3'  'no' 'no' 'input' 'no' 'no' 'no' 'no'   3  1  0.50 1.00  F
$
$ In this example three grids are used requiring the files
$ mod_def.grdN. All files get ther winds from the grid 'input'
$ defined by mod_def.input, and no other inputs are used. In the lines
$ that are commented out, each grid runs on a part of the pool of
$ processes assigned to the computation.
$
$ -------------------------------------------------------------------- $
$ Starting and ending times for the entire model run
$
   $sdat1 $sdat2   $edat1 $edat2
$
$ -------------------------------------------------------------------- $
$ Specific multi-scale model settings (single line).
$    Flag for masking computation in two-way nesting (except at
$                                                     output times).
$    Flag for masking at printout time.
$
  T F
$
$ Define output data ------------------------------------------------- $
$
$ Five output types are available (see below). All output types share
$ a similar format for the first input line:
$ - first time in yyyymmdd hhmmss format, output interval (s), and
$   last time in yyyymmdd hhmmss format (all integers).
$ Output is disabled by setting the output interval to 0.
$
$ Type 1 : Fields of mean wave parameters
$          Standard line and line with flags to activate output fields
$          as defined in section 2.4 of the manual. The second line is
$          not supplied if no output is requested.
$                               The raw data file is out_grd.ww3,
$                               see w3iogo.ftn for additional doc.
$
$
    $sdat1 $startf 3600  $edat1 $edat2
$
$ (1) Forcing Fields
  T
$ DPT CUR WND DT  WLV ICE IBG D50
  T   T   T   T   T   F   F   F
$ (2) Standard mean wave Parameters
  T
$ HS  LM  TZ  TE  TM  FP  DIR SPR DP
  T   T   T   T   T   T   T   T   T
$ (3) Frequency-dependent parameters
  T
$ EF TH1M STH1M TH1M STH1M WN
  T  T  T  F  F  F
$ (4) Spectral Partition Parameters
  T
$ PHS PTP PLP PTH PSP PWS WSF PNR
  T   T   T   T   T   T   T   T
$ (5) Atmosphere-waves layer
  F
$ UST CHN CGE FAW TAW NWS WCC WCF WCH WCM
$  T   T   T   T   T   T   T   T   T   T
$ (6) Wave-Ocean layer
  F
$ SXY TWO BHD FOC TUS USS P2S U3D P2L
$  T   T   T   T   T   T   T   F   F   F
$ (7) Wave-bottom layer
  F
$ ABR UBR BED FBB TBB
$  T   T   T   T   T
$ (8) Spectrum parameters
  F
$ MSS MSC
$  T   T
$ (9) Numerical diagnostics
  F
$ DTD FC  CFX CFD CFK
$  T   T   T   T   T
$ (10) User defined (NOEXTR flags needed)
  F
$ US1  US2
$ T    T
$
$
    $sdat1 $startf 0  $edat1 $edat2
$
$
    $sdat1 $startf 0  $edat1 $edat2
$
$
$ Type 4 : Restart files (no additional data required).
$                               The data file is restartN.ww3, see
$                               w3iors.ftn for additional doc.
$
    $edat1 $edat2 1  $edat1 $edat2
$
$ Type 5 : Boundary data (no additional data required).
$                               The data file is nestN.ww3, see
$                               w3iobp.ftn for additional doc.
$
   $sdat1 $startf     0  $edat1 $edat2
$
   $sdat1 $startf     0  $edat1 $edat2
$
$ -------------------------------------------------------------------- $
$ Output requests per grid and type to overwrite general setup
$ as defined above. First record per set is the grid name MODID
$ and the output type number. Then follows the standard time string,
$ and conventional data as per output type. In mww3_test_05 this is
$ not used. Below, one example generating partitioning output for
$ the inner grid is included but commented out.
$
 'basin_l1'  2
  $sdat1 $startf  3600  $edat1 $edat2
  -148.00  56.00  46001
  -130.00  42.50  46002
  -131.00  46.00  46005
  -137.50  41.00  46006
  -177.70  56.90  46035
  -133.94  48.35  46036
  -130.00  38.00  46059
  -146.80  60.20  46061
  -155.00  52.60  46066
  -185.00  55.00  46070
  -181.00  51.00  46071
  -172.20  51.60  46072
  -172.00  55.00  46073
  -161.00  54.00  46075
  -148.00  59.00  46076
  -154.00  58.00  46077
  -152.00  56.00  46078
  -150.00  58.00  46080
  -143.40  59.70  46082
  -138.00  58.20  46083
  -136.20  56.50  46084
  -143.00  56.00  46085
  -131.22  51.83  46147
  -138.85  53.91  46184
  -129.79  52.42  46185
  -128.75  51.37  46204
  -134.28  54.16  46205
  -129.92  50.87  46207
  -132.69  52.52  46208
  -145.09  49.99  46246
  -154.06  23.55  51000
  -162.00  23.50  51001
  -157.80  17.20  51002
  -160.60  19.00  51003
  -152.50  17.40  51004
  -153.90   0.00  51028
  -162.00  24.50  51101
   145.00  13.35  52200
  -144.70  13.70  52009
  -120.60  23.70  46290
  -155.90  51.83  46003
    0.E3  0.E3 'STOPSTRING'
$
 'westc_l2'  2
  $sdat1 $startf   3600  $edat1 $edat2
  -120.90  34.90  46011
  -122.70  37.40  46012
  -123.30  38.20  46013
  -124.00  39.20  46014
  -124.80  42.70  46015
  -124.50  40.80  46022
  -121.00  34.70  46023
  -119.10  33.80  46025
  -122.83  37.76  46026
  -124.38  41.85  46027
  -121.90  35.70  46028
  -124.20  46.20  46029
  -124.80  47.40  46041
  -122.47  36.79  46042
  -119.50  32.40  46047
  -124.50  44.60  46050
  -119.84  34.25  46053
  -120.46  34.27  46054
  -120.70  34.30  46063
  -120.20  33.67  46069
  -118.00  32.00  46086
  -125.00  48.00  46087
  -126.00  46.00  46089
  -124.30  44.63  46094
  -122.34  36.71  46114
  -127.93  49.74  46132
  -126.00  48.84  46206
  -124.74  40.29  46213
  -123.47  37.95  46214
  -119.80  34.33  46216
  -119.44  34.17  46217
  -120.77  34.45  46218
  -119.88  33.22  46219
  -118.63  33.85  46221
  -118.32  33.62  46222
  -117.39  32.93  46225
  -124.55  43.77  46229
  -117.37  32.75  46231
  -117.43  32.53  46232
  -121.95  36.76  46236
  -122.60  37.78  46237
  -119.50  33.50  46238
  -124.36  40.89  46244
  -122.83  37.75  46247
  -124.67  46.13  46248
  -119.71  33.82  46249
  -119.20  33.00  46024
  -117.90  32.90  46048
  -117.44  32.63  46227
  -120.70  34.48  46051
  -121.01  35.10  46062
  -124.40  41.90  46038
  -124.30  44.80  46040
  -122.10  36.34  46239
  -117.47  33.18  46224
    0.E3  0.E3  'STOPSTRING'
$
 'westc_l3'  2
  $sdat1 $startf   3600  $edat1 $edat2
  -120.90  34.90  46011
  -122.70  37.40  46012
  -123.30  38.20  46013
  -124.00  39.20  46014
  -124.80  42.70  46015
  -124.50  40.80  46022
  -121.00  34.70  46023
  -119.10  33.80  46025
  -122.83  37.76  46026
  -124.38  41.85  46027
  -121.90  35.70  46028
  -124.20  46.20  46029
  -124.80  47.40  46041
  -122.47  36.79  46042
  -119.50  32.40  46047
  -124.50  44.60  46050
  -119.84  34.25  46053
  -120.46  34.27  46054
  -120.70  34.30  46063
  -120.20  33.67  46069
  -118.00  32.00  46086
  -125.00  48.00  46087
  -126.00  46.00  46089
  -124.30  44.63  46094
  -122.34  36.71  46114
  -127.93  49.74  46132
  -126.00  48.84  46206
  -124.74  40.29  46213
  -123.47  37.95  46214
  -119.80  34.33  46216
  -119.44  34.17  46217
  -120.77  34.45  46218
  -119.88  33.22  46219
  -118.63  33.85  46221
  -118.32  33.62  46222
  -117.39  32.93  46225
  -124.55  43.77  46229
  -117.37  32.75  46231
  -117.43  32.53  46232
  -121.95  36.76  46236
  -122.60  37.78  46237
  -119.50  33.50  46238
  -124.36  40.89  46244
  -122.83  37.75  46247
  -124.67  46.13  46248
  -119.71  33.82  46249
  -119.20  33.00  46024
  -117.90  32.90  46048
  -117.44  32.63  46227
  -120.70  34.48  46051
  -121.01  35.10  46062
  -124.40  41.90  46038
  -124.30  44.80  46040
  -122.10  36.34  46239
  -117.47  33.18  46224
    0.E3  0.E3  'STOPSTRING'
$
 'cali_l4'  2
  $sdat1 $startf   3600  $edat1 $edat2
  -119.10  33.80  46025
  -119.50  32.40  46047
  -119.84  34.25  46053
  -120.46  34.27  46054
  -120.70  34.30  46063
  -120.20  33.67  46069
  -119.80  34.33  46216
  -119.44  34.17  46217
  -120.77  34.45  46218
  -119.88  33.22  46219
  -118.63  33.85  46221
  -118.32  33.62  46222
  -117.39  32.93  46225
  -117.37  32.75  46231
  -117.43  32.53  46232
  -119.50  33.50  46238
  -119.71  33.82  46249
  -119.20  33.00  46024
  -117.90  32.90  46048
  -117.44  32.63  46227
  -120.70  34.48  46051
  -117.47  33.18  46224
    0.E3  0.E3  'STOPSTRING'
$
$ -------------------------------------------------------------------- $
$ Mandatory end of outpout requests per grid, identified by output
$ type set to 0.
$
  'the_end'  0
$
$ -------------------------------------------------------------------- $
$ Moving grid data as in ww3_hel.inp. All grids will use same data.
$
   'STP'
$
$ -------------------------------------------------------------------- $
$ End of input file                                                    $
$ -------------------------------------------------------------------- $
EOF
