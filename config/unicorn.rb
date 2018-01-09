root = "/var/www/deploy_demo/current"
	working_directory root
	#pid của unicorn khi chạy
	pid "#{root}/tmp/pids/unicorn.pid"
	#log
	stderr_path "#{root}/log/unicorn.error.log"
	stdout_path "#{root}/log/unicorn.access.log"
	
	listen "/var/www/deploy_demo/shared/sockets/unicorn.sock"
	worker_processes 2
	timeout 30
	
	
	before_fork do |server, worker|
	  Signal.trap 'TERM' do
	    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
	    Process.kill 'QUIT', Process.pid
	  end
	
	  defined?(ActiveRecord::Base) and
	    ActiveRecord::Base.connection.disconnect!
	end
	
	after_fork do |server, worker|
	  Signal.trap 'TERM' do
	    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
	  end
	
	  defined?(ActiveRecord::Base) and
	    ActiveRecord::Base.establish_connection
	end
	
	# Force the bundler gemfile environment variable to
	# reference the capistrano "current" symlink
	before_exec do |_|
	  ENV['BUNDLE_GEMFILE'] = File.join(root, 'Gemfile')
	end
