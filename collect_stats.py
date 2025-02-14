import os
import numpy as np


def get_times(log, time_type):
    lines = [line for line in log.split("\n") if "%s time: " % time_type in line]
    times = [float(line.split("time: ")[1]) for line in lines]
    return times

with open("gpt-fast-stats.csv", "w") as f:
    f.write("seqlen,time_inductor_default,time_inductor_reduce_overhead\n")

for default_filename, reduce_overhead_filename in zip(os.listdir("exp_outs/inductor-default"), os.listdir("exp_outs/inductor-reduce-overhead")):
    seqlen = default_filename.split(".")[0]

    # Parse times from logs
    with open("exp_outs/inductor-default/" + default_filename, "r") as f:
        default = f.read()
    with open("exp_outs/inductor-reduce-overhead/" + reduce_overhead_filename, "r") as f:
        reduce_overhead = f.read()

    default_times = get_times(default, "Prefill")
    reduce_overhead_times = get_times(reduce_overhead, "Prefill")

    # Remove the first n iterations, which might be slower
    n = 2
    default_times = default_times[n:]
    reduce_overhead_times = reduce_overhead_times[n:]

    # Calculate metrics
    default_times_median = np.median(default_times)
    reduce_overhead_times_median = np.median(reduce_overhead_times)

    print(seqlen, default_times_median, reduce_overhead_times_median)
    #print(default_times_median / reduce_overhead_times_median)

    with open("gpt-fast-stats.csv", "a") as f:
        f.write(f"{seqlen},{default_times_median},{reduce_overhead_times_median}\n")
