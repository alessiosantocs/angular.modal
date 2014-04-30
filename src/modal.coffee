
# Use the provider $modalProvider to .push popups and be sure to use this structure:

modal = angular.module('modal', []).provider('$modal', [->
	
	# All available popup statuses
	popup_statuses =
		visible: "active"
		hidden: "hidden"

	# The object with the configuration
	config = 
		dom_id_prefix: "modalized_"
		dom_class: "modal"
		dom_active_class: "active"

	# The object with all the modals. Initialized empty
	available_modals = {}


	# DOM Manipulation methods ===================================================

	# - Generate an univoke id and give it to the element then return the id
	generateId = (elm)->
		date	= new Date()
		milli	= date.getMilliseconds()
		# Using only value of caused some issues - Duplicated ids
		stamp	= "#{date.valueOf()}#{milli}"

		# 
		id 		= "#{config.dom_id_prefix}#{stamp}#{milli}"

		elm.attr('id', id)

		id

	# - Manage the dom related stuff of the element
	manipulateDom = (popup)->
		elm = angular.element("##{popup.elm_id}")

		elm.addClass(config.dom_class)

		if popup.status == popup_statuses.active
			elm.addClass config.dom_active_class
		else
			elm.removeClass config.dom_active_class

	#  ============================================================================



	# Data manipulation methods ===================================================

	# - Push a popup into the main object available_modals
	@push = (popup={})->
		if popup.type == "html"
			available_modals[popup.id] = {}
			available_modals[popup.id].type 	= popup.type
			available_modals[popup.id].id 		= popup.id
			available_modals[popup.id].elm_id	= generateId(popup.elm)
			available_modals[popup.id].status 	= popup_statuses.hidden

			manipulateDom(available_modals[popup.id])
		else if popup.type == "link"
			alert "fill here"

	#  ============================================================================


	# Configuration methods =======================================================

	@configSet = (property, value)->
		config[property] = value

	@configGet = (property)->
		config[property]

	#  ============================================================================

	# FACTORY: $modal
	@$get = ['$timeout', ($timeout)->

		@closeAll = ->

			for modal_id of available_modals
				modal = available_modals[modal_id]
				console.log modal
				modal.status = popup_statuses.hidden
				manipulateDom(modal)


		@open = (id)->
			@closeAll()

			$timeout(-> 
				# alert id
				console.log "=============================="
				console.log available_modals


				available_modals[id].status = popup_statuses.active
				manipulateDom(available_modals[id])
				
			, 300)

		@
	]

	@
])


# + The directive to register a modal - Data stuff
modal.directive("modalize", ['$modal', ($modal)->
	restrict: "A"
	link: (scope, elm, attr)->

		modal_id = attr.modalize

		console.log modal_id
		console.log elm

		$modal.push({type: "html", id: modal_id, elm: elm})

		true
])

# + The directive to generate the basic layout of a modal - Graphic stuff
modal.directive("modalize", ['$modal', ($modal)->
	restrict: "E"
	scope: 
		windowClass:	"@"
		contentClass:	"@"
	replace: true
	transclude: true
	controller: ['$scope', '$modal', ($scope, $modal)->
		$scope.$modal = $modal
	]
	template: "

	  <div>
	    <div class='closer_overlay' ng-click='$modal.closeAll()'></div>
	    <div class='window' ng-class='windowClass'>
	      <div  style='font-size: 2em;position: absolute;right: 0.5em;z-index: 1;cursor:pointer' 
	      		ng-click='$modal.closeAll()' 
	      		class='close_popup_x'>
	      	&times;
	      </div>
	      <div  class='content' 
				ng-class='popup.container_class' 
				ng-init='in_popup = true; data = popup.message'
				ng-transclude>
	        
	      </div>
	    </div>
	  </div>


	"
])


modal.run(['$modal', '$rootScope', ($modal, $rootScope)->

	if $modal.configGet('inject_into_html')
		$rootScope.$modal = $modal

])