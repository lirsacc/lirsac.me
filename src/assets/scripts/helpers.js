/**
 * Helpers module
 * Replaces common DOM related operations usually done through jQuery
 *
 * -  most functional helpers or in lodash (curry, debounce, map, etc.)
 * -  ajax should be done through superagent (request like interface)
 * -  promises and deferred are handled through es6-promise
 *
 * @module helpers
 */
"use strict";

module.exports = {};

/**
 * Test if given DOM element has class className
 * @param  {DOMElement}  elem
 * @param  {String}  className
 * @return {Boolean}
 */
module.exports.hasClass = function hasClass (elem, className) {
  if (elem.classList) {
    return elem.classList.contains(className);
  } else {
    return new RegExp('(^| )' + className + '( |$)', 'gi').test(elem.className);
  }
};

/**
 * Add a class if not there, remove otherwise
 * @param  {DOMElement}  elem
 * @param  {String}  className
 */
module.exports.toggleClass = function toggleClass (elem, className) {
  var classes, existingIndex;
  if (elem.classList) {
    elem.classList.toggle(className);
  } else {
    classes = elem.className.split(' ');
    existingIndex = classes.indexOf(className);
    if (existingIndex >= 0) {
      classes.splice(existingIndex, 1);
    } else {
      classes.push(className);
    }
    elem.className = classes.join(' ');
  }
};

/**
 * Add className to element
 * @param  {DOMElement}  elem
 * @param  {String}  className
 * @return {Boolean}
 */
module.exports.addClass = function addClass (elem, className) {
  if (elem.classList) {
    elem.classList.add(className);
  } else {
    elem.className += ' ' + className;
  }
};

/**
 * Remove className to element, fails silently
 * @param  {DOMElement}  elem
 * @param  {String}  className
 * @return {Boolean}
 */
module.exports.removeClass = function removeClass (elem, className) {
  if (module.exports.hasClass(elem, className)) {
    if (elem.classList) {
      elem.classList.remove(className);
    } else {
      elem.className = elem.className.replace(
        new RegExp(
          '(^|\\b)' + className.split(' ').join('|') + '(\\b|$)', 'gi'), ' ');
    }
  }
};

/**
 * Add an event callback to an element
 * @param {DOMElement}   element
 * @param {String}   eventName
 * @param {Function} callback
 * @param {Boolean}   useCapture
 */
module.exports.addEvent = function addEvent (element, eventName, callback, useCapture) {
  if (element.addEventListener) {
    element.addEventListener(eventName, callback, useCapture || false);
  } else if (element.attachEvent) { // Internet Explorer specific
    element.attachEvent("on" + eventName, callback);
  } else {
    element["on" + eventName] = callback;
  }
};

/**
 * Remove an event callback from an element
 * @param {DOMElement}   element
 * @param {String}   eventName
 * @param {Function} callback
 * @param {Boolean}   useCapture
 */
module.exports.removeEvent = function removeEvent (element, eventName, callback, useCapture) {
  if (element.removeEventListener) {
    element.removeEventListener("" + eventName, useCapture);
  } else if (element.detachEvent) { // Internet Explorer specific
    element.detachEvent("on" + eventName, callback);
  } else {
    element["on" + eventName] = void 0;
  }
};

/**
 * Prevent default event listeners from being called
 * @param {Event} event
 */
module.exports.preventDefault = function preventDefault (event) {
  if (event.preventDefault) {
    event.preventDefault();
  } else {
    event.returnValue = false;
  }
};

/**
 * [debounce description]
 * @param  {[type]} func  [description]
 * @param  {[type]} delay [description]
 * @return {[type]}       [description]
 */
module.exports.debounce = function (func, delay) {

  var _timeout = null;

  return function () {
    var _this = this,
        args = arguments;

    var delayed = function () {
      _timeout = null;
      func.apply(_this, args);
    }

    var toCall = !_timeout;
    clearTimeout(_timeout);
    _timeout = setTimeout(delayed, delay);
    if (toCall) {
      func.apply(_this, args);
    }
  }
}
