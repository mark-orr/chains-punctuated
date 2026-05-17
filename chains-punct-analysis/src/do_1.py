import pandas as pd
import matplotlib.pyplot as plt
import numpy as np


''' CUSTOM PACKAGES'''
from pathlib import Path
import os
import sys

try:
    here = Path(__file__).resolve().parent
except NameError:
    here = Path.cwd()   # fallback for notebooks/REPL; this is GENERIC-PY-PROJ

package_path = os.path.join(here, 'package_1')
sys.path.insert(0,str(package_path))

#THE SYS PATH WILL BE ../src/package_1
import module_1 as m1

'''CODE'''

# ---------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------

DATA_PATH = Path("../../data-original/_replication_materials/data/input/cooperation_quant.dta")
OUT_DIR = Path("../../out-data")
OUT_DIR.mkdir(parents=True, exist_ok=True)

# ---------------------------------------------------------------------
# Load data
# ---------------------------------------------------------------------

df = pd.read_stata(DATA_PATH)

# ---------------------------------------------------------------------
# Stata locals
# ---------------------------------------------------------------------

'''HACK WARNING'''
#outcomes = ["contrate", "effortrate"]
outcomes = ["contrate"]
groups = pd.Series(np.unique(np.array(df.groupid)))
#groups = [895, 3, 6, 449, 17, 18, 835, 879]

# ---------------------------------------------------------------------
# Helper: reproduce Stata summarize mean
# ---------------------------------------------------------------------
# Stata's sum var if ... stores r(mean), ignoring missing values.
# pandas mean() also ignores missing values by default.
# If there are no observations, pandas returns NaN, matching the spirit
# of Stata's missing result.

def stata_mean(series):
    return series.mean(skipna=True)

# ---------------------------------------------------------------------
# Part 1: means by loancycle and repayq6
# ---------------------------------------------------------------------

for outcome in outcomes:
    rows = []

    for cycle in range(1, 6):       # Stata: forvalues k=1/5
        for round_ in range(1, 7):  # Stata: forvalues i=1/6
            mask = (
                (df["repayq6"] == round_) &
                (df["loancycle"] == cycle)
            )

            mean = stata_mean(df.loc[mask, outcome])

            rows.append({
                "cycle": cycle,
                "round": round_,
                "mean": mean
            })

    out = pd.DataFrame(rows)

    out_path = OUT_DIR / f"figure_1_source_data_mean_{outcome}.dta"
    out.to_stata(out_path, write_index=False)

    # Optional CSV for easy inspection
    out.to_csv(OUT_DIR / f"figure_1_source_data_mean_{outcome}.csv", index=False)

# ---------------------------------------------------------------------
# Part 2: selected individual groups
# ---------------------------------------------------------------------

for outcome in outcomes:
    rows = []

    grouplabel = 1

    for groupid in groups:
        for cycle in range(1, 6):
            for round_ in range(1, 7):
                mask = (
                    (df["repayq6"] == round_) &
                    (df["loancycle"] == cycle) &
                    (df["groupid"] == groupid)
                )

                mean = stata_mean(df.loc[mask, outcome])

                rows.append({
                    "groupid": groupid,
                    "grouplabel": grouplabel,
                    "cycle": cycle,
                    "round": round_,
                    "outcome": mean
                })

        grouplabel += 1

    out = pd.DataFrame(rows)

    out_path = OUT_DIR / f"figure_1_source_data_individual_{outcome}.dta"
    out.to_stata(out_path, write_index=False)

    # Optional CSV for easy inspection
    out.to_csv(OUT_DIR / f"figure_1_source_data_individual_{outcome}.csv", index=False)

'''EXPLORE'''
df.contrate[0:100].plot()
x = pd.crosstab(df.groupid,df.groupsize)
#DYAD GROUP IDS
x[x[x.columns[0]]>0]

x[x[x.columns[2]]>0]

'''HACK WARNING'''
#ALL GROUPS MEAN RATES
means_per_group_effort_rate = out.groupby('groupid')['outcome'].mean()
means_per_group_effort_rate.plot()

means_per_group_contrib_rate = out.groupby('groupid')['outcome'].mean()
means_per_group_contrib_rate.plot()


'''A FEW NOTES ON THE DATA:
group size can change over load periods per group
a handful of groups were dyads

'''

#EOF
