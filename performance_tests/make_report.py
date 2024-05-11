import os
import seaborn as sns
import matplotlib.pyplot as plt
import pandas as pd

# get the current directory
current_dir = os.path.dirname(os.path.realpath(__file__))
# get the performance tests directory
performance_tests_dir = os.path.join(current_dir, '')
# get the subfolders
subfolders = ['omp_schedule_dynamic', 'omp_schedule_static', 'trahrhe_collapsed']
# get the tests
tests = ['dim3_exec_time.txt', 'utma_exec_time.txt', 'utmm_exec_time.txt']
# get the test names
test_names = ['dim3', 'utma', 'utmm']
# get the data

data = []
for subfolder in subfolders:
    for test in tests:
        test_path = os.path.join(performance_tests_dir, subfolder, test)
        with open(test_path, 'r') as f:
            lines = f.readlines()
            for line in lines:
                data.append([subfolder, test, int(line.strip())])

# create a dataframe
df = pd.DataFrame(data, columns=['Strategy', 'test', 'Execution Time (microseconds)'])

# create the report
for test_name, test in zip(test_names, tests):
    plt.figure()
    sns.boxplot(x='Strategy', y='Execution Time (microseconds)', data=df[df['test'] == test], showfliers=False, showmeans=True, meanprops={"marker":"o","markerfacecolor":"white", "markeredgecolor":"black"}, palette='Set2', hue='Strategy')
    plt.title(test_name)
    plt.savefig(os.path.join(performance_tests_dir, test_name + '.png'))
    plt.close()

# save the report
df.to_csv(os.path.join(performance_tests_dir, 'report.csv'), index=False)
print('Report saved in performance_tests folder')

