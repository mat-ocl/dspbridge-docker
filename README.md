# DSPBridge Docker

This repository provides a containerized environment for the **DSPBridge Server** (part of the DSP56300 Gearmulator project). It includes a Dockerfile to build the emulator server directly from the official release packages, a Docker Compose configuration for easy deployment, and intelligent GitHub Actions workflows for automated upstream tracking, building, and maintenance.

---

## 🚀 1. How to use the Compose File (`docker-compose.yml`)

The easiest way to run DSPBridge is by using Docker Compose. This method pulls the latest pre-built image directly from the GitHub Container Registry (GHCR) so you don't have to build anything yourself.

### To start the server ###

Run the following command in the root of the repository. The `-d` flag runs it in the background.
```bash
docker-compose up -d
```

This will automatically pull the image and expose the required ports on your host machine:
* TCP Port: 56362
* UDP Port: 56303

### To stop the server ###
Run the following command in the root of the repository.
```bash
docker-compose down
```


## 🛠 2. How to use the Dockerfile ##
If you want to build the image manually from source (for example, to test a different version of the emulator), you can use the provided Dockerfile.
By default, the Dockerfile acts as a fallback and is set to build version 2.1.4 of TheUsualSuspects-DSPBridgeServer.

### Building the default image ###
```bash
docker build -t dspbridge-local .
```

### Building a specific version ###
You can override the default version using a --build-arg to fetch a different release from the upstream project. For example:
```bash
docker build --build-arg VERSION="2.2.0" -t dspbridge-local .
```

### Running your local build ###
Make sure to map the necessary TCP and UDP ports when running your custom image:
```bash
docker run -d --name dspbridge \
  -p 56362:56362/tcp \
  -p 56303:56303/udp \
  dspbridge-local
```

## ⚙️ 3. What the GitHub Actions do ##
This repository relies on two Continuous Integration and Maintenance workflows located in the .github/workflows/ directory.
### Build and Push Image (docker-publish.yml) ###
This workflow handles the CI/CD pipeline. It runs daily, on every push/PR to main, or manually.
* Upstream Polling: It uses the GitHub CLI to dynamically query the upstream repository (dsp56300/gearmulator) for the latest release tag.
* Skip Logic: It checks the GitHub Container Registry. If an image matching the upstream version already exists (and it isn't a Pull Request), it skips the build to save resources.
* Dynamic Version Injection: If a new version is found, it injects that exact version number into the Dockerfile as a --build-arg, replacing the default fallback.
* Registry Publishing: Upon a successful push to main (or a scheduled new release), it tags the resulting image with both latest and the specific upstream version number, and pushes it directly to ghcr.io/mat-ocl/dspbridge-docker. (Note: For Pull Requests, it forces a build to test changes but skips the publish step).

### Actions Dependency Updater (updater.yml) ###
This workflow handles repository maintenance.
* Scheduled Maintenance: It runs automatically every Sunday (or manually via workflow dispatch).
* Automated Updates: It scans the repository's workflow files and updates the versions of the GitHub Actions being used (e.g., updating a v3 action to v4), ensuring the CI/CD pipeline is always using the most secure and up-to-date tools.
