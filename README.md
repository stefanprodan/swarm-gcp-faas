# swarm-gcp

Automating Docker Swarm cluster operations with Terraform GCP provider.

Clone the repository and install the dependencies:

```bash
$ git clone https://github.com/stefanprodan/swarm-gcp.git
$ cd swarm-gcp
$ terraform init
```

Before running the project you'll have to create a service account key. 
Go to _Google Cloud Platform -> API Manager -> Credentials -> Create Credentials -> Service account key_ and 
chose JSON as key type. Rename the file to `account.json` and put it the project root next to `main.tf`.
Add your SSH key under _Compute Engine -> Metadata -> SSH Keys_.

### Usage

Create a Docker Swarm Cluster with one manager and two workers:

```bash
# create a workspace
terraform workspace new swarm

terraform apply \
-var docker_version=17.06.0~ce-0~ubuntu \
-var project=my-swarm-proj \
-var region=europe-west3 \
-var region_zone=europe-west3-a \
-var machine_type=n1-standard-1 \
-var worker_instance_count=2 \
-var docker_api_ip_allow=86.124.244.168
```

This will do the following:

* provisions three VMs with Ubuntu 16.04 LTS
* starts the manager node and installs Docker CE using the local SSH agent
* customizes the Docker daemon systemd config by enabling the experimental features and the metrics endpoint
* initializes the manager node as Docker Swarm manager and extracts the join tokens
* creates a firewall rule for HTTP/S inbound traffic
* allows traffic to the Docker remote API only from the IP specified with `docker_api_ip_allow`
* starts the worker nodes in parallel and setups Docker CE the same as on the manager node
* joins the worker nodes in the cluster using the manager node private IP

The naming convention for a swarm node is in `<WORKSPACE>-<ROLE>-<INDEX>` format, 
running the project on workspace dev will create 3 nodes: swarm-manager-1, swarm-worker-1, swarm-worker-2. 
If you don't create a workspace then you'll be running on the default one and your nods prefix will be `default`. 
You can have multiple workspaces, each with it's own state, so you can run in parallel different Docker Swarm clusters.

You can scale up or down the Docker Swarm Cluster by modifying the `worker_instance_count`. 
On scale up, all new nodes will join the current cluster. 
When you scale down the workers, Terraform will first drain the node 
and remove it from the swarm before destroying the resources.

After applying the Terraform plan you'll see several output variables like the public IPs of 
each node and the current workspace. 
You can use the manager public IP variable to connect to the Docker remote API 
and lunch a service within the Swarm.

```bash
$ export DOCKER_HOST=$(terraform output swarm_manager_ip)

$ docker service create \
    --name nginx -dp 80:80 \
    --replicas 6 \
    --constraint 'node.role == worker' nginx

$ curl $(terraform output swarm_manager_ip)
```

Tear down the whole infrastructure with:

 ```bash
terraform destroy -force
```

