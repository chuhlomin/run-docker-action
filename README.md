# "Run" Docker action

This action GitHub action starts/restarts Docker container with a given image on a remote host.

## Inputs

### `who-to-greet`

**Required** The name of the person to greet. Default `"World"`.

### `server`

**Required** SSH / Server hostname

### `username`

**Required** SSH / Username

### `ssh_key`

**Required** SSH / Private SSH key to connect to the server (use secrets)

### `sudo`

**Required** Prefix docker run command with sudo

### `image`

**Required** Docker / Image

### `envs`

Docker / Set environment variables (JSON)

### `network`

Docker / Connect a container to a network

### `network_alias`

Docker / Add network-scoped alias for the container

### `container_name`

Docker / Assign a name to the container

### `expose`

Docker / Expose a port or a range of ports

### `resart`

Docker / Restart policy to apply when a container exits (default "no")

### `mounts`

Docker / Attach a filesystem mount to the container (comma separated)

### `log_driver`

Docker / Logging driver for the container

### `log_opt`

Docker / Log driver options

## Outputs

Action has no outputs

## Example usage

```yaml
uses: chuhlomin/run-docker-action@v1.0
env:
  SSH_KEY: ${{ secrets.SSH_KEY }}
  SECRET_DB_PASSWORD: ${{ secrets.DATABASE_PASSWORD }}
with:
  server: server.com
  username: username
  sudo: "true"
  image: redis:latest
  network: docker_network
  network_alias: network_alias
  expose: "80"
  envs: |
    {
      "PORT": "80",
    }
```
