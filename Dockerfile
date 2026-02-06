FROM node:20-bookworm-slim

# -------------------------------------------------
# System dependencies + Chromium
# -------------------------------------------------
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
       ca-certificates \
       curl \
       apt-transport-https \
       lsb-release \
       gnupg \
       chromium \
       fonts-liberation \
       libatk-bridge2.0-0 \
       libatk1.0-0 \
       libcups2 \
       libnss3 \
       libxkbcommon0 \
       libxcomposite1 \
       libxdamage1 \
       libxrandr2 \
       libgbm1 \
       libasound2 \
       libpangocairo-1.0-0 \
       libgtk-3-0 \
    && rm -rf /var/lib/apt/lists/*

# -------------------------------------------------
# Azure CLI (same install strategy as Playwright image)
# -------------------------------------------------
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# -------------------------------------------------
# Puppeteer (pinned to repo version)
# -------------------------------------------------
RUN npm install -g puppeteer@24.32.1

# -------------------------------------------------
# Runtime configuration
# -------------------------------------------------
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium
ENV CI=true

# -------------------------------------------------
# Hardening / diagnostics (visible in CI logs)
# -------------------------------------------------
RUN node --version \
    && npm --version \
    && chromium --version \
    && puppeteer --version || true

WORKDIR /workspace
