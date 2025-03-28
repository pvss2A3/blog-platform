# Blog Platform

A simple blog platform built with Node.js, Express, PostgreSQL, and React, deployed on AWS using Terraform. Users can register, log in, and create posts, with data stored in an RDS PostgreSQL database and the app hosted on an EC2 instance.

## Project Overview
This project demonstrates a full-stack application deployed on AWS:
- **Infrastructure**: Provisioned with Terraform (VPC, EC2, RDS, S3).
- **Backend**: Node.js/Express server with user authentication and post management.
- **Frontend**: React app for the user interface.
- **Database**: PostgreSQL on AWS RDS.

## Project Structure

- **Root**: [`blog-platform/`](/) - Project root directory
- [**terraform/**](/terraform) - Terraform configuration files
  - [`main.tf`](/terraform/main.tf) - Main infrastructure setup
  - [`variables.tf`](/terraform/variables.tf) - Variable definitions
  - [`outputs.tf`](/terraform/outputs.tf) - Outputs (e.g., EC2 IP, RDS endpoint)
  - [`modules/`](/terraform/modules/) - Reusable Terraform modules
    - [`ec2/`](/terraform/modules/ec2) - EC2 instance setup
    - [`rds/`](/terraform/modules/rds) - RDS database setup
    - [`s3/`](/terraform/modules/s3_cloudfront) - S3 bucket setup
    - [`vpc/`](/terraform/modules/vpc) - VPC, subnets, and security groups
- [**backend/**](/backend/) - Backend code
  - [`server.js`](/backend/server.js) - Node.js server with API endpoints
- [**frontend/** ](/frontend/)- Frontend React app
  - [`src/`](/frontend/src/) - React source files
    - [`App.js`](/frontend/src/App.js) - Main React component
    - [`index.js`](/frontend/src/index.js) - React entry point
    - [`App.css`](App.css) - Styling for App.js
  - [`public/`](/frontend/public/) - Public assets
    - [`index.html`](/frontend/public/index.html) - HTML template
    - [`manifest.json`](/frontend/public/manifest.json) - Web manifest
  - [`package.json`](/frontend/package.json) - Frontend dependencies and scripts
- [**.gitignore**](/.gitignore) - Ignored files (e.g., node_modules/)
- [**LICENSE**](/LICENSE) - MIT License
- [**README.md**](/README.md) - Project documentation

## Architecture
```mermaid
graph TD
    A[User] -->|HTTP| B[EC2: Node.js + React]
    B -->|SQL| C[RDS: PostgreSQL]
    B -->|Static Files| D[S3 Bucket]
    E[Terrraform] -->|Provisions| B
    E -->|Provisions| C
    E -->|Provisions| D
```

## Prerequisites
- **AWS Account**: Access to AWS (e.g., AWS Academy Lab or personal account).
- **Terraform**: Installed locally (`terraform -v` to check).
- **Node.js**: Installed locally (`node -v` to check).
- **Git**: Installed locally (`git --version` to check).   <!-- **SSH Key**: An AWS key pair (e.g., `KeyPair.pem`) for EC2 access.-->
- **Local Terminal**: For running commands.

## Setup Instructions
  
#### Setup Flowchart
```mermaid
flowchart TD
    A[Clone Repo] --> B(Configure Terraform)
    B -->|terraform apply| C(EC2, RDS, S3)
    C --> D(SSH to EC2)
    D --> E(Setup PostgreSQL)
    E --> F(Restart Backend)
    F --> G(Build Frontend Locally)
    G -->|scp to EC2| H(Restart Server)
    H --> I(App Live)
```

### 1. Clone the Repository
    git clone https://github.com/pvss2A3/blog-platform.git
    cd blog-platform

### 2. Configure Terraform
#### 1. Navigate to Terraform Directory:
    cd terraform
#### 2. Initialize Terraform:
    terraform init
#### 3. Review Variables:
- Open **variables.tf** and adjust if needed (e.g., **region, db_password**).
  - **Example:**
    ```hcl
    variable "db_password" {
      description = "RDS database password"
      type        = string
      sensitive   = true
      }

#### 4. Apply Terraform:
    terraform plan
    terraform apply
    
- When prompted for db_password provide with a secure password.
- Type **yes** if you agree with the changes and wait for 10-15 mins.
- Note outputs: ec2_public_ip, rds_endpoint etc.

### 3. Set Up the Database
Before SSH into EC2, we need keypair.pem. This can be done in two ways.
  - ***Option 1:*** Use Existing Key Pair: Go to ***AWS Console → EC2 → Key Pairs*** and note the name (e.g., LabKeyPair) and download the ***.pem*** file. Update terraform [ec2/main.tf](/terraform/modules/ec2/main.tf) by replacing with this ***.pem*** file name.
  - ***Option 2:*** Create a Key Pair (if allowed): Use the following commands by replacing **<MyKeyPair>** with your preferred key pair name.
  ```bash
  aws ec2 create-key-pair --key-name <MyKeyPair> --query 'KeyMaterial' --output text > <MyKeyPair>.pem
  chmod 400 <MyKeyPair>.pem
```
    
#### 1. SSH into EC2:
    ssh -i <your-key.pem> ec2-user@<EC2-PUBLIC-IP>
Replace ***<your-key.pem>*** with your .pem file name and ***\<EC2-PUBLIC-IP>*** with your Terraform output (ec2_public_ip).

#### 2. Install PostgreSQL Client (AL2023):
    sudo dnf install -y wget
    wget https://get.enterprisedb.com/postgresql/postgresql-15.2-1-linux-x64-binaries.tar.gz
    tar -xzf postgresql-15.2-1-linux-x64-binaries.tar.gz
    sudo mv pgsql/bin/psql /usr/local/bin/
    psql --version

#### 3. Connect to RDS:
    psql -h <RDS-ENDPOINT> -U bloguser -d postgres
- Replace ***\<RDS-ENDPOINT>*** with your Terraform output (rds_endpoint). 
- Enter your db_password.

#### 4. Create Database and Tables:
```sql
CREATE DATABASE blog_platform;
\c blog_platform
CREATE TABLE users (
id SERIAL PRIMARY KEY,
username VARCHAR(50) UNIQUE NOT NULL,
password VARCHAR(255) NOT NULL,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE posts (
id SERIAL PRIMARY KEY,
user_id INT REFERENCES users(id),
title VARCHAR(100) NOT NULL,
content TEXT NOT NULL,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
\q
```

### 4. Deploy the Backend

- The backend (server.js) is already installed on EC2 at /app/server.js via Terraform’s user_data.

#### 1. Restart Server:
    cd /app
    pkill node
    node server.js &

#### 2. Test: 
    curl http://localhost:3000/api/posts
***Expected:*** [].

### 5. Deploy the Frontend
#### 1. Build Locally:
    cd frontend
    npm install
    npm run build

#### 2. Upload to EC2:
    scp -i <your-key.pem> -r build/* ec2-user@<EC2-PUBLIC-IP>:/app/frontend/
Replace ***<your-key.pem>*** with your .pem file name and ***\<EC2-PUBLIC-IP>*** with your Terraform output (ec2_public_ip).

#### 3. Restart Server:
    ssh -i <your-key.pem> ec2-user@<EC2-PUBLIC-IP>
    cd /app
    pkill node
    node server.js &
Replace ***<your-key.pem>*** with your .pem file name and ***\<EC2-PUBLIC-IP>*** with your Terraform output (ec2_public_ip).

### 6. Access the Application

- Open a browser and visit: `http://\<EC2-PUBLIC-IP>:3000` (Note: Replace ***\<EC2-PUBLIC-IP>*** with your Terraform output (ec2_public_ip)).
- Register a user, log in, and create posts.

### Troubleshooting
- **Terraform Errors:** Check AWS credentials and permissions. 
- **SSH Fails:** Ensure "app_sg" allows port 22 from your IP and that the key pair matches. 
- **Empty Reply:** Run node "server.js" in foreground on EC2 to see logs. 
- **Blank Page:** Check browser console (F12) for frontend errors.

### Cleanup
    cd terraform
    terraform destroy
- To destroy AWS resources

### Dependencies
- **Terraform:** AWS provider. 
- **Backend:** express, pg, bcrypt, express-session, serve-static (installed on EC2 via user_data). 
- **Frontend:** react, react-dom, react-scripts (installed locally via npm).

### Contributing
1. Fork the repository.
2. Create a branch: git checkout -b <feature-name>.
3. Commit changes: git commit -m "Add feature".
4. Push: git push origin <feature-name>.
5. Open a pull request.

### License
This project is licensed under the MIT License. See the [**LICENSE**](/LICENSE) file for details.
