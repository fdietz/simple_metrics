module SimpleMetrics

	module Functions

  	# calculate the maximum value for multiple targets
  	#
  	# params:
    #  data_points   [1, 3, 5], [2, 1, 6]
    #
    # return:
    #  array         [2, 3, 6]
	 def max(*data_points)
    end

    # calculate the minimum value for multiple targets
    def min(*data_points)
    end

    # add offset to each value
	 def offset(*data_points)
    end

    # multiple each value 
    def scale(*data_points)
    end

    # Return sum of all databounds
		# 
		# params:
    #  data_points   [1, 3, 5], [2, 1, 6]
    #
    # return:
    #  array         [3, 4, 11]
    def sum(*data_points)
    end

  	# 
  	# Other ideas
  	# 
    # as_percent:
    # * calculate percentage of given targets
    # * sum of all data_points will be used as the total 100% marker
    # 
    # average_above (param):
    # * return data_points with average value above given param
    #
    # average_below (param):
    # * return data_points with average value below given param
    #
    # average_series:
    # * return average value of given multiple targets
    #
    # current_above (param):
    # * return data_points with value above given param
    #
    # current_below (param):
    # * return data_points with value below given param
    #
    # derivative:
    # * take an absolute value based target and show how many requests per min were handled
    #
    # integral:
    # * calculate sum over time for relative values collected per minute
    #
    # logarithm:
    # * calculate the value with log n (base 10 default)
    # 

	end # module Functions
end