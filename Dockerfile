FROM pytorch/pytorch:2.2.0-cuda12.1-cudnn8-devel

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_NO_CACHE_DIR=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    TZ=Asia/Jakarta

# ===============================
# Install OS dependencies + Node.js + pm2
# ===============================
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget bash curl sudo screen \
    libomp-dev libomp5 libjansson4 \
    libcurl4-openssl-dev build-essential \
    ocl-icd-opencl-dev nvidia-opencl-dev \
    nvidia-cuda-toolkit \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g pm2 \
    && rm -rf /var/lib/apt/lists/*

# ===============================
# Python & Jupyter dependencies
# ===============================
RUN pip install --upgrade pip \
    && pip install \
        jupyter_kernel_gateway \
        ipykernel \
        jupyterlab \
        ploomber ploomber-engine \
        matplotlib seaborn plotly \
        pandas numpy scipy scikit-learn \
        pygraphviz tqdm rich \
        dvc[all] papermill \
        requests pyyaml sqlalchemy joblib

# ===============================
# Copy requirements (opsional project-specific)
# ===============================
COPY requirements.txt /tmp/requirements.txt
RUN if [ -s /tmp/requirements.txt ]; then pip install -r /tmp/requirements.txt; fi

# ===============================
# Workdir
# ===============================
WORKDIR /app

# ===============================
# Entrypoint default: Jupyter Kernel Gateway di port 80
# Bisa diganti lewat docker run command
# ===============================
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["jupyter", "kernelgateway", "--KernelGatewayApp.ip=0.0.0.0", "--KernelGatewayApp.port=80", "--KernelGatewayApp.allow_stdin=True"]
