# Workshop Guide: Docker Configuration

## Prerequisites

Before starting, ensure that:
- **Docker is installed** in a version lower than 25.
- If you use **WSL2**, some configurations must be done in **Docker Desktop** on Windows. Ideally, use native Ubuntu.

![image](https://github.com/user-attachments/assets/4a101d54-42c0-454c-a525-d0fd63e06ab8)

## 1. Run a "Hello World" Container

To verify that Docker is installed and working correctly, run:

```
docker run hello-world
```

Docker will download the image if it's not available and display a message confirming the correct installation.

![image](https://github.com/user-attachments/assets/666f09c0-42f7-4c2e-8146-3956a627b359)

## 2. Modify the Storage Driver

### Change to `devicemapper`

Edit the Docker configuration file:

```
sudo mkdir -p /etc/docker
sudo nano /etc/docker/daemon.json
```

![image](https://github.com/user-attachments/assets/f2f7b2f5-0afb-417e-926c-5114df9bf64b)

Add the following content:

```
{
  "storage-driver": "devicemapper"
}
```

![image](https://github.com/user-attachments/assets/63220918-ce72-4d1a-84e9-21729922e6c0)

Save the changes and restart Docker:

```
sudo systemctl restart docker
```

To verify the change:

```
docker info | grep "Storage Driver"
```

![image](https://github.com/user-attachments/assets/4e999a74-a6d5-4e22-b621-4e715789bf1c)

### Revert to `overlay2`

![image](https://github.com/user-attachments/assets/a56d52a8-30c6-48fa-83ef-14f7b2c55be4)

## 3. Run Nginx with a Specific Version

To start an **Nginx 1.18.0** container, run:

```
docker run nginx:1.18.0
```

![image](https://github.com/user-attachments/assets/39423db8-eed4-42e2-b564-3d7f56d9d6dd)

## 4. Run Nginx in the Background

To run it in **detached mode** and free up the terminal:

```
docker run -d nginx:1.18.0
```

![image](https://github.com/user-attachments/assets/33c7dc5c-848e-4402-8893-a944420bfc4a)

## 5. Configure Nginx with Specific Parameters

Now, run the container with some additional configurations:

```
docker run -d \
  --name nginx18 \
  --restart on-failure \
  -p 443:80 \
  -m 250M \
  nginx:1.18.0
```

![image](https://github.com/user-attachments/assets/373f0dce-d29a-4fa7-ba7a-1e45a3dcab85)

- `--name nginx18`: Assigns a custom name to the container.
- `--restart on-failure`: Restarts the container if it fails.
- `-p 443:80`: Redirects traffic from port 443 on the host to port 80 on the container.
- `-m 250M`: Limits the container's memory to 250 MB.

## 6. Change the Logging Driver to `journald`

Edit the Docker configuration file:

```
sudo nano /etc/docker/daemon.json
```

Add or modify the configuration:

```json
{
  "storage-driver": "overlay2",
  "log-driver": "journald"
}
```

![image](https://github.com/user-attachments/assets/81d0ed19-32fa-469c-b6c1-ce246f13fc62)

Save the changes and restart Docker:

```
sudo systemctl restart docker
```

To verify that the change has been applied:

```
docker info | grep "Logging Driver"
```

![image](https://github.com/user-attachments/assets/38a7ad9f-be5d-421a-8f28-5000c629a059)

