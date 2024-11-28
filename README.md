# Podman support
| Feature | Docker | Podman | Comment |
|---------|--------|--------|---------|
| Server Bootstrap | Yes | No | Curretly no offical platform indepedent install script for Podman |

# Rootless

Podman operates without a daemon unlike Docker, meaning each container runs as a direct process under your user account.
Therefore if you are not using the root user for your kamal server, you will not be able to expose privileged ports (below 1024).

If you need to expose ports 80/443 for your web server for instance do the following:
```
# /etc/sysctl.conf
net.ipv4.ip_unprivileged_port_start=80
```

And then run `sudo sysctl -p` to apply.

# Kamal Proxy

So far I have been having trouble with getting kamal-proxy to bind to port 80/443.
Current workaround is to edit the proxy options file on the app server:
```
# .kamal/proxy/options 
-e HTTP_PORT=8080 -e HTTPS_PORT=4443 --publish 8080:8080 --publish 4443:4443 --log-opt max-size=10m
```

Then use `redir` on the host:
```
nohup sudo redir --lport=80 --cport=8080 &
nohup sudo redir --lport=443 --cport=4443 &
```

# Kamal: Deploy web apps anywhere

From bare metal to cloud VMs, deploy web apps anywhere with zero downtime. Kamal uses [kamal-proxy](https://github.com/basecamp/kamal-proxy) to seamlessly switch requests between containers. Works seamlessly across multiple servers, using SSHKit to execute commands. Originally built for Rails apps, Kamal will work with any type of web app that can be containerized with Docker.

➡️ See [kamal-deploy.org](https://kamal-deploy.org) for documentation on [installation](https://kamal-deploy.org/docs/installation), [configuration](https://kamal-deploy.org/docs/configuration), and [commands](https://kamal-deploy.org/docs/commands).

## Contributing to the documentation

Please help us improve Kamal's documentation on the [the basecamp/kamal-site repository](https://github.com/basecamp/kamal-site).

## License

Kamal is released under the [MIT License](https://opensource.org/licenses/MIT).
