from netCDF4 import Dataset

def create_stat_global_att(ncfile,info):
    import datetime as DT
    ncfile.creator_name = 'USACE Wave Information Studies Hindcast'
    ncfile.creator_url = 'http://wis.usace.army.mil'
    ncfile.project = 'Wave Information Studies'
    ncfile.standard_name_vocabulary = 'CF Standard Name Table (v23, 23 March 2013)'
    ncfile.Metadata_Conventions = 'Unidata Dataset Discovery v1.0'
    ncfile.license = 'These data may be redistributed and used without restriction.'
    ncfile.references = 'http://wis.usace.army.mil/WIS_Documentation'
    ncfile.Conventions = 'CF-1.6'
    ncfile.summary = 'The Wave Information Studies (WIS) is a US Army Corps of Engineers (USACE) ' + \
        'sponsored project that generates consistent, hourly, long-term (30+ years) wave climatologies '  + \
        'along all US coastlines, including the Great Lakes and US island territories. '
    ncfile.keywords = ' EARTH SCIENCE, OCEANS, OCEAN WAVES, GRAVITY WAVES, WIND WAVES, ' + \
        'SIGNIFICANT WAVE HEIGHT, WAVE FREQUENCY, WAVE PERIOD, WAVE SPECTRA, OCEAN, ' + \
        'PACIFIC OCEAN, NUMERICAL MODEL'
    ncfile.wis_basin = info['basin']
    ncfile.time_datum = 'UTC'
    ncfile.data_datum = 'None'
    ncfile.data_units = 'Metric'
    ncfile.data_type = 'Station file'
    ncfile.date_created = DT.datetime.ctime(DT.datetime.today())
    ncfile.created_on = 'Cray XE6 Garnet'
    ncfile.depth = round(info['depth'],2)
    ncfile.station = info['station']
    ncfile.geospatial_lat = round(info['latitude'],6)
    ncfile.geospatial_lat_units = 'degrees North'
    ncfile.geospatial_lon = round(info['longitude'],6)
    ncfile.geospatial_lon_units = 'degrees West'
    ncfile.time_coverage_start = info['timestart'].strftime('%Y-%m-%dT%H:%M:%SZ')
    ncfile.time_coverage_end =  info['timeend'].strftime('%Y-%m-%dT%H:%M:%SZ')
    ncfile.time_coverage_resolution = '1-hr'
    ncfile.time_coverage_units =  'hours'
    ncfile.source = 'numerical model results'
    ncfile.model = 'WaveWatch III version 4'

def create_stat_var_att(datakeys):
    longn = {'time':'Time','datetime':'Time in yyyy,mm,dd,hh,mm,ss','wavhs':'Wave Height Total','wavtp':'Peak Period Total','wavtpp':'Parabolic Fit Peak Period Total','wavtm':'Mean Period Total','wavtm1':'1st Moment Mean Period Total','wavtm2':'2nd Moment Mean Period Total','wavdir':'Mean Wave Direction Total','wavspr':'Wave Direction Spreading Total','frequency':'Frequency','direction':'Direction','ef2d':'Sea-Surface Energy Density Spectrum','wndspd':'10-m Wind Speed','wnddir':'Wind Direction','ustar':'Friction Velocity','cd':'Coefficient of Drag','ef2d_swell':'Sea-Surface Energy Density Spectrum for Swell','ef2d_wndsea':'Sea-Surface Energy Density Spectrum for WindSea','wavhs_wndsea':'Wave Height WindSea','wavtp_wndsea':'Peak Period WindSea','wavtpp_wndsea':'Parabolic Fit Peak Period WindSea','wavtm_wndsea':'Mean Period WindSea','wavtm1_wndsea':'1st Moment Mean Period WindSea','wavtm2_wndsea':'2nd Moment Mean Period WindSea','wavdir_wndsea':'Mean Wave Direction WindSea','wavspr_wndsea':'Wave Direction Spreading WindSea','wavhs_swell':'Wave Height Swell','wavtp_swell':'Peak Period Swell','wavtpp_swell':'Parabolic Fit Peak Period Swell','wavtm_swell':'Mean Period Swell','wavtm1_swell':'1st Moment Mean Period Swell','wavtm2_swell':'2nd Moment Mean Period Swell','wavdir_swell':'Mean Wave Direction Swell','wavspr_swell':'Wave Direction Spreading Swell'}

    units = {'time':'Seconds since 1970-01-01 00:00:00','datetime':'year,month,day,hour,minute,second','wavhs':'meter','wavtp':'second','wavtpp':'second','wavtm':'second','wavtm1':'second','wavtm2':'second','wavdir':'degree toward','wavspr':'degree toward','frequency':'1/second','direction':'degree','ef2d':'meter^2/second','wndspd':'meter/second','wnddir':'degree from','ustar':'meter/second','cd':'*1000','ef2d_swell':'meter^2/second','ef2d_wndsea':'meter^2/second','wavhs_wndsea':'meter','wavtp_wndsea':'second','wavtpp_wndsea':'second','wavtm_wndsea':'second','wavtm1_wndsea':'second','wavtm2_wndsea':'second','wavdir_wndsea':'degree toward','wavspr_wndsea':'degree toward','wavhs_swell':'meter','wavtp_swell':'second','wavtpp_swell':'second','wavtm_swell':'second','wavtm1_swell':'second','wavtm2_swell':'second','wavdir_swell':'degree toward','wavspr_swell':'degree toward'}

#    for key in datakeys:
#        dataset = ncfile[key]
#        dataset.long_name = longn[key]
#        dataset.units = units[key]
    return longn[datakeys], units[datakeys]

def create_field_var_att(key):
    longn = {'time':'Time','datetime':'Time in yyyy,mm,dd,hh,mm,ss','wavhs':'Wave Height Total','wavtp':'Peak Period Total','wavdir':'Mean Wave Direction Total','wavspr':'Wave Direction Spreading Total','wnd_u':'10-m Wind Speed U','wnd_v':'10-m Wind Speed V','wavhs_wndsea':'Wave Height WindSea','wavtp_wndsea':'Peak Period WindSea','wavdir_wndsea':'Mean Wave Direction WindSea','wavhs_swell1':'Wave Height Swell1','wavtp_swell1':'Peak Period Swell1','wavdir_swell1':'Mean Wave Direction Swell1','wavhs_swell2':'Wave Height Swell2','wavtp_swell2':'Peak Period Swell2','wavdir_swell2':'Mean Wave Direction Swell2'}

    units = {'time':'Seconds since 1970-01-01 00:00:00','datetime':'year,month,day,hour,minute,second','wavhs':'meter','wavtp':'second','wavdir':'degree toward','wavspr':'degree toward','wnd_u':'meter/second','wnd_v':'meter/second','wavhs_wndsea':'meter','wavtp_wndsea':'second','wavdir_wndsea':'degree toward','wavhs_swell1':'meter','wavtp_swell1':'second','wavdir_swell1':'degree toward','wavhs_swell2':'meter','wavtp_swell2':'second','wavdir_swell2':'degree toward'}

#    for key in datakeys:
#        dataset = h5file[key]
#        dataset.attrs['Long Name'] = longn[key]
#        dataset.attrs['Units'] = units[key]
    return longn[key], units[key]

def create_field_global_att(ncfile,info):
    import datetime as DT
    ncfile.creator_name = 'USACE Wave Information Studies Hindcast'
    ncfile.creator_url = 'http://wis.usace.army.mil'
    ncfile.project = 'Wave Information Studies'
    ncfile.standard_name_vocabulary = 'CF Standard Name Table (v23, 23 March 2013)'
    ncfile.Metadata_Conventions = 'Unidata Dataset Discovery v1.0'
    ncfile.license = 'These data may be redistributed and used without restriction.'
    ncfile.references = 'http://wis.usace.army.mil/WIS_Documentation'
    ncfile.Conventions = 'CF-1.6'
    ncfile.summary = 'The Wave Information Studies (WIS) is a US Army Corps of Engineers (USACE) ' + \
        'sponsored project that generates consistent, hourly, long-term (30+ years) wave climatologies '  + \
        'along all US coastlines, including the Great Lakes and US island territories. '
    ncfile.keywords = ' EARTH SCIENCE, OCEANS, OCEAN WAVES, GRAVITY WAVES, WIND WAVES, ' + \
        'SIGNIFICANT WAVE HEIGHT, WAVE FREQUENCY, WAVE PERIOD, WAVE SPECTRA, OCEAN, ' + \
        'PACIFIC OCEAN, NUMERICAL MODEL'
    ncfile.wis_basin = info['basin']
    ncfile.wis_domain = info['domain']
    ncfile.time_datum = 'UTC'
    ncfile.data_datum = 'None'
    ncfile.data_units = 'Metric'
    ncfile.data_type = 'Field files'
    ncfile.date_created = DT.datetime.ctime(DT.datetime.today())
    ncfile.created_on = 'Cray XE6 Garnet'
    ncfile.geospatial_lat = info['latitude']
    ncfile.geospatial_lat_units = 'degrees North and South'
    ncfile.geospatial_lat_res = round(info['latres'],6)
    ncfile.geospatial_lat_num = info['nlat']
    ncfile.geospatial_lon = info['longitude']
    ncfile.geospatial_lon_units = 'degrees 0 to 360 '
    ncfile.geospatial_lon_res = round(info['lonres'],6)
    ncfile.geospatial_lon_num = info['nlon']
    ncfile.time_coverage_start = info['timestart'].strftime('%Y-%m-%dT%H:%M:%SZ')
    ncfile.time_coverage_end =  info['timeend'].strftime('%Y-%m-%dT%H:%M:%SZ')
    ncfile.time_coverage_resolution = '1-hr'
    ncfile.time_coverage_units =  'hours'
    ncfile.source = 'numerical model results'
    ncfile.model = 'WaveWatch III version 4'



def write_stat_nc(results):
    ncfile = Dataset('ST' + results['info']['station'] + '_' + results['info']['year'] + '_' + results['info']['month'] + '.nc','w')
    create_stat_global_att(ncfile,results['info'])
    ncfile.createDimension('time',results['data']['time'].shape[0])
    ncfile.createDimension('freq',results['data']['frequency'].shape[0])
    ncfile.createDimension('direc',results['data']['direction'].shape[0])
    ncfile.createDimension('date',6)
    for key,value in results['data'].items():
        varshape = results['info']['outshape'][key]
        if isinstance(varshape,dict):
            if len(varshape) == 2:
                dataset = ncfile.createVariable(key,results['info']['outtype'][key],(varshape[0],varshape[1]),fill_value=-999.9)
            elif len(varshape) == 3:
                dataset = ncfile.createVariable(key,results['info']['outtype'][key],(varshape[0],varshape[1],varshape[2]),fill_value=-999.9)
        else:
            dataset = ncfile.createVariable(key,'f4',(results['info']['outshape'][key],),fill_value=-999.9)
        dataset[:] = value
        dataset.Dimension = value.shape
        longn, units = create_stat_var_att(key)
        dataset.long_name = longn
        dataset.units = units


    
    ncfile.close()

