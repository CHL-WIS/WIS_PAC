import h5py

def create_stat_global_att(h5file,info):
    import datetime as DT
    h5file.attrs['Data Type'] = 'USACE Wave Information Studies Hindcast'
    h5file.attrs['WIS Basin'] = info['basin']
    h5file.attrs['Time Datum'] = 'UTC'
    h5file.attrs['Data Datum'] = 'None'
    h5file.attrs['Data Units'] = 'Metric'
    h5file.attrs['Longitude'] = info['longitude']
    h5file.attrs['Latitude'] = info['latitude']
    h5file.attrs['File Created On'] = DT.datetime.ctime(DT.datetime.today())
    h5file.attrs['Computer'] = 'Cray XE6 Garnet'
    h5file.attrs['File Created By'] = info['uname']
    h5file.attrs['Depth'] = info['depth']
    h5file.attrs['Station'] = info['station']

def create_stat_var_att(h5file,datakeys):
    longn = {'time':'Time in Days since 0001-01-01 00:00:00','datetime':'Time in yyyy,mm,dd,hh,mm,ss','wavhs':'Wave Height Total','wavtp':'Peak Period Total','wavtpp':'Parabolic Fit Peak Period Total','wavtm':'Mean Period Total','wavtm1':'1st Moment Mean Period Total','wavtm2':'2nd Moment Mean Period Total','wavdir':'Mean Wave Direction Total','wavspr':'Wave Direction Spreading Total','frequency':'Frequency','direction':'Direction','ef2d':'Sea-Surface Energy Density Spectrum','wndspd':'10-m Wind Speed','wnddir':'Wind Direction','ustar':'Friction Velocity','cd':'Coefficient of Drag','ef2d_swell':'Sea-Surface Energy Density Spectrum for Swell','ef2d_wndsea':'Sea-Surface Energy Density Spectrum for WindSea','wavhs_wndsea':'Wave Height WindSea','wavtp_wndsea':'Peak Period WindSea','wavtpp_wndsea':'Parabolic Fit Peak Period WindSea','wavtm_wndsea':'Mean Period WindSea','wavtm1_wndsea':'1st Moment Mean Period WindSea','wavtm2_wndsea':'2nd Moment Mean Period WindSea','wavdir_wndsea':'Mean Wave Direction WindSea','wavspr_wndsea':'Wave Direction Spreading WindSea','wavhs_swell':'Wave Height Swell','wavtp_swell':'Peak Period Swell','wavtpp_swell':'Parabolic Fit Peak Period Swell','wavtm_swell':'Mean Period Swell','wavtm1_swell':'1st Moment Mean Period Swell','wavtm2_swell':'2nd Moment Mean Period Swell','wavdir_swell':'Mean Wave Direction Swell','wavspr_swell':'Wave Direction Spreading Swell'}

    units = {'time':'day','datetime':'year,month,day,hour,minute,second','wavhs':'meter','wavtp':'second','wavtpp':'second','wavtm':'second','wavtm1':'second','wavtm2':'second','wavdir':'degree toward','wavspr':'degree toward','frequency':'1/second','direction':'degree','ef2d':'meter^2/second','wndspd':'meter/second','wnddir':'degree from','ustar':'meter/second','cd':'*1000','ef2d_swell':'meter^2/second','ef2d_wndsea':'meter^2/second','wavhs_wndsea':'meter','wavtp_wndsea':'second','wavtpp_wndsea':'second','wavtm_wndsea':'second','wavtm1_wndsea':'second','wavtm2_wndsea':'second','wavdir_wndsea':'degree toward','wavspr_wndsea':'degree toward','wavhs_swell':'meter','wavtp_swell':'second','wavtpp_swell':'second','wavtm_swell':'second','wavtm1_swell':'second','wavtm2_swell':'second','wavdir_swell':'degree toward','wavspr_swell':'degree toward'}

    for key in datakeys:
        dataset = h5file[key]
        dataset.attrs['Long Name'] = longn[key]
        dataset.attrs['Units'] = units[key]

def create_field_var_att(h5file,datakeys):
    longn = {'time':'Time in Days since 0001-01-01 00:00:00','datetime':'Time in yyyy,mm,dd,hh,mm,ss','wavhs':'Wave Height Total','wavtp':'Peak Period Total','wavdir':'Mean Wave Direction Total','wavspr':'Wave Direction Spreading Total','wnd_u':'10-m Wind Speed U','wnd_v':'10-m Wind Speed V','wavhs_wndsea':'Wave Height WindSea','wavtp_wndsea':'Peak Period WindSea','wavdir_wndsea':'Mean Wave Direction WindSea','wavhs_swell1':'Wave Height Swell1','wavtp_swell1':'Peak Period Swell1','wavdir_swell1':'Mean Wave Direction Swell1','wavhs_swell2':'Wave Height Swell2','wavtp_swell2':'Peak Period Swell2','wavdir_swell2':'Mean Wave Direction Swell2'}

    units = {'time':'day','datetime':'year,month,day,hour,minute,second','wavhs':'meter','wavtp':'second','wavdir':'degree toward','wavspr':'degree toward','wnd_u':'meter/second','wnd_v':'meter/second','wavhs_wndsea':'meter','wavtp_wndsea':'second','wavdir_wndsea':'degree toward','wavhs_swell1':'meter','wavtp_swell1':'second','wavdir_swell1':'degree toward','wavhs_swell2':'meter','wavtp_swell2':'second','wavdir_swell2':'degree toward'}

    for key in datakeys:
        dataset = h5file[key]
        dataset.attrs['Long Name'] = longn[key]
        dataset.attrs['Units'] = units[key]

def create_field_global_att(h5file,info):
    import datetime as DT
    h5file.attrs['Data Type'] = 'USACE Wave Information Studies Hindcast'
    h5file.attrs['WIS Basin'] = info['basin']
    h5file.attrs['Time Datum'] = 'UTC'
    h5file.attrs['Data Datum'] = 'None'
    h5file.attrs['Data Units'] = 'Metric'
    h5file.attrs['Longitude'] = info['longitude']
    h5file.attrs['Latitude'] = info['latitude']
    h5file.attrs['File Created On'] = DT.datetime.ctime(DT.datetime.today())
    h5file.attrs['Computer'] = 'Cray XE6 Garnet'
    h5file.attrs['File Created By'] = info['uname']
    h5file.attrs['nlon'] = info['nlon']
    h5file.attrs['nlat'] = info['nlat']
    h5file.attrs['Domain'] = info['domain']



def write_stat_h5(results):
    h5file = h5py.File('ST' + results['info']['station'] + '.h5','w')
    create_stat_global_att(h5file,results['info'])
    for key,value in results['data'].items():
        dataset = h5file.create_dataset('/' + key,value.shape,dtype=results['info']['outtype'][key])
        dataset[...] = value
        dataset.attrs['Dimension'] = value.shape
    create_stat_var_att(h5file,results['data'].keys())

    
    h5file.close()

