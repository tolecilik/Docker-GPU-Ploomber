FROM pytorch/pytorch:2.2.0-cuda12.1-cudnn8-devel

# Install OS deps + Node.js + pm2
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y --no-install-recommends \
    wget bash curl sudo screen \
    libomp-dev libomp5 libjansson4 \
    libcurl4-openssl-dev build-essential \
    ocl-icd-opencl-dev nvidia-opencl-dev \
    nvidia-cuda-toolkit \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g pm2 \
    && rm -rf /var/lib/apt/lists/*

# Install Python deps
RUN pip install --upgrade pip \
    && pip install \
        jupyter_kernel_gateway ipykernel jupyterlab \
        ploomber ploomber-engine \
        matplotlib seaborn plotly \
        pandas numpy scipy scikit-learn \
        pygraphviz tqdm rich \
        dvc[all] papermill \
        requests pyyaml sqlalchemy joblib

# Copy requirements.txt (opsional)
COPY requirements.txt /tmp/requirements.txt
RUN if [ -s /tmp/requirements.txt ]; then pip install -r /tmp/requirements.txt; fi

# Workdir
WORKDIR /app

# Expose port 80
EXPOSE 80

# Entrypoint default: Jupyter Kernel Gateway
CMD ["jupyter", "kernelgateway", "--KernelGatewayApp.ip=0.0.0.0", "--KernelGatewayApp.port=80", "--KernelGatewayApp.allow_stdin=True"]
