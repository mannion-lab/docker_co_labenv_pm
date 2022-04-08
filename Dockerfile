# hash:sha256:cc82a6752b67224109d0e02ea6f67c8a6a610550852a697246b4fb72b63bb7b6
FROM registry.codeocean.com/codeocean/ubuntu:20.04.2

ARG DEBIAN_FRONTEND=noninteractive

# install system packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        software-properties-common \
        python3 \
        python3-dev \
        python3-pip \
        libopenblas-openmp-dev \
        libgl1-mesa-glx \
        xvfb \
        gsfonts \
        ghostscript \
        poppler-utils \
        qt5-image-formats-plugins \
        libtiff-dev \
        libsndfile1-dev \
        wget \
    && add-apt-repository -y ppa:jeremysanders/ppa \
    && apt-get update \
    && apt-get install -y --no-install-recommends veusz \
    && apt-get purge -y --autoremove software-properties-common \
    && dpkg --remove --force-depends python3-numpy \
    && rm -rf /var/lib/apt/lists/*

# install python packages
RUN pip install -U --no-cache-dir  \
    numpy==1.20.3 \
    scikit-image \
    scikit-learn \
    python-dateutil \
    imageio \
    jupyter \
    jupyterlab \
    matplotlib \
    seaborn \
    ipython \
    statsmodels \
    tabulate \
    user-agents \
    pymc3 \
    librosa \
    resampy \
    soundfile \
    black \
    pylint \
    openpyxl \
    distro \
    watermark \
    pycountry

# run python v3 via just `python`
RUN ln -s /usr/bin/python3 /usr/local/bin/python

# QT complains if this doesn't exist
ENV XDG_RUNTIME_DIR=/tmp/runtime-root/
RUN mkdir -m 0700 -p ${XDG_RUNTIME_DIR}

# set some theano config flags
RUN echo "[blas] \n\
ldflags=-L/usr/lib/x86_64-linux-gnu/openblas-openmp -lopenblas -lblas -llapack \n\
\n\
[global] \n\
config.compile.timeout = 5000" > ~/.theanorc

# set python to automatically discover packages in `/code`
RUN echo "import pathlib \n\
import sys\n\
\n\
base_code_dir = pathlib.Path('/code')\n\
\n\
if base_code_dir.exists():\n\
\n\
    code_dirs = [\n\
        str(path.absolute())\n\
        for path in base_code_dir.iterdir()\n\
        if path.is_dir()\n\
    ]\n\
\n\
    sys.path.extend(code_dirs)" > /usr/lib/python3.8/sitecustomize.py
