# Prime Number Calculator Application

This is a simple Node.js web application that calculates prime numbers up to a given integer. It is designed to be a test application for Istio canary deployments.

There are two versions of the application:
*   **v1 (`index.js`):** A more efficient prime number calculator.
*   **v2 (`index.v2.js`):** A less efficient version to simulate a performance regression.

## Running Locally

### Prerequisites
- [Node.js](https://nodejs.org/) (v18 or later)
- [npm](https://www.npmjs.com/)

### Installation
1.  Navigate to the `app` directory.
2.  Install the dependencies:
    ```bash
    npm install
    ```

### Running v1 (Stable)
To run the more efficient version of the application, use the following command:
```bash
npm start
```
This will start the server on `http://localhost:3000` using `index.js`.

### Running v2 (Canary)
To run the less efficient version of the application, use this command:
```bash
node index.v2.js
```
This will start the server on `http://localhost:3000` using `index.v2.js`.
