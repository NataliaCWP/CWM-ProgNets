# !/usr/bin/python3
import numpy as np
import matplotlib.pyplot as plt
# parameters to modify
filename1="iperf_2A_sorted.log"
filename2="iperf_2B_sorted.log"
label1='iperf direction A'
label2='iperf direction B'
xlabel = 'time'
ylabel = 'bandwidth (Mbit/s)'
title='Server=Pi Client=LabMachine'
fig_name='iperf_2.png'
bins=10 #adjust the number of bins to your plot


t1 = np.loadtxt(filename1, delimiter=" ", dtype="float")
t2 = np.loadtxt(filename2, delimiter=" ", dtype="float")

plt.plot(t1[:,0], t1[:,1], label=label1)  # Plot some data on the (implicit) axes.
plt.plot(t2[:,0], t2[:,1], label=label2)  # Plot some data on the (implicit) axes.
#Comment the line above and uncomment the line below to plot a CDF
#plt.hist(t[:,1], bins, density=True, histtype='step', cumulative=True, label=label)
plt.xlabel(xlabel)
plt.ylabel(ylabel)
plt.title(title)
plt.legend()
plt.savefig(fig_name)
plt.show()
