# Rakefile adapted from
# http://davidwparker.com/2009/12/01/my-jekyll-rake-file/
#

# `rake` will build the test site
task :default => [:"build:test"]

# `rake build` should compile the site
task :build => [:"build:compile_quick"]

# by default, `rake deploy` should perform a full compile
# and deploy the site
task :deploy => [:"deploy:rsync"]

desc "build _site"
namespace :build do
  desc "build css with compass"
  task :compass do
    puts "Calling compass"
    system('compass compile')
    puts "compass finished"
    puts ""
  end

  desc "build and start webserver"
  task :test => [:delete, :compass] do
    puts "building _site"
    system('jekyll --server')
  end

  desc "compile site"
  task :compile => [:delete, :compass, :favicon, :cloud] do
    puts "building production _site"
    system('jekyll --lsi')
    puts "building _site complete"
    puts ""
  end

  desc "compile site without --lsi option, favicon, or cloud"
  task :compile_quick => [:delete, :compass] do
    puts "building production _site"
    system('jekyll')
    puts "building _site complete"
    puts ""
  end

  desc "compress things in _site directory"
  task :compress do
    puts "Compressing..."
    system('./_lib/compressor.sh')
    puts "Finished compressing"
    puts ""
  end

  desc "generates the favicon"
  task :favicon do
    puts "Generating favicon..."
    system('./_lib/gen_favicon.sh')
    puts "Finished generating favicon"
    puts ""
  end

  desc "generates the cloud"
  task :cloud do
    puts "Generating cloud..."
    system('./_lib/generate_cloud.py 40 10 . > ./_includes/cloud.html')
    puts "Finished generating cloud"
    puts ""
  end

end

namespace :deploy do
  desc "rsync _site"
  task :rsync => [:"build:compile", :"build:compress"] do
    system('rsync -avrz --checksum --delete _site/ homeserver:blog')
    puts "site deployed"
    puts ""
  end

  desc "ping web services"
  task :ping => :rsync do
    puts "Pinging web services"
    system('wget --output-document=/dev/null http://www.google.com/webmasters/tools/ping?sitemap=http%3A%2F%2Fjason.the-graham.com%2Fsitemap.xml')
    system('wget --output-document=/dev/null http://www.bing.com/webmaster/ping.aspx?siteMap=http://jason.the-graham.com/sitemap.xml')
    system('./_lib/rpcping.pl "Blog for Jason Graham" http://jason.the-graham.com/')
    puts "Finished pinging web services"
    puts ""
  end

end

desc "deletes _site"
task :delete do
  puts "deleting _site"
  system('rm -r _site')
  puts "deleting _site complete"
  puts ""
end
