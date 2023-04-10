#!/usr/bin/env ruby

require 'xcodeproj'

project_path, file_path, target_name = ARGV

project = Xcodeproj::Project.open(project_path)
target = project.targets.find { |t| t.name == target_name }

file_ref = project.new_file(file_path)
target.add_file_references([file_ref])

project.save
