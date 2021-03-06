# A sample Guardfile
# More info at https://github.com/guard/guard#readme


group 'views' do
  guard 'livereload' do
    watch(%r{app/helpers/.+\.rb})
    watch(%r{app/.+\.(erb|haml)})
    watch(%r{(public/).+\.(css|js|html)})
    watch(%r{app/assets/stylesheets/(.+\.css).*$})    { |m| "assets/#{m[1]}" }
    watch(%r{app/assets/javascripts/(.+\.js).*$})     { |m| "assets/#{m[1]}" }
    watch(%r{lib/assets/stylesheets/(.+\.css).*$})    { |m| "assets/#{m[1]}" }
    watch(%r{lib/assets/javascripts/(.+\.js).*$})     { |m| "assets/#{m[1]}" }
    watch(%r{vendor/assets/stylesheets/(.+\.css).*$}) { |m| "assets/#{m[1]}" }
    watch(%r{vendor/assets/javascripts/(.+\.js).*$})  { |m| "assets/#{m[1]}" }
    watch(%r{config/locales/.+\.yml})
  end
end

group 'specs' do
  guard 'rspec', version: 2, cli: "--color --format=doc --format=Nc", notification: false  do # --fail-fast
    watch(%r{^spec/.+_spec\.rb$})
    watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
    watch('spec/spec_helper.rb')  { "spec" }

    # Rails example
    watch(%r{^spec/.+_spec\.rb$})
    watch(%r{^app/(.+)\.rb$})                           { |m| "spec/#{m[1]}_spec.rb" }
    watch(%r{^app/(.*)(\.erb|\.haml)$})                 { |m| "spec/#{m[1]}#{m[2]}_spec.rb" }
    # watch(%r{^lib/(.+)\.rb$})                           { |m| "spec/lib/#{m[1]}_spec.rb" }
    # watch(%r{^lib/(.+)\.rb$})                           { |m| "spec" }
    watch(%r{^app/controllers/(.+)_(controller)\.rb$})  { |m| ["spec/routing/#{m[1]}_routing_spec.rb", "spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb", "spec/acceptance/#{m[1]}_spec.rb"] }
    watch(%r{^app/mailers/(.+)_(mailer)\.rb$})          { |m| ["spec/models/#{m[1]}_spec.rb", "spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb"] }
    watch(%r{^spec/support/(.+)\.rb$})                  { "spec" }
    watch('spec/spec_helper.rb')                        { "spec" }
    watch('config/routes.rb')                           { "spec/routing" }
    watch('app/controllers/application_controller.rb')  { "spec/controllers" }

    # Capybara request specs
    watch(%r{^app/(views|controllers)/(.+)/.*\.(erb|haml)$})          { |m| "spec/requests/#{m[1]}_spec.rb" }
    watch(%r{^app/(views|controllers)/(.+)/})                         { |m| "spec/requests/#{m[1]}_spec.rb" }
  end
end
