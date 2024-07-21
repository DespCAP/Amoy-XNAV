from astropy.io import fits
import numpy as np
import matplotlib.pyplot as plt


P = 1.557708e-3 # period in seconds
num_bins = 10 # number of phase bins
binsize = P / num_bins

overbin_factor = binsize / 10

num_mpus = 1

def binner(bins, qty1, qty2):
    accumulate = np.zeros(np.size(bins) - 1)
    for i in range(np.size(qty1)):
        for j in range(np.size(bins)-1):
            if(bins[j] < qty1[i] and bins[j+1] > qty1[i]):
                accumulate[j] += qty2[i]
    return(accumulate)


def pieces_calculator(interval):
    return(int(np.ceil(interval / overbin_factor)))
    
def exptime_per_phase(gti_start_time, gti_stop_time, interval, slicing=True):
    if(slicing == True):
        #t = np.linspace(gti_start_time, gti_stop_time, pieces_calculator(interval))
        t = np.arange(gti_start_time, gti_stop_time, overbin_factor)
        t_subtracted = t - cl_data[1].header['TSTART']
        t_subtracted[0] = 0
        mod_t_subtracted = (t_subtracted % P) / P
        result = overbin_factor * np.histogram(mod_t_subtracted, bins=phase)[0]
    else:
        hist, bins = np.histogram(((gti_start_time - cl_data[1].header['TSTART']) % P) / P, bins=phase)
        result = bins[np.argmax(hist)]
    return(result)

path_code = "/home/amoy/xnav/codes/"
path_cl = "/home/amoy/xnav/nicer-data/B1937+21/0070020111/xti/event_cl/"    
path_uf = "/home/amoy/xnav/nicer-data/B1937+21/0070020111/xti/event_uf/"
profile_filename = '-'

gti_exp_result_summed = np.zeros((num_bins-1, num_mpus))
deadtime_result_summed = np.zeros((num_bins-1, num_mpus))
count_per_mpu = np.zeros((num_bins - 1, num_mpus))
exp_time = 2.656133243486285e+03
exp_time_per_bin = exp_time / num_bins
profiles = np.zeros((num_bins-1, num_mpus))

for i in range(num_mpus):
    print('--------------------------------------------')
    print('Working on Profile Number ' + str(i) + '...')
    profile_fits = fits.open(path_cl + profile_filename + '.fef')
    rate_table = profile_fits[1].data
    phase = rate_table['PHASE']
    rate = rate_table['RATE1']
    counts = exp_time_per_bin * rate
    count_per_mpu[:, i] = counts[:-1]
    phase_err = rate_table['XAX_E']
    rate_err = rate_table['ERROR1']   
    print('Entering MPU number ' + str(i) + '...')
    cl_data = fits.open(path_cl + 'ni0070020111_0mpu7_cl.evt')
    #   event_table = cl_data[1].data
    #   events = event_table['TIME']
    print(cl_data[2].data)
    gti_start_times = cl_data[2].data['start']
    gti_stop_times = cl_data[2].data['stop']
    gt_intervals = gti_stop_times - gti_start_times
    for k in range(np.size(gt_intervals)):
        if(gt_intervals[k] > binsize):
            gti_exp_result_summed[:,i] += exptime_per_phase(gti_start_times[k], gti_stop_times[k], gt_intervals[k])
        else:
            bin_idx = exptime_per_phase(gti_start_times[k], gti_stop_times[k], gt_intervals[k], slicing=False)
            gti_exp_result_summed[bin_idx, i] += gt_intervals[k]

    gti_exposure = np.average(gti_exp_result_summed, axis=1)
    
    event_table = fits.open(path_cl +'0070020111_bary.evt')
    events = event_table[1].data['TIME']
    deadtime = event_table[1].data['DEADTIME']
    events_folded = ((events - event_table[1].header['TSTART']) % P) / P
    deadtime_result_summed[:, i] = binner(phase, events_folded, deadtime)
    print('MPU number ' + str(i) + ' finished.')

    deadtime_result = np.average(deadtime_result_summed, axis = 1)

for j in range(num_mpus):
    profiles[:, j] = count_per_mpu[:, j] / (gti_exp_result_summed[:, j] - deadtime_result_summed[:, j])

fig = plt.figure()
for i in range(num_mpus):
    plt.step(phase[:-1], profiles[:, i])
    plt.step(phase[:-1], np.average(profiles, axis = 1))
