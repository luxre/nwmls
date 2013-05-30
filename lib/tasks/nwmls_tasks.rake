namespace :nwmls do 
  desc "Find attribute mappings common to all NWMLS listing classes"
  task :common_attribute_mappings => [:environment] do
      r = Nwmls::ResidentialListing::CODES
      co = Nwmls::CondominiumListing::CODES
      b = Nwmls::BusinessOpportunityListing::CODES
      c = Nwmls::CommercialListing::CODES
      f = Nwmls::FarmListing::CODES
      m = Nwmls::ManufacturedHomeListing::CODES
      mf = Nwmls::MultiFamilyListing::CODES
      re = Nwmls::RentalListing::CODES
      v = Nwmls::VacantLandListing::CODES

      keys = r.keys & co.keys & b.keys & c.keys & f.keys & m.keys & mf.keys & re.keys & v.keys
      puts keys.length
      all_keys = r.keys | co.keys | b.keys | c.keys | f.keys | m.keys | mf.keys | re.keys | v.keys
      diff_hash = {}
      [r,co,b,c,f,m,mf,re,v].each do |codes|
        all_keys.each do |key|
          if diff_hash[key] and codes[key] and diff_hash[key] != codes[key]
            puts "#{key} as #{diff_hash[key]} and #{codes[key]}"
          else
            diff_hash[key] = codes[key]
          end
        end
      end
      
  end
end
