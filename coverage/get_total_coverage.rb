require "net/http"
require "json"

covered_lines = 0
total_lines = 0

data = File.read("./coverage/lcov.info")

data.scan(/L[FH]:([0-9]+)/).each_slice(2) do |values|
    values = values.flatten
    covered_lines += values[1].to_f
    total_lines += values[0].to_f
end

key = ENV["TEST_COV_KEY"]
coverage_percentage = (100 * covered_lines / total_lines).ceil

data = {name: "miziptools", value: coverage_percentage, key: key}
headers = {'Content-Type': 'application/json'}
Net::HTTP.post(URI.parse("https://coverage.floof.ovh/set"), data.to_json, headers)
