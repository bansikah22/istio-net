# Phase 1 & 2: Application and CI/CD

This document covers the setup of the test application and the continuous integration/continuous delivery (CI/CD) pipeline.

## Application

The application is a simple web-based prime number calculator built with Node.js and the Express framework. It is designed to be a testbed for Istio's traffic management features.

### Key Features:
- **Two Versions:** The application has two versions to simulate a canary deployment scenario:
    - **v1 (Stable):** A more efficient algorithm for calculating prime numbers.
    - **v2 (Canary):** A less efficient algorithm, which allows us to simulate a performance regression.
- **Web UI:** A simple web interface allows users to input a number and see the calculated prime numbers, the time taken, and which version of the application is running.

## CI/CD Pipeline

We use GitHub Actions to automate the building and releasing of our application. This ensures that our code is always tested and that our releases are consistent and repeatable.

### Workflows:
- **`build.yml`:** This workflow runs on every push to a non-master branch. It performs the following steps:
    1.  Checks out the code.
    2.  Installs the Node.js dependencies.
    3.  Builds both the stable and canary versions of the Docker image locally.
    This ensures that all code is in a buildable state before it is merged into the `master` branch.

- **`release.yml`:** This workflow is triggered when a new version tag (e.g., `v1.0.1`) is pushed to the repository. It handles the release process:
    1.  Checks out the code.
    2.  Logs in to the GitHub Container Registry (GHCR).
    3.  Extracts the version number from the Git tag.
    4.  Builds and pushes the stable and canary Docker images to GHCR, tagged with the version number (e.g., `v1.0.1-stable`, `v1.0.1-canary`).

This separation of build and release workflows is a best practice that provides a clear and controllable release process.

### Dockerfile and Build Arguments

The `Dockerfile` uses a build argument (`APP_VERSION`) to determine which version of the application to build. The default is `index.js` (the stable version).

When the CI/CD pipeline builds the canary image, it overrides this default by passing the `--build-arg APP_VERSION=index.v2.js` flag to the `docker build` command. This allows us to use a single `Dockerfile` to build both versions of our application.

### Creating a New Release

To create a new release, you need to create a new Git tag and push it to the repository. The `release.yml` workflow will then automatically build and publish the new versioned Docker images.

Here's how to create and push a new tag (for example, `v1.0.1`):

```bash
# Create a new tag
git tag v1.0.1

# Push the tag to the remote repository
git push origin v1.0.1
```

This will trigger the release workflow and publish the following images to GHCR:
- `ghcr.io/<your-username>/<your-repo>/istio-test-app:v1.0.1-stable`
- `ghcr.io/<your-username>/<your-repo>/istio-test-app:v1.0.1-canary`
