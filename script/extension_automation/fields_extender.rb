# frozen_string_literal: true

# rubocop:disable LineLength.freeze
mongo_fields = []
FILENAME = 'script/extension_automation/fields.txt'
NEWLINE = "\n"
USER_UPDATE_WORKER = 'app/v1/workers/user_update_worker.rb'
USER_UPDATE_WORKER_SPEC = 'spec/app/v1/workers/user_update_worker_spec.rb'
KEY_TRANSLATOR = 'app/v1/use_cases/key_translator.rb'
REPLACEHOLDER = '# <FIELD_EXTENSIONS>'

# read field data
line_num = 0
text = File.open(FILENAME).read
text.gsub!(/\r\n?/, "\n")
text.each_line do |line|
  line_num += 1
  mongo_fields << line.delete!("'").delete!("\n")
end

# last bit before .value as default sequel field name
sequel_fields = []
mongo_fields.each do |mongo|
  split = mongo.split('.')
  if split[-1] == 'value'
    sequel_fields << split[-2]
  else
    raise "unsupported field type: #{mongo}"
  end
end

# dashify for export api names
export_fields = []
sequel_fields.each do |sequel|
  export_fields << sequel.tr('_', '-')
end

# build strings for UserUpdateWorker, UserUpdateWorkerSpec and KeyTranslator
user_update_worker = ''
user_update_worker_spec = ''
key_translator = ''

mongo_fields.each_with_index do |mongo, i|
  user_update_worker += "'#{export_fields[i]}' => :#{sequel_fields[i]},#{NEWLINE}"
  user_update_worker_spec += "#{sequel_fields[i]}: @user.profile.fetch('#{export_fields[i]}'),#{NEWLINE}"
  key_translator += "'#{mongo}' => :#{sequel_fields[i]},#{NEWLINE}"
end
user_update_worker += REPLACEHOLDER
user_update_worker_spec += REPLACEHOLDER
key_translator += REPLACEHOLDER

# write to files
files = [
  USER_UPDATE_WORKER,
  USER_UPDATE_WORKER_SPEC,
  KEY_TRANSLATOR
]
strings = [user_update_worker, user_update_worker_spec, key_translator]

(0..2).each do |i|
  text = File.read(files[i])
  new_contents = text.sub(REPLACEHOLDER, strings[i])
  File.write(files[i], new_contents)
end

# build migration string
migration = ''
migration += "Sequel.migration do#{NEWLINE}"
migration += "  up do#{NEWLINE}"
sequel_fields.each do |field|
  migration += "    add_column :users, :#{field}, String, size: XX#{NEWLINE}"
end
migration += "  end#{NEWLINE}#{NEWLINE}"
migration += "  down do#{NEWLINE}"
sequel_fields.each do |field|
  migration += "    drop_column :users, :#{field}#{NEWLINE}"
end
migration += "  end#{NEWLINE}end"

# write migration file
require 'date'
migration_filename = "app/db/migrations/#{DateTime.now.to_time.to_i}_add_#{sequel_fields[0]}_and_others_to_prophet.rb"
File.write(migration_filename, migration)

# output info for mothership extension
puts '===== the files have been changed successfully ====='
puts '===== now please add these to ProphetSelectorChecker in mothership ====='
mongo_fields.each do |mongo|
  puts "'#{mongo}',"
end
puts '===== please make sure to correct migration types and fill in appropriate field sizes ====='
puts '===== also fix the indentation on all files please ====='
# rubocop:enable LineLength
