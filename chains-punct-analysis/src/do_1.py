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


#EOF
