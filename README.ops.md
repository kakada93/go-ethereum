# PR Pipelines Overview

## Pipeline Types

1. **Build Pipeline**  
   Triggered when the PR contains the label: `CI:Build`.

2. **Deploy Pipeline**  
   Triggered when the PR contains the label: `CI:Deploy`.

---

## BUILD Pipeline

The **Build pipeline** performs the following tasks:

- Builds the default `go-ethereum` container image.
- Pushes the built image to a **public Docker Hub repository**.
- Docker credentials are securely stored in GitHub repository secrets.

---

## DEPLOY Pipeline

The **Deploy pipeline** carries out the following steps:

1. Pulls the Docker image produced by the Build pipeline.
2. Deploys the image to a local or testnet environment.
3. Uploads pre-defined Hardhat contracts to the deployed Geth node.
4. Creates a new container image that includes the deployed contracts.
5. Runs custom Hardhat tests against the image with pre-uploaded contracts.

### Included Hardhat Tests

- **Default Hardhat sample test** - default sample test that only works against Hardhat network
- **Block count test** – lists the number of blocks in the chain.
- **Contract address test** – checks that a contract has been deployed to the correct address (hardcoded in test).

The deployed contract address is extracted from the pipeline output.

---

## Hardhat Contract Deployment

Contracts are deployed using the [`@nomicfoundation/hardhat-ignition`](https://hardhat.org/hardhat-runner/plugins/nomicfoundation-hardhat-ignition) module, modified to reduce the number of block confirmations to **just one** for faster feedback.

### Example `hardhat.config.js`

```js
require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-ignition-ethers");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.28",
  networks: {
    geth: {
      url: "http://localhost:8545",
      chainId: 1337,
      // mining: {
      //   auto: false,
      //   interval: 5000,
      // },
    },
  },
  ignition: {
    requiredConfirmations: 1,
    chainId: 1337,
    // Optional Ignition tweaks:
    // blockPollingInterval: 1000,
    // timeBeforeBumpingFees: 0,
    // disableFeeBumping: true,
  },
};
```
---

## Infrastructure Setup

Two directories handle deployment infrastructure:

- **`terraform/`**  
  Contains Terraform scripts for provisioning:
  - AWS VPC
  - EKS Cluster

- **`helm/`**  
  Includes a Helm chart for deploying the `go-ethereum` container with or without pre-deployed contracts.
  Example command for installing the Cahrt.

```
helm upgrade geth-dev . --install --values values.yaml -n geth-dev
```


**N.B.**

Terraform state is configured to local file. For the purposes of this example no state file or lock directories will be commited.
Terraform scripts are enough to create the infra by doing:
1. `terraform init`
2. `terraform apply -var-file=apply-tfvars/lm-dev.tfvars

---

## Security Note
N.B.

Although the Docker Hub repository is **public** for transparency and verification:
  - The CI pipeline **still uses `docker login`**.
  - Docker credentials are securely stored in **GitHub repository secrets**.
