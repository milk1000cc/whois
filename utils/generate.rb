#!/usr/bin/env ruby -wKU

$:.unshift(File.dirname(__FILE__) + '/../lib')

require File.dirname(__FILE__) + '/../lib/whois'
require 'fileutils'

FileUtils.mkpath(File.dirname(__FILE__) + "/tlds")
File.readlines(File.dirname(__FILE__) + "/tlds.txt").each do |line|
  extension, domain = line.chomp.split(",")
  puts "Serving #{extension}..."
  
  if !domain
    # puts "Skipped"
    next
  end

  begin
    response = whois(domain)
    File.open(File.dirname(__FILE__) + "/tlds/domain#{extension}.txt", "w+") { |f| f.write(response) }
    puts "Success #{domain}"
  rescue => e
    puts "Error #{domain}: #{e.message}"
  end
  
end