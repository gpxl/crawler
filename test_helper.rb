#!/usr/bin/env ruby

require "minitest/autorun"
require "vcr"
require "minitest-vcr"
require "webmock"

VCR.configure do |c|
  c.cassette_library_dir = 'test/cassettes'
  c.hook_into :webmock
end

MinitestVcr::Spec.configure!
