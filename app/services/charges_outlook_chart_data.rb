class ChargesOutlookChartData
	def initialize(user, charges, outlook_period = 53)
		@user = user
		@outlook_period = outlook_period
		@charges = charges.chartable
		@billing_outlooks = billing_outlook_for_all_charges
	end

	def any_charges_in_year?
		@charges.present? && @billing_outlooks.present?
	end

	def line_data
		[cumulative_outlook_for_all_charges]
	end

	def bar_categories
		billing_outlook_total_by_merchant.keys
	end

	def bar_data
		[{name: 'total', data: billing_outlook_total_by_merchant.values}]
	end

	def total_next_twelve_months
		billing_outlook_total_by_merchant.values.inject(:+)
	end

	private

	def billing_outlook_total_by_merchant
		data = @charges.collect{ |c| total_cost_outlook_for_charge(c) }
		data = data.inject(Hash.new(0)){ |h,(merchant_name,amount)| h[merchant_name] += amount; h}
		data.sort_by{|k,v| v}.reverse.to_h
	end

	def cumulative_outlook_for_all_charges
		total = 0
		cumulative = zip_billing_outlooks.to_h.sort{ |x,y| x.first <=> y.first }
		{ name: 'total', data: cumulative.map{ |d,v| [d.to_datetime.to_i*1000, (total += v).round(2)] } }
	end

	def zip_billing_outlooks
		@billing_outlooks.inject({}){ |zip, (date, amount)| zip[date].present? ? zip[date] += amount : zip[date] = amount; zip }
	end

	def billing_outlook_for_all_charges
		@charges.collect do |c|
			billing_outlook_for_charge(c)
		end.flatten(1)
	end

	def billing_outlook_for_charge(charge)
		bill_day = charge.next_billing_date
		charge_outlook = Array.new
		while bill_day < Date.today + @outlook_period.weeks
			charge_outlook << [ charge.next_billing_date(bill_day), (charge.amount / 100.0) ]
			bill_day = charge.iterate_billing_date(bill_day)
		end
		charge_outlook
	end

	def total_cost_outlook_for_charge(charge)
		[charge.descriptor, (@outlook_period / charge.renewal_period_in_weeks) * charge.amount / 100.0]
	end

end