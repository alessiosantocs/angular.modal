

# Angular modal ===============
angular_modal_module_name = "angular.modal" # Who knows, maybe you want to change the name of the module


# AModal Class ======================================================

class AModal

	# PRIVATE METHODS AND PROPERTIES ================================

	# Let's have some predefined constants
	constants =
		popup_statuses:
			visible: "active"
			hidden: "hidden"

	# - Manage the dom related stuff of the element
	manipulateDom = (popup)->
		raw = popup.elm
		elm = angular.element(raw) # Wrap into an jqlite object

		elm.addClass popup.config.dom_class

		if popup.status == constants.popup_statuses.active
			elm.addClass popup.config.dom_active_class
		else
			elm.removeClass popup.config.dom_active_class


	# PUBLIC METHODS AND PROPERTIES =================================


	# + Constructor method: # => new AModal(option={}, config)
	# 	Params:
	# 		options: 		# => Json object
	# 			id:			# => The id/name of the modal
	# 			elm:		# => The dom element
	# 			type:		# => String [link|html]
	# 			status:		# => Is it hidden or visible?
	# 
	# 		config:			# => Should come from the modal manager
	constructor: (options={}, @config)->
		{@elm, @id, @type, @status} = options
		@status ||= constants.popup_statuses.hidden
		@attached_events =
			"onOpen":			 []
			"onClose":			 []
		manipulateDom @
	
	# + Opens a popup changing its status and updating the dom
	open: ()->
		@fire "onOpen" if @status == constants.popup_statuses.hidden
		@status = constants.popup_statuses.active
		manipulateDom @

	# + Closes a popup changing its status and updating the dom
	close: ()->
		@fire "onClose" if @status == constants.popup_statuses.active
		@status = constants.popup_statuses.hidden
		manipulateDom @

	# + Attach an event to the modal
	on: (event_name, handler)->
		event_name = event_name.toLowerCase()
		event_name = event_name.charAt(0).toUpperCase() + event_name.substring(1);
		event_name = "on#{event_name}"

		@attached_events[event_name].push handler

	fire: (event_name)->
		for event in @attached_events[event_name]
			event(@)

	clearEvent: (event_name)->
		@attached_events[event_name] = []


# ==================================================================






# The provider to save templates
angularModal = angular.module(angular_modal_module_name, []).provider('$modalTemplates', [->

	available_templates = {
		default: "
			<div adapt-to-parent='centered'>
				<div class='closer_overlay' 
					ng-click='$modal.closeAll()'
					ng-show='closable || true'></div>
				<div class='window' ng-class='windowClass'>
					<div  style='font-size: 2em;position: absolute;right: 0.5em;z-index: 1;cursor:pointer' 
						ng-click='$modal.closeAll()' 
						class='close_popup_x'
						ng-show='closable || true'>
						&times;
					</div>
					<div  class='content' 
						ng-class='contentClass' 
						ng-init='in_popup = true; data = popup.message'
						ng-transclude>
					</div>
				</div>
			</div>
			"
	}

	@current_template = 'default'

	@getTemplate = (id)->
		available_templates[id]

	# - Push a template into the main object available_templates
	@push = (id, template)->
		available_templates[id] = template


	#  ============================================================================

	# FACTORY: $modal
	@$get = ['$timeout', ($timeout)->

		@
	]

	@
])







# Use the provider $modalProvider to .push popups and be sure to use this structure:
# 	id:			# => The id/name of the modal
# 	elm:		# => The dom element
# 	type:		# => String [link|html]
# 	status:		# => Is it hidden or visible?

angularModal.provider('$modal', ['$modalTemplatesProvider', ($modalTemplatesProvider)->
	
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

	# Internal logging method. It will print # angular.modal => [your message here]
	@log = (message, method='log')->
		console[method]("# angular.modal => ", message)

	# Private method to set a modal in the main object and return it
	set = (modal)->
		available_modals[modal.id] = modal

	# Get the current template
	@current_template = ->
		$modalTemplatesProvider.getTemplate $modalTemplatesProvider.current_template

	# + Push a popup into the main object available_modals
	@push = (popup={})->
		# Assign to a variable
		newpopup = set(new AModal(popup, config))
		event_handler.refreshEvents()
		newpopup

	# + A public method to retreive a modal
	@get = (id)->
		available_modals[id]

	#  ============================================================================


	# Configuration methods =======================================================

	@configSet = (property, value)->
		config[property] = value

	@configGet = (property)->
		config[property]

	#  ============================================================================

	# Event handler ===============================================================

	modal_provider_object = @

	class EventHandler
		events_to_attach = []

		constructor: ->
		register: (modal_id, event_name, handler)->
			events_to_attach.push {modal_id: modal_id, event_name: event_name, handler: handler}
			@refreshEvents()
		refreshEvents: ->
			for event in events_to_attach when event
				modal = modal_provider_object.get(event.modal_id)
				if modal
					modal.on(event.event_name, event.handler) if modal
					events_to_attach.splice(_i, 1)
			events_to_attach

	event_handler = new EventHandler()

	# + Universal method to 
	@attachEventTo = (modal_id, event_name, handler)-> 
		event_handler.register(modal_id, event_name, handler)

	#  ============================================================================

	# FACTORY: $modal
	@$get = ['$timeout', ($timeout)->

		# 
		@closeAll = ->
			for modal_id of available_modals
				modal = available_modals[modal_id]
				modal.close()

		@open = (id)->
			@closeAll()

			if available_modals[id] == undefined
				@log "Angular.modal: There is no popup with id #{id}","warn"
			else
				$timeout(->
						available_modals[id].open()
				, 300)

		@isOpened = (id)->
			available_modals[id].status == popup_statuses.active unless available_modals[id] == undefined

		@
	]

	@
])


# + The directive to register a modal - Data stuff
# 	Register a normal inline modal through HTML
angularModal.directive("modalize", ['$modal', ($modal)->
	restrict: "A"
	link: (scope, elm, attr)->

		modal_id = attr.modalize
		type = "html"

		$modal.push({type: type, id: modal_id, elm: elm})

		true
])

# + The directive to register a modal - Data stuff
# 	Register a dynamic modal through HTML declaration
angularModal.directive("modalizeD", ['$modal', ($modal)->
	restrict: "A"
	scope:
		src: "@"
		# binding: "="
	# This way we can load modals only when needed
	template: "<div ng-include='modalSource(src)'></div>"
	link: (scope, elm, attr)->
		
		# Get the given modal_id
		modal_id = attr.modalizeD
		
		# LET NG-INCLUDE TO INHERIT THE PARENT SCOPE
		scope.binding = scope.$parent

		# NG-INCLUDE DOES NOT INHERIT THE $rootScope SO WE'LL INJECT IT MANUALLY
		if $modal.configGet('inject_into_html') then scope.$modal = $modal

		fullyLoaded = false
		# Returns the source given in input only if the popup is opened
		scope.modalSource = (src)->
			# If the modal is opened or it has been already fullyLoaded
			if $modal.isOpened(modal_id) or fullyLoaded
				fullyLoaded = true
				src
			else
				null

		type = "html"

		if attr.src?
			type = "link"

		$modal.push({type: type, id: modal_id, elm: elm})

		true
])

# + The directive to generate the basic layout of a modal - Graphic stuff
# 	It helps devs to have a repeatable pattern when building a modal.
angularModal.directive("modalize", ['$modal', ($modal)->
	restrict: "E"
	scope: 
		windowClass:	"@"
		contentClass:	"@"
		closable:		"@"
		centered:		"@"
	replace: true
	transclude: true
	controller: ['$scope', '$modal', ($scope, $modal)->
		# make the modal available
		$scope.$modal = $modal
	]
	template: $modal.current_template()
])

# + Adapt to the parent container
# 	This is an utility directive created just for this occasion. It makes some div adapt and position to its parent.
angularModal.directive("adaptToParent", ['$timeout', ($timeout)->
	restrict: "A"
	link: (scope, elm, attr)->

		time = window.setInterval(->
			if scope.centered != "false"
				elm.css "display", "table-cell"
				elm.css "vertical-align", "middle"

				if window.jQuery
					parent = elm.offsetParent()
					height = parent.height()
					width  = parent.width()

					elm.height height
					elm.width width
				else
					parent = elm.parent()[0]
					height = parent.offsetHeight
					width  = parent.offsetWidth

					elm[0].style.height = height
					elm[0].style.width = width
			else
				window.clearInterval time

		, 100)

		true
])



# Default configuration of the module
angularModal.run(['$modal', '$modalTemplates', '$rootScope', ($modal, $modalTemplates, $rootScope)->

	if $modal.configGet('inject_into_html')
		$rootScope.$modal = $modal
		window.$modal = $modal
])