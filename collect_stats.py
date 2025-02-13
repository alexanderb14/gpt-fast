import numpy as np


def get_times(log, time_type):
    lines = [line for line in log.split("\n") if "%s time: " % time_type in line]
    times = [float(line.split("time: ")[1]) for line in lines]
    return times


# Parse times from logs
with open("exp_outs/inductor-default/1.log", "r") as f:
    default = f.read()
with open("exp_outs/inductor-reduce-overhead/1.log", "r") as f:
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

# Report metrics
print("default median:", default_times_median)
print("reduce_overhead median:", reduce_overhead_times_median)
print("speedup:", default_times_median / reduce_overhead_times_median)
