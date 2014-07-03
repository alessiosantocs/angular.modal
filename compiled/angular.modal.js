var modal;

modal = angular.module('angular.modal', []).provider('$modalTemplates', [
  function() {
    var available_templates;
    available_templates = {
      "default": "<div adapt-to-parent='centered'> <div class='closer_overlay' ng-click='$modal.closeAll()' ng-show='closable || true'></div> <div class='window' ng-class='windowClass'> <div  style='font-size: 2em;position: absolute;right: 0.5em;z-index: 1;cursor:pointer' ng-click='$modal.closeAll()' class='close_popup_x' ng-show='closable || true'> &times; </div> <div  class='content' ng-class='contentClass' ng-init='in_popup = true; data = popup.message' ng-transclude> </div> </div> </div>"
    };
    this.current_template = 'default';
    this.getTemplate = function(id) {
      return available_templates[id];
    };
    this.push = function(id, template) {
      return available_templates[id] = template;
    };
    this.$get = [
      '$timeout', function($timeout) {
        return this;
      }
    ];
    return this;
  }
]);

modal.provider('$modal', [
  '$modalTemplatesProvider', function($modalTemplatesProvider) {
    var ModalEventHandler, available_events, available_modals, config, eventHandler, generateId, manipulateDom, popup_statuses;
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
    this.current_template = function() {
      return $modalTemplatesProvider.getTemplate($modalTemplatesProvider.current_template);
    };
    generateId = function(elm) {
      var date, id, milli, rand, stamp;
      date = new Date();
      milli = date.getMilliseconds();
      rand = Math.random().toString().replace("0.", "");
      stamp = "" + (date.valueOf()) + milli + rand;
      id = "" + config.dom_id_prefix + stamp + milli;
      elm.attr('id', id);
      return id;
    };
    manipulateDom = function(popup) {
      var elm, raw;
      raw = document.getElementById(popup.elm_id);
      elm = angular.element(raw);
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
        available_modals[popup.id] = {};
        available_modals[popup.id].type = popup.type;
        available_modals[popup.id].id = popup.id;
        available_modals[popup.id].elm_id = generateId(popup.elm);
        available_modals[popup.id].status = popup_statuses.hidden;
        manipulateDom(available_modals[popup.id]);
        return alert("fill here");
      }
    };
    this.configSet = function(property, value) {
      return config[property] = value;
    };
    this.configGet = function(property) {
      return config[property];
    };
    available_events = {
      modalWillAppear: "modalWillAppear",
      modalDidAppear: "modalDidAppear",
      modalWillDisappear: "modalWillDisappear",
      modalDidDisappear: "modalDidDisappear"
    };
    ModalEventHandler = function() {
      var registered_events;
      registered_events = {};
      this.register = function(event, callback) {
        if (!(registered_events[event] instanceof Array)) {
          registered_events[event] = [];
        }
        registered_events[event].push(callback);
        return true;
      };
      return this.call = function(event) {
        var callback, callbacks, _i, _len;
        if (callbacks = registered_events[event]) {
          for (_i = 0, _len = callbacks.length; _i < _len; _i++) {
            callback = callbacks[_i];
            callback();
          }
        }
        return true;
      };
    };
    eventHandler = new ModalEventHandler();
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
        var modal_id, type;
        modal_id = attr.modalize;
        type = "html";
        console.log(modal_id);
        console.log(elm);
        $modal.push({
          type: type,
          id: modal_id,
          elm: elm
        });
        return true;
      }
    };
  }
]);

modal.directive("modalizeD", [
  '$modal', function($modal) {
    return {
      restrict: "A",
      scope: {
        src: "@"
      },
      template: "<div ng-include='src'></div>",
      link: function(scope, elm, attr) {
        var modal_id, type;
        scope.binding = scope.$parent;
        if ($modal.configGet('inject_into_html')) {
          scope.$modal = $modal;
        }
        modal_id = attr.modalizeD;
        type = "html";
        if (attr.src != null) {
          type = "link";
        }
        console.log(modal_id);
        console.log(elm);
        $modal.push({
          type: type,
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
        contentClass: "@",
        closable: "@",
        centered: "@"
      },
      replace: true,
      transclude: true,
      controller: [
        '$scope', '$modal', function($scope, $modal) {
          return $scope.$modal = $modal;
        }
      ],
      template: $modal.current_template()
    };
  }
]);

modal.directive("adaptToParent", [
  '$timeout', function($timeout) {
    return {
      restrict: "A",
      link: function(scope, elm, attr) {
        var time;
        time = window.setInterval(function() {
          var height, parent, width;
          if (scope.centered !== "false") {
            elm.css("display", "table-cell");
            elm.css("vertical-align", "middle");
            if (window.jQuery) {
              parent = elm.offsetParent();
              height = parent.height();
              width = parent.width();
              elm.height(height);
              return elm.width(width);
            } else {
              parent = elm.parent()[0];
              height = parent.offsetHeight;
              width = parent.offsetWidth;
              elm[0].style.height = height;
              return elm[0].style.width = width;
            }
          } else {
            console.log("Clear interval");
            return window.clearInterval(time);
          }
        }, 100);
        return true;
      }
    };
  }
]);

modal.run([
  '$modal', '$modalTemplates', '$rootScope', function($modal, $modalTemplates, $rootScope) {
    if ($modal.configGet('inject_into_html')) {
      $rootScope.$modal = $modal;
      return window.$modal = $modal;
    }
  }
]);
