package 'cowsay'

ruby_block 'Greet the user' do
  block do
    puts Mixlib::ShellOut.new("cowsay '#{node['cowsay']['greeting']}'").run_command.stdout
  end
end
