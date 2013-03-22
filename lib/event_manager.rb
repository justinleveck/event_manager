require 'csv'
require 'sunlight'
require 'erb'

Sunlight::Base.api_key = "e179a6973728c4dd3fb1204283aaccb5"

def bad_phone_number?(phone_number)
  if phone_number.length <  10
    return true
  elsif phone_number.length == 11 && phone_number[0].to_i != 1
    return true
  elsif phone_number.length > 11
    return true
  else
    return false
  end
end

def clean_phone_number(phone_number)
  phone_number.gsub!(/\D/, "")
  phone_number.strip!
  return phone_number[1..10] if phone_number.length == 11 && phone_number[0] == 1
  return phone_number.rjust(10,"0") if bad_phone_number?(phone_number)
end

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def legislators_for_zipcode(zipcode)
  Sunlight::Legislator.all_in_zipcode(zipcode)
end

def save_thank_you_letters(id,form_letter)
  Dir.mkdir("output") unless Dir.exists?("output")

  filename = "output/thanks_#{id}.html"

  File.open(filename,'w') do |file|
    file.puts form_letter
  end
end

puts "EventManager initialized."

contents = CSV.open 'full_event_attendees.csv', headers: true, header_converters: :symbol

template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  phone_number = clean_phone_number(row[:homephone])
  legislators = legislators_for_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  puts "#{id.to_i} , #{row[:homephone]}, #{phone_number}"
 
  save_thank_you_letters(id,form_letter)
end