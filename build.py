import os
import sys
from dsp_base.build_helper import main_build

PROJECT_DIR = os.path.dirname(os.path.abspath(__file__))

if __name__ == "__main__":
    main_build(
        sys = sys,
        firebase_app_id_prod = "1:879252460066:android:704e691af5de6445c2b07b",
        firebase_app_id_dev = "1:879252460066:android:704e691af5de6445c2b07b",
    )
