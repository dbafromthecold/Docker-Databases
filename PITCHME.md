# Docker & Databases

---

## Andrew Pruski

### SQL Server DBA & Microsoft Data Platform MVP

@fa[twitter] @dbafromthecold <br>
@fa[envelope] dbafromthecold@gmail.com <br>
@fa[wordpress] www.dbafromthecold.com <br>
@fa[github] github.com/dbafromthecold

---

### Problem

QA/Dev departments repeatedly creating new VMs <br>
All VMs require a local instance of SQL Server <br>
SQL installed from chocolately <br>
30+ databases then restored via PoSH scripts <br>
SQL install taking ~40 minutes from start to finish

---

### Solution

Docker Containers! <br>
Deploy containers running SQL Server <br>
SQL containers built from custom image <br>
No longer need to install SQL <br>
No longer need to restore databases <br>
Resources freed up on VMs 

---

# Demo

---

### Benefits

New VMs deployed in a fraction of the previous time <br>
No longer need to run PoSH scripts to restore databases <br>
Base image can be used to keep containers at production level <br>
More VMs can be provisioned on host due to each VM requiring less resources 

---

### Architecture

![Architecture](assets/images/DockerArchitecture.PNG)

---

### Issues

Apps using DNS entries to reference local SQL instance <br>
Update to existing test applications <br>
Trial and error to integrate with Octopus deploy <br>
New ways of thinking <br>
Persisting data

---

## Persisting data

1. Mounting volumes from the host<br>
2. Named volumes<br>
3. Data volume containers<br>

---

# Demo

---

## Upgrades

Docker containers make upgrades easy<br>
Existing containers are stopped<br>
New containers (running new image) are started<br>
Databases re-attached to new container (if needed)

---

# Demo

---

## Resources

@size[0.7em](https://github.com/dbafromthecold/Docker-Databases)<br>

@snap[east]
![QR](assets/images/Docker-Databases-QR.png)
@snapend
