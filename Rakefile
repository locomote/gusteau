desc "Run specs"
task :spec do
  Dir.glob('spec/lib/gusteau/*.rb').each {|f| puts f; require_relative f }
end

task :default => :spec
