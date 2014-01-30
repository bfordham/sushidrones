helpers do
  def strike_headline(strike)
    "#{strike['deaths']} people killed in #{strike['town']} (#{location_link strike})"
  end
  
  def strike_link(strike, text=nil)
    text = "#{strike['number']}" if text.nil?
    "<a href=\"/strikes/#{strike['number']}\">#{text}</a>"
  end

  def country_link(strike, text=nil)
    text = strike['country'] if text.nil?
    "<a href=\"/countries/#{strike['country_slug']}\">#{text}</a>"
  end

  def location_link(strike, text=nil)
    text = strike['location'] if text.nil?
    "<a href=\"/countries/#{strike['country_slug']}/#{strike['location_slug']}\">#{text}</a>"
  end

  def town_link(strike, text=nil)
    text = strike['town'] if text.nil?
    "<a href=\"/countries/#{strike['country_slug']}/#{strike['location_slug']}/#{strike['town_slug']}\">#{text}</a>"
  end

  def find_by_slug(params)
    p = params.select{|k,v| k.match(/_slug$/)}
    settings.strikes.find_one(p)
  end

  def find_strikes(**args)
    settings.strikes.find(args).sort_by { |item| Time.parse(item['date']) }.reverse
  end

  def find_one_strike(**args)
    settings.strikes.find_one(args)
  end

  def find_unique(field, **args)
    all = []
    check = lambda{|x| all.select { |a| a[field] == x[field] }.empty? }

    find_strikes(args).to_a.each do |s|
      all << s if check.call(s)
    end
    return all
  end

  def find_locations(s)
    find_unique('location', country: s['country'])
  end

  def find_towns(s)
    find_unique('town', country: s['country'], location: s['location'])
  end

end