# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'minitest' do
  # with Minitest::Unit
  watch(%r{test/test_(.*).rb})
  watch(%r{app/(.*)([^/]+)\.rb})                       { |m| "test/#{m[1]}test_#{m[2]}.rb" }
  watch('test/test_helper.rb')                       { "test" }

  # with Minitest::Spec
  # watch('^spec/(.*)_spec.rb')
  # watch('^lib/(.*)\.rb')                            { |m| "spec/#{m[1]}_spec.rb" }
  # watch('^spec/spec_helper.rb')                     { "spec" }
end
