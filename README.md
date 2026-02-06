# Puppeteer CI Docker Image  
**Puppeteer 24.32.1 · Chromium · Azure CLI**

A **CI-ready Docker image** for running **Puppeteer-based UI automation** with **zero setup time** during CI.

Designed for:
- GitHub Actions (self-hosted runners)
- Kubernetes / AKS runner pods
- Docker Compose–based runners

> pull image → checkout code → npm ci → run tests

---

## 🚀 What’s Included

- Node.js 20 (`bookworm-slim`)
- Puppeteer **24.32.1** (pinned)
- System-installed Chromium
- Azure CLI (for Blob Storage uploads)
- All required Chromium runtime libraries

---

## 📦 Image Tag
`aloknecessary/puppeteer-az-cli:latest` or
`aloknecessary/puppeteer-az-cli:24.32.1`

The image version is kept **in sync with the original puppeteer repo** to avoid confusion.

---

## 🧠 Design Notes

- Chromium is installed at the OS level (not downloaded by Puppeteer)
- Faster CI startup and better Kubernetes stability

Runtime configuration:

`PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true`
`PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium`
`CI=true`


---

## ✅ Kubernetes Compatibility

When running Puppeteer in containers, use these launch flags:

```js
args: [
  '--no-sandbox',
  '--disable-setuid-sandbox',
  '--disable-dev-shm-usage',
  '--disable-gpu'
]
```
☁️ Azure CLI Support

Azure CLI is preinstalled to enable:

```js
az login --service-principal

az storage blob upload-batch
```
Ideal for publishing HTML test reports directly to Azure Blob Storage.

Sample usage:

```yaml
name: Run Puppeteer Tests

on:
  workflow_dispatch:
    inputs:
      folder:
        description: "Test folder inside automation_tests"
        required: true
        type: string

jobs:
  puppeteer-tests:
    runs-on: [self-hosted, automation]

    container:
      image: aloknecessary/puppeteer-az-cli:latest
      options: --ipc=host --user root

    env:
      BASE_URL: ${{ vars.AUTOMATION_APP_BASE_URL }}

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Install dependencies
        run: npm ci

      - name: Run Puppeteer tests
        run: |
          mkdir -p puppeteer-report
          npm run test -- automation_tests/${{ inputs.folder }}

      # -------------------------------------------------
      # Upload reports to Azure Blob Storage
      # -------------------------------------------------
      - name: Upload reports to Azure Blob Storage
        if: always()
        run: |
          az login --service-principal \
            --username "${{ secrets.AZURE_CLIENT_ID }}" \
            --password "${{ secrets.AZURE_CLIENT_SECRET }}" \
            --tenant "${{ secrets.AZURE_TENANT_ID }}"

          az storage blob upload-batch \
            --destination "puppeteer-runs/${{ github.run_id }}" \
            --source ./puppeteer-report \
            --connection-string "${{ secrets.AZURE_STORAGE_CONNECTION_STRING }}" \
            --overwrite
```
