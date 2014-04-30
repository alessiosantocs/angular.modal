
angular.module("modalExample", ['angular.modal']);

angular.module("modalExample").config(['$modalProvider', function($modalProvider){
	$modalProvider.configSet('dom_class', 'back_overlay');
	$modalProvider.configSet('dom_active_class', 'enter');
	
	// It adds the $modal variable in the rootscope
	$modalProvider.configSet('inject_into_html', true);

}]);