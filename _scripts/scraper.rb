#!/usr/bin/env ruby
require 'facets'
require 'logger'
require 'nokogiri'
require 'open-uri'
require 'optparse'
require 'yaml'

# Pull in facets just to shut up icalendar
silence_stderr() do
  require 'icalendar'
  Icalendar.logger = Icalendar::Logger.new(nil)
end

STANDINGS_URL = "http://kampe.dhf.dk/dhf/Turneringer-og-resultater/Pulje-Stilling.aspx?PuljeId=%{league_id}"
ICS_URL = "http://kampe.dhf.dk/Cal/Holdkampprogram.ashx?key=%{key}"

def collect_teams(dir)
  teams = Hash.new
  Dir["#{dir}/*.md"].each do |file|
    yml = YAML.load_file(file)
    dhf = yml['dhf']
    teams[yml['team_id']] = {
      :team_name => yml['team_name'],
      :team_id   => dhf['team_id'],
      :league_id => dhf['league_id'],
      :ics_key   => dhf['ics_key']
    }
  end
  teams
end

def scrape_standings(league, league_id)
  standings = []
  f = open(STANDINGS_URL % {:league_id => league_id})
  doc = Nokogiri::HTML(f, nil, 'UTF-8')
  doc.css('tr.srOdd, tr.srEven').each do |tr|
    standings.push({
                     'league'    => league,
                     'team'      => tr.css('td.c02 a').first.content.strip,
                     'position'  => tr.css('td.c01').first.content.strip.to_i,
                     'matches'   => tr.css('td.c04').first.content.strip.to_i,
                     'won'       => tr.css('td.c05').first.content.strip.to_i,
                     'tied'      => tr.css('td.c06').first.content.strip.to_i,
                     'lost'      => tr.css('td.c07').first.content.strip.to_i,
                     'score_out' => tr.css('td.c08').first.content.strip.to_i,
                     'score_in'  => tr.css('td.c10').first.content.strip.to_i,
                     'points'    => tr.css('td.c14').first.content.strip.to_i,
    })
  end
  standings
end

def parse_address(address)
  if address.class == Icalendar::Values::Array
    address = address.join(',')
  end
  street = address.scan(/^[^\d].*\d+.*/).last.gsub(/\*/, '').strip
  city = address.scan(/^\d{4}.*$/).last
  "#{street}\n#{city}"
end

def parse_summary(summary)
  if summary.class == Icalendar::Values::Array
    summary = summary.join(',')
  end
  m = /^(.+) - (.+) ((\d+) - (\d+))?$/.match(summary)
  {
    'home_team'  => m[1].strip,
    'away_team'  => m[2].strip,
    'home_score' => m[4].strip,
    'away_score' => m[5].strip
  }
end

def scrape_matches(league, team_name, key)
  matches = []
  f = open(ICS_URL % {:key => key})
  cal = Icalendar::Parser.new(f, false).parse.first
  cal.events.each do |e|
    s = parse_summary(e.summary)
    matches.push({
                   'league'     => league,
                   'team_name'  => team_name,
                   'uid'        => e.uid.to_s,
                   'dtstart'    => e.dtstart.strftime('%FT%R'),
                   'dtend'      => e.dtend.strftime('%FT%R'),
                   'home_team'  => s['home_team'],
                   'away_team'  => s['away_team'],
                   'home_score' => s['home_score'].to_i,
                   'away_score' => s['away_score'].to_i,
                   'location'   => e.location.to_s,
                   'address'    => parse_address(e.description),
                   'home_match' => !!(s['home_team'] =~ /DSIO/)
    })
  end
  matches
end

def create_calendar(matches)
  calendar = []
  days = matches.group_by { |m| m['dtstart'].sub(/T.*/, '') }
  days.each do |day, ms|
    day_matches = []
    # Check if MSG cup
    date = Date.parse(day)
    if date.saturday? || date.sunday?
      msg_matches = ms.select { |m| m['location'].include?('Munkebjergskolen')}
      # Create msg cup
      if msg_matches.length > 1
        # Remove MSG cup matches from ms
        ms = ms.reject { |m| m['location'].include?('Munkebjergskolen')}
        # Create an msg cup
        day_matches.push({
                           'type'    => 'msg_cup',
                           'matches' => msg_matches,
                           'dtstart'   => msg_matches.min_by { |m| m['dtstart']}['dtstart'],
                           'dtend'     => msg_matches.max_by { |m| m['dtend']}['dtend']
        })
      end
    end
    ms.each do |m|
      m['type'] = 'match'
      day_matches.push(m)
    end
    calendar.push({
                    'date' => day,
                    'matches' => day_matches
    })
  end
  calendar.sort_by { |d| d['date']}
end

def scrape(args)
  teams = collect_teams(args[:team_folder])
  standings = []
  matches = []
  teams.each do |team, hash|
    standings += scrape_standings(team, hash[:league_id])
    matches += scrape_matches(team, hash[:team_name], hash[:ics_key])
  end
  calendar = create_calendar(matches)
  File.open(args[:standings_file], 'w') { |f| YAML.dump(standings, f) }
  File.open(args[:matches_file], 'w')   { |f| YAML.dump(matches, f) }
  File.open(args[:calendar_file], 'w')  { |f| YAML.dump(calendar, f)}
end

options = {
  :team_folder    => '_hold',
  :standings_file => '_data/generated/standings.yml',
  :matches_file   => '_data/generated/matches.yml',
  :calendar_file  => '_data/generated/calendar.yml'
}

OptionParser.new do |opts|
  opts.banner = "Usage: scraper.rb [options]"

  opts.on('-t FOLDER_PATH', 'Path to folder with team files') do |v|
    options[:team_folder] = v
  end

  opts.on('-s FILE_PATH', 'Path to standings file') do |v|
    options[:standings_file] = v
  end

  opts.on('-m FILE_PATH', 'Path to matches file') do |v|
    options[:matches_file] = v
  end

  opts.on('-c FILE_PATH', 'Path to calendar file') do |v|
    options[:calendar_file] = v
  end
end.parse!

# scrape(options)

matches = YAML.load_file '_data/generated/matches.yml'
calendar = create_calendar matches
File.open(options[:calendar_file], 'w') { |f| YAML.dump(calendar, f)}
