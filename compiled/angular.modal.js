var modal;

modal = angular.module('angular.modal', []).provider('$modal', [
  function() {
    var available_modals, config, generateId, manipulateDom, popup_statuses;
    popup_statuses = {
      visible: "active",
      hidden: "hidden"
    };
    config = {
      dom_id_prefix: "modalized_",
      dom_class: "modal",
      dom_active_class: "active"
    };
    available_modals = {};
    generateId = function(elm) {
      var date, id, milli, stamp;
      date = new Date();
      milli = date.getMilliseconds();
      stamp = "" + (date.valueOf()) + milli;
      id = "" + config.dom_id_prefix + stamp + milli;
      elm.attr('id', id);
      return id;
    };
    manipulateDom = function(popup) {
      var elm;
      elm = angular.element("#" + popup.elm_id);
      elm.addClass(config.dom_class);
      if (popup.status === popup_statuses.active) {
        return elm.addClass(config.dom_active_class);
      } else {
        return elm.removeClass(config.dom_active_class);
      }
    };
    this.push = function(popup) {
      if (popup == null) {
        popup = {};
      }
      if (popup.type === "html") {
        available_modals[popup.id] = {};
        available_modals[popup.id].type = popup.type;
        available_modals[popup.id].id = popup.id;
        available_modals[popup.id].elm_id = generateId(popup.elm);
        available_modals[popup.id].status = popup_statuses.hidden;
        return manipulateDom(available_modals[popup.id]);
      } else if (popup.type === "link") {
        return alert("fill here");
      }
    };
    this.configSet = function(property, value) {
      return config[property] = value;
    };
    this.configGet = function(property) {
      return config[property];
    };
    this.$get = [
      '$timeout', function($timeout) {
        this.closeAll = function() {
          var modal_id, _results;
          _results = [];
          for (modal_id in available_modals) {
            modal = available_modals[modal_id];
            console.log(modal);
            modal.status = popup_statuses.hidden;
            _results.push(manipulateDom(modal));
          }
          return _results;
        };
        this.open = function(id) {
          this.closeAll();
          return $timeout(function() {
            console.log("==============================");
            console.log(available_modals);
            available_modals[id].status = popup_statuses.active;
            return manipulateDom(available_modals[id]);
          }, 300);
        };
        return this;
      }
    ];
    return this;
  }
]);

modal.directive("modalize", [
  '$modal', function($modal) {
    return {
      restrict: "A",
      link: function(scope, elm, attr) {
        var modal_id;
        modal_id = attr.modalize;
        console.log(modal_id);
        console.log(elm);
        $modal.push({
          type: "html",
          id: modal_id,
          elm: elm
        });
        return true;
      }
    };
  }
]);

modal.directive("modalize", [
  '$modal', function($modal) {
    return {
      restrict: "E",
      scope: {
        windowClass: "@",
        contentClass: "@"
      },
      replace: true,
      transclude: true,
      controller: [
        '$scope', '$modal', function($scope, $modal) {
          return $scope.$modal = $modal;
        }
      ],
      template: "<div> <div class='closer_overlay' ng-click='$modal.closeAll()'></div> <div class='window' ng-class='windowClass'> <div  style='font-size: 2em;position: absolute;right: 0.5em;z-index: 1;cursor:pointer' ng-click='$modal.closeAll()' class='close_popup_x'> &times; </div> <div  class='content' ng-class='popup.container_class' ng-init='in_popup = true; data = popup.message' ng-transclude> </div> </div> </div>"
    };
  }
]);

modal.run([
  '$modal', '$rootScope', function($modal, $rootScope) {
    if ($modal.configGet('inject_into_html')) {
      return $rootScope.$modal = $modal;
    }
  }
]);
