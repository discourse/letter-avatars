worker_processes 6
timeout 10
listen "[::]:8080"

if socket_path = ENV["UNICORN_SOCKET_PATH"]
  listen socket_path
end
