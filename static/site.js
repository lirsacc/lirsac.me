var requestAnimationFrame = (
  window.requestAnimationFrame ||
  window.webkitRequestAnimationFrame ||
  window.mozRequestAnimationFrame ||
  function(func) { return setTimeout(func, 1000 / 60); }
);

onReady(function () {
  initScrollTop();
});

/**
 * Initialise smooth scroll-to-top behaviour.
 * @param {object} opts
 */
function initScrollTop(opts) {
  var opts = opts || {};
  var threshold = opts.threshold || 256;
  var scrollDuration = opts.scrollDuration || 250;

  var links = document.getElementsByClassName('scrolltop');
  if (!links.length) return;
  var link = links[0];

  link.addEventListener('click', function(evt) {
    evt.preventDefault();
    evt.stopPropagation();
    smoothScroll(0, scrollDuration);
  });

  function onScroll(evt) {
    if (window.pageYOffset > threshold) {
      link.classList.add('visible');
    } else {
      link.classList.remove('visible');
    }
  }

  document.addEventListener('scroll', throttle(onScroll, 50));
  onScroll();
}

// ease-in-out sine function. from: http://gizma.com/easing
function ease(t, b, c, d) {
  return -c / 2 * (Math.cos(Math.PI * t / d) - 1) + b;
};

function getScrollerElement() {
  return (document.scrollingElement || document.documentElement ||
          document.body.parentNode || document.body);
}

/**
 * Smoothly scroll the page to a certain vertical offset.
 * @param {number} to
 * @param {number} duration
 */
function smoothScroll(to, duration) {

  var scroller = getScrollerElement();
  var start = scroller.scrollTop;
  var delta = to - start;
  var currentTime = 0;
  var step = 25;

  function animate() {
    currentTime += step;
    var nextPosition = ease(currentTime, start, delta, duration);
    scroller.scrollTop = nextPosition;
    if (currentTime < duration) requestAnimationFrame(animate);
  };

  animate();
}

/** Equivalent to jQuery `document.ready()` ... */
function onReady(fn) {
  if (document.readyState !== "loading") {
    requestAnimationFrame(fn);
  } else {
    document.addEventListener('DOMContentLoaded', fn);
  }
}

/**
 * Minimalist throttle implementation.
 * @param {Function} func
 * @param {number} ms
 * @return {Function}
 */
function throttle(func, ms) {
  var next, lastTimestamp;
  return function() {
    var context = this;
    var args = arguments;

    function call() {
      func.apply(context, args);
      lastTimestamp = Date.now();
      next = null;
    }

    if (!next) {
      call();
    } else {
      clearTimeout(next);
      next = setTimeout(call, ms - (Date.now() - lastTimestamp));
    }
  }
}
