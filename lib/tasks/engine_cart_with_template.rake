# lib/tasks/engine_cart_with_template.rake
namespace :engine_cart do
  task :generate do
    sh "bundle exec engine_cart --template=jenkins/rails_template.rb generate"
  end
end
