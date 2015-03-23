class ChargePattern
	attr_reader :interval, :interval_likely_recurring, :recurring_amounts_similar, :dates_are_perfectly_recurring, :recurring_date_count
	
	def initialize(history)
		@history = history.collect{ |d,v| [d.to_date,v.to_f] }.to_h
		check_for_perfect_recurrance
		unless @dates_are_perfectly_recurring
			find_interval
		end
	end

	private

	def recurring_periods_in_days
		[14, 28, 29, 30, 31, 90, 91, 92, 180, 181, 182, 183, 363, 364, 365, 366]
	end

	def check_for_perfect_recurrance
		distances = distances_between_dates(@history.keys.sort)
		if @history.size > 2 && distances.uniq.size == 1 && recurring_periods_in_days.include?(distances.first)
			@recurring_date_count = @history.size
			@dates_are_perfectly_recurring = true
			@interval_likely_recurring = true
			@recurring_amounts_similar = amounts_are_similar? @history.values
			@interval = distances_between_dates(@history.keys.sort).first
		else
			@dates_are_perfectly_recurring = false
		end
	end

	def find_interval

		## First try to find recurrance without any hocus pokus
		@interval = find_recurring_interval( distances_between_dates @history.keys.sort )
		
		if @interval.present?
			@interval_likely_recurring = true
			@recurring_date_count = @history.size
		
		else
			## if that doesn't work, then try and group the charges by the charge amount and find a pattern there
			@interval ||= find_recurring_interval distances_between_grouped_dates

			if @interval.present?
				@interval_likely_recurring = true
				@recurring_amounts_similar = group_history_by_amount.values.collect{ |x| amounts_are_similar? x.map(&:last) }.select{ |x| x }.present?
				@recurring_date_count = group_history_by_amount.values.size
			## If that still doesn't work, try to find outliers in the data and remove them to see if there are any patterns
			else
				charges_on_similar_days_of_the_month = find_charges_on_similar_days_of_the_month 
				@interval ||= find_recurring_interval( distances_between_dates charges_on_similar_days_of_the_month.keys.sort )

				if @interval.present?
					@interval_likely_recurring = true
					@recurring_amounts_similar = amounts_are_similar? charges_on_similar_days_of_the_month.values
					@recurring_date_count = charges_on_similar_days_of_the_month.size
				
				## Ok it's probably not recurring
				else
					@interval = -1
					@interval_likely_recurring = false
					@recurring_date_count = 0
				end
			end
		end

		if @recurring_amounts_similar.nil?
			@recurring_amounts_similar = amounts_are_similar? @history.values
		end
	end

	def find_recurring_interval(distances)
		return nil if iqr_greater_than(distances, 5)
	  recurring_periods_in_days.each do |interval|
	  	return interval if in_iqr?(distances, interval)
		end
		nil
	end

	def distances_between_grouped_dates
		if @history.size > 3
			grouped_history = group_history_by_amount
			return [-1] unless grouped_history.present?
			grouped_dates = group_dates(grouped_history)
			distances = grouped_dates.collect{ |d| distances_between_dates d }.flatten
		else
			distances = [-1]
		end
	end

  def amounts_are_similar?(amounts)
  	amounts = remove_outliers(amounts)
    (amounts.min.to_f / amounts.max.to_f) > 0.8
  end

  def remove_outliers(vals)
  	floor = vals.percentile(25)
  	ciel = vals.percentile(75)
  	vals.reject{ |x| x < floor || x > ciel }
  end

	def group_history_by_amount
		@history.reject{ |_,v| v < 0 }.group_by(&:last).select{ |_,d| d.size > 1 }
	end

	def group_dates(grouped_history)
		grouped_history.values.map(&:to_h).collect(&:keys)
	end

	def distances_between_dates(dates)
		dates.each_cons(2).collect{ |a,b| (b - a).to_i }
	end

	def iqr_greater_than(distances, test_val)
		test_val < distances.percentile(75) - distances.percentile(25)
	end

	def iqr_less_than(distances, test_val)
		test_val > distances.percentile(75) - distances.percentile(25)
	end

	def in_iqr?(arr, val)
		val.between?(arr.percentile(25), arr.percentile(75))
	end

	def find_charges_on_similar_days_of_the_month
		base_day = @history.keys.map(&:day).median
		
		#we expect the day to fall within +/- 3 days of the median day of the history
		scrubbed_charges = @history.select do |d,_| 
			
			#handle end of month
			if Date.valid_date?(d.year,d.month,base_day)
				test_day = Date.new(d.year,d.month,base_day)
			else
				test_day = d.end_of_month
			end
			
			( d - test_day ).to_i.abs < 3 
		end
			
		#we need at least 60% of the charges to fall in the predicted interval
		if (scrubbed_charges.size / @history.size.to_f) > 0.6 
			return scrubbed_charges
		end
		@history
	end

end