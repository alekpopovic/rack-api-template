# rack-api

```bash
- kubectl exec --stdin --tty POD -- /bin/bash
```

```bash
echo -n 'admin' | base64
```

```sh
docker build -t rack-api:0.0.1 .
```

```sh
docker run --rm -it --env-file .env -p 3000:3000/tcp --name rack-api rack-api:0.0.1 bundle exec puma -C config/puma.rb

docker run --rm -it --env-file .env --name rack-api-sidekiq rack-api:0.0.1 bundle exec puma -C config/puma.rb
```
