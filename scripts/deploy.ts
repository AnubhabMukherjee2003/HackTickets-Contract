import { ethers } from "hardhat";
import fs from "fs";
import path from "path";

async function main() {
  console.log("Deploying DecentralizedTicketRegistry...");

  // Get the ContractFactory and Signers here.
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  // Deploy the contract
  const DecentralizedTicketRegistry = await ethers.getContractFactory("DecentralizedTicketRegistry");
  const contract = await DecentralizedTicketRegistry.deploy();

  await contract.waitForDeployment();
  const contractAddress = await contract.getAddress();

  console.log("DecentralizedTicketRegistry deployed to:", contractAddress);

  // Save deployment info
  const deploymentInfo = {
    contractAddress,
    deployer: deployer.address,
    network: "localhost",
    deployedAt: new Date().toISOString()
  };

  // Create deployment file for backend to use
  const deploymentPath = path.join(__dirname, "../../htBe/deployment.json");
  fs.writeFileSync(deploymentPath, JSON.stringify(deploymentInfo, null, 2));

  console.log("Deployment info saved to:", deploymentPath);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });