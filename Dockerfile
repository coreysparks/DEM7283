# Base image: Rocker r-ver (R 4.6.1 as of October 2026).
# Using :latest because the explicit :4.6.1 tag has not been
# published yet. Once it appears on Docker Hub, pin to it
# for long-term reproducibility.
FROM rocker/r-ver:latest

ARG QUARTO_VERSION=1.10.18

LABEL maintainer="Corey Sparks"
LABEL description="R + Python environment for DEM 7283 analysis"

# System libraries required by R packages (tidyverse, sf, etc.)
RUN apt-get update && apt-get install -y --no-install-recommends \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    zlib1g-dev \
    unzip \
    curl \
    wget \
    ca-certificates \
    && curl -fsSLo /tmp/quarto.deb \
        "https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.deb" \
    && apt-get install -y --no-install-recommends /tmp/quarto.deb \
    && rm /tmp/quarto.deb \
    && rm -rf /var/lib/apt/lists/*

# Install Miniforge (conda-forge-based conda; includes compiled GDAL/PROJ
# binaries so geopandas needs no extra system libraries)
RUN wget -qO /tmp/miniforge.sh \
        "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh" \
    && bash /tmp/miniforge.sh -b -p /opt/conda \
    && rm /tmp/miniforge.sh \
    && /opt/conda/bin/conda clean -afy
# Put the dem7283 env first so 'jupyter', 'python', and 'python3' resolve
# to the dem7283 binaries; Quarto picks up jupyter from PATH automatically.
ENV PATH="/opt/conda/envs/dem7283/bin:/opt/conda/bin:${PATH}"

# Install R packages
RUN install2.r --error --skipinstalled \
    tidyverse \
    haven \
    srvyr \
    lme4 \
    languageserver \
    httpgd \
    quarto

# Create the Python environment from the project spec.
# Conda handles numpy/pandas/statsmodels/patsy/scikit-learn/geopandas/etc.;
# pip handles svy/samplics/censusdata/cenpy (conda-forge has no builds for these).
COPY environment.yml /tmp/environment.yml
RUN conda env create -f /tmp/environment.yml \
    && conda clean -afy

# Register the dem7283 kernel globally so Quarto can find it
# (QMDs use both "jupyter: dem7283" and "jupyter: python3")
# Install both kernels to the system-wide share dir (/usr/local/share/jupyter)
# so Quarto finds them regardless of which jupyter binary it invokes.
RUN /opt/conda/envs/dem7283/bin/python -m ipykernel install \
        --name dem7283 \
        --display-name "Python (dem7283)" \
    && /opt/conda/envs/dem7283/bin/python -m ipykernel install \
        --name python3 \
        --display-name "Python 3 (dem7283)" \
        --prefix /usr/local

# Create a working directory and data directory
RUN mkdir -p /home/analyst/data
WORKDIR /home/analyst

# Copy and extract the BRFSS MMSA data
# Place the ZIP file in a data/ subfolder next to this Dockerfile
# before building.
COPY data/MMSA2024_XPT.zip /home/analyst/data/
RUN cd /home/analyst/data \
    && unzip MMSA2024_XPT.zip \
    && rm MMSA2024_XPT.zip

# Default command: start R
CMD ["R"]
