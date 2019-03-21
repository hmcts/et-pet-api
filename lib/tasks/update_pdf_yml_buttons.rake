desc "Update application yml mappings for pdf files with button options"
task update_pdf_yml_buttons: :environment do
  pdf_files = Dir.glob Rails.root.join('vendor', 'assets', 'pdf_forms', '**', '*.pdf')
  builder = PdfForms.new('pdftk', utf8_fields: true)
  reports = {}
  find_yaml_node = lambda do |name, from:, path: []|
    return nil unless from.is_a?(Hash)
    return from if from.key?('field_name') && from['field_name'] == name

    from.each do |(key, value)|
      node = find_yaml_node.call(name, from: value, path: path + [key])
      return node unless node.nil?
    end
    return nil
  end

  node_unselected_option = lambda do |field|
    field.options.detect { |f| f.casecmp('off').zero? }
  end

  correct_yaml_unselected_value = lambda do |node, from:|
    value = node_unselected_option.call(from)
    node['unselected_value'] = value unless node['unselected_value'] == value
  end

  correct_yaml_option = lambda do |node, option|
    node['select_values'] ||= {}
    return if node['select_values'].value?(option)

    node['select_values'][option.underscore] = option
  end

  correct_yaml_tri_state_option = lambda do |node, option|
    node['select_values'] ||= {}
    return if node['select_values'].value?(option)

    key = option =~ /yes|true/i ? true : false
    # Make sure we are not gonna overwrite something - change the key if we are
    key = option.underscore if node['select_values'].key?(key)
    node['select_values'][key] = option
  end

  correct_yaml_bi_state_option = lambda do |node, option|
    node['select_values'] ||= {}
    return if node['select_values'].value?(option)

    key = option !~ /off/i
    # Make sure we are not gonna overwrite something - change the key if we are
    key = option.underscore if node['select_values'].key?(key)
    node['select_values'][key] = option
  end

  correct_yaml_options_list = lambda do |node, from:|
    unselected = node_unselected_option.call(from)
    list = from.options - [unselected]
    list.each do |option|
      correct_yaml_option.call(node, option)
    end
  end

  correct_yaml_tri_state_options_list = lambda do |node, from:|
    unselected = node_unselected_option.call(from)
    list = from.options - [unselected]
    list.each do |option|
      correct_yaml_tri_state_option.call(node, option)
    end
  end

  correct_yaml_bi_state_node = lambda do |node, from:|
    node.delete('unselected_value')
    from.options.each do |option|
      correct_yaml_bi_state_option.call(node, option)
    end
  end

  correct_yaml_tri_state_node = lambda do |node, from:|
    correct_yaml_unselected_value.call(node, from: from)
    correct_yaml_tri_state_options_list.call(node, from: from)
  end

  correct_yaml_options_list_node = lambda do |node, from:|
    correct_yaml_unselected_value.call(node, from: from)
    correct_yaml_options_list.call(node, from: from)
  end

  correct_yaml_node = lambda do |node, from:|
    options = from.options.map(&:downcase).sort
    if options == ['off', 'yes']
      # A bi state option
      correct_yaml_bi_state_node.call(node, from: from)
    elsif options == ['no', 'off', 'yes']
      # A tri state option
      correct_yaml_tri_state_node.call(node, from: from)
    elsif options.include?('off')
      correct_yaml_options_list_node.call(node, from: from)
    else
      raise "Not sure what to do here"
    end
  end

  pdf_files.each do |pdf_file|
    reports[pdf_file] = { missing: [] }
    puts "Starting file #{pdf_file}\n\n"
    fields = builder.get_fields(pdf_file)
    button_fields = fields.select { |f| f.type == 'Button' && f.options.present? }

    yaml_file = pdf_file.gsub(/\.pdf\z/, '.yml')
    yaml = YAML.load_file(yaml_file)

    button_fields.each do |field|
      yaml_node = find_yaml_node.call(field.name, from: yaml)
      if yaml_node.nil?
        reports[pdf_file][:missing] << field
        next
      end
      correct_yaml_node.call(yaml_node, from: field)
    end

    File.open(yaml_file, 'w') do |file|
      file.write YAML.dump(yaml)
    end

    if reports[pdf_file][:missing].present?
    end

  end

  if reports.values.any? { |r| r[:missing].present? }
    puts "\n\n--------- Missing Field Definitions ----------------"
    puts "\n The following fields were not defined in your yaml file."
    puts "\n Example yaml has been provided below - just copy and pase the fields"
    puts "\n that you want and adjust to suit"
    puts "\n Note that the field names will be unfriendly - please change to describe the field and organise in the structure you require"
    puts "\n\n"
    pdf_files.each do |pdf_file|
      next if reports[pdf_file][:missing].empty?

      puts "\tFile: #{pdf_file}\n\n"
      yaml = reports[pdf_file][:missing].inject({}) do |acc, field|
        field_name = "field_#{field.name.tr(' ', '_').underscore}"
        node = {
          'field_name' => field.name.underscore
        }
        correct_yaml_node.call(node, from: field)
        acc[field_name] = node
        acc
      end
      puts YAML.dump(yaml)
      puts "\n\n"
    end
  end
end
