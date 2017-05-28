'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class PowercalcSidebarCtrl extends BaseCtrl
	@inject  'app_analysis_powercalc_dataService', 
	'app_analysis_powercalc_msgService', 
	'app_analysis_powercalc_algorithms', 
	'app_analysis_powercalc_TwoTGUI',
	'$scope', 
	'$timeout'

	initialize: ->
		console.log("sidebar initialized")
		@dataService = @app_analysis_powercalc_dataService
		@msgService = @app_analysis_powercalc_msgService
		@algorithmsService = @app_analysis_powercalc_algorithms
		@TwoTGUI = @app_analysis_powercalc_TwoTGUI

		# choose algorithms
		@algorithms = ['Select',
		 'CI for One Proportion', 
		 'CI for One Mean', 
		 'Test of One Proportion', 
		 'One-Sample (or Paired) t Test', 
		 'Pilot Study', 
		 'R-square (multiple correlation)', 
		 'Generic chi-square test', 
		 'Power of a Simple Poisson Test', 
		 'Two-sample t test (general case)']
		@powercalcRunning = off
		@algParams = null
		@selectedAlgorithm = @algorithms[9]
		@DATA_TYPES = @dataService.getDataTypes()

		# set up data and algorithm-agnostic controls
		@useLabels = off
		@reportAccuracy = on
		@clusterRunning = off
		@ready = off
		@running = 'hidden'
		@uniqueLabels =
		  labelCol: null
		  num: null
		@algParams = null

		# dataset
		@dataFrame = null
		@dataType = null
		@cols = []
		@chosenCols = []
		@chosenVars = []
		@numericalCols = []
		@categoricalCols = []
		@populations = {}
		@container = {}
		@xCol = null
		@yCol = null
		@Zcol = null
		@labelCol = ["none"]
		@vars = []
		@chosenLabel = null
		@df = null

		@TwoTGUI_alpha=0.010
		@deployed = false
		$("#toggle_switch").bootstrapSwitch();

		#if the switch is toggled, change mode
		$("#toggle_switch").on 'switchChange.bootstrapSwitch', () =>
			@deployed = !@deployed
			@msgService.broadcast 'powercalc:change_mode',
				deploy: @deployed

		@slidebar_initiate()


		@dataService.getData().then (obj) =>
			if obj.dataFrame and obj.dataFrame.dataType? and obj.dataFrame.dataType is @DATA_TYPES.FLAT
				if @dataType isnt obj.dataFrame.dataType
					# update local data type
					@dataType = obj.dataFrame.dataType
					# send update to main are actrl
					@msgService.broadcast 'powercalc:updateDataType', obj.dataFrame.dataType
				# make local copy of data
				@dataFrame = obj.dataFrame
				# parse dataFrame
				@parseData obj.dataFrame
			else
				# TODO: add processing for nested object
				console.log 'NESTED DATASET'

		@$scope.$on 'powercalc:updateAlgorithm_back', (event, data)=>
			@selectedAlgorithm = data
			console.log("algorithms updated:", @selectedAlgorithm)


	drive_data: () ->
		@msgService.broadcast 'powercalc:drive_data',
			populations:@populations
			chosenCol:@chosenCols
			chosenVar:@chosenVars
			chosenlab:@chosenLabel


		# if data selected meets specified creteria, run the caculation
	run: (data) ->
		if (@selectedAlgorithm is 'Two-sample t test (general case)')
			# if compare two different Variables, calculate sepaerately
			if (@chosenLabel isnt "none") and (@chosenLabel isnt null)
				console.log @chosenLabel
				# check num of chosenCol is one
				if @chosenCols.length isnt 1
					console.log(@chosenCols.length)
					window.alert("Must one and only one Col")
					return

				# check num of chosenVar is two
				if @chosenVars.length isnt 2
					console.log(@chosenVars.length)
					window.alert("Must two and only two Vars")
					return

				#extract index if col
				index = data.header.indexOf(@chosenCols[0])

				#check if index if -1
				if index is -1
					console.log -1
					return 

				#extract data from container to population 
				@populations = {}
				for elt in @chosenVars
					@populations[elt] = []
					for row in @container[elt]
						@populations[elt].push(row[index])
				console.log @populations

			else

				# check num of chosenCol is two
				if @chosenCols.length isnt 2
					console.log(@chosenCols.length)
					window.alert("Must two and only two Col")
					return

				# extract data from data to population
				index1 = data.header.indexOf(@chosenCols[0])
				index2 = data.header.indexOf(@chosenCols[1])
				@populations = {}
				@populations[@chosenCols[0]] = []
				@populations[@chosenCols[1]] = []
				for row in data.data
					@populations[@chosenCols[0]].push(row[index1])
					@populations[@chosenCols[1]].push(row[index2])
				console.log @populations

			@msgService.broadcast 'powercalc:TwoTGUI_data',
				populations:@populations
				chosenCol:@chosenCols
				chosenVar:@chosenVars
				chosenlab:@chosenLabel


	updateAlgControls: () ->
		#update algorithm method in local and broadcast to main control
		#broadcast algorithms to main controller
		@msgService.broadcast 'powercalc:updateAlgorithm',
			@selectedAlgorithm


	updateVar: (data) ->
		index = data.header.indexOf(@chosenLabel)
		@vars = []
		@container = []
		if index isnt -1
			for row in data.data
				if row[index] not of @container
					@container[row[index]] = []

				if row[index] not in @vars
					@vars.push(row[index])

				@container[row[index]].push(row)
				#console.log (@container)

		console.log @container
		
			

	uniqueVals: (arr) -> arr.filter (x, i, a) -> i is a.indexOf x

	parseData: (data) ->
		@df = data
		@dataService.inferDataTypes data, (resp) =>
			if resp? and resp.dataFrame? and resp.dataFrame.data?

				#update data types
				for type, idx in @df.types
					@df.types[idx] = resp.dataFrame.data[idx]

				# update columns
				@categoricalCols = []
				@labelCol = ["none"]
				id = 0
				for header in @df.types
					if header in ["number", "integer"]
						@categoricalCols.push(@df.header[id])
					else if header in ["string"]
						@labelCol.push(@df.header[id])
					id += 1
			# @updateDataPoints(@df)

			# @msgService.broadcast 'powercalc:updateDataPoints',
			# 	dataPoints: @df

	slidebar_initiate: () ->
		$("#TwoTGUI_alphaui").slider(
			min: 0.001
			max: 0.200
			value: @TwoTGUI_alpha
			orientation: "horizontal"
			range: "min"
			step: 0.001
			slide: (event, ui) =>
				@TwoTGUI_alpha = ui.value
				$('#TwoTGUI_alpha_v').val ui.value
				@msgService.broadcast 'powercalc:TwoTGUI_alpha',
					alpha_in: @TwoTGUI_alpha
				return
		)
		#$("#alphai").val($("#alphauii").slider("value"));
